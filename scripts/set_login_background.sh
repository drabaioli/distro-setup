#!/bin/bash

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No image path provided"
    echo "Usage: $0 <path_to_image>"
    exit 1
fi

IMAGE_PATH="$1"

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: Image file '$IMAGE_PATH' does not exist"
    exit 1
fi

# Create backgrounds directory if it doesn't exist
BACKGROUNDS_DIR="/usr/share/backgrounds/custom"
sudo mkdir -p "$BACKGROUNDS_DIR"

# Get the filename from the path
IMAGE_FILENAME=$(basename "$IMAGE_PATH")

# Copy image to permanent location (system-wide)
PERMANENT_PATH="$BACKGROUNDS_DIR/$IMAGE_FILENAME"
sudo cp "$IMAGE_PATH" "$PERMANENT_PATH"

echo "Copied image to: $PERMANENT_PATH"

# Install required packages
echo "Installing required packages..."

# Check Ubuntu version and add PPA if needed
UBUNTU_VERSION=$(lsb_release -rs)
if (( $(echo "$UBUNTU_VERSION < 24.04" | bc -l) )); then
    # Ubuntu 22.04 and earlier - add PPA
    sudo add-apt-repository -y ppa:ubuntuhandbook1/gdm-settings
fi

sudo apt update
sudo apt install -y gdm-settings libglib2.0-dev-bin dbus-x11

if [ $? -ne 0 ]; then
    echo "Error: Failed to install required packages"
    exit 1
fi

echo "Setting login screen background..."

# Use gdm-settings to set the background
# Since gdm-settings is primarily a GUI tool, we'll use the underlying gsettings approach
# that GDM Settings uses internally
sudo -u gdm dbus-launch gsettings set com.ubuntu.login-screen background-picture-uri "file://$PERMANENT_PATH"

# Alternative method using gdm-settings CLI if available
if gdm-settings --help 2>/dev/null | grep -q "background"; then
    sudo gdm-settings set background-image "$PERMANENT_PATH"
fi

echo "Login screen background set successfully"
echo "You may need to restart GDM or reboot to see the changes:"
echo "  sudo systemctl restart gdm3"
