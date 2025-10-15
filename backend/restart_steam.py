import os
import tempfile
import subprocess
import sys

def restart_steam():
    """
    Reinicia o Steam através de uma janela de prompt de comando visível
    """
    try:
        # Criar um arquivo batch temporário
        with tempfile.NamedTemporaryFile(mode='w', suffix='.bat', delete=False, encoding='utf-8') as f:
            batch_file = f.name
            
            # Escrever os comandos no arquivo batch
            f.write('@echo off\n')
            f.write('title luafast - Reiniciando Steam\n')
            f.write('echo [luafast] Reiniciando Steam...\n')
            f.write('echo.\n')
            
            # Fechar o Steam
            f.write('echo Fechando Steam...\n')
            f.write('taskkill /F /IM steam.exe >nul 2>&1\n')
            f.write('timeout /t 2 /nobreak >nul\n')
            f.write('echo Steam fechado.\n')
            f.write('echo.\n')
            
            # Iniciar o Steam novamente
            f.write('echo Iniciando Steam...\n')
            
            # Tentar caminhos comuns do Steam
            steam_paths = [
                "C:\\Program Files (x86)\\Steam\\Steam.exe",
                "C:\\Program Files\\Steam\\Steam.exe"
            ]
            
            # Adicionar caminho do desktop como fallback
            desktop_path = os.path.expanduser("~") + "\\Desktop\\Steam.lnk"
            if os.path.exists(desktop_path):
                steam_paths.append(desktop_path)
            
            steam_started = False
            for i, path in enumerate(steam_paths):
                if i == 0:
                    f.write(f'if exist "{path}" (\n')
                else:
                    f.write(f') else if exist "{path}" (\n')
                f.write(f'    start "" "{path}"\n')
                f.write('    echo Steam iniciado com sucesso.\n')
                f.write('    set STEAM_STARTED=1\n')
            
            # Se não encontrou nos caminhos comuns, tentar via registro
            f.write(') else (\n')
            f.write('    echo Procurando Steam no registro...\n')
            f.write('    for /f "tokens=2*" %%a in (\'reg query "HKCU\\Software\\Valve\\Steam" /v "SteamExe" 2^>nul\') do (\n')
            f.write('        if exist "%%b" (\n')
            f.write('            start "" "%%b"\n')
            f.write('            echo Steam iniciado a partir do registro.\n')
            f.write('            set STEAM_STARTED=1\n')
            f.write('        )\n')
            f.write('    )\n')
            f.write(')\n')
            
            f.write('if "%STEAM_STARTED%"=="1" (\n')
            f.write('    echo.\n')
            f.write('    echo Reinicio do Steam concluido com sucesso!\n')
            f.write('    echo.\n')
            f.write('    echo Esta janela fechara automaticamente em 3 segundos...\n')
            f.write('    timeout /t 3 /nobreak >nul\n')
            f.write(') else (\n')
            f.write('    echo.\n')
            f.write('    echo ERRO: Nao foi possivel encontrar o Steam.\n')
            f.write('    echo Por favor, inicie o Steam manualmente.\n')
            f.write('    echo.\n')
            f.write('    echo Pressione qualquer tecla para fechar esta janela...\n')
            f.write('    pause >nul\n')
            f.write(')\n')
        
        # Executar o arquivo batch em uma nova janela de prompt
        if sys.platform == "win32":
            # Usar start com /wait para aguardar conclusão e depois fechar
            subprocess.Popen(['cmd', '/c', 'start', '/wait', 'cmd', '/c', batch_file], 
                           shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Agendar a exclusão do arquivo batch
            def delete_batch_file():
                import time
                time.sleep(10)
                try:
                    if os.path.exists(batch_file):
                        os.unlink(batch_file)
                except:
                    pass
            
            import threading
            threading.Thread(target=delete_batch_file, daemon=True).start()
            
            return True
        else:
            try:
                os.unlink(batch_file)
            except:
                pass
            return False
            
    except Exception as e:
        print(f"Erro ao criar script de reinicio: {e}")
        return False