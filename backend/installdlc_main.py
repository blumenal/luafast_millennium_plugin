import sys
import os
import requests
import json
import re
from typing import List, Dict, Optional

def get_steam_path() -> str:
    """Obtém o caminho de instalação do Steam"""
    try:
        import winreg
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam") as key:
            steam_path, _ = winreg.QueryValueEx(key, 'SteamPath')
            return steam_path
    except Exception:
        # Fallback para caminho padrão
        return "C:\\Program Files (x86)\\Steam"

def get_stplugin_path() -> str:
    """Obtém o caminho da pasta stplug-in"""
    steam_path = get_steam_path()
    stplugin_path = os.path.join(steam_path, 'config', 'stplug-in')
    os.makedirs(stplugin_path, exist_ok=True)
    return stplugin_path

def load_dlcs_for_game(appid: int) -> List[Dict[str, str]]:
    """Carrega as DLCs do jogo selecionado usando a API da Steam Store"""
    try:
        print("Buscando DLCs para AppID {} na Steam Store...".format(appid))
        
        # URL da API da Steam Store
        url = f"https://store.steampowered.com/api/appdetails?appids={appid}"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'application/json'
        }
        
        response = requests.get(url, headers=headers, timeout=15)
        
        if response.status_code == 200:
            data = response.json()
            app_data = data.get(str(appid), {}).get('data', {})
            
            if not app_data:
                print("❌ Jogo não encontrado na Steam Store")
                return []
            
            # Obter nome do jogo
            game_name = app_data.get('name', f'AppID {appid}')
            print("Jogo encontrado: {}".format(game_name))
            
            if 'dlc' in app_data and app_data['dlc']:
                dlc_list = app_data['dlc']
                print("Encontradas {} DLCs no total".format(len(dlc_list)))
                
                dlcs = []
                # Para cada DLC, obter o nome
                for i, dlc_id in enumerate(dlc_list, 1):
                    dlc_name = get_dlc_name_from_steam(dlc_id)
                    dlcs.append({'appid': dlc_id, 'name': dlc_name})
                
                # Ordenar por nome
                dlcs.sort(key=lambda x: x['name'])
                return dlcs
            else:
                print("ℹ️  Este jogo não possui DLCs na Steam Store")
                return []
        else:
            print(f"❌ Erro HTTP na API da Steam: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"❌ Erro ao carregar DLCs: {str(e)}")
        return []

def get_dlc_name_from_steam(dlc_id: int) -> str:
    """Obtém o nome de uma DLC da API da Steam"""
    try:
        url = f"https://store.steampowered.com/api/appdetails?appids={dlc_id}"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'application/json'
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            dlc_data = data.get(str(dlc_id), {}).get('data', {})
            if dlc_data:
                return dlc_data.get('name', f'DLC {dlc_id}')
    except Exception as e:
        pass
    
    return f'DLC {dlc_id}'

def get_game_name_from_steam(appid: int) -> str:
    """Obtém o nome do jogo da API da Steam"""
    try:
        url = f"https://store.steampowered.com/api/appdetails?appids={appid}"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'application/json'
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            app_data = data.get(str(appid), {}).get('data', {})
            if app_data:
                return app_data.get('name', f'AppID {appid}')
        
    except Exception as e:
        print(f"Erro ao buscar nome do jogo: {e}")
    
    return f'AppID {appid}'

def select_dlcs_interactive(dlcs: List[Dict[str, str]], game_name: str) -> List[int]:
    """
    Interface interativa para seleção de DLCs
    """
    if not dlcs:
        return []
    
    print("\n🎮 DLCs ENCONTRADAS PARA: {}".format(game_name))
    print("=" * 60)
    
    selected_dlcs = []
    
    # Mostrar lista numerada de DLCs
    for i, dlc in enumerate(dlcs, 1):
        print(" {}. [{:>8}] - {}".format(i, dlc['appid'], dlc['name']))
    
    print("\n🎯 OPÇÕES DE SELEÇÃO:")
    print("  [A] - Selecionar TODAS as DLCs")
    print("  [N] - Selecionar NENHUMA DLC")
    print("  [1,2,3...] - Selecionar DLCs específicas (ex: 1,3,5)")
    print("  [S] - Sair sem selecionar")
    print("-" * 60)
    
    while True:
        try:
            choice = input("\n👉 Sua escolha: ").strip().upper()
            
            if choice == 'A':
                # Selecionar todas
                selected_dlcs = [dlc['appid'] for dlc in dlcs]
                print("✅ Todas as {} DLCs selecionadas!".format(len(selected_dlcs)))
                break
                
            elif choice == 'N':
                # Nenhuma
                print("✅ Nenhuma DLC selecionada")
                break
                
            elif choice == 'S':
                # Sair
                print("🚫 Operação cancelada pelo usuário")
                return []
                
            else:
                # Seleção específica por números
                selected_indices = []
                try:
                    # Suporta tanto "1,2,3" quanto "1 2 3"
                    if ',' in choice:
                        selected_indices = [int(x.strip()) for x in choice.split(',')]
                    else:
                        selected_indices = [int(x.strip()) for x in choice.split()]
                except ValueError:
                    print("❌ Formato inválido! Use números separados por vírgula ou espaço.")
                    continue
                
                # Validar índices
                valid_indices = [idx for idx in selected_indices if 1 <= idx <= len(dlcs)]
                
                if len(valid_indices) != len(selected_indices):
                    invalid_count = len(selected_indices) - len(valid_indices)
                    print("❌ {} número(s) inválido(s)! Use números entre 1 e {}.".format(invalid_count, len(dlcs)))
                    continue
                
                if not valid_indices:
                    print("❌ Nenhum número válido selecionado!")
                    continue
                
                selected_dlcs = [dlcs[idx-1]['appid'] for idx in valid_indices]
                print("✅ {} DLC(s) selecionada(s)!".format(len(selected_dlcs)))
                break
                
        except KeyboardInterrupt:
            print("\n🚫 Operação cancelada pelo usuário")
            return []
        except Exception as e:
            print("❌ Erro: {}".format(e))
            continue
    
    return selected_dlcs

def get_lua_file_path(appid: int) -> str:
    """
    Obtém o caminho do arquivo .lua para o appid
    """
    stplugin_path = get_stplugin_path()
    lua_file = os.path.join(stplugin_path, f'{appid}.lua')
    
    # Se não existir, verifica se existe .lua.disabled
    if not os.path.exists(lua_file):
        disabled_file = lua_file + '.disabled'
        if os.path.exists(disabled_file):
            lua_file = disabled_file
    
    return lua_file

def read_lua_file(lua_file: str) -> List[str]:
    """
    Lê o conteúdo do arquivo .lua
    """
    if not os.path.exists(lua_file):
        return []
    
    try:
        with open(lua_file, 'r', encoding='utf-8') as f:
            return f.readlines()
    except Exception as e:
        print("❌ Erro ao ler arquivo {}: {}".format(lua_file, e))
        return []

def write_lua_file(lua_file: str, lines: List[str]):
    """
    Escreve o conteúdo no arquivo .lua
    """
    try:
        with open(lua_file, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        return True
    except Exception as e:
        print("❌ Erro ao escrever arquivo {}: {}".format(lua_file, e))
        return False

def add_dlcs_to_lua_file(appid: int, dlc_appids: List[int]) -> bool:
    """
    Adiciona as DLCs selecionadas ao arquivo .lua do jogo
    """
    if not dlc_appids:
        print("ℹ️  Nenhuma DLC para adicionar")
        return True
    
    lua_file = get_lua_file_path(appid)
    
    if not os.path.exists(lua_file):
        print("❌ Arquivo .lua não encontrado para AppID {}".format(appid))
        return False
    
    # Ler conteúdo atual
    lines = read_lua_file(lua_file)
    if not lines:
        print("❌ Não foi possível ler o arquivo .lua")
        return False
    
    # Encontrar onde adicionar as DLCs (após as linhas addappid existentes)
    insert_position = 0
    addappid_pattern = re.compile(r'^\s*addappid\s*\(\s*\d+\s*,\s*\d+\s*\)')
    
    for i, line in enumerate(lines):
        if addappid_pattern.match(line.strip()):
            insert_position = i + 1
    
    # Se não encontrou addappid, inserir no final
    if insert_position == 0:
        insert_position = len(lines)
        # Garantir que há uma linha em branco antes se o arquivo não estiver vazio
        if lines and lines[-1].strip() != '':
            lines.append('\n')
            insert_position += 1
    
    # Adicionar as DLCs
    dlc_lines = []
    for dlc_appid in dlc_appids:
        dlc_line = f'addappid({dlc_appid}, 1)\n'
        dlc_lines.append(dlc_line)
    
    # Inserir as novas linhas
    lines[insert_position:insert_position] = dlc_lines
    
    # Escrever arquivo atualizado
    if write_lua_file(lua_file, lines):
        print("✅ {} DLC(s) adicionada(s) com sucesso!".format(len(dlc_appids)))
        return True
    else:
        print("❌ Erro ao salvar arquivo .lua")
        return False

def create_backup_lua_file(appid: int) -> bool:
    """
    Cria um backup do arquivo .lua
    """
    lua_file = get_lua_file_path(appid)
    
    if not os.path.exists(lua_file):
        return False
    
    try:
        import shutil
        import datetime
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = lua_file + f'.backup_{timestamp}'
        
        shutil.copy2(lua_file, backup_file)
        return True
    except Exception as e:
        return False

def main():
    print("🎮 === INSTALADOR DE DLC's - LuaFast ===")
    print("=" * 50)
    
    # Verificar se foi passado um AppID como argumento
    if len(sys.argv) > 1:
        try:
            appid = int(sys.argv[1])
            print("🎯 AppID detectado: {}".format(appid))
        except ValueError:
            print("❌ AppID inválido fornecido")
            appid = None
    else:
        appid = None
        print("❌ Nenhum AppID fornecido")
    
    if not appid:
        try:
            manual_input = input("🔢 Digite o AppID do jogo: ").strip()
            if manual_input:
                appid = int(manual_input)
            else:
                print("🚫 Operação cancelada.")
                return
        except (ValueError, KeyboardInterrupt):
            print("❌ AppID inválido ou operação cancelada.")
            return
    
    # Obter nome do jogo
    game_name = get_game_name_from_steam(appid)
    print("🎮 Jogo: {}".format(game_name))
    print("🌐 URL: https://store.steampowered.com/app/{}/".format(appid))
    print("-" * 50)
    
    # Verificar se o arquivo .lua existe
    lua_file = get_lua_file_path(appid)
    if not os.path.exists(lua_file):
        print("❌ Arquivo .lua não encontrado para este jogo!")
        print("\n💡 Certifique-se de que:")
        print("  1. O jogo foi adicionado via luafast")
        print("  2. O arquivo .lua existe na pasta stplug-in")
        input("\n⏎ Pressione Enter para fechar...")
        return
    
    # Buscar DLCs na Steam Store
    dlcs = load_dlcs_for_game(appid)
    
    if not dlcs:
        print("\n❌ Este jogo não possui DLCs na Steam Store.")
        input("\n⏎ Pressione Enter para fechar...")
        return
    
    # Criar backup do arquivo .lua
    create_backup_lua_file(appid)
    
    # Seleção interativa de DLCs
    selected_dlc_appids = select_dlcs_interactive(dlcs, game_name)
    
    if selected_dlc_appids:
        # Adicionar DLCs ao arquivo .lua
        success = add_dlcs_to_lua_file(appid, selected_dlc_appids)
        
        if success:
            print("\n🎉 CONCLUÍDO!")
            print("📁 Arquivo atualizado.")
            print("📦 DLCs adicionadas: {}".format(len(selected_dlc_appids)))
            print("\n⚠️  IMPORTANTE: Reinicie o Steam para aplicar as mudanças!")
            print("   Use o botão 'Restart Steam' no canto inferior esquerdo")
        else:
            print("\n❌ Erro ao adicionar DLCs ao arquivo.")
    else:
        print("\nℹ️  Nenhuma DLC selecionada.")
    
    print("\n⏎ Pressione Enter para fechar...")
    input()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n🚫 Operação cancelada pelo usuário")
    except Exception as e:
        print("\n❌ Erro inesperado: {}".format(e))
        print("⏎ Pressione Enter para fechar...")
        input()