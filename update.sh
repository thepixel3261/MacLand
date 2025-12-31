#!/bin/bash

# WARNING: This script will update your dotfiles, but will not overwrite ~/.config/hypr/conf/keybinds.conf.
echo "This script will update your dotfiles, but will not overwrite ~/.config/hypr/conf/keybinds.conf."
echo "You will be asked if you want to keep your custom keybinds configuration."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# Copy all dotfiles except keybinds.conf
echo ">> Updating dotfiles..."
mkdir -p ~/.config

# Copy all files except `keybinds.conf` from ~/dotfiles/dotconfig to ~/.config/
shopt -s extglob
cp -a ~/dotfiles/home/. ~/
cp -a ~/dotfiles/dotconfig/!(hypr/conf/keybinds.conf) ~/.config/

# Ask if the user wants to overwrite keybinds.conf
read -p "Do you want to overwrite ~/.config/hypr/conf/keybinds.conf? (y/N): " overwrite_keybinds

if [[ "$overwrite_keybinds" == "y" || "$overwrite_keybinds" == "Y" || "$overwrite_keybinds" == "yes" || "$overwrite_keybinds" == "YES" ]]; then
    echo ">> Overwriting keybinds.conf..."
    cp -a ~/dotfiles/confv3/keybinds.conf ~/.config/hypr/conf/keybinds.conf
else
    echo ">> Keeping custom keybinds.conf..."
fi

# Hyprland config version 3 (for comparison)
REQUIRED_VERSION="0.53.0"

# Get the first line of hyprland -v
FIRST_LINE=$(hyprland -v 2>/dev/null | head -n 1)

# Extract version number (e.g. 0.52.2, 1.2.3)
VERSION=$(echo "$FIRST_LINE" | grep -oE '[0-9]+(\.[0-9]+)+')

if [[ -z "$VERSION" ]]; then
    echo "Failed to detect Hyprland version."
    exit 1
fi

# Compare versions using sort -V
if [[ "$(printf '%s\n%s\n' "$REQUIRED_VERSION" "$VERSION" | sort -V | head -n1)" == "$REQUIRED_VERSION" ]]; then
    echo "Hyprland version $VERSION, using new config"
    cp -a ~/dotfiles/confv3/* ~/.config/hypr/
else
    echo "Hyprland version $VERSION, using old config"
fi

# Clean up dotfiles
rm -rf ~/dotfiles/

# Ask for keyboard layout selection
read -p "What is your keyboard code (us/de/fr/...)? : " keyboardlayout
sudo -u $USER sh -c "echo -e 'input {\n        kb_layout = $keyboardlayout\n}' > ~/.config/hypr/conf/input.conf"

# Self-delete (remove the script after execution)
echo ">> Cleaning up... deleting the update script."
rm -- "$0"

echo "[!] Done"
