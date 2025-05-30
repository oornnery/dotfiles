#!/bin/bash

# Copy files from home/.config to backup directory
mkdir -p ~/.config.bak

cp -r ~/.config ~/.config.bak/
