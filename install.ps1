# install.ps1 - Script de instalação automática para Millennium + luafast
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

# Configurações para evitar fechamento prematuro
$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 Instalador Automático luafast + Millennium + Python" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se é administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-NOT $isAdmin) {
    Write-Host "❌ ERRO: Este script requer privilégios de administrador!" -ForegroundColor Red
    Write-Host "💡 Por favor, execute o PowerShell como Administrador:" -ForegroundColor Yellow
    Write-Host "   1. Clique com botão direito no PowerShell" -ForegroundColor Yellow
    Write-Host "   2. Selecione 'Executar como Administrador'" -ForegroundColor Yellow
    Write-Host "   3. Execute o comando novamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
    exit 1
}

Write-Host "✅ PowerShell executando como Administrador" -ForegroundColor Green

try {
    # Passo 1: Verificar e instalar Python
    Write-Host ""
    Write-Host "🐍 Passo 1/3: Verificando e instalando Python..." -ForegroundColor Yellow
    
    # Verificar se Python já está instalado
    $pythonInstalled = $false
    $pythonVersions = @("python", "python3", "py")
    
    foreach ($pythonCmd in $pythonVersions) {
        try {
            $null = Get-Command $pythonCmd -ErrorAction Stop
            $pythonVersion = & $pythonCmd --version 2>&1
            Write-Host "   ✅ Python encontrado: $pythonVersion" -ForegroundColor Green
            $pythonInstalled = $true
            break
        } catch {
            # Continua para próxima tentativa
        }
    }
    
    # Se Python não está instalado, instalar
    if (-NOT $pythonInstalled) {
        Write-Host "   📥 Python não encontrado. Instalando..." -ForegroundColor Gray
        
        # URL do instalador do Python
        $pythonInstallerUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
        $pythonInstallerPath = "$env:TEMP\python-installer.exe"
        
        # Download do Python
        Write-Host "   📥 Baixando Python 3.11.9..." -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $pythonInstallerPath
            Write-Host "   ✅ Download do Python concluído" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Erro no download do Python: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
        
        # Instalar Python silenciosamente
        Write-Host "   ⚙️ Instalando Python (isso pode levar alguns minutos)..." -ForegroundColor Gray
        $installArgs = @(
            "/quiet",
            "InstallAllUsers=1",
            "PrependPath=1",
            "Include_test=0",
            "SimpleInstall=1"
        )
        
        $process = Start-Process -FilePath $pythonInstallerPath -ArgumentList $installArgs -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "   ✅ Python instalado com sucesso!" -ForegroundColor Green
            
            # Atualizar PATH para reconhecer Python imediatamente
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } else {
            Write-Host "   ⚠️ A instalação do Python pode não ter concluído completamente. Código de saída: $($process.ExitCode)" -ForegroundColor Yellow
        }
        
        # Limpar instalador
        Remove-Item $pythonInstallerPath -Force -ErrorAction SilentlyContinue
        
        # Verificar novamente se Python está disponível
        Start-Sleep -Seconds 3
        $pythonInstalled = $false
        foreach ($pythonCmd in $pythonVersions) {
            try {
                $null = Get-Command $pythonCmd -ErrorAction Stop
                $pythonVersion = & $pythonCmd --version 2>&1
                Write-Host "   ✅ Python instalado: $pythonVersion" -ForegroundColor Green
                $pythonInstalled = $true
                break
            } catch {
                # Continua para próxima tentativa
            }
        }
        
        if (-NOT $pythonInstalled) {
            Write-Host "   ⚠️ Python pode exigir reinicialização do PowerShell para ser reconhecido." -ForegroundColor Yellow
        }
    }

    # Passo 1.5: Instalar dependências Python
    Write-Host ""
    Write-Host "📦 Passo 1.5/3: Instalando dependências Python..." -ForegroundColor Yellow
    
    $dependenciesInstalled = $false
    $maxRetries = 3
    
    foreach ($pythonCmd in $pythonVersions) {
        for ($retry = 1; $retry -le $maxRetries; $retry++) {
            try {
                Write-Host "   🔍 Tentando instalar dependências com $pythonCmd (tentativa $retry/$maxRetries)..." -ForegroundColor Gray
                
                # Verificar se o comanda Python está disponível
                $null = Get-Command $pythonCmd -ErrorAction Stop
                
                # Atualizar pip primeiro
                & $pythonCmd -m pip install --upgrade pip --disable-pip-version-check --no-warn-script-location 2>&1 | Out-Null
                
                # Instalar requests (única dependência necessária)
                & $pythonCmd -m pip install requests --disable-pip-version-check --no-warn-script-location 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Dependências Python instaladas com sucesso!" -ForegroundColor Green
                    $dependenciesInstalled = $true
                    break
                } else {
                    Write-Host "   ⚠️ Falha na tentativa $retry com $pythonCmd" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "   ⚠️ $pythonCmd não disponível para instalar dependências" -ForegroundColor Yellow
            }
            
            if ($retry -lt $maxRetries) {
                Write-Host "   ⏳ Aguardando 2 segundos antes da próxima tentativa..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            }
        }
        
        if ($dependenciesInstalled) {
            break
        }
    }
    
    if (-NOT $dependenciesInstalled) {
        Write-Host "   ❌ Não foi possível instalar as dependências Python automaticamente." -ForegroundColor Red
        Write-Host "   💡 Instale manualmente com: pip install requests" -ForegroundColor Yellow
        # Não vamos falhar a instalação completa por causa disso, apenas avisar
    }

    # Passo 2: Instalar Millennium
    Write-Host ""
    Write-Host "📥 Passo 2/3: Instalando Millennium..." -ForegroundColor Yellow
    Write-Host "   Isso pode levar alguns minutos..." -ForegroundColor Gray
    
    # Instalar Millennium
    try {
        $millenniumScript = Invoke-WebRequest -Uri "https://steambrew.app/install.ps1" -UseBasicParsing
        Invoke-Expression $millenniumScript.Content
        Write-Host "✅ Millennium instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro na instalação do Millennium: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Continuando com a instalação do plugin luafast..." -ForegroundColor Yellow
    }
    
    # Aguardar instalação do Millennium
    Write-Host "   ⏳ Aguardando conclusão da instalação..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Passo 3: Instalar plugin luafast nos locais CORRETOS
    Write-Host ""
    Write-Host "🎮 Passo 3/3: Instalando plugin luafast..." -ForegroundColor Yellow
    
    # CAMINHOS CORRETOS PARA STEAM
    $steamPath = "C:\Program Files (x86)\Steam"
    $correctPluginPath = "$steamPath\plugins"
    $correctHidDllPath = "$steamPath\hid.dll"
    
    # Verificar se o Steam está instalado no local padrão
    if (-not (Test-Path $steamPath)) {
        Write-Host "❌ ERRO: Steam não encontrado em $steamPath" -ForegroundColor Red
        Write-Host "💡 Instale o Steam no local padrão ou ajuste o script." -ForegroundColor Yellow
        throw "Steam não encontrado no local padrão"
    }
    
    Write-Host "   📁 Steam encontrado em: $steamPath" -ForegroundColor Green
    
    # Criar diretório de plugins se não existir
    if (-not (Test-Path $correctPluginPath)) {
        New-Item -ItemType Directory -Path $correctPluginPath -Force
        Write-Host "   📁 Diretório de plugins criado: $correctPluginPath" -ForegroundColor Gray
    }
    
    # Definir caminhos temporários
    $tempZip = "$env:TEMP\luafast_plugin.zip"
    $extractPath = "$env:TEMP\luafast_extract"
    
    # Download do plugin
    Write-Host "   📥 Baixando plugin luafast..." -ForegroundColor Gray
    $pluginUrl = "https://github.com/blumenal/luafast_millennium_plugin/archive/refs/heads/main.zip"
    try {
        Invoke-WebRequest -Uri $pluginUrl -OutFile $tempZip
        Write-Host "   ✅ Download concluído" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro no download: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    
    # Extrair arquivo
    Write-Host "   📦 Extraindo arquivos..." -ForegroundColor Gray
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    try {
        Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
        Write-Host "   ✅ Extração concluída" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro na extração: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    
    # Mover arquivos para o diretório CORRETO do Steam
    $sourceDir = "$extractPath\luafast_millennium_plugin-main"
    $targetDir = "$correctPluginPath\luafast"
    
    # Verificar se o source existe
    if (-not (Test-Path $sourceDir)) {
        Write-Host "   ❌ Diretório de origem não encontrado: $sourceDir" -ForegroundColor Red
        # Tentar encontrar qualquer diretório extraído
        $folders = Get-ChildItem -Path $extractPath -Directory
        if ($folders.Count -eq 1) {
            $sourceDir = $folders[0].FullName
            Write-Host "   🔄 Usando diretório alternativo: $sourceDir" -ForegroundColor Yellow
        } else {
            throw "Não foi possível encontrar o diretório de origem extraído"
        }
    }
    
    # Remover instalação anterior se existir
    if (Test-Path $targetDir) {
        Write-Host "   ♻️ Removendo instalação anterior..." -ForegroundColor Gray
        try {
            Remove-Item $targetDir -Recurse -Force -ErrorAction Stop
            Write-Host "   ✅ Instalação anterior removida" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Aviso: Não foi possível remover completamente a instalação anterior" -ForegroundColor Yellow
        }
    }
    
    # Criar diretório de destino
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    
    # COPIAR ARQUIVOS INDIVIDUALMENTE para o local CORRETO
    Write-Host "   📄 Copiando arquivos para $targetDir..." -ForegroundColor Gray
    $items = Get-ChildItem -Path $sourceDir -File
    $folders = Get-ChildItem -Path $sourceDir -Directory
    
    # Copiar arquivos
    foreach ($item in $items) {
        try {
            Copy-Item -Path $item.FullName -Destination $targetDir -Force
            Write-Host "     ✅ $($item.Name)" -ForegroundColor Gray
        } catch {
            Write-Host "     ❌ Erro copiando $($item.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Copiar pastas
    foreach ($folder in $folders) {
        try {
            $destFolder = Join-Path $targetDir $folder.Name
            Copy-Item -Path $folder.FullName -Destination $destFolder -Recurse -Force
            Write-Host "     📁 $($folder.Name)" -ForegroundColor Gray
        } catch {
            Write-Host "     ❌ Erro copiando pasta $($folder.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "   ✅ Plugin luafast instalado em: $targetDir" -ForegroundColor Green
    
    # VERIFICAR E INSTALAR HID.DLL se necessário
    Write-Host "   🔍 Verificando hid.dll..." -ForegroundColor Gray
    
    # Procurar hid.dll no repositório extraído
    $hidDllSource = Get-ChildItem -Path $extractPath -Recurse -Filter "hid.dll" | Select-Object -First 1
    if ($hidDllSource) {
        try {
            Copy-Item -Path $hidDllSource.FullName -Destination $correctHidDllPath -Force
            Write-Host "   ✅ hid.dll instalada em: $correctHidDllPath" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️  Não foi possível copiar hid.dll: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ℹ️  hid.dll não encontrada no repositório" -ForegroundColor Gray
    }
    
    # Verificar se os arquivos principais foram copiados
    $requiredFiles = @("plugin.json", "main.py", "index.js")
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$targetDir\$file")) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "   ⚠️  Aviso: Alguns arquivos podem estar faltando: $($missingFiles -join ', ')" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ Todos os arquivos principais instalados" -ForegroundColor Green
    }
    
    # Limpar arquivos temporários
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "🎉 Instalação concluída com sucesso!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
    Write-Host "   1. Feche completamente o Steam (se estiver aberto)" -ForegroundColor White
    Write-Host "   2. Inicie o Steam normalmente" -ForegroundColor White
    Write-Host "   3. Acesse a página de qualquer jogo na Steam Store" -ForegroundColor White
    Write-Host "   4. Clique no botão 'Grátis - LuaFast' para adicionar jogos" -ForegroundColor White
    Write-Host ""
    Write-Host "📍 Componentes instalados:" -ForegroundColor Cyan
    Write-Host "   • Python 3.11.9 (para execução de scripts)" -ForegroundColor White
    Write-Host "   • Biblioteca requests (para requisições HTTP)" -ForegroundColor White
    Write-Host "   • Millennium (framework de modificação Steam)" -ForegroundColor White
    Write-Host "   • Plugin luafast" -ForegroundColor White
    Write-Host ""
    Write-Host "📍 Arquivos instalados em:" -ForegroundColor Cyan
    Write-Host "   • Plugin: $targetDir" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Para suporte e novidades:" -ForegroundColor Cyan
    Write-Host "   Grupo do Telegram: https://t.me/luafaststeamgames" -ForegroundColor White
    Write-Host "   Repositório: https://github.com/blumenal/luafast_millennium_plugin" -ForegroundColor White
    Write-Host ""
    
    # Verificar se o Steam está aberto
    $steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($steamProcess) {
        Write-Host "⚠️  O Steam está atualmente em execução." -ForegroundColor Yellow
        $choice = Read-Host "Deseja fechar o Steam agora? (S/N)"
        if ($choice -eq 'S' -or $choice -eq 's') {
            Write-Host "🛑 Fechando Steam..." -ForegroundColor Yellow
            Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Steam fechado. Você pode iniciá-lo novamente agora." -ForegroundColor Green
        }
    } else {
        Write-Host "💡 Dica: Inicie o Steam para começar a usar o plugin!" -ForegroundColor Cyan
    }

} catch {
    Write-Host ""
    Write-Host "❌ ERRO na instalação: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Soluções possíveis:" -ForegroundColor Yellow
    Write-Host "   • Verifique sua conexão com a internet" -ForegroundColor White
    Write-Host "   • Execute o PowerShell como Administrador" -ForegroundColor White
    Write-Host "   • Desative temporariamente o antivírus" -ForegroundColor White
    Write-Host "   • Tente instalar manualmente seguindo o README.md" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Detalhes do erro:" -ForegroundColor Yellow
    Write-Host "   $($_.Exception.StackTrace)" -ForegroundColor Gray
}

# FIM DO SCRIPT - Aguardar entrada do usuário antes de fechar
Write-Host ""
Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
[Console]::ReadKey($true) | Out-Null
