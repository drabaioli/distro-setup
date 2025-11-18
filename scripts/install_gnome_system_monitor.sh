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

    # Get GNOME Shell version
    GNOME_VERSION=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)

    # Download the extension from GitHub (latest release)
    cd /tmp
    wget "https://github.com/mgalgs/gnome-shell-system-monitor-applet/archive/refs/heads/master.zip" -O $TMPFILE.zip
    unzip -q $TMPFILE.zip
    rm $TMPFILE.zip

    # Move extension to the correct location
    mv gnome-shell-system-monitor-applet-master "$EXTENSION_DIR"

    echo "Extension installed to $EXTENSION_DIR"
fi

# Enable the extension
gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null || true

echo ""
echo "System Monitor Next extension installed successfully!"
echo ""
echo "IMPORTANT: You need to restart GNOME Shell for the extension to appear:"
echo "  - Press Alt+F2, type 'r' and press Enter"
echo "  - Or log out and log back in"
