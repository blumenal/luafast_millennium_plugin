# uninstall.ps1 - Desinstalação SEGURA baseada no método oficial do Millennium
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🗑️  Desinstalador luafast - Método Oficial" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Verificar admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-NOT $isAdmin) {
    Write-Host "❌ Execute como Administrador!" -ForegroundColor Red
    exit 1
}

try {
    # Fechar Steam
    Write-Host "🛑 Fechando Steam..." -ForegroundColor Yellow
    Get-Process -Name "steam" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 3

    # Caminhos oficiais do Millennium
    $steamPath = "C:\Program Files (x86)\Steam"
    
    Write-Host ""
    Write-Host "🔧 Opções de Desinstalação:" -ForegroundColor Cyan
    Write-Host "   1. Remover apenas luafast" -ForegroundColor White
    Write-Host "   2. Remover luafast + Millennium (Método Oficial)" -ForegroundColor White
    Write-Host "   3. Cancelar" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Selecione (1-3)"
    
    if ($choice -eq "1") {
        # Apenas luafast
        $luafastPath = "$steamPath\plugins\luafast"
        if (Test-Path $luafastPath) {
            Remove-Item $luafastPath -Recurse -Force
            Write-Host "✅ luafast removido!" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ luafast não encontrado." -ForegroundColor Yellow
        }
    }
    elseif ($choice -eq "2") {
        # Método oficial completo
        Write-Host "🗑️  Removendo Millennium (método oficial)..." -ForegroundColor Yellow
        
        # 1. Remover hid.dll (arquivo principal do Millennium)
        $hidDll = "$steamPath\hid.dll"
        if (Test-Path $hidDll) {
            Remove-Item $hidDll -Force
            Write-Host "✅ hid.dll removida" -ForegroundColor Green
        }
        
        # 2. Remover pasta de plugins (inclui luafast e outros plugins)
        $pluginsPath = "$steamPath\plugins"
        if (Test-Path $pluginsPath) {
            Remove-Item $pluginsPath -Recurse -Force
            Write-Host "✅ Pasta plugins removida" -ForegroundColor Green
        }
        
        # 3. Remover pasta ext (extensões do Millennium)
        $extPath = "$steamPath\ext"
        if (Test-Path $extPath) {
            Remove-Item $extPath -Recurse -Force
            Write-Host "✅ Pasta ext removida" -ForegroundColor Green
        }
        
        Write-Host "✅ Millennium removido completamente!" -ForegroundColor Green
    }
    else {
        Write-Host "🚫 Operação cancelada" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "💡 Reinicie o Steam para aplicar as mudanças." -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
