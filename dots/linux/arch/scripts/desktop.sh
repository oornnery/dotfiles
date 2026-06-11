#!/bin/bash

# Sway

sudo pacman -S sway swaylock swayidle swaybg swayimg swaync sway-contrib\
    wf-recorder autotiling waybar nwg-bar nwg-displays nwg-dock nwg-menu\
    nwg-panel lxappearance wofi polkit pavucontrol wl-clipboard
paru -S  swaylock-effects wlogout wdisplays # swayfx wifi4wofi

# i3
# sudo pacman -S i3-wm i3lock i3blocks autotiling lxappearance rofi feh dunst\
    # redshift autorandr pavucontrol picom

# Hyprland
sudo pacman -S hyprland hyprcursor hyprgraphics hypridle hyprland-protocols\
    hyprland-qt-support hyprland-qtutils hyprlock hyprpolkitagent hyprsunset\
    hyprutils hyprwayland-scanner nwg-displays nwg-dock-hyprland nwg-panel\
    xdg-desktop-portal-hyprland hyprpicker wf-recorder lxappearance wofi waybar pavucontrol\
    wl-clipboard
paru -S wlogout wdisplays

# Cosmic
sudo pacman -S cosmic cosmic-player

# Fonts
sudo pacman -S noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-hack-nerd ttf-firacode-nerd ttf-jetbrains-mono-nerd \
    ttf-ubuntu-nerd ttf-roboto-mono-nerd

### Qtile
# sudo pacman -S qtile autorandr picom volumeicon xclip arandr
# paru -S qtile-extras

# Display manager
sudo pacman -S ly
