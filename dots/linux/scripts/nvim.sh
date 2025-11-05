#!/usr/bin/bash

# Install neovim from source

git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim || exit
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install
cd build || exit
sudo cpack -G DEB
sudo dpkg -i nvim-linux*.deb
cd ~ || exit
sudo rm -Rf ~/neovim
