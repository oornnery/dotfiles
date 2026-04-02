#!/usr/bin/env bash
set -euo pipefail

USER_NAME="oornnery"
USER_SHELL="/bin/zsh"
EDITOR_NAME="nvim"
TIMEZONE="America/Sao_Paulo"
LOCALE="en_US.UTF-8"
LOCALE_GEN_EN="en_US.UTF-8 UTF-8"
LOCALE_GEN_PT="pt_BR.UTF-8 UTF-8"

# Install WSL
# Use: wsl --install -d archlinux
# Open: wsl -d archlinux
# Run this script as root

# Pacman settings
sed -i 's/^#\?Color$/Color/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 5/' /etc/pacman.conf
grep -qxF 'ILoveCandy' /etc/pacman.conf || sed -i '/^Color$/a ILoveCandy' /etc/pacman.conf

# Update system
pacman -Syu

# Set root password
passwd

# Install packages
pacman -S --needed \
  base-devel sudo git curl wget vim neovim bash zsh fastfetch jq tree htop \
  unzip zip tar gzip bzip2 xz openssl openssh ca-certificates \
  fzf fd ripgrep bat eza tmux stow btop lazygit lazydocker \
  python python-pip uv ruff ty rust nim lua luarocks make cmake nodejs nvm npm bun pnpm \
  rumdl

# Create user if needed
if ! id "$USER_NAME" >/dev/null 2>&1; then
  useradd -m -G wheel -s "$USER_SHELL" "$USER_NAME"
fi

passwd "$USER_NAME"

# Allow wheel group to use sudo
printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
visudo -c

# Timezone
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

# Locale
sed -i "s/^#\($LOCALE_GEN_EN\)/\1/" /etc/locale.gen
sed -i "s/^#\($LOCALE_GEN_PT\)/\1/" /etc/locale.gen
locale-gen
printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf

# WSL config
cat > /etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=$USER_NAME
EOF

echo
echo "Setup finished."
echo "Now run from Windows PowerShell:"
echo "  wsl --shutdown"
echo
echo "Then open Arch again and verify:"
echo "  whoami"
echo "  echo \$SHELL"
echo
echo "Next steps:"
echo "  ./zsh.sh"
echo "  ./stow.sh"
echo "  ./paru.sh"
echo
