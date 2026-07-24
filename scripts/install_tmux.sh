#!/bin/bash

# Install tmux from apt
echo "Installing tmux..."
sudo apt install -y tmux

# Move to the dir where this script is
base_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd "$base_path"

# Copy tmux configuration
echo "Setting up tmux configuration..."
cp ../data/tmux.conf ~/.tmux.conf

echo "Tmux installed successfully!"
