# uninstall.ps1 - Script de desinstalação SEGURO do luafast + Millennium
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalador SEGURO luafast + Millennium" -ForegroundColor Cyan
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

# LISTA DE PASTAS PROTEGIDAS - NUNCA REMOVER!
$protectedPaths = @(
    "C:\",
    "C:\Windows",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\Users",
    "C:\ProgramData",
    $env:USERPROFILE,
    $env:HOMEPATH,
    $env:SystemRoot
)

function Test-ProtectedPath {
    param([string]$path)
    
    foreach ($protected in $protectedPaths) {
        if ($path -eq $protected -or $path.StartsWith($protected + "\")) {
            return $true
        }
    }
    return $false
}

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

    # Locais SEGUROS onde o Millennium pode estar instalado
    $safeSteamPaths = @(
        "C:\Program Files (x86)\Steam",
        "C:\Program Files\Steam"
    )

    # Encontrar o caminho real do Steam de forma SEGURA
    $realSteamPath = $null
    foreach ($path in $safeSteamPaths) {
        if (Test-Path $path -PathType Container) {
            $realSteamPath = $path
            break
        }
    }

    if (-not $realSteamPath) {
        Write-Host "❌ Steam não encontrado nos locais seguros." -ForegroundColor Red
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
            "$realSteamPath\plugins\luafast"
        )
        
        $removed = $false
        foreach ($path in $luafastPaths) {
            if (Test-Path $path -PathType Container) {
                try {
                    if (Test-ProtectedPath $path) {
                        Write-Host "   ⚠️  Caminho protegido, ignorando: $path" -ForegroundColor Yellow
                        continue
                    }
                    Remove-Item $path -Recurse -Force
                    Write-Host "   ✅ Plugin luafast removido: $path" -ForegroundColor Green
                    $removed = $true
                } catch {
                    Write-Host "   ❌ Erro ao remover $path : $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "   ℹ️  Não encontrado: $path" -ForegroundColor Gray
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
        # Opção 2: Desinstalação COMPLETA mas SEGURA
        Write-Host ""
        Write-Host "⚠️  ATENÇÃO: Esta opção removerá COMPLETAMENTE o Millennium e todos os plugins!" -ForegroundColor Red
        Write-Host "    Isso inclui o luafast e qualquer outro plugin instalado." -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Tem certeza que deseja continuar? (digite 'SIM' para confirmar)"
        
        if ($confirm -eq 'SIM') {
            Write-Host ""
            Write-Host "🗑️  Iniciando desinstalação COMPLETA e SEGURA..." -ForegroundColor Yellow
            
            # Lista SEGURA de arquivos e pastas do Millennium - APENAS LOCAIS CONHECIDOS E SEGUROS
            $safeMillenniumItems = @(
                # Arquivos na raiz do Steam
                "$realSteamPath\hid.dll",
                "$realSteamPath\millennium.dll",
                "$realSteamPath\steamui.dll",
                "$realSteamPath\steamui.dll.original",
                
                # Pastas de plugins (apenas se dentro do Steam)
                "$realSteamPath\plugins",
                "$realSteamPath\ext",
                
                # AppData Local - APENAS pastas específicas do Millennium
                "$env:LOCALAPPDATA\MillenniumSteam",
                "$env:LOCALAPPDATA\steam_cef"
            )

            Write-Host "🔍 Procurando e removendo componentes do Millennium..." -ForegroundColor Yellow
            
            $removedCount = 0
            $errorCount = 0
            
            foreach ($item in $safeMillenniumItems) {
                # VERIFICAÇÃO DE SEGURANÇA CRÍTICA
                if (Test-ProtectedPath $item) {
                    Write-Host "   🚫 BLOQUEADO (protegido): $item" -ForegroundColor Red
                    continue
                }
                
                if (Test-Path $item) {
                    try {
                        if (Test-Path $item -PathType Container) {
                            # É uma pasta
                            Remove-Item $item -Recurse -Force
                            Write-Host "   ✅ Pasta removida: $item" -ForegroundColor Green
                        } else {
                            # É um arquivo
                            Remove-Item $item -Force
                            Write-Host "   ✅ Arquivo removido: $item" -ForegroundColor Green
                        }
                        $removedCount++
                    } catch {
                        Write-Host "   ❌ Erro em: $item" -ForegroundColor Red
                        Write-Host "      $($_.Exception.Message)" -ForegroundColor DarkRed
                        $errorCount++
                    }
                } else {
                    Write-Host "   ℹ️  Não encontrado: $item" -ForegroundColor Gray
                }
            }

            # Limpar caches de forma SEGURA
            Write-Host "🧹 Limpando caches de forma segura..." -ForegroundColor Yellow
            
            $safeCachePatterns = @(
                "$env:TEMP\Millennium*",
                "$env:TEMP\steam_cef*"
            )
            
            foreach ($cachePattern in $safeCachePatterns) {
                Get-ChildItem -Path $cachePattern -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        if (Test-ProtectedPath $_.FullName) {
                            Write-Host "   🚫 Cache bloqueado: $($_.Name)" -ForegroundColor Red
                            return
                        }
                        Remove-Item $_.FullName -Recurse -Force
                        Write-Host "   ✅ Cache: $($_.Name)" -ForegroundColor Green
                        $removedCount++
                    } catch {
                        Write-Host "   ❌ Erro no cache: $($_.Name)" -ForegroundColor DarkRed
                    }
                }
            }

            Write-Host ""
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host "✅ Desinstalação COMPLETA e SEGURA concluída!" -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📊 Resumo da desinstalação:" -ForegroundColor Yellow
            Write-Host "   • Itens removidos com segurança: $removedCount" -ForegroundColor White
            if ($errorCount -gt 0) {
                Write-Host "   • Erros encontrados: $errorCount" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host "🎯 Componentes removidos:" -ForegroundColor Yellow
            Write-Host "   • Plugin luafast" -ForegroundColor White
            Write-Host "   • Millennium (arquivos e pastas seguras)" -ForegroundColor White
            Write-Host "   • Caches temporários" -ForegroundColor White
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
    Write-Host "   • Remova os arquivos manualmente com segurança:" -ForegroundColor White
    Write-Host "     1. Delete C:\Program Files (x86)\Steam\hid.dll" -ForegroundColor White
    Write-Host "     2. Delete C:\Program Files (x86)\Steam\plugins\" -ForegroundColor White
    Write-Host "     3. Delete %LOCALAPPDATA%\MillenniumSteam" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "🔒 Desinstalação concluída com SEGURANÇA!" -ForegroundColor Green
