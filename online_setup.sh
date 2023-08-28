#!/bin/bash

# Run as:
# bash <(wget -qO- https://raw.githubusercontent.com/drabaioli/distro-setup/main/online_setup.sh)

# Run as main user
if [ "$EUID" -eq 0 ]
  then echo "Please run without sudo"
  exit
fi

# Check dependencies
for cmd in wget mktemp unzip
do
  if ! [ -x "$(command -v $cmd)" ]; then
    echo 'Error: $cmd is not installed.' >&2
    exit 1
  fi
done

# Generate tmp filename
TMPFILE=`mktemp`

# Dowload the repo and execute the setup.sh script
cd /tmp
wget "https://github.com/drabaioli/distro-setup/archive/refs/heads/main.zip" -O $TMPFILE.zip
unzip $TMPFILE.zip
rm $TMPFILE.zip
cd /tmp/distro-setup-main
./setup.sh
