#!/bin/bash

# Run with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

DEBIAN_FRONTEND=noninteractive apt update && apt install -y git vim exuberant-ctags
