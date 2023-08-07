#!/bin/bash

dconf dump /org/gnome/terminal/ | grep -v font > ../scripts/gnome-terminal-config.dconf
