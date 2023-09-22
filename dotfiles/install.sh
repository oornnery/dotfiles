#!/bin/bash

# Imports

# Set variable
line_left="===>"
data=$(date +"%T")
file_package="dotfiles/packages/base"


# Funções
call_taks() {
    # $1 = string da task
    # $1 = task para ser chamadas
    echo -e "\e[32m$data :: ===> $1 \e[1;34m(yes ou no):\e[0m\n"
    read resp

    if [ "$resp" = "yes" ] || [ "$resp" = "y" ]
    then
        echo -e "\e[34m$data :: ===> Starting task.\e[0m\n"
        $2
    elif [ "$resp" = "no" ] || [ "$resp" = "n" ]
    then
        echo -e "\e[34m$data :: ===> Skipped task.\e[0m\n"
    else
        echo -e "\e[31m$data :: ===> Select a valid option.\e[0m\n"
        call_taks "$1" $2
    fi
}

# List to store packages
package_list=""

# Install packages
install_packages() {
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*$ || "$line" == \#* ]]; then
            continue
        else
            echo "Processing line: $line"
            # Add your package installation logic here
            package_list+=" $line"
        fi
    done < "$file_package"

    # Install the collected packages
    if [ -n "$package_list" ]; then
        echo "Installing packages: $package_list"
        sudo pacman -Sy $package_list
    else
        echo "No packages to install."
    fi
}


install_packages


