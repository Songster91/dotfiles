#!/bin/bash

set -e  # stop if any command fails

echo "====================================="
echo "   Dotfiles Auto Install Script"
echo "====================================="

# ── Step 1: Install paru (AUR helper) ──
echo ""
echo "[1/6] Installing paru..."
if ! command -v paru &> /dev/null; then
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd ~
else
    echo "paru already installed, skipping."
fi

# ── Step 2: Install pacman packages ──
echo ""
echo "[2/6] Installing pacman packages..."
sudo pacman -S --needed - < ~/dotfiles/packages.txt

# ── Step 3: Install AUR packages ──
echo ""
echo "[3/6] Installing AUR packages..."
paru -S --needed - < ~/dotfiles/packages-aur.txt

# ── Step 4: Install stow (if not already) ──
echo ""
echo "[4/6] Making sure stow is installed..."
sudo pacman -S --needed stow

# ── Step 5: Create symlinks with stow ──
echo ""
echo "[5/6] Creating symlinks with stow..."
cd ~/dotfiles
stow .

# ── Step 6: Set zsh as default shell ──
echo ""
echo "[6/6] Setting zsh as default shell..."
chsh -s $(which zsh)

echo ""
echo "====================================="
echo " All done! Reboot or re-login now."
echo "====================================="
