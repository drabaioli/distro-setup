#!/bin/bash

# Custom look for GNOME Shell 42 (Ubuntu 22.04, X11):
#  - Yaru-dark-custom shell theme: translucent top bar, rounded containers for its items
#  - Blur my Shell: blur behind the top bar
#  - screen-gaps (own extension): keeps maximized/tiled windows away from screen edges
#  - Tiling Assistant: gap between tiled windows
# Restart the shell afterwards (Alt+F2, r, Enter) to load the new extensions.

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXT_DIR"

# Add an extension to enabled-extensions. `gnome-extensions enable` refuses
# extensions the running shell has not discovered yet, so edit the setting.
enable_extension() {
    local uuid="$1" current
    current=$(gsettings get org.gnome.shell enabled-extensions)
    if [[ "$current" == *"'$uuid'"* ]]; then
        return
    fi
    if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
        gsettings set org.gnome.shell enabled-extensions "['$uuid']"
    else
        gsettings set org.gnome.shell enabled-extensions "${current%]}, '$uuid']"
    fi
}

# Install an extension from extensions.gnome.org at a pinned version.
install_ego_extension() {
    local uuid="$1" version_tag="$2" tmp
    if [ -d "$EXT_DIR/$uuid" ]; then
        echo "$uuid is already installed."
        return
    fi
    echo "Downloading $uuid..."
    tmp=$(mktemp -d)
    wget -q "https://extensions.gnome.org/download-extension/$uuid.shell-extension.zip?version_tag=$version_tag" \
        -O "$tmp/ext.zip" && gnome-extensions install "$tmp/ext.zip"
    rm -rf "$tmp"
}

# Shell theme (needs the User Themes extension, shipped with gnome-shell-extensions)
echo "Installing shell theme..."
sudo apt install -y gnome-shell-extensions
mkdir -p ~/.themes/Yaru-dark-custom/gnome-shell
cp "$DATA_DIR/gnome_look/theme/gnome-shell.css" ~/.themes/Yaru-dark-custom/gnome-shell/gnome-shell.css

# Own extension: always refresh from the repo
echo "Installing screen-gaps extension..."
rm -rf "$EXT_DIR/screen-gaps@distro-setup"
cp -r "$DATA_DIR/gnome_look/screen-gaps@distro-setup" "$EXT_DIR/"

# Blur my Shell v47 and Tiling Assistant v36 are the last releases for GNOME 42
install_ego_extension "blur-my-shell@aunetx" 42627
install_ego_extension "tiling-assistant@leleat-on-github" 34016

# Settings
dconf load /org/gnome/shell/extensions/tiling-assistant/ < "$DATA_DIR/gnome_tiling_assistant_settings.dconf"
dconf write /org/gnome/shell/extensions/user-theme/name "'Yaru-dark-custom'"

for uuid in user-theme@gnome-shell-extensions.gcampax.github.com \
            blur-my-shell@aunetx \
            screen-gaps@distro-setup \
            tiling-assistant@leleat-on-github; do
    enable_extension "$uuid"
done

echo ""
echo "GNOME look installed. Restart the shell to apply it: Alt+F2, type r, Enter."
echo "(On Wayland, log out and back in instead.)"
