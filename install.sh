#!/bin/bash
set -e

echo "====================================="
echo "   Songster's Dotfiles Installer"
echo "====================================="

# ── Step 1: Install paru ──
echo ""
echo "[1/9] Installing paru (AUR helper)..."
if ! command -v paru &> /dev/null; then
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm && cd ~
else
    echo "paru already installed, skipping."
fi

# ── Step 2: Install pacman packages ──
echo ""
echo "[2/9] Installing pacman packages..."
sudo pacman -S --needed - < ~/dotfiles/packages.txt

# ── Step 3: Install AUR packages ──
echo ""
echo "[3/9] Installing AUR packages..."
paru -S --needed - < ~/dotfiles/packages-aur.txt

# ── Step 4: Install stow ──
echo ""
echo "[4/9] Making sure stow is installed..."
sudo pacman -S --needed stow

# ── Step 5: Symlink configs with stow ──
echo ""
echo "[5/9] Symlinking configs..."
cd ~/dotfiles
stow --target="$HOME" --restow .

# ── Step 6: Install Oh My Zsh ──
echo ""
echo "[6/9] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping."
fi

# ── Step 7: Install OMZ plugins ──
echo ""
echo "[7/9] Installing Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
fi

# ── Step 8: Apply GTK theme ──
echo ""
echo "[8/9] Applying GTK theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-mauve-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# ── Step 9: Set zsh as default shell ──
echo ""
echo "[9/9] Setting zsh as default shell..."
chsh -s $(which zsh)

# ── System configs (optional) ──
echo ""
echo "====================================="
echo " Optional: Apply system configs"
echo "====================================="
echo "WARNING: These contain device-specific UUIDs."
echo "Only apply on the SAME hardware."
echo ""
read -p "Apply /etc/fstab? [y/N] " apply_fstab
if [[ "$apply_fstab" =~ ^[Yy]$ ]]; then
    sudo cp ~/dotfiles/system-configs/etc/fstab /etc/fstab
    echo "fstab applied."
fi

read -p "Apply bootloader config? [y/N] " apply_boot
if [[ "$apply_boot" =~ ^[Yy]$ ]]; then
    sudo cp ~/dotfiles/system-configs/boot/loader/loader.conf /boot/loader/loader.conf
    sudo cp ~/dotfiles/system-configs/boot/loader/entries/arch.conf /boot/loader/entries/arch.conf
    echo "Bootloader config applied."
fi

echo ""
echo "====================================="
echo " All done! Reboot to apply everything."
echo "====================================="
