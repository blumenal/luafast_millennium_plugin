import os
import threading
import requests
import json
from typing import Dict, Any, List, Optional
import PluginUtils
from steam_utils import get_stplug_in_path

logger = PluginUtils.Logger()

class luafastManager:
    def __init__(self, backend_path: str, api_manager):
        self.backend_path = backend_path
        self.api_manager = api_manager
        self._download_state: Dict[int, Dict[str, Any]] = {}
        self._download_lock = threading.Lock()

    def _set_download_state(self, appid: int, update: Dict[str, Any]) -> None:
        with self._download_lock:
            state = self._download_state.get(appid, {})
            state.update(update)
            self._download_state[appid] = state

    def _get_download_state(self, appid: int) -> Dict[str, Any]:
        with self._download_lock:
            return self._download_state.get(appid, {}).copy()

    def get_download_status(self, appid: int) -> Dict[str, Any]:
        state = self._get_download_state(appid)
        return {'success': True, 'state': state}

    def _download_from_github(self, appid: int, repository: str) -> bool:
        """
        Tenta baixar de um repositório GitHub específico
        Retorna True se bem-sucedido, False se não encontrado
        """
        try:
            self._set_download_state(appid, {
                'status': 'checking',
                'bytesRead': 0,
                'totalBytes': 0,
                'endpoint': 'github',
                'currentRepository': repository
            })

            branch_url = f"https://api.github.com/repos/{repository}/branches/{appid}"
            
            # Verifica se a branch existe
            response = requests.get(branch_url)
            if response.status_code != 200:
                return False  # Repositório não tem este appid

            branch_info = response.json()
            sha = branch_info['commit']['sha']

            # Busca todos os arquivos na branch
            tree_url = f"https://api.github.com/repos/{repository}/git/trees/{sha}?recursive=1"
            response = requests.get(tree_url)
            response.raise_for_status()
            tree_info = response.json()

            # Filtra apenas arquivos .lua e .manifest
            arquivos = [item for item in tree_info.get('tree', []) 
                       if item['path'].endswith('.manifest') or item['path'].endswith('.lua')]

            if not arquivos:
                return False  # Nenhum arquivo encontrado

            total_arquivos = len(arquivos)
            self._set_download_state(appid, {
                'status': 'downloading',
                'totalFiles': total_arquivos,
                'downloadedFiles': 0,
                'currentRepository': repository
            })

            # Prepara diretórios
            stplug_path = get_stplug_in_path()
            depotcache_path = os.path.join(os.path.dirname(stplug_path), 'depotcache')
            os.makedirs(stplug_path, exist_ok=True)
            os.makedirs(depotcache_path, exist_ok=True)

            # Download de cada arquivo
            for idx, item in enumerate(arquivos):
                path = item['path']
                download_url = f"https://raw.githubusercontent.com/{repository}/{sha}/{path}"
                file_response = requests.get(download_url)
                file_response.raise_for_status()

                # Decide onde salvar baseado na extensão
                if path.endswith('.lua'):
                    destino = stplug_path
                else:  # .manifest
                    destino = depotcache_path

                file_path = os.path.join(destino, os.path.basename(path))
                with open(file_path, 'wb') as f:
                    f.write(file_response.content)

                # Atualiza progresso
                self._set_download_state(appid, {
                    'downloadedFiles': idx + 1,
                    'status': 'downloading'
                })

            # Concluído com sucesso
            self._set_download_state(appid, {
                'status': 'done',
                'success': True
            })
            return True

        except Exception as e:
            if "Not Found" in str(e) or "404" in str(e):
                return False  # Repositório não encontrado
            else:
                self._set_download_state(appid, {
                    'status': 'failed',
                    'error': str(e)
                })
                raise  # Propaga outros erros

    def _check_availability_and_download(self, appid: int, endpoints_to_check: List[str]) -> None:
        """
        Tenta baixar de cada repositório em ordem até encontrar o jogo
        """
        repositories = self.api_manager.get_download_endpoints()
        
        for repository in repositories:
            try:
                self._set_download_state(appid, {
                    'status': 'checking',
                    'currentRepository': repository
                })
                
                logger.log(f"luafast: Tentando repositório {repository} para appid {appid}")
                
                success = self._download_from_github(appid, repository)
                if success:
                    logger.log(f"luafast: Download concluído com sucesso do repositório {repository}")
                    return  # Sucesso, sai da função
                else:
                    logger.log(f"luafast: Appid {appid} não encontrado no repositório {repository}")
                    continue  # Tenta próximo repositório
                    
            except Exception as e:
                logger.error(f"luafast: Erro no repositório {repository}: {e}")
                # Se for o último repositório e ainda falhar, propaga o erro
                if repository == repositories[-1]:
                    self._set_download_state(appid, {
                        'status': 'failed',
                        'error': f'Todos os repositórios falharam: {str(e)}'
                    })
                    raise
        
        # Se nenhum repositório teve sucesso
        self._set_download_state(appid, {
            'status': 'failed',
            'error': f'Ainda não temos as keys para esse jogos! Entre no grupo do Telegram para fazer o pedido.'
        })

    def add_via_lua(self, appid: int, endpoints: Optional[List[str]] = None) -> Dict[str, Any]:
        try:
            appid = int(appid)
        except (ValueError, TypeError):
            return {'success': False, 'error': 'Invalid appid'}

        # Inicia o estado de download
        self._set_download_state(appid, {
            'status': 'queued',
            'bytesRead': 0,
            'totalBytes': 0
        })

        def safe_availability_check_wrapper(appid, endpoints_to_check):
            try:
                self._check_availability_and_download(appid, endpoints_to_check)
            except Exception as e:
                logger.error(f"luafast: Unhandled error in availability check thread: {e}")
                self._set_download_state(appid, {
                    'status': 'failed',
                    'error': f'Availability check crashed: {str(e)}'
                })

        # Inicia thread de download
        thread = threading.Thread(
            target=safe_availability_check_wrapper,
            args=(appid, ['github']),
            daemon=True
        )
        thread.start()

        return {'success': True}

    # O restante do código permanece igual...
    def remove_via_lua(self, appid: int) -> Dict[str, Any]:
        try:
            appid = int(appid)
        except (ValueError, TypeError):
            return {'success': False, 'error': 'Invalid appid'}

        try:
            stplug_path = get_stplug_in_path()
            removed_files = []

            # Remove arquivos .lua
            lua_file = os.path.join(stplug_path, f'{appid}.lua')
            if os.path.exists(lua_file):
                os.remove(lua_file)
                removed_files.append(f'{appid}.lua')
                logger.log(f"luafast: Removed {lua_file}")

            # Remove arquivos .lua.disabled
            disabled_file = os.path.join(stplug_path, f'{appid}.lua.disabled')
            if os.path.exists(disabled_file):
                os.remove(disabled_file)
                removed_files.append(f'{appid}.lua.disabled')
                logger.log(f"luafast: Removed {disabled_file}")

            # Remove arquivos .manifest
            for filename in os.listdir(stplug_path):
                if filename.startswith(f'{appid}_') and filename.endswith('.manifest'):
                    manifest_file = os.path.join(stplug_path, filename)
                    os.remove(manifest_file)
                    removed_files.append(filename)
                    logger.log(f"luafast: Removed {manifest_file}")

            if removed_files:
                logger.log(f"luafast: Successfully removed {len(removed_files)} files for app {appid}")
                return {'success': True, 'message': f'Removed {len(removed_files)} files', 'removed_files': removed_files}
            else:
                return {'success': False, 'error': f'No files found for app {appid}'}

        except Exception as e:
            logger.error(f"luafast: Error removing files for app {appid}: {e}")
            return {'success': False, 'error': str(e)}
