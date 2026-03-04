#!/bin/bash

# Install required dependency for System Monitor Next
sudo apt install -y gir1.2-gtop-2.0

# Extension details
EXTENSION_UUID="system-monitor-next@paradoxxx.zero.gmail.com"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

# Check if extension is already installed
if [ -d "$EXTENSION_DIR" ]; then
    echo "System Monitor Next extension is already installed."
else
    echo "Downloading System Monitor Next extension..."

    # Create extensions directory if it doesn't exist
    mkdir -p "$HOME/.local/share/gnome-shell/extensions"

    # Generate tmp filename
    TMPFILE=$(mktemp)

    # Download the extension from GitHub (latest release)
    cd /tmp
    wget "https://github.com/mgalgs/gnome-shell-system-monitor-applet/archive/refs/heads/master.zip" -O "$TMPFILE.zip"
    unzip -q "$TMPFILE.zip"
    rm "$TMPFILE.zip"

    # Move extension to the correct location
    # The repo extracts to gnome-shell-system-monitor-next-applet-master/ and the
    # actual extension lives in a subdirectory matching the UUID.
    mv "gnome-shell-system-monitor-next-applet-master/$EXTENSION_UUID" "$EXTENSION_DIR"
    rm -rf gnome-shell-system-monitor-next-applet-master

    echo "Extension installed to $EXTENSION_DIR"
fi

# Apply saved settings
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$SCRIPT_DIR/../data/gnome_system_monitor_settings.dconf"
if [ -f "$SETTINGS_FILE" ]; then
    dconf load /org/gnome/shell/extensions/system-monitor-next-applet/ < "$SETTINGS_FILE"
    echo "Settings applied from $SETTINGS_FILE"
fi

# Enable the extension (may fail on first install if GNOME hasn't detected it yet)
gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null || true

echo ""
echo "System Monitor Next extension installed successfully!"
echo ""
echo "NOTE: If the extension doesn't appear:"
echo "  1. Log out and log back in"
echo "  2. Run: gnome-extensions enable $EXTENSION_UUID"
