#!/bin/bash

# Move to the dir where this script is
base_path=$( dirname $( readlink -f $0 ) )
cd $base_path

dconf dump /org/gnome/terminal/ > ../data/gnome-terminal-config.dconf
