#!/bin/bash

# Run as main user
if [ "$EUID" -eq 0 ]
  then echo "Please run without sudo"
  exit
fi

MAIN_USER=`echo $USER`

# Install required APT packages
sudo ./scripts/install_apt_packages.sh

# Load terminal configuration
./scripts/load_terminal_config.sh

# Load vim configuration
./scripts/load_vim_config.sh
