# dotfiles

Coleção dos meus dotfiles, scripts de provisionamento e anotações para manter ambientes pessoais e de trabalho replicáveis em Linux, Windows e contêineres auto-hospedados.

## Panorama rápido

- **Editor**: Neovim (LazyVim / Tokyonight) com tmux.
- **Shell**: Zsh + Oh My Zsh, gerenciador de pacotes AUR `paru` e utilitários CLI (`fzf`, `ripgrep`, `eza`, `bat`, etc.).
- **Terminal**: Alacritty, multiplexado com tmux.
- **Gerenciadores de janelas**: foco em Hyprland e i3; inclui notas para outros WM em `docs/window-managers.md`.
- **Fontes e UI**: Nerd Fonts, temas compatíveis Wayland/X11, Flintshot, Thunar.
- **Stacks adicionais**: Docker/Compose, VirtualBox/QEMU/libvirt, suporte a ferramentas de IA (Ollama), linguagem com foco em Python, Go, Rust, Zig e Node.js.

## Estrutura do repositório

- `dots/linux/`
  - `arch/`: scripts de instalação completa (`install.sh`, `maintenance.sh`, `quick-setup.sh`) e módulos de pós-instalação para desktop, desenvolvimento, jogos e shell.
  - `debian/`: playbooks básicos (`install.sh`, `packages.yaml`) para Debian/Ubuntu.
  - `nixos/`: configuração declarativa (`configuration.nix`, `hardware-configuration.nix`).
  - `home/utils/`: utilitários Python e shell para backup, notificações, ajustes de resolução e gestão de pacotes (`backup.py`, `install_packages.py`, `paru-last-update.sh`, etc.).
  - `pkg-files/`: listas categorizadas de pacotes (base, dev, wayland, docker, python, zsh, etc.) usadas pelos scripts.
- `dots/windows/`: scripts PowerShell (`install.ps1`), lista de pacotes (`packages.yaml`), módulos e configurações do Windows Terminal.
- `docs/`: guias rápidos em Markdown para instalação de Docker, comandos Linux, setup Python e notas NixOS.
- `self-hosted/`: composições Docker para serviços pessoais (ex.: Firefly III), além de scripts auxiliares (`docker.sh`).
- `templates/`: reservado para skeletons futuros de configuração.
- `pyproject.toml`: metadado mínimo para os utilitários Python rodarem em `>=3.12`.

## Fluxos de provisionamento

- **Arch Linux** (`setup/linux/arch/install.sh`): instalação modular com logs coloridos, tratamento de privilégios `sudo` e suporte a `paru` para pacotes AUR. Inclui blocos opcionais para desenvolvimento, virtualização, IA, jogos e desktop.
- **Debian/Ubuntu** (`dots/linux/debian/`): script de bootstrap e lista YAML de pacotes para fácil manutenção.
- **NixOS** (`dots/linux/nixos/`): arquivos de configuração para ambientes declarativos com overlays customizados.
- **Windows** (`dots/windows/install.ps1`): automatiza instalação de apps, módulos PowerShell e ajustes de sistema.
- **Self-hosted** (`self-hosted/`): automação para stacks Docker, com ambientes `.env` versionados de forma segura via exemplos.

## Tecnologias em destaque

- **CLI & Shell**: Zsh, Oh My Zsh, tmux, fzf, fd, ripgrep, bat, lazygit.
- **Edição & Dev**: Neovim (LazyVim), Alacritty, Git + GitHub CLI, linguagens Python/Node/Rust/Go/Zig, ferramentas de virtualização e contêiner.
- **Desktop Linux**: Hyprland, i3, rofi, picom, nitrogen, dunst, Wayland/X11 utilitários.
- **Containers & IaC**: Docker, Docker Compose, Vagrant, Firefly III stack.
- **Automação Python**: scripts utilitários em `dots/linux/home/utils` com logging próprio.

## Como usar

1. **Clonar o repositório**: `git clone https://github.com/oornnery/dotfiles.git ~/dotfiles`.
2. **Selecionar o alvo**:
   - Arch Linux: executar `setup/linux/arch/install.sh` em uma sessão com `sudo` configurado.
   - Debian/Ubuntu: usar `dots/linux/debian/install.sh` ou converter a lista `packages.yaml` para seu gerenciador.
   - Windows: abrir PowerShell como administrador e rodar `dots/windows/install.ps1`.
   - NixOS: aplicar `dots/linux/nixos/configuration.nix` ao rebuild.
3. **Vincular dotfiles**: adaptar seus symlinks a partir da estrutura `dots/` ou usar os utilitários em `home/utils` para automatizar.

## Próximos passos

- Mapear e gerar symlinks automaticamente para cada ambiente.
- Criar interface TUI (provavelmente com Python + Textual) para escolher perfis de setup.
- Documentar checklist pós-instalação por distro.
