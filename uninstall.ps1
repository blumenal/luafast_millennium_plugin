# uninstall.ps1 - Script de desinstalação para Millennium + luafast
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

# Define ANSI escape sequence for bold purple color
$BoldPurple = [char]27 + '[38;5;219m'
$BoldGreen = [char]27 + '[1;32m'
$BoldYellow = [char]27 + '[1;33m'
$BoldRed = [char]27 + '[1;31m'
$BoldGrey = [char]27 + '[1;30m'
$BoldLightBlue = [char]27 + '[38;5;75m'
$ResetColor = [char]27 + '[0m'

function Ask-Boolean-Question {
    param([bool]$newLine = $true, [string]$question, [bool]$default = $false)

    $choices = if ($default) { "[Y/n]" } else { "[y/N]" }
    $parsedQuestion = "${BoldPurple}::${ResetColor} $question $choices"
    $parsedQuestion = if ($newLine) { "`n$parsedQuestion" } else { $parsedQuestion }

    $choice = Read-Host "$parsedQuestion"

    if ($choice -eq "") {
        $choice = if ($default) { "y" } else { "n" }
    }

    if ($choice -eq "y" -or $choice -eq "yes") {
        $choice = "Yes"
    }
    else {
        $choice = "No"
    }

    [Console]::CursorTop -= if ($newLine) { 2 } else { 1 }
    [Console]::SetCursorPosition(0, [Console]::CursorTop)
    [Console]::Write(' ' * [Console]::WindowWidth)
    Write-Host "`r${parsedQuestion}: ${BoldLightBlue}$choice${ResetColor}"

    return $(if ($choice -eq "yes") { $true } else { $false })
}

function Close-SteamProcess {
    $steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue

    if ($steamProcess) {
        Stop-Process -Name "steam" -Force
        Write-Output "${BoldPurple}[+]${ResetColor} Closed Steam process."
    }
}

function ConvertTo-ReadableSize {
    param([int64]$size)
    
    if ($size -eq 0) {
        return "0 Bytes"
    }

    $units = @("Bytes", "KiB", "MiB", "GiB")
    $index = [Math]::Floor([Math]::Log($size, 1024))
    $sizeFormatted = [Math]::Round($size / [Math]::Pow(1024, $index), 2, [MidpointRounding]::AwayFromZero)
    
    return "$sizeFormatted $($units[$index])"
}

function Get-FileSize {
    param ($relativePath)
    $totalSize = 0

    $absolutePath = Join-Path -Path $steamPath -ChildPath $relativePath

    if (Test-Path $absolutePath -PathType Leaf) {
        $fileSize = (Get-Item $absolutePath).Length
        $totalSize += $fileSize
    }

    return $totalSize
}

function Get-FolderSize {
    param ([Parameter(Mandatory = $true)] [string]$FolderPath)

    $totalSize = 0
    $absolutePath = Join-Path -Path $steamPath -ChildPath $FolderPath

    if (-not (Test-Path -Path $absolutePath -PathType Container)) {
        return 0
    }

    $files = Get-ChildItem -Path $absolutePath -File -Recurse -Force

    foreach ($file in $files) {
        $totalSize += $file.Length
    }
    return $totalSize
}

function ContentIsDirectory {
    param ([string]$path)
    return (Test-Path -Path (Join-Path -Path $steamPath -ChildPath $path) -PathType Container)
}

function DynamicSizeCalculator {
    param ($value)

    $totalSize = 0

    if ($value -is [System.Object[]]) {

        for ($i = 0; $i -lt $value.Length; $i += 1) {

            $isDirectory = ContentIsDirectory -path $value[$i]
            if ($isDirectory) {
                $totalSize += Get-FolderSize -FolderPath $value[$i]
            }
            else {
                $totalSize += Get-FileSize -relativePath $value[$i]
            }
        }
        
    }
    else { 
        $isDirectory = ContentIsDirectory -path $value
        if ($isDirectory) {
            $totalSize += Get-FolderSize -FolderPath $value
        }
        else {
            $totalSize += Get-FileSize -relativePath $value
        }
    }
    return $totalSize
}

function PrettyPrintSizeOnDisk {
    param ([Parameter(Mandatory = $true)] [object[]]$targetPath)

    $totalSize = 0
    $index = 0

    for ($i = 0; $i -lt $targetPath.Length; $i += 2) {
        $index++
        $key = $targetPath[$i]
        $value = $targetPath[$i + 1]

        $size = DynamicSizeCalculator -value $value
        $totalSize += $size

        if ($size -eq 0) {
            $strSize = "0 Bytes"
        }
        else {
            $strSize = ConvertTo-ReadableSize -size $size
        }
        Write-Output "${BoldGrey}++${ResetColor} [$index] ${BoldPurple}$($key.PadRight(15))${ResetColor} $($strSize.PadLeft(10))"
    }

    $global:globalInitialSize = $totalSize
    Write-Output "`n${BoldPurple}::${ResetColor} Current Install Size: $(ConvertTo-ReadableSize -size $totalSize)"
}

function Uninstall-Millennium {
    Write-Host "`n${BoldPurple}::${ResetColor} Iniciando desinstalação do Millennium..." -ForegroundColor Cyan

    # Path to installed files
    $jsonFilePath = Join-Path -Path $steamPath -ChildPath "/ext/data/logs/installer.log"

    # test if file exists
    if (-not (Test-Path -Path $jsonFilePath)) {
        Write-Host "${BoldRed}[!]${ResetColor} Millennium installation log not found. It may have been already uninstalled." -ForegroundColor Yellow
        return
    }

    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json

    Write-Host "${BoldPurple}::${ResetColor} Reading package database...`n"

    $assets = @(
        "Millennium", @("user32.dll", "python311.dll", "millennium.dll")
        "Core Modules", "ext/data/assets"
        "Python Cache", "ext/data/cache"
        "User Plugins", "plugins"
        "User Themes", "steamui/skins"
    )

    PrettyPrintSizeOnDisk -targetPath $assets
    $packageList = (1..($assets.Length / 2)) -join ''

    $result = Read-Host "${BoldPurple}::${ResetColor} Enter a numerical list of packages to uninstall [default=$packageList]"

    if (-not $result) {
        $result = $packageList
    }

    $selectedPackages = ($result.ToCharArray() | Select-Object -Unique) | ForEach-Object { $assets[($_ - 48) * 2 - 2] }
    $selectedPackagesPath = ($result.ToCharArray() | Select-Object -Unique) | ForEach-Object { $assets[($_ - 48) * 2 - 1] }

    $purgedAssetsSize = DynamicSizeCalculator -value $selectedPackagesPath
    $selectedPackages = $selectedPackages -join ", "

    $strReclaimedSize = ConvertTo-ReadableSize -size $purgedAssetsSize
    $strRemainingSize = ConvertTo-ReadableSize -size ($global:globalInitialSize - $purgedAssetsSize)

    Write-Host "`n${BoldPurple}++${ResetColor} Purging Packages: [${BoldRed}$selectedPackages${ResetColor}]`n"

    Write-Host " Total Removed Size:    $($strReclaimedSize.PadLeft(10))"
    Write-Host " Total Remaining Size:  $($strRemainingSize.PadLeft(10))`n"

    $result = Ask-Boolean-Question -question "Proceed with PERMANENT removal of selected packages?" -default $true -newLine $false

    if (-not $result) {
        Write-Output "${BoldPurple}[+]${ResetColor} Removal aborted."
        return
    }

    $deletionSuccess = $true

    $selectedPackagesPath | ForEach-Object {

        $isDirectory = ContentIsDirectory -path $_

        if ($_ -match "user32.dll") {
            $cefRemoteDebugging = Join-Path -Path $steamPath -ChildPath ".cef-enable-remote-debugging"

            if (Test-Path -Path $cefRemoteDebugging) {
                Remove-Item -Path $cefRemoteDebugging -Force -ErrorAction SilentlyContinue
            }
        }

        $absolutePath = Join-Path -Path $steamPath -ChildPath $_

        Remove-Item -Path $absolutePath -Recurse -Force -ErrorAction SilentlyContinue

        if (-not $?) {
            $global:deletionSuccess = $false
            Write-Host "${BoldRed}[!]${ResetColor} Failed to remove: $absolutePath" -ForegroundColor Red
        }
    }

    if ($deletionSuccess) {
        Write-Host "${BoldGreen}++${ResetColor} Successfully removed selected packages." -ForegroundColor Green
    }
    else {
        Write-Host "${BoldRed}[!]${ResetColor} Some deletions failed. Please manually remove the remaining files." -ForegroundColor Red
    }
}

# ==================================================
# MAIN DESINSTALADOR SCRIPT
# ==================================================

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
    Close-SteamProcess

    # Obter caminho do Steam
    Write-Host ""
    Write-Host "🔍 Localizando instalação do Steam..." -ForegroundColor Yellow
    
    $customSteamPath = Read-Host "${BoldPurple}[?]${ResetColor} Steam Path (leave blank for default)"

    if (-not $customSteamPath) {
        $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

        if (-not $steamPath) {
            $steamPath = "C:\Program Files (x86)\Steam"
            Write-Host "${BoldYellow}[!]${ResetColor} Steam path not found in registry, using default: $steamPath" -ForegroundColor Yellow
        } else {
            [Console]::CursorTop -= 1
            [Console]::SetCursorPosition(0, [Console]::CursorTop)
            [Console]::Write(' ' * [Console]::WindowWidth)
            Write-Output "`r${BoldPurple}[?]${ResetColor} Steam Path (leave blank for default): ${BoldLightBlue}$steamPath${ResetColor}"
        }
    } else {
        $steamPath = $customSteamPath
    }

    if (-not (Test-Path -Path $steamPath)) {
        Write-Host "${BoldRed}[!]${ResetColor} Steam path not found: $steamPath" -ForegroundColor Red
        throw "Steam path not found"
    }

    Write-Host "${BoldGreen}[+]${ResetColor} Steam encontrado em: $steamPath" -ForegroundColor Green

    # Caminhos de instalação do luafast
    $pluginPath = "$steamPath\plugins\luafast"
    $hidDllPath = "$steamPath\hid.dll"

    Write-Host ""
    Write-Host "📁 Removendo plugin luafast..." -ForegroundColor Yellow

    # Remover plugin luafast
    if (Test-Path $pluginPath) {
        Write-Host "   🗑️ Removendo plugin luafast..." -ForegroundColor Gray
        
        $luafastSize = Get-FolderSize -FolderPath "plugins\luafast"
        $luafastSizeStr = ConvertTo-ReadableSize -size $luafastSize
        
        try {
            Remove-Item $pluginPath -Recurse -Force -ErrorAction Stop
            Write-Host "   ✅ Plugin luafast removido: $pluginPath ($luafastSizeStr)" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Aviso: Não foi possível remover completamente o plugin: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ℹ️ Plugin luafast não encontrado: $pluginPath" -ForegroundColor Gray
    }

    # Remover hid.dll (com verificação de segurança)
    if (Test-Path $hidDllPath) {
        Write-Host "   🗑️ Removendo hid.dll..." -ForegroundColor Gray
        
        $hidSize = Get-FileSize -relativePath "hid.dll"
        $hidSizeStr = ConvertTo-ReadableSize -size $hidSize
        
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
            Write-Host "   ✅ hid.dll removida: $hidDllPath ($hidSizeStr)" -ForegroundColor Green
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

    # Desinstalar Millennium
    Write-Host ""
    $choice = Read-Host "${BoldPurple}::${ResetColor} Deseja desinstalar o Millennium também? (S/N)"
    if ($choice -eq 'S' -or $choice -eq 's') {
        Uninstall-Millennium
    }

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "✅ Desinstalação concluída com sucesso!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Próximos passos:" -ForegroundColor Yellow
    Write-Host "   1. Reinicie o Steam para aplicar as mudanças" -ForegroundColor White
    Write-Host "   2. O plugin luafast foi completamente removido" -ForegroundColor White
    if (Test-Path "$hidDllPath.backup") {
        Write-Host "   3. Backup da hid.dll disponível em: $hidDllPath.backup" -ForegroundColor White
    }
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
