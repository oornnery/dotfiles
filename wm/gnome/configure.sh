#!/bin/bash

# GNOME Configuration Script
# Applies custom settings and extensions

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Check if GNOME is running
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    warn "GNOME desktop not detected. Skipping GNOME configuration."
    exit 0
fi

log "Configuring GNOME desktop..."

# Basic GNOME settings
log "Applying basic GNOME settings..."

# Interface settings
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'
gsettings set org.gnome.desktop.interface document-font-name 'Cantarell 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'

# Window management
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'

# Workspaces
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

# Shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Control><Alt>t']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"

# File manager
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.preferences show-hidden-files true

# Power settings
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800

log "GNOME configuration completed!"

# Install common GNOME extensions
if command -v gnome-extensions &> /dev/null; then
    log "Installing recommended GNOME extensions..."
    
    # Note: Extensions need to be installed manually from extensions.gnome.org
    # or via package manager depending on distribution
    
    warn "Consider installing these extensions:"
    echo "  - Dash to Dock"
    echo "  - User Themes"
    echo "  - Clipboard Indicator"
    echo "  - Caffeine"
    echo "  - GSConnect"
    echo "  - Pop Shell (tiling)"
fi
