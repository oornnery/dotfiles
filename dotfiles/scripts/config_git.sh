#!/bin/bash

# Configure Git
date=$(date +"%T")
echo -e "\e[32m $date:: ===> Configurando o Git.\e[0m\n"
echo -e "\e[32m $date:: ===> Informe seu nome:\e[0m\n"
read name
git config --global user.name "$name"
echo -e "\e[32m $date:: ===> Informe seu e-mail:\e[0m\n"
read email
git config --global user.email $email
