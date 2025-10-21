import os
import threading
import requests
import json
from typing import Dict, Any, List, Optional
import PluginUtils
from steam_utils import get_stplug_in_path

logger = PluginUtils.Logger()

def get_depotcache_path():
    """Retorna o caminho correto para a pasta depotcache"""
    stplug_path = get_stplug_in_path()
    steam_path = os.path.dirname(os.path.dirname(stplug_path))
    return os.path.join(steam_path, 'depotcache')

def get_log_file_path():
    """Retorna o caminho do arquivo de log"""
    stplug_path = get_stplug_in_path()
    return os.path.join(stplug_path, 'log.json')

def read_log_file():
    """Lê e retorna o conteúdo do arquivo de log"""
    log_path = get_log_file_path()
    if not os.path.exists(log_path):
        return {}
    
    try:
        with open(log_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"luafast: Erro ao ler log.json: {e}")
        return {}

def write_log_file(data):
    """Escreve dados no arquivo de log"""
    try:
        log_path = get_log_file_path()
        with open(log_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logger.error(f"luafast: Erro ao escrever log.json: {e}")

def update_log_file(appid: int, manifest_files: List[str]):
    """Atualiza o arquivo de log com os arquivos de um appid"""
    log_data = read_log_file()
    
    # Converte appid para string para ser chave do JSON
    appid_str = str(appid)
    
    if appid_str not in log_data:
        log_data[appid_str] = {}
    
    # Atualiza a lista de manifest files
    log_data[appid_str]['manifests'] = manifest_files
    
    write_log_file(log_data)

def remove_from_log_file(appid: int):
    """Remove um appid do arquivo de log"""
    log_data = read_log_file()
    appid_str = str(appid)
    
    if appid_str in log_data:
        del log_data[appid_str]
        write_log_file(log_data)

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

            # Prepara diretórios CORRETOS
            stplug_path = get_stplug_in_path()
            depotcache_path = get_depotcache_path()
            os.makedirs(stplug_path, exist_ok=True)
            os.makedirs(depotcache_path, exist_ok=True)

            # Lista para armazenar os nomes dos arquivos .manifest baixados
            manifest_files = []

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
                    # Adiciona à lista de manifest files
                    manifest_files.append(os.path.basename(path))

                file_path = os.path.join(destino, os.path.basename(path))
                with open(file_path, 'wb') as f:
                    f.write(file_response.content)

                # Atualiza progresso
                self._set_download_state(appid, {
                    'downloadedFiles': idx + 1,
                    'status': 'downloading'
                })

            # Atualiza o arquivo de log com os manifests baixados
            if manifest_files:
                update_log_file(appid, manifest_files)

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

    def remove_via_lua(self, appid: int) -> Dict[str, Any]:
        try:
            appid = int(appid)
        except (ValueError, TypeError):
            return {'success': False, 'error': 'Invalid appid'}

        try:
            stplug_path = get_stplug_in_path()
            depotcache_path = get_depotcache_path()
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

            # Remove arquivos .manifest baseados no log
            log_data = read_log_file()
            appid_str = str(appid)
            
            if appid_str in log_data and 'manifests' in log_data[appid_str]:
                for manifest_file in log_data[appid_str]['manifests']:
                    manifest_path = os.path.join(depotcache_path, manifest_file)
                    if os.path.exists(manifest_path):
                        os.remove(manifest_path)
                        removed_files.append(manifest_file)
                        logger.log(f"luafast: Removed manifest {manifest_path}")
                
                # Remove a entrada do appid do log
                remove_from_log_file(appid)
                logger.log(f"luafast: Removed appid {appid} from log file")

            # Remove arquivos .manifest antigos (para compatibilidade)
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

    def test_install_dlc(appid: int) -> str:
        """
        Função de teste para verificar se a comunicação está funcionando
        """
        try:
            logger.log(f"luafast: Teste de DLC recebido - AppID: {appid}")
            return json_response({'success': True, 'message': f'AppID {appid} recebido com sucesso'})
        except Exception as e:
            logger.error(f'Teste DLC failed: {e}')
            return error_response(str(e))