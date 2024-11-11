#!/bin/bash

detect_os() {
    if [ -f /etc/arch-release ]; then
        echo 'arch'
    elif [ -f /etc/debian_version ]; then
        if grep -q Ubuntu /etc/os-release; then
            echo 'ubuntu'
        else
            echo 'debian'
        fi
    else
        echo 'unknown'
}

install_package() {
    os=$(detect_os)
    package=$@

    case $os in
        "arch")
            $arch_package=$(echo $package | cut -d',' -f1)
            sudo pacman -S $package
            ;;
        "ubuntu"|"debian")
            sudo apt-get install -y $package
            ;;
        *)
            echo "Could not install $package. Unknown OS."
            ;;
    esac
}
