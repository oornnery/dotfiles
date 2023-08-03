from scripts.backup import backup
from scripts.directory import directory
from scripts.install_packages import install_packages


# Backup .config
backup(
    "~/.config"
)

# Create directories
directory(
    "~/.config",
    [
        "i3",
        'qtile',
        'rofi',
        'picom',
        'sway',
    ]
)

# Install packages
install_packages(
    [
        "cmatrix",
        "neofetch"
    ]
)

# Copy directory from dotfiles to .config
backup(
    
)
