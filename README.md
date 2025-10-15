🚀 luafast - Millennium Plugin

Desbloqueie uma nova dimensão de jogos na Steam! 
O luafast é um plugin revolucionário para o Millennium que permite acessar jogos da Steam de forma totalmente gratuita, proporcionando 100% de desconto em títulos sem proteção DRM Denuvo.

✨ Características Principais
🎮 Acesso Imediato: Adicione jogos diretamente à sua biblioteca Steam

💰 100% Gratuito: Sem custos, sem mensalidades, sem limitações

🔒 Modo Local: Jogos permanecem na sua conta em modo local

🔄 Fácil Gerenciamento: Adicione e remova jogos com um clique

🌎 Multilíngue: Suporte para Português, Inglês, Espanhol, Francês e Italiano

📋 Requisitos
Windows 10/11

Steam instalado

Millennium Steam Patcher

🛠 Instalação Completa (Millennium + luafast)
Método 1: Instalação Automática (Recomendado)
Execute o seguinte comando no PowerShell como Administrador:

powershell
# Instala o Millennium e o plugin luafast automaticamente
irm "https://raw.githubusercontent.com/blumenal/luafast_millennium_plugin/main/install.ps1" | iex

Método 2: Instalação Manual
Passo 1: Instalar o Millennium

powershell
# Execute no PowerShell como Administrador
iwr -useb "https://steambrew.app/install.ps1" | iex

Passo 2: Instalar o Plugin luafast

powershell
# Baixe e instale o plugin luafast
$pluginUrl = "https://github.com/blumenal/luafast_millennium_plugin/archive/refs/heads/main.zip"
$pluginsPath = "$env:LOCALAPPDATA\MillenniumSteam\plugins"
iwr -Uri $pluginUrl -OutFile "$env:TEMP\luafast.zip"
Expand-Archive -Path "$env:TEMP\luafast.zip" -DestinationPath "$pluginsPath\luafast" -Force
Remove-Item "$env:TEMP\luafast.zip"

🎯 Como Usar
Abra o Steam com o Millennium instalado

Navegue até a página do jogo desejado na Steam Store

Clique no botão "Pegar Emprestado" que aparecerá na página de compra

Aguarde o processo de download e instalação automática

Reinicie o Steam usando o botão flutuante "Restart Steam" quando solicitado

Aproveite seu jogo na biblioteca!

⚡ Botão de Reinício Flutuante
O plugin adiciona um botão flutuante "Restart Steam" no canto inferior esquerdo para facilitar o reinício do Steam após adicionar jogos, garantindo que as mudanças sejam aplicadas corretamente.

🔧 Funcionalidades Técnicas
Sistema de Download Multi-fonte

Sem necissidade de ter o Steam Tools isntalado

Interface Integrada: Botões nativos na interface da Steam

Monitoramento em Tempo Real: Acompanhamento do progresso de download

Gerenciamento de Biblioteca: Adicione e remova jogos facilmente

Atualizações Automáticas: Sistema de repositórios atualizável

🐛 Solução de Problemas
O botão não aparece?
Verifique se o Millennium está instalado corretamente

Certifique-se de estar na página de um jogo específico (URL /app/...)

Reinicie o Steam

Download falha?
Verifique sua conexão com a internet

O jogo pode ter proteção Denuvo (não suportado)

Tente reiniciar o Steam e tentar novamente

Jogo não aparece na biblioteca?
Use o botão "Restart Steam" para aplicar as mudanças

Verifique se o download foi concluído com sucesso

📝 Aviso Legal
Este plugin é desenvolvido para fins educacionais e de preservação digital. O uso do plugin é de responsabilidade do usuário final. Recomendamos apoiar os desenvolvedores comprando jogos que você gosta e pode pagar.

🤝 Contribuição
Contribuições são bem-vindas! Sinta-se à vontade para:

Reportar bugs e issues

Sugerir novas funcionalidades

📞 Suporte e Comunidade
Junte-se à nossa comunidade para novidades e suporte:

Grupo do Telegram: https://t.me/luafaststeamgames

Repositório: https://github.com/blumenal/luafast_millennium_plugin

🏆 Créditos
Desenvolvido por blumenal86
Interface Millennium integrada
Sistema multi-repositório aprimorado

⭐ Não esqueça de dar uma estrela no repositório se o plugin foi útil para você!

*Atualizado para v0.1.0 - Sistema estável e confiável*
