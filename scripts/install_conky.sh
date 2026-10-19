#!/bin/bash

# Conky desktop widget (clock, system bars, Amsterdam weather) and autostart on login.

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data/conky"
CONF_DIR="$HOME/.config/conky"

sudo apt install -y conky-all fonts-ubuntu fonts-dejavu-core curl jq

mkdir -p "$CONF_DIR" "$HOME/.config/autostart"
cp "$DATA_DIR/conky.conf" "$DATA_DIR/panels.lua" "$DATA_DIR/weather.sh" "$CONF_DIR/"

cat > "$HOME/.config/autostart/conky.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky -d -p 5
DESKTOP

pkill -x conky
conky -d >/dev/null 2>&1 </dev/null

echo "Conky installed successfully!"
