#!/bin/bash



f_test() {
    # $1 = string da task
    # $1 = task para ser chamadas
    data=$(date +"%T")

    echo -e "\e[32m$data :: $1 \e[34m(yes ou no):\e[0m\n"
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
        f_test "$1" $2
    fi
}

fun1() {
    date
}

f_test "Você gosta de maçãs?" fun1