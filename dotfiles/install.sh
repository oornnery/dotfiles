#!/bin/bash

# Imports

# Set variable
line_left="===>"
data=$(date +"%T")


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

write() {
    if [ "$1" = "title"]
    then 
        echo "\e[32m$data :: ===> $1.\e[0m\n"
}
