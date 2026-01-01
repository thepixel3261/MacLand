#!/bin/bash

echo "This script will update your dotfiles.."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# Copy all dotfiles except keybinds.conf
echo ">> Updating dotfiles..."
mkdir -p ~/.config

# Save the current keybinds.conf if it exists
if [[ -f ~/.config/hypr/conf/keybinds.conf ]]; then
    echo ">> Saving current keybinds.conf to ~/keybinds.conf.bak"
    cp ~/.config/hypr/conf/keybinds.conf ~/keybinds.conf.bak
fi

cp -a ~/dotfiles/home/* ~/
cp -a ~/dotfiles/dotconfig/* ~/.config/

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

# /usr/share
mkdir -p /usr/share/
sudo cp -a ~/dotfiles/usrshare/. /usr/share/

# Ask if the user wants to overwrite keybinds.conf
read -p "Do you want to overwrite ~/.config/hypr/conf/keybinds.conf? (y/N): " overwrite_keybinds

if [[ "$overwrite_keybinds" == "y" || "$overwrite_keybinds" == "Y" || "$overwrite_keybinds" == "yes" || "$overwrite_keybinds" == "YES" ]]; then
    echo ">> Overwriting keybinds.conf..."
else
    echo ">> Restoring custom keybinds.conf..."
    if [[ -f ~/keybinds.conf.bak ]]; then
        cp ~/keybinds.conf.bak ~/.config/hypr/conf/keybinds.conf
        rm ~/keybinds.conf.bak  # Remove backup after restoring
    else
        echo "No backup of keybinds.conf found."
    fi
fi

# Clean up dotfiles
rm -rf ~/dotfiles/

# Ask for keyboard layout selection
read -p "What is your keyboard code (us/de/fr/...)? : " keyboardlayout
sudo -u $USER sh -c "echo -e 'input {\n        kb_layout = $keyboardlayout\n}' > ~/.config/hypr/conf/input.conf"

echo "[!] Done"
