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
BACKGROUNDS_DIR="$HOME/.local/share/backgrounds"
mkdir -p "$BACKGROUNDS_DIR"

# Get the filename from the path
IMAGE_FILENAME=$(basename "$IMAGE_PATH")

# Copy image to permanent location
PERMANENT_PATH="$BACKGROUNDS_DIR/$IMAGE_FILENAME"
cp "$IMAGE_PATH" "$PERMANENT_PATH"

echo "Copied image to: $PERMANENT_PATH"
echo "Setting desktop background..."

# Set background using gsettings for GNOME
gsettings set org.gnome.desktop.background picture-uri "file://$PERMANENT_PATH"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$PERMANENT_PATH"

echo "Desktop background set successfully"