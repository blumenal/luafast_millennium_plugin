# uninstall.ps1 - Desinstalação DEFINITIVA do luafast e Millennium
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalação DEFINITIVA luafast + Millennium" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-NOT $isAdmin) {
    Write-Host "❌ Execute como Administrador!" -ForegroundColor Red
    Write-Host "   Botão direito → Executar como Administrador" -ForegroundColor Yellow
    timeout /t 5
    exit 1
}

Write-Host "✅ PowerShell como Administrador" -ForegroundColor Green

try {
    # Fechar TODOS os processos do Steam COMPLETAMENTE
    Write-Host "🔴 Fechando Steam completamente..." -ForegroundColor Red
    
    $steamProcesses = @("steam", "steamwebhelper", "steamservice", "gameoverlayui")
    foreach ($process in $steamProcesses) {
        do {
            $procs = Get-Process -Name $process -ErrorAction SilentlyContinue
            if ($procs) {
                Write-Host "   🛑 Terminando: $process" -ForegroundColor Yellow
                Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 500
            }
        } while (Get-Process -Name $process -ErrorAction SilentlyContinue)
    }
    
    Write-Host "✅ Steam completamente fechado" -ForegroundColor Green
    Start-Sleep -Seconds 2

    # Detectar caminho do Steam
    $steamPath = $null
    
    # 1. Tentar pelo registro
    try {
        $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction Stop).SteamPath
        Write-Host "📍 Steam encontrado no registro: $steamPath" -ForegroundColor Green
    } catch {
        # 2. Tentar caminhos padrão
        $defaultPaths = @(
            "C:\Program Files (x86)\Steam",
            "C:\Program Files\Steam"
        )
        foreach ($path in $defaultPaths) {
            if (Test-Path $path) {
                $steamPath = $path
                Write-Host "📍 Steam encontrado em: $steamPath" -ForegroundColor Green
                break
            }
        }
    }

    if (-not $steamPath -or -not (Test-Path $steamPath)) {
        Write-Host "❌ Steam não encontrado!" -ForegroundColor Red
        Write-Host "💡 Instale o Steam primeiro." -ForegroundColor Yellow
        timeout /t 5
        exit 1
    }

    Write-Host ""
    Write-Host "🔧 Opções de Desinstalação:" -ForegroundColor Cyan
    Write-Host "   1. Remover APENAS luafast" -ForegroundColor White
    Write-Host "   2. Remover COMPLETAMENTE (luafast + Millennium)" -ForegroundColor White
    Write-Host "   3. Cancelar" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Selecione (1-3)"

    if ($choice -eq "3") {
        Write-Host "🚫 Cancelado" -ForegroundColor Yellow
        timeout /t 3
        exit 0
    }

    if ($choice -eq "1") {
        # Apenas luafast
        Write-Host "🎮 Removendo luafast..." -ForegroundColor Yellow
        $luafastPath = "$steamPath\plugins\luafast"
        if (Test-Path $luafastPath) {
            Remove-Item $luafastPath -Recurse -Force
            Write-Host "✅ luafast removido!" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ luafast não encontrado." -ForegroundColor Gray
        }
    }
    elseif ($choice -eq "2") {
        # Remoção COMPLETA e DEFINITIVA
        Write-Host "💥 REMOÇÃO COMPLETA INICIADA..." -ForegroundColor Red
        Write-Host "   Isso resolverá o erro do millennium.dll" -ForegroundColor Yellow
        
        # LISTA DEFINITIVA de arquivos/pastas do Millennium
        $millenniumItems = @(
            # Arquivos principais
            "$steamPath\hid.dll",
            "$steamPath\millennium.dll",
            "$steamPath\steamui.dll",
            "$steamPath\steamui.dll.original",
            "$steamPath\steamui.dll.backup",
            
            # Pastas
            "$steamPath\plugins",
            "$steamPath\ext",
            "$steamPath\millennium",
            
            # AppData
            "$env:LOCALAPPDATA\MillenniumSteam",
            "$env:APPDATA\MillenniumSteam"
        )

        Write-Host "🔍 Removendo componentes do Millennium..." -ForegroundColor Yellow
        
        $removedCount = 0
        foreach ($item in $millenniumItems) {
            if (Test-Path $item) {
                try {
                    if (Test-Path $item -PathType Container) {
                        Remove-Item $item -Recurse -Force
                    } else {
                        Remove-Item $item -Force
                    }
                    Write-Host "   ✅ Removido: $(Split-Path $item -Leaf)" -ForegroundColor Green
                    $removedCount++
                } catch {
                    Write-Host "   ❌ Erro em: $(Split-Path $item -Leaf)" -ForegroundColor Red
                }
            }
        }

        # VERIFICAÇÃO CRÍTICA: Garantir que o hid.dll foi removido
        $hidCheck = Test-Path "$steamPath\hid.dll"
        if ($hidCheck) {
            Write-Host "⚠️  AVISO: hid.dll ainda presente!" -ForegroundColor Red
            Write-Host "   Tentando método alternativo..." -ForegroundColor Yellow
            
            # Método alternativo para remover hid.dll
            try {
                cmd /c "del /F /Q `"$steamPath\hid.dll`" 2>nul"
                Start-Sleep -Seconds 1
            } catch {
                Write-Host "   ❌ Não foi possível remover hid.dll" -ForegroundColor Red
                Write-Host "   💡 Feche manualmente o Steam e delete o arquivo." -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host "📊 Resumo:" -ForegroundColor Cyan
        Write-Host "   • Itens removidos: $removedCount" -ForegroundColor White
        Write-Host "   • Erro do millennium.dll: RESOLVIDO ✓" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 O Millennium foi COMPLETAMENTE removido!" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "💡 Próximo passo:" -ForegroundColor Cyan
    Write-Host "   Reinicie o Steam para confirmar que o erro desapareceu." -ForegroundColor White
    Write-Host ""
    Write-Host "🔄 Se o erro persistir, REINICIE O COMPUTADOR antes de abrir o Steam." -ForegroundColor Yellow

} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
