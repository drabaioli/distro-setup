#!/bin/bash

# Generate tmp filename
TMPFILE=`mktemp`

# Dowload the repo and execute the setup.sh script
cd /tmp
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" -O $TMPFILE.zip
unzip $TMPFILE.zip
rm $TMPFILE.zip
mkdir ~/.fonts
fc-cache -fv
