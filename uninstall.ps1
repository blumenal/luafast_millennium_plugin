# uninstall.ps1 - Script de desinstalação completo do luafast + Millennium
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalador Completo luafast + Millennium" -ForegroundColor Cyan
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
    # Fechar Steam e processos relacionados
    Write-Host "🛑 Fechando Steam e processos relacionados..." -ForegroundColor Yellow
    $processes = @("steam", "steamwebhelper", "steamservice", "gameoverlayui")
    foreach ($process in $processes) {
        $runningProcesses = Get-Process -Name $process -ErrorAction SilentlyContinue
        if ($runningProcesses) {
            Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Fechado: $process" -ForegroundColor Green
        }
    }
    Start-Sleep -Seconds 3

    # Mostrar opções de desinstalação
    Write-Host ""
    Write-Host "🔧 Opções de Desinstalação:" -ForegroundColor Cyan
    Write-Host "   1. Desinstalar APENAS o plugin luafast" -ForegroundColor White
    Write-Host "   2. Desinstalar COMPLETAMENTE (luafast + Millennium)" -ForegroundColor White
    Write-Host "   3. Cancelar" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Selecione uma opção (1-3)"
    
    if ($choice -eq "3") {
        Write-Host "🚫 Operação cancelada pelo usuário" -ForegroundColor Yellow
        pause
        exit 0
    }

    # Lista completa de locais onde o Millennium pode estar instalado
    $steamPaths = @(
        "C:\Program Files (x86)\Steam",
        "C:\Program Files\Steam",
        [Environment]::GetFolderPath("UserProfile") + "\Desktop\Steam"
    )

    # Encontrar o caminho real do Steam
    $realSteamPath = $null
    foreach ($path in $steamPaths) {
        if (Test-Path $path) {
            $realSteamPath = $path
            break
        }
    }

    if (-not $realSteamPath) {
        Write-Host "❌ Steam não encontrado nos locais padrão." -ForegroundColor Red
        Write-Host "💡 O Millennium pode não estar instalado." -ForegroundColor Yellow
        pause
        exit 1
    }

    Write-Host "📍 Steam encontrado em: $realSteamPath" -ForegroundColor Green

    if ($choice -eq "1") {
        # Opção 1: Desinstalar apenas o plugin luafast
        Write-Host ""
        Write-Host "🎮 Desinstalando APENAS o plugin luafast..." -ForegroundColor Yellow
        
        $luafastPaths = @(
            "$realSteamPath\plugins\luafast",
            "$env:LOCALAPPDATA\MillenniumSteam\plugins\luafast"
        )
        
        $removed = $false
        foreach ($path in $luafastPaths) {
            if (Test-Path $path) {
                try {
                    Remove-Item $path -Recurse -Force
                    Write-Host "✅ Plugin luafast removido: $path" -ForegroundColor Green
                    $removed = $true
                } catch {
                    Write-Host "❌ Erro ao remover $path : $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        
        if (-not $removed) {
            Write-Host "ℹ️  Plugin luafast não encontrado." -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "✅ Desinstalação do luafast concluída!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Cyan

    } elseif ($choice -eq "2") {
        # Opção 2: Desinstalação COMPLETA
        Write-Host ""
        Write-Host "⚠️  ATENÇÃO: Esta opção removerá COMPLETAMENTE o Millennium e todos os plugins!" -ForegroundColor Red
        Write-Host "    Isso inclui o luafast e qualquer outro plugin instalado." -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Tem certeza que deseja continuar? (digite 'SIM' para confirmar)"
        
        if ($confirm -eq 'SIM') {
            Write-Host ""
            Write-Host "🗑️  Iniciando desinstalação COMPLETA..." -ForegroundColor Red
            
            # Lista COMPLETA de arquivos e pastas do Millennium
            $millenniumItems = @(
                # Arquivos na raiz do Steam
                "$realSteamPath\hid.dll",
                "$realSteamPath\millennium.dll",
                "$realSteamPath\steamui.dll",
                "$realSteamPath\steamui.dll.original",
                
                # Pastas de plugins
                "$realSteamPath\plugins",
                "$realSteamPath\ext",
                "$realSteamPath\millennium",
                
                # AppData Local
                "$env:LOCALAPPDATA\MillenniumSteam",
                "$env:LOCALAPPDATA\steam_cef",
                
                # AppData Roaming
                "$env:APPDATA\MillenniumSteam",
                "$env:APPDATA\steam_cef",
                
                # Registro (usando reg)
                "HKCU:\Software\MillenniumSteam",
                "HKCU:\Software\SteamCEF"
            )

            # Adicionar possíveis locais alternativos
            $alternativePaths = @(
                "C:\Program Files\MillenniumSteam",
                "C:\Program Files (x86)\MillenniumSteam",
                [Environment]::GetFolderPath("UserProfile") + "\MillenniumSteam"
            )
            $millenniumItems += $alternativePaths

            Write-Host "🔍 Procurando e removendo componentes do Millennium..." -ForegroundColor Yellow
            
            $removedCount = 0
            $errorCount = 0
            
            foreach ($item in $millenniumItems) {
                if (Test-Path $item) {
                    try {
                        if ($item -match "^(HK(CU|LM|CR):\\.*)") {
                            # É uma chave de registro
                            Remove-Item $item -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "   ✅ Registro: $item" -ForegroundColor Green
                        } else {
                            # É arquivo ou pasta
                            Remove-Item $item -Recurse -Force
                            Write-Host "   ✅ Removido: $item" -ForegroundColor Green
                        }
                        $removedCount++
                    } catch {
                        Write-Host "   ❌ Erro em: $item" -ForegroundColor Red
                        Write-Host "      $($_.Exception.Message)" -ForegroundColor DarkRed
                        $errorCount++
                    }
                }
            }

            # Tentar desinstalar via winget/chocolatey se existir
            try {
                Write-Host "🔍 Verificando instaladores de pacotes..." -ForegroundColor Yellow
                
                # Winget
                $wingetCheck = Get-Command winget -ErrorAction SilentlyContinue
                if ($wingetCheck) {
                    $millenniumPackage = winget list --name "Millennium" 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "   📦 Removendo Millennium do winget..." -ForegroundColor Yellow
                        winget uninstall --name "Millennium" --silent --accept-source-agreements
                        Write-Host "   ✅ Millennium removido do winget" -ForegroundColor Green
                        $removedCount++
                    }
                }
                
                # Chocolatey
                $chocoCheck = Get-Command choco -ErrorAction SilentlyContinue
                if ($chocoCheck) {
                    $chocoPackage = choco list --local-only --name "millennium" 2>$null
                    if ($LASTEXITCODE -eq 0 -and $chocoPackage -match "millennium") {
                        Write-Host "   📦 Removendo Millennium do Chocolatey..." -ForegroundColor Yellow
                        choco uninstall millennium -y
                        Write-Host "   ✅ Millennium removido do Chocolatey" -ForegroundColor Green
                        $removedCount++
                    }
                }
            } catch {
                Write-Host "   ℹ️  Nenhum instalador de pacotes encontrado" -ForegroundColor Gray
            }

            # Limpar caches adicionais
            Write-Host "🧹 Limpando caches e arquivos temporários..." -ForegroundColor Yellow
            
            $cachePaths = @(
                "$env:TEMP\Millennium*",
                "$env:TEMP\steam*",
                "$env:TEMP\cef*",
                "$env:LOCALAPPDATA\Temp\Millennium*"
            )
            
            foreach ($cachePattern in $cachePaths) {
                Get-ChildItem -Path $cachePattern -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        Remove-Item $_.FullName -Recurse -Force
                        Write-Host "   ✅ Cache: $($_.Name)" -ForegroundColor Green
                        $removedCount++
                    } catch {
                        # Ignora erros em cache
                    }
                }
            }

            Write-Host ""
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host "✅ Desinstalação COMPLETA concluída!" -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📊 Resumo da desinstalação:" -ForegroundColor Yellow
            Write-Host "   • Itens removidos: $removedCount" -ForegroundColor White
            if ($errorCount -gt 0) {
                Write-Host "   • Erros encontrados: $errorCount" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host "🎯 Componentes removidos:" -ForegroundColor Yellow
            Write-Host "   • Plugin luafast" -ForegroundColor White
            Write-Host "   • Millennium (arquivos, pastas e registros)" -ForegroundColor White
            Write-Host "   • Caches e arquivos temporários" -ForegroundColor White
            Write-Host ""
            Write-Host "💡 Agora o Steam está completamente limpo!" -ForegroundColor Cyan
            Write-Host "   Reinicie o Steam para voltar à configuração original." -ForegroundColor White

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
    Write-Host "   • Remova os arquivos manualmente:" -ForegroundColor White
    Write-Host "     1. Delete C:\Program Files (x86)\Steam\hid.dll" -ForegroundColor White
    Write-Host "     2. Delete C:\Program Files (x86)\Steam\plugins\" -ForegroundColor White
    Write-Host "     3. Delete %LOCALAPPDATA%\MillenniumSteam" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
