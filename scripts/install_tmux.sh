#!/bin/bash

# Install tmux from snap, not apt: Ubuntu 22.04 only carries 3.2a, and the mouse
# and passthrough bindings in data/tmux.conf were written and verified against
# 3.6b. Classic confinement so tmux can reach xclip and the X display.
echo "Installing tmux..."
sudo snap install --classic tmux

# xclip backs `copy-command` in data/tmux.conf, which puts tmux selections into
# the X PRIMARY and CLIPBOARD selections so Shift+Insert can paste them.
echo "Installing xclip..."
sudo apt install -y xclip

# Move to the dir where this script is
base_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd "$base_path"

# Copy tmux configuration
echo "Setting up tmux configuration..."
cp ../data/tmux.conf ~/.tmux.conf

echo "Tmux installed successfully!"
