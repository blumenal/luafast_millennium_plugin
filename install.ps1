# install.ps1 - Script de instalação automática para Millennium + luafast
# Repositório: https://github.com/blumenal/luafast_millennium_plugin

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 Instalador Automático luafast + Millennium" -ForegroundColor Cyan
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
    # Passo 1: Instalar Millennium
    Write-Host ""
    Write-Host "📥 Passo 1/2: Instalando Millennium..." -ForegroundColor Yellow
    Write-Host "   Isso pode levar alguns minutos..." -ForegroundColor Gray
    
    # Instalar Millennium
    $millenniumScript = Invoke-WebRequest -Uri "https://steambrew.app/install.ps1" -UseBasicParsing
    Invoke-Expression $millenniumScript.Content
    
    Write-Host "✅ Millennium instalado com sucesso!" -ForegroundColor Green
    
    # Aguardar instalação do Millennium
    Write-Host "   ⏳ Aguardando conclusão da instalação..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Passo 2: Instalar plugin luafast
    Write-Host ""
    Write-Host "🎮 Passo 2/2: Instalando plugin luafast..." -ForegroundColor Yellow
    
    # Definir caminhos
    $pluginsPath = "$env:LOCALAPPDATA\MillenniumSteam\plugins"
    $tempZip = "$env:TEMP\luafast_plugin.zip"
    $extractPath = "$env:TEMP\luafast_extract"
    
    # Criar diretório de plugins se não existir
    if (-not (Test-Path $pluginsPath)) {
        New-Item -ItemType Directory -Path $pluginsPath -Force
        Write-Host "📁 Diretório de plugins criado: $pluginsPath" -ForegroundColor Gray
    }
    
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
    
    # Mover arquivos para o diretório correto - MÉTODO CORRIGIDO
    $sourceDir = "$extractPath\luafast_millennium_plugin-main"
    $targetDir = "$pluginsPath\luafast"
    
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
    
    # Remover instalação anterior se existir - MÉTODO MAIS SEGURO
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
    
    # COPIAR ARQUIVOS INDIVIDUALMENTE - MÉTODO CORRIGIDO
    Write-Host "   📄 Copiando arquivos..." -ForegroundColor Gray
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
    
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
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
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
