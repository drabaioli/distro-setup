#!/bin/bash

# Move to the dir where this script is
base_path=$( dirname $( readlink -f $0 ) )
cd $base_path

cat ../data/gnome-terminal-config.dconf | dconf load /org/gnome/terminal/

cp ../data/ps1 ~/.ps1

cat <<EOT >> ~/.bashrc

# DIEGO

# Customize prompt
source ~/.ps1

# Use Vim as editor in git
export VISUAL=vim
export EDITOR="$VISUAL"
EOT
