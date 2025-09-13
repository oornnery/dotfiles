# 🏠 Modern Dotfiles - Instalador CLI Inteligente

[![Python 3.13](https://img.shields.io/badge/python-3.13-blue.svg)](https://python.org)
[![uv](https://img.shields.io/badge/package%20manager-uv-green.svg)](https://github.com/astral-sh/uv)
[![Rich Terminal UI](https://img.shields.io/badge/ui-rich-yellow.svg)](https://github.com/Textualize/rich)
[![Typer CLI](https://img.shields.io/badge/cli-typer-purple.svg)](https://typer.tiangolo.com)

Sistema de dotfiles unificado com instalador CLI moderno usando **Python 3.13**, **uv/uvx** para gerenciamento de pacotes, **Rich** para interface terminal e suporte inteligente para múltiplos sistemas operacionais e window managers.

## 🚀 Instalação Rápida

### Pré-requisitos
- Python 3.13+
- Git
- curl/wget

### Instalação em Uma Linha
```bash
git clone https://github.com/seu-usuario/dotfiles ~/.dotfiles
cd ~/.dotfiles
python install_cli.py install
```

### Modos de Instalação
```bash
# Instalação completa (recomendado)
python install_cli.py install --mode full

# Apenas configurações (sem pacotes do sistema)
python install_cli.py install --mode config-only

# Apenas ferramentas Python de desenvolvimento
python install_cli.py install --mode python-dev

# Apenas configurações de shell (ZSH)
python install_cli.py install --mode shell-setup

# Instalação forçada (sem confirmações)
python install_cli.py install --force

# Pular instalação de pacotes do sistema
python install_cli.py install --skip-system
```

## 🛠️ CLI Moderno

### Comandos Disponíveis

#### Status do Sistema
```bash
# Verificar sistema detectado e ferramentas instaladas
python install_cli.py status
```

#### Backup
```bash
# Criar backup das configurações atuais
python install_cli.py backup
```

#### Atualização
```bash
# Atualizar dotfiles e reinstalar configurações
python install_cli.py update
```

#### Logs
```bash
# Visualizar logs recentes de instalação
python install_cli.py logs
```

#### Ajuda
```bash
# Ver todos os comandos disponíveis
python install_cli.py --help

# Ajuda de comando específico
python install_cli.py install --help
```

## 🎯 Detecção Inteligente

O sistema detecta automaticamente:

### Sistemas Operacionais Suportados
- **Arch Linux** (incluindo Manjaro, EndeavourOS)
- **Debian/Ubuntu** (incluindo Pop!_OS, Linux Mint)
- **NixOS**
- **Windows 11** (PowerShell)

### Window Managers Suportados
- **i3/i3-gaps** - Tiling window manager clássico
- **Sway** - Compositor Wayland compatível com i3
- **Hyprland** - Compositor Wayland moderno com animações
- **Qtile** - Window manager configurável em Python
- **GNOME** - Desktop environment popular
- **XFCE** - Desktop environment leve

### Ferramentas Python Incluídas
Instaladas automaticamente via **uvx**:
- **black** - Formatador de código
- **isort** - Organizador de imports
- **mypy** - Type checker
- **pytest** - Framework de testes
- **poetry** - Gerenciador de dependências
- **pre-commit** - Git hooks
- **ruff** - Linter e formatador rápido

## 📁 Estrutura do Projeto

```
dotfiles/
├── install_cli.py          # 🎯 CLI principal moderno
├── mcp/                    # 🤖 Model Context Protocol
│   ├── claude-desktop.json    # Configuração completa MCP
│   ├── claude-dev.json        # Configuração para desenvolvimento
│   ├── claude-research.json   # Configuração para pesquisa
│   ├── mcp_manager.py         # CLI para gerenciar MCP servers
│   ├── .env-example           # Variáveis de ambiente
│   └── README.md              # Documentação MCP
├── utils/                  # 🔧 Utilitários e logging
│   ├── logger.py              # Sistema de logging avançado
│   ├── backup.py              # Utilitários de backup
│   └── utils.py               # Funções auxiliares
├── setup/                  # 📦 Scripts de instalação por OS
│   ├── linux/
│   │   ├── arch/install.sh
│   │   ├── debian/install.sh
│   │   └── nixos/configuration.nix
│   └── windows/install.ps1
├── wm/                     # 🪟 Configurações Window Managers
│   ├── i3/
│   ├── sway/
│   ├── hyprland/
│   ├── qtile/
│   ├── gnome/
│   └── xfce/
├── shells/                 # 🐚 Configurações de shells
│   ├── zsh/
│   │   ├── .zshrc
│   │   ├── plugins/
│   │   └── scripts/
│   └── bash/
├── home/                   # 🏠 Configurações pessoais
│   ├── .config/
│   │   ├── nvim/
│   │   ├── git/
│   │   └── rofi/
│   └── scripts/
├── rofi/                   # 🎨 Scripts Rofi modernos
│   └── scripts/
│       ├── launcher.sh
│       ├── powermenu.sh
│       ├── screenshot.sh
│       └── workspace-manager.sh
└── docker/                 # 🐳 Configurações Docker
    └── docker-compose/
```## 🤖 MCP (Model Context Protocol)

Sistema completo para integração com Claude Desktop e outros clientes MCP:

### Configurações Disponíveis
- **claude-desktop.json** - Configuração completa com todos os servidores MCP
- **claude-dev.json** - Focado em desenvolvimento (filesystem, git, database)
- **claude-research.json** - Focado em pesquisa (web scraping, fetch, brave)

### Gerenciamento MCP
```bash
# Gerenciar servidores MCP
python mcp/mcp_manager.py --help

# Instalar servidor MCP específico
python mcp/mcp_manager.py install filesystem

# Listar servidores disponíveis
python mcp/mcp_manager.py list

# Verificar status
python mcp/mcp_manager.py status
```

## 🎨 Scripts Rofi Modernos

### Launcher Inteligente (`rofi/scripts/launcher.sh`)
- Auto-detecta terminal e file manager
- Comandos de desenvolvimento Python integrados
- Notificações visuais
- Suporte para aplicações desktop

### Power Menu (`rofi/scripts/powermenu.sh`)
- Auto-detecta window manager ativo
- Opções completas: shutdown, reboot, suspend, hibernate, logout, lock
- Interface com emojis

### Screenshot Tool (`rofi/scripts/screenshot.sh`)
- Múltiplos modos: área, janela, tela completa
- Auto-save em ~/Pictures/Screenshots/
- Suporte Wayland (grim+slurp) e X11 (scrot)

### Workspace Manager (`rofi/scripts/workspace-manager.sh`)
- Navegação rápida entre workspaces
- Suporte multi-WM (i3, Sway, Hyprland)
- Visualização de status

## 🔧 Configurações por Window Manager

### i3/i3-gaps
- Configuração otimizada com gaps
- Integração com polybar
- Scripts de automação incluídos
- Teclas de atalho modernas

### Sway
- Versão Wayland do i3
- Suporte completo para HiDPI
- Scripts Wayland-nativos

### Hyprland
- Animações suaves configuradas
- Configuração de performance otimizada
- Integração com waybar

### Qtile
- Configuração Python avançada
- Layouts inteligentes
- Widgets customizados

## 📊 Sistema de Logging

O sistema inclui logging avançado com:
- **Logs coloridos** no terminal via Rich
- **Arquivo de log** detalhado em `~/.local/log/dotfiles/`
- **Tracking de comandos** executados
- **Métricas de instalação** (tempo, erros, sucessos)
- **Backup automático** de configurações

### Visualizar Logs
```bash
# Logs recentes no terminal
python install_cli.py logs

# Arquivo de log completo
cat ~/.local/log/dotfiles/dotfiles_installer_$(date +%Y%m%d).log
```

## 🔄 Manutenção

### Backup Automático
```bash
# Criar backup das configurações atuais
python install_cli.py backup
```

### Atualização
```bash
# Atualizar repositório e reinstalar
python install_cli.py update
```

### Scripts de Manutenção
```bash
# Limpeza e atualizações do sistema
./maintenance.sh

# Verificação de integridade
python utils/backup.py --check
```

## 🎯 Casos de Uso

### Desenvolvedor Python
```bash
# Instalar apenas ferramentas de desenvolvimento
python install_cli.py install --mode python-dev

# Inclui: black, isort, mypy, pytest, poetry, pre-commit, ruff
```

### Usuário Desktop
```bash
# Instalação completa com window manager
python install_cli.py install --mode full

# Detecta e configura automaticamente o WM ativo
```

### Servidor/Headless
```bash
# Apenas configurações de shell e utilitários
python install_cli.py install --mode shell-setup --skip-system
```

### Configuração Rápida
```bash
# Apenas aplicar configurações (sem instalar pacotes)
python install_cli.py install --mode config-only --force
```

## 🔍 Troubleshooting

### Problemas Comuns

#### uv não encontrado
```bash
# Instalar uv manualmente
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### Permissões de symlink
```bash
# Executar com sudo se necessário para criar symlinks
sudo python install_cli.py install --mode config-only
```

#### Window manager não detectado
```bash
# Verificar detecção do sistema
python install_cli.py status

# Configurar manualmente
export XDG_CURRENT_DESKTOP=i3
python install_cli.py install
```

### Logs de Debug
```bash
# Ver logs detalhados
python install_cli.py logs

# Arquivo de log completo
tail -f ~/.local/log/dotfiles/dotfiles_installer_$(date +%Y%m%d).log
```

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### Estrutura de Commits
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Atualização de documentação
- `style:` Formatação de código
- `refactor:` Refatoração de código
- `test:` Adição/correção de testes

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Dotfiles modernos com instalação inteligente e interface rica!** 🚀

Para mais informações, consulte:
- [Documentação MCP](mcp/README.md)
- [Status da Refatoração](setup/trash/REFACTOR_STATUS.md)
- [Scripts Específicos](docs/)
