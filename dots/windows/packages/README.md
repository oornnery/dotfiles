# Windows Package Collections

Este diretório contém coleções organizadas de pacotes Windows gerenciados via WinGet/UniGetUI.

## 📁 Estrutura de Arquivos

Cada arquivo JSON representa uma categoria específica de software:

### `minimal.json` - Essenciais do Sistema
Ferramentas fundamentais que devem estar em qualquer instalação:
- **7-Zip** - Compactador de arquivos
- **UniGetUI** - Gerenciador de pacotes gráfico
- **Windows Terminal** - Terminal moderno
- **PowerShell** - Shell avançado
- **PowerToys** - Utilitários Microsoft
- **ripgrep** - Busca rápida em texto
- **Git** - Controle de versão essencial

**Uso:** Instalação inicial de sistema limpo

### `system-advanced.json` - Ferramentas Avançadas do Sistema
Customização e otimização avançada do Windows:
- **WinScript** - Scripts de otimização
- **Microsoft PC Manager** - Gerenciador de PC
- **Wintoys** - Tweaks e customização
- **Oh My Posh** - Customização de prompt
- **MSYS2** - Ambiente Unix-like
- **Windhawk** - Customização de UI do Windows

**Uso:** Após configuração básica, para usuários que querem personalização profunda

### `dev.json` - Desenvolvimento e IA
Ambiente completo de desenvolvimento e ferramentas de IA:

**Infraestrutura:**
- WSL, Docker Desktop, usbipd

**Editores:**
- Neovim, Zed

**Linguagens e Runtimes:**
- Python 3.14 + uv
- Rust (rustup)
- Go
- Node.js + Bun

**Ferramentas:**
- GitHub CLI, Wireshark

**IA e ML:**
- Ollama
- LM Studio
- ComfyUI Desktop
- Onlook
- Perplexity Comet

**Uso:** Desenvolvedores e usuários de ferramentas de IA

### `productivity.json` - Produtividade e Documentos
Apps para notas, documentos e organização:
- **Notion** - Workspace colaborativo
- **Anki** - Flashcards e memorização
- **Obsidian** - Notas em Markdown
- **MarkText** - Editor Markdown
- **LibreOffice** - Suite de escritório

**Uso:** Estudantes, pesquisadores, criadores de conteúdo

### `games.json` - Jogos e Streaming
Plataformas de jogos e ferramentas relacionadas:

**Launchers:**
- Minecraft, Epic Games, EA Desktop, Steam

**Ferramentas:**
- Blitz (League analytics)
- CurseForge (mods)
- DS4Windows (controle PlayStation)
- Discord
- OBS Studio
- qBittorrent

**Jogos:**
- League of Legends (Live + PBE)

**Uso:** Gaming e streaming

### `web.json` - Web e Segurança
Navegadores, segurança e serviços online:

**Browsers:**
- Zen Browser
- Microsoft Edge

**Segurança:**
- Bitwarden (gerenciador de senhas)

**Proton Suite:**
- Proton Authenticator
- Proton Drive
- Proton Mail + Bridge
- Proton Pass
- Proton VPN

**Mídia:**
- Spotify

**Uso:** Navegação segura e privacidade

### `runtimes.json` - Bibliotecas Runtime
Todos os Visual C++ Redistributables necessários para compatibilidade:
- VCRedist 2005-2022 (x86, x64, ARM64)

**Uso:** Instalação automática para compatibilidade com aplicativos e jogos

## 🚀 Como Usar

### Método 1: Script PowerShell Automatizado (Recomendado)

O script `install-packages.ps1` facilita a instalação por categorias:

```powershell
# Ver o que será instalado (dry-run)
.\install-packages.ps1 -Category minimal -DryRun

# Instalar apenas pacotes mínimos
.\install-packages.ps1 -Category minimal

# Instalar múltiplas categorias
.\install-packages.ps1 -Category minimal,dev,runtimes

# Instalar tudo
.\install-packages.ps1 -Category all

# Modo interativo (pede confirmação)
.\install-packages.ps1 -Category dev -Interactive

# Pular upgrades (só instalar novos)
.\install-packages.ps1 -Category all -SkipUpgrade
```

**Features do script:**
- ✓ Instalação automática por categoria
- ✓ Verificação de pacotes já instalados
- ✓ Atualização automática de pacotes existentes
- ✓ Modo dry-run para preview
- ✓ Relatório detalhado de sucessos/falhas
- ✓ Ordenação por prioridade de instalação
- ✓ Interface colorida e informativa

### Método 2: UniGetUI (Interface Gráfica)

1. Abra o UniGetUI
2. Vá em **Packages** → **Import packages from file**
3. Selecione o(s) arquivo(s) JSON desejado(s)
4. Clique em **Install**

### Método 3: PowerShell Manual

Para instalar todos os pacotes de uma categoria manualmente:

```powershell
# Exemplo: instalar minimal
$packages = Get-Content .\minimal.json | ConvertFrom-Json
foreach ($pkg in $packages.packages) {
    winget install --id $pkg.Id --silent --accept-package-agreements --accept-source-agreements
}
```</parameter>
```

### Combinações Recomendadas

**Setup Mínimo (novo PC):**
```
minimal.json + runtimes.json
```

**Developer Full:**
```
minimal.json + dev.json + runtimes.json + web.json
```

**Gaming Setup:**
```
minimal.json + games.json + runtimes.json + web.json
```

**Produtividade:**
```
minimal.json + productivity.json + web.json + runtimes.json
```

**Power User Completo:**
```
Todos os arquivos
```

## 📝 Manutenção

### Atualizar packages.txt

O arquivo `packages.txt` serve como fonte de verdade em formato texto simples. Atualize-o primeiro, depois regenere os JSONs.

### Gerar/Atualizar JSONs

Use o comando comentado no `packages.txt` para descobrir novos pacotes:

```powershell
# Exemplo para VCRedist
winget search --id Microsoft.VCRedist | rg -o 'Microsoft\.VCRedist\.[^\s]+'

# Exemplo para Proton
winget search Proton.Proton | rg -o 'Proton\.Proton\S+'
```

### Estrutura JSON

Cada pacote segue este formato:

```json
{
    "Id": "Publisher.PackageName",
    "Name": "Display Name",
    "Source": "winget",
    "ManagerName": "Winget"
}
```

## 🔄 Workflow

1. **Descobrir** novos pacotes via `winget search`
2. **Adicionar** ao `packages.txt` com comentários de categoria
3. **Atualizar** o JSON correspondente
4. **Testar** importação no UniGetUI
5. **Documentar** mudanças neste README se necessário

## ⚙️ Configuração

### Ordem de Instalação Recomendada

1. `minimal.json` - Base do sistema
2. `runtimes.json` - Compatibilidade
3. Categoria principal (dev/games/productivity)
4. `web.json` - Browsers e segurança
5. `system-advanced.json` - Customização final

### Pós-Instalação

Alguns pacotes requerem configuração adicional:
- **WSL**: `wsl --install -d Debian`
- **Docker**: Login e configuração de recursos
- **Git**: `git config --global user.name/email`
- **Oh My Posh**: Configurar tema no perfil do PowerShell
- **uv**: Gerenciador de pacotes Python (substituir pip)

## 📌 Notas

- Todos os pacotes usam o source **winget**
- Os IDs com números (ex: `9PM860492SZD`) são da Microsoft Store
- Pacotes comentados no `.txt` foram removidos mas podem ser reativados
- O arquivo `packages.json` original contém TODOS os pacotes (gerado por export do UniGetUI)

## 🔗 Links Úteis

- [WinGet Documentation](https://learn.microsoft.com/windows/package-manager/)
- [UniGetUI GitHub](https://github.com/marticliment/UniGetUI)
- [WinGet Packages](https://winget.run/)