# !/bin/bash
$(pwd)/sripts/docker.sh
# Update system
sudo pacman -Syyu

sudo pacman -S obs-studio qbittorrent gimp vlc telegram-desktop discord slack-desktop

sudo chmod +x $(pwd)/scripts/*.sh

$(pwd)/scripts/system.sh
$(pwd)/scripts/network.sh
$(pwd)/scripts/desktop.sh
# $(pwd)/scripts/shell.sh
$(pwd)/scripts/docker.sh
$(pwd)/scripts/aur.sh

mkdir $HOME/projects
mkdir $HOME/docker-apps
mkdir $HOME/notes
