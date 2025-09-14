#!/bin/bash

# Install required packages (no harm if already installed)
sudo apt install -y wget unzip fontconfig

# Generate tmp filename
TMPFILE=`mktemp`

# Download the repo and execute the setup.sh script
cd /tmp
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" -O $TMPFILE.zip
unzip $TMPFILE.zip
rm $TMPFILE.zip
mkdir ~/.fonts
mv *.ttf ~/.fonts/
fc-cache -fv

echo "Nerd fonts installed successfully!"
