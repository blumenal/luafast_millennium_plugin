# uninstall.ps1 - Script de desinstalação do luafast + Millennium
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalador luafast + Millennium" -ForegroundColor Cyan
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
    $steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($steamProcess) {
        Write-Host "🛑 Fechando Steam..." -ForegroundColor Yellow
        Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "✅ Steam fechado" -ForegroundColor Green
    }

    # Mostrar opções de desinstalação
    Write-Host ""
    Write-Host "🔧 Opções de Desinstalação:" -ForegroundColor Cyan
    Write-Host "   1. Desinstalar APENAS o plugin luafast" -ForegroundColor White
    Write-Host "   2. Desinstalar plugin luafast + Millennium (COMPLETO)" -ForegroundColor White
    Write-Host "   3. Cancelar" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Selecione uma opção (1-3)"
    
    if ($choice -eq "3") {
        Write-Host "🚫 Operação cancelada pelo usuário" -ForegroundColor Yellow
        pause
        exit 0
    }

    # Caminhos de instalação
    $steamPath = "C:\Program Files (x86)\Steam"
    $luafastPluginPath = "$steamPath\plugins\luafast"
    $millenniumHidDll = "$steamPath\hid.dll"
    $millenniumIni = "$steamPath\ext\millennium.ini"
    $millenniumExtPath = "$steamPath\ext"

    if ($choice -eq "1") {
        # Opção 1: Desinstalar apenas o plugin luafast
        Write-Host ""
        Write-Host "🎮 Desinstalando plugin luafast..." -ForegroundColor Yellow
        
        if (Test-Path $luafastPluginPath) {
            try {
                Remove-Item $luafastPluginPath -Recurse -Force
                Write-Host "✅ Plugin luafast removido: $luafastPluginPath" -ForegroundColor Green
            } catch {
                Write-Host "❌ Erro ao remover plugin: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "ℹ️  Plugin luafast não encontrado em: $luafastPluginPath" -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "✅ Desinstalação do luafast concluída!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 O Millennium permanece instalado." -ForegroundColor Yellow
        Write-Host "   Se quiser desinstalar completamente, execute novamente e escolha a opção 2." -ForegroundColor White

    } elseif ($choice -eq "2") {
        # Opção 2: Desinstalação completa
        Write-Host ""
        Write-Host "⚠️  ATENÇÃO: Esta opção removerá COMPLETAMENTE o Millennium e todos os plugins!" -ForegroundColor Red
        Write-Host "    Isso inclui o luafast e qualquer outro plugin instalado." -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Tem certeza que deseja continuar? (S/N)"
        
        if ($confirm -eq 'S' -or $confirm -eq 's') {
            Write-Host ""
            Write-Host "🗑️  Iniciando desinstalação completa..." -ForegroundColor Yellow
            
            # 1. Remover plugin luafast
            if (Test-Path $luafastPluginPath) {
                try {
                    Remove-Item $luafastPluginPath -Recurse -Force
                    Write-Host "✅ Plugin luafast removido" -ForegroundColor Green
                } catch {
                    Write-Host "❌ Erro ao remover plugin luafast: $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # 2. Remover hid.dll do Millennium
            if (Test-Path $millenniumHidDll) {
                try {
                    Remove-Item $millenniumHidDll -Force
                    Write-Host "✅ hid.dll removida" -ForegroundColor Green
                } catch {
                    Write-Host "❌ Erro ao remover hid.dll: $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # 3. Remover arquivo de configuração millennium.ini
            if (Test-Path $millenniumIni) {
                try {
                    Remove-Item $millenniumIni -Force
                    Write-Host "✅ millennium.ini removido" -ForegroundColor Green
                } catch {
                    Write-Host "❌ Erro ao remover millennium.ini: $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # 4. Remover pasta ext se estiver vazia
            if (Test-Path $millenniumExtPath) {
                try {
                    $extItems = Get-ChildItem $millenniumExtPath
                    if ($extItems.Count -eq 0) {
                        Remove-Item $millenniumExtPath -Force
                        Write-Host "✅ Pasta ext removida" -ForegroundColor Green
                    } else {
                        Write-Host "ℹ️  Pasta ext não está vazia, mantida no sistema" -ForegroundColor Gray
                    }
                } catch {
                    Write-Host "❌ Erro ao processar pasta ext: $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # 5. Remover do winget (se instalado via package manager)
            try {
                $millenniumPackage = winget list --id Millennium 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "📦 Removendo Millennium do winget..." -ForegroundColor Yellow
                    winget uninstall --id Millennium --silent
                    Write-Host "✅ Millennium removido do winget" -ForegroundColor Green
                }
            } catch {
                Write-Host "ℹ️  Millennium não encontrado no winget" -ForegroundColor Gray
            }

            Write-Host ""
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host "✅ Desinstalação COMPLETA concluída!" -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "🎯 Foram removidos:" -ForegroundColor Yellow
            Write-Host "   • Plugin luafast" -ForegroundColor White
            Write-Host "   • Millennium (hid.dll e configurações)" -ForegroundColor White
            Write-Host ""
            Write-Host "💡 Reinicie o Steam para voltar à configuração original." -ForegroundColor Cyan

        } else {
            Write-Host "🚫 Operação cancelada pelo usuário" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Opção inválida!" -ForegroundColor Red
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
    Write-Host "   • Remova os arquivos manualmente se necessário" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}