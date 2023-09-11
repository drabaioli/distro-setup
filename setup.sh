#!/bin/bash

# Run as main user
if [ "$EUID" -eq 0 ]
  then echo "Please run without sudo"
  exit
fi

# Install required APT packages
sudo ./scripts/install_apt_packages.sh

# Install nerd fonts
./scripts/install_nerd_fonts.sh

# Load terminal configuration
./scripts/load_terminal_config.sh

# Load vim configuration
./scripts/load_vim_config.sh
