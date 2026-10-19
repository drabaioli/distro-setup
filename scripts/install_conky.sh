#!/bin/bash

# Conky desktop widget (clock, date, CPU/RAM/disk) and autostart on login.

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data/conky"
CONF_DIR="$HOME/.config/conky"

sudo apt install -y conky-all fonts-ubuntu fonts-dejavu-core

mkdir -p "$CONF_DIR" "$HOME/.config/autostart"
cp "$DATA_DIR/conky.conf" "$DATA_DIR/panels.lua" "$CONF_DIR/"

cat > "$HOME/.config/autostart/conky.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky -d -p 5
DESKTOP

pkill -x conky
conky -d >/dev/null 2>&1 </dev/null

echo "Conky installed successfully!"
