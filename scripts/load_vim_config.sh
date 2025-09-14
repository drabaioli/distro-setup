#!/bin/bash

# Install required packages (no harm if already installed)
sudo apt install -y vim exuberant-ctags

# Move to the dir where this script is
base_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd "$base_path"

cp ../data/vimrc ~/.vimrc
echo "Vim configuration loaded successfully!"
