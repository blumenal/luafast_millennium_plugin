# uninstall.ps1 - Script de desinstalação para Millennium + luafast
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalador Automático luafast + Millennium" -ForegroundColor Cyan
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
    pause
    exit 1
}

Write-Host "✅ PowerShell executando como Administrador" -ForegroundColor Green

try {
    # Fechar Steam se estiver aberto
    Write-Host ""
    Write-Host "🔴 Fechando Steam..." -ForegroundColor Yellow
    $steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($steamProcess) {
        Write-Host "   ⏳ Fechando processos do Steam..." -ForegroundColor Gray
        Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Write-Host "   ✅ Steam fechado" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️ Steam não estava em execução" -ForegroundColor Gray
    }

    # Caminhos de instalação
    $steamPath = "C:\Program Files (x86)\Steam"
    $pluginPath = "$steamPath\plugins\luafast"
    $hidDllPath = "$steamPath\hid.dll"

    Write-Host ""
    Write-Host "📁 Removendo arquivos..." -ForegroundColor Yellow

    # Remover plugin luafast
    if (Test-Path $pluginPath) {
        Write-Host "   🗑️ Removendo plugin luafast..." -ForegroundColor Gray
        try {
            Remove-Item $pluginPath -Recurse -Force -ErrorAction Stop
            Write-Host "   ✅ Plugin luafast removido: $pluginPath" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Aviso: Não foi possível remover completamente o plugin: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ℹ️ Plugin luafast não encontrado: $pluginPath" -ForegroundColor Gray
    }

    # Remover hid.dll (com verificação de segurança)
    if (Test-Path $hidDllPath) {
        Write-Host "   🗑️ Removendo hid.dll..." -ForegroundColor Gray
        
        # Fazer backup da hid.dll antes de remover (opcional)
        $backupPath = "$hidDllPath.backup"
        try {
            Copy-Item -Path $hidDllPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
            Write-Host "   💾 Backup criado: $backupPath" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠️ Não foi possível criar backup da hid.dll" -ForegroundColor Yellow
        }
        
        try {
            Remove-Item $hidDllPath -Force -ErrorAction Stop
            Write-Host "   ✅ hid.dll removida: $hidDllPath" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Aviso: Não foi possível remover hid.dll: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ℹ️ hid.dll não encontrada: $hidDllPath" -ForegroundColor Gray
    }

    # Verificar se a pasta de plugins está vazia e remover se estiver
    $pluginsDir = "$steamPath\plugins"
    if (Test-Path $pluginsDir) {
        $remainingItems = Get-ChildItem $pluginsDir -ErrorAction SilentlyContinue
        if ($remainingItems.Count -eq 0) {
            Write-Host "   🗑️ Removendo diretório de plugins vazio..." -ForegroundColor Gray
            Remove-Item $pluginsDir -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Diretório de plugins removido" -ForegroundColor Green
        }
    }

    # Opção para desinstalar Millennium
    Write-Host ""
    Write-Host "🔍 Verificando Millennium..." -ForegroundColor Yellow
    $choice = Read-Host "Deseja desinstalar o Millennium também? (S/N)"
    if ($choice -eq 'S' -or $choice -eq 's') {
        Write-Host "   🗑️ Desinstalando Millennium..." -ForegroundColor Gray
        
        # Tentar encontrar e executar desinstalador do Millennium
        $millenniumPaths = @(
            "$env:LOCALAPPDATA\Millennium",
            "$env:PROGRAMFILES\Millennium",
            "$env:PROGRAMFILES(X86)\Millennium"
        )
        
        $uninstallFound = $false
        foreach ($path in $millenniumPaths) {
            if (Test-Path $path) {
                Write-Host "   📁 Millennium encontrado em: $path" -ForegroundColor Gray
                
                # Procurar por desinstalador
                $uninstaller = Get-ChildItem $path -Filter "uninstall*.exe" -Recurse | Select-Object -First 1
                if ($uninstaller) {
                    Write-Host "   🚀 Executando desinstalador: $($uninstaller.FullName)" -ForegroundColor Gray
                    try {
                        Start-Process -FilePath $uninstaller.FullName -Wait
                        Write-Host "   ✅ Desinstalador do Millennium executado" -ForegroundColor Green
                        $uninstallFound = $true
                        break
                    } catch {
                        Write-Host "   ❌ Erro ao executar desinstalador: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        }
        
        if (-not $uninstallFound) {
            Write-Host "   ℹ️ Desinstalador do Millennium não encontrado automaticamente" -ForegroundColor Yellow
            Write-Host "   💡 Você pode desinstalar manualmente pelo Painel de Controle" -ForegroundColor White
        }
    }

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "✅ Desinstalação concluída com sucesso!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
    Write-Host "   1. Reinicie o Steam para aplicar as mudanças" -ForegroundColor White
    Write-Host "   2. O plugin luafast foi completamente removido" -ForegroundColor White
    Write-Host "   3. Se tiver problemas, verifique o backup da hid.dll em: $hidDllPath.backup" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Para suporte:" -ForegroundColor Cyan
    Write-Host "   Repositório: https://github.com/blumenal/luafast_millennium_plugin" -ForegroundColor White
    Write-Host ""

    # Opção para reiniciar o Steam
    $restartChoice = Read-Host "Deseja iniciar o Steam agora? (S/N)"
    if ($restartChoice -eq 'S' -or $restartChoice -eq 's') {
        Write-Host "🚀 Iniciando Steam..." -ForegroundColor Green
        Start-Process "steam://"
    }

    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host ""
    Write-Host "❌ ERRO na desinstalação: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Soluções possíveis:" -ForegroundColor Yellow
    Write-Host "   • Execute o PowerShell como Administrador" -ForegroundColor White
    Write-Host "   • Feche o Steam manualmente antes de executar" -ForegroundColor White
    Write-Host "   • Remova os arquivos manualmente:" -ForegroundColor White
    Write-Host "     - $pluginPath" -ForegroundColor White
    Write-Host "     - $hidDllPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
