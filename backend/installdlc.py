import os
import subprocess
import sys

def install_dlc(appid: int = None):
    """
    Função para instalar DLC's - MESMA ESTRUTURA do restart_steam.py
    """
    try:
        # Obtém o diretório do script atual
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Construir comando com AppID se disponível
        if appid:
            # COMANDO com AppID como argumento
            if os.name == 'nt':  # Windows
                cmd = f'start "Instalador de DLCs - AppID {appid}" /D "{current_dir}" python installdlc_main.py {appid}'
            else:  # Linux
                cmd = f'cd "{current_dir}" && python3 installdlc_main.py {appid}'
        else:
            # COMANDO sem AppID (compatibilidade)
            if os.name == 'nt':  # Windows
                cmd = f'start "Instalador de DLCs" /D "{current_dir}" python installdlc_main.py'
            else:  # Linux
                cmd = f'cd "{current_dir}" && python3 installdlc_main.py'
        
        # Executa exatamente como o restart_steam.py faz
        subprocess.Popen(cmd, shell=True)
        
        # Log do comando executado
        if appid:
            print(f"luafast: Comando DLC executado para AppID {appid}: {cmd}")
        else:
            print(f"luafast: Comando DLC executado: {cmd}")
            
        return True
        
    except Exception as e:
        print(f"Erro em install_dlc: {e}")
        return False

if __name__ == "__main__":
    # Para execução direta, verifica se há AppID como argumento
    appid = sys.argv[1] if len(sys.argv) > 1 else None
    success = install_dlc(appid)
    sys.exit(0 if success else 1)