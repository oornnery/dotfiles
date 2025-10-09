#! /bin/bash
set -euo pipefail

if [[ -t 1 ]]; then
  COLOR_BLUE="\033[1;34m"
  COLOR_GREEN="\033[1;32m"
  COLOR_YELLOW="\033[1;33m"
  COLOR_RED="\033[1;31m"
  COLOR_PURPLE="\033[1;35m"
  COLOR_RESET="\033[0m"
else
  COLOR_BLUE=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_PURPLE=""
  COLOR_RESET=""
fi

log_info() {
  echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
  echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $*"
}

log_warn() {
  echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*"
}

log_error() {
  echo -e "${COLOR_RED}[ERRO]${COLOR_RESET} $*" >&2
}

log_section() {
  echo -e "${COLOR_PURPLE}▶ $*${COLOR_RESET}"
}

AUR_USER="${SUDO_USER:-$USER}"

if [[ $EUID -eq 0 ]]; then
  if [[ -z ${SUDO_USER:-} ]]; then
    log_error "Execute este script como um usuário comum com sudo configurado."
    exit 1
  fi
  log_warn "Executando com privilégios elevados; tarefas AUR serão executadas como '$AUR_USER'."
fi

run_as_aur_user() {
  if [[ $USER == "$AUR_USER" ]]; then
    "$@"
  else
    sudo -u "$AUR_USER" "$@"
  fi
}

install_aur_packages() {
  if command -v paru &> /dev/null; then
    run_as_aur_user paru -S --needed --noconfirm "$@"
  else
    echo "Paru não está disponível; ignorando pacotes AUR: $*" >&2
  fi
}

# Update system
log_section "Atualizando o sistema"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel --noconfirm

setup_paru() {
  if ! command -v paru &> /dev/null; then
  log_info "Paru não encontrado, iniciando instalação..."
    local build_dir
    build_dir=$(mktemp -d "${TMPDIR:-/tmp}/paru-build-XXXXXX")
    if [[ $EUID -eq 0 ]]; then
      chown "$AUR_USER:$AUR_USER" "$build_dir"
    fi
    run_as_aur_user git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
    run_as_aur_user bash -lc "cd '$build_dir/paru' && makepkg -si --noconfirm"
    rm -rf "$build_dir"
    if ! command -v paru &> /dev/null; then
      log_error "Falha ao instalar o paru."
      exit 1
    fi
  else
    log_success "Paru já está instalado."
  fi
}

setup_shell_tools() {
  log_section "Instalando ferramentas de shell"
  # Install packages
  sudo pacman -S --needed --noconfirm \
    alacritty \
    unzip \
    git \
    wget \
    curl \
    neovim \
    zsh \
    eza \
    fzf \
    fd \
    thefuck \
    ripgrep \
    bat \
    openssh
  # Install TUI's
  sudo pacman -S --needed --noconfirm \
    htop \
    btop \
    bluetui
}

setup_dev() {
  log_section "Instalando ferramentas de desenvolvimento"
  # Install development packages
  sudo pacman -S --needed --noconfirm \
    git \
    github-cli \
    vagrant \
    python \
    nodejs \
    dino \
    yarn \
    npm \
    rust \
    go \
    lua \
    zig
}

setup_docker() {
  log_section "Instalando Docker e Docker Compose"
  # Install Docker and Docker Compose
  sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose

  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker "$USER"
}

setup_virtualization() {
  log_section "Instalando pacotes de virtualização"
  # Install virtualization packages
  sudo pacman -S --needed --noconfirm \
    virtualbox \
    virt-manager \
    qemu \
    libvirt \
    edk2-ovmf \
    gnome-boxes
}

setup_ai() {
  log_section "Instalando pacotes de IA"
  # Install AI packages
  sudo pacman -S --needed --noconfirm \
    ollama
}

setup_shell(){
  log_section "Configurando ZSH e Oh My Zsh"
  # Change default shell to zsh
  # chsh -s "$(which zsh)"
  # Install oh-my-zsh
  run_as_aur_user bash -c '
    export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
  '
  # # Install ZSH Zap
  # zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
}

setup_vim(){
  log_section "Configurando Neovim"
  # Install vim-plug for Neovim
}

setup_fonts(){
  log_section "Instalando fontes"
  # Install fonts
  sudo pacman -S --needed --noconfirm \
    ttf-dejavu \
    ttf-liberation \
    ttf-roboto \
    ttf-ubuntu-font-family \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    nerd-fonts-fira-code
}

setup_games(){
  log_section "Instalando pacotes de jogos"
  # Install games packages
  sudo pacman -S --needed --noconfirm \
    steam \
    lutris \
    wine
  install_aur_packages \
    curseforge \
    heroic-games-launcher \
    minecraft-launcher
}


setup_desktop_apps(){
  log_section "Instalando aplicativos desktop"
  # Install other packages
  sudo pacman -S --needed --noconfirm \
    vivaldi \
    obsidian \
    notion \
    discord \
    telegram-desktop \
    obs-studio \
    vlc \
    flameshot \
    libreoffice \
    gimp \
    inkscape \
    kdenlive \
    audacity \
    blender \
    qbittorrent
    # krita \ # Alternative to GIMP
    # shotcut \ # Alternative to Kdenlive

  install_aur_packages \
    slack-desktop \
    siyuan \
    marktext \
    anki

}

setup_tiling_wm(){
  log_section "Configurando gerenciador de janelas tiling"
  # Install a tiling window manager and related tools
  sudo pacman -S --needed --noconfirm \
    i3 \
    i3blocks \
    rofi \
    picom \
    nitrogen \
    lxappearance \
    dunst
}


# Call functions
setup_paru
setup_shell_tools
setup_dev
setup_docker
setup_virtualization
setup_ai
setup_shell
setup_vim
setup_fonts
setup_games
setup_desktop_apps

log_success "Setup concluído. Reinicie a sessão para aplicar todas as mudanças."
