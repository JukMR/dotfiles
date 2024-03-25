#!/bin/bash

# Script to set up a new Linux environment
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

# Check for root
#if [[ $EUID -ne 0 ]]; then
#  echo "This script must be run as root"
#  exit 1
#fi

dotdir="$HOME/dotfiles/"

# Enable strict mode
set -eu

# Logging
exec > >(tee -i "$HOME"/dotfiles_setup.log)
exec 2>&1

# Install kitty terminal
# Check if kitty is installed
if ! command -v kitty &>/dev/null; then
  echo "Installing kitty terminal"
  bash "$dotdir"/programs/kitty/install.sh
else
  echo "Kitty terminal is already installed."
fi

# Install yay
# Check if yay is installed
if ! command -v yay &>/dev/null; then
  echo "Installing yay"
  bash pacman -S --no-confirm --needed yay
else
  echo "Yay is already installed."
fi

# Install fundamental programs
programs="
git
zsh
openssh
vsftpd
gparted
htop
xclip
bat
flameshot
nitrogen
obs-studio
bitwarden
telegram-desktop
lxappearance
netcat
awesome
playerctl
wireless_tools
btop
bluez-utils
viewnior
brave-browser
xlockmore
neovim
tmux
xorg-xrandr
network-manager-applet
volumeicon
brightnessctl
trash-cli
net-tools
picom
ranger
"

# Conditional package installation
for prog in $programs; do
  if ! command -v "$prog" &>/dev/null; then
    sudo pacman -Syyu --noconfirm --needed "$prog"
  else
    echo "$prog is already installed."
  fi
done

# Install and set zsh
if [ ! -d ~/.oh-my-zsh ] || [ ! -f ~/.zshrc ]; then
  # If either the .oh-my-zsh directory or the .zshrc file doesn't exist, run the installation scripts
  "$dotdir"/programs/oh-my-zsh/zsh.sh
  "$dotdir"/programs/oh-my-zsh/oh-my-zsh-unattended.sh
  "$dotdir"/programs/oh-my-zsh/autosuggestion.sh
fi

# Set permanent shortcuts
"$dotdir"/scripts/gitlola.sh
"$dotdir"/scripts/keyboard-us-altgr-variant.sh

# Backup and copy rcFiles
cp -v ~/.zshrc ~/.old_zshrc
cp -v "$dotdir"/rcFiles/zshrc ~/.zshrc

# Change default shell to zsh
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s "$(which zsh)"
fi

# Backup and move awesome rc.lua config
mkdir -p "$HOME"/.config/awesome
cp -uvr "$dotdir"/programs/awesome "$HOME"/.config

# Backup and move kitty config
mkdir -p "$HOME"/.config/kitty
cp -v "$HOME"/.config/kitty/kitty.conf "$HOME"/.config/kitty/kitty_bkp.conf || echo 'Failed to copy default kitty.conf from config. Posibly it doesnt exists'
cp -v "$dotdir"/programs/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf

# Configure git name and email
GIT_NAME="Julian Merida"
GIT_EMAIL="julianmr97@gmail.com"

echo "Configuring git name: $GIT_NAME and email: $GIT_EMAIL"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Clone awesome plugin repositories
if [ ! -d "$HOME/.config/awesome/awesome-wm-widgets" ]; then
  echo "Cloning awesome-wm-widgets repository"
  cd "$HOME"/.config/awesome || exit
  git clone https://github.com/streetturtle/awesome-wm-widgets "$HOME/.config/awesome/awesome-wm-widgets"
  git clone https://github.com/pltanton/net_widgets.git
else
  echo "Directory awesome-wm-widgets already exists."
fi

# Initiate cronjob wallpaper changer script
echo "Initiating cronjob wallpaper changer script"
mkdir -p "$HOME"/Pictures/wallpapers
"$dotdir"/scripts/create_cronjob.sh

# Install astrovim
echo "Installing astrovim"
bash "$dotdir"/programs/astrovim/install.sh

# Copy config nvim repo
echo "Copying nvim config"
git clone https://github.com/JuKMR/nvim_plugins ~/.config/nvim/lua/user

# Enable AUR in pamac.conf

sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf

# Pamac installation packages
yay -S --noconfirm visual-studio-code-bin
yay -S --noconfirm spotify

# Install atuin and register
echo "Installing atuin"
bash "$dotdir"/programs/atuin/install.sh

echo "Login in into atuin"
bash "$dotdir"/programs/atuin/login.sh

# Disabling this for now
echo "Enable ctrl_n_shortcuts in autin"
bash "$dotdir"/programs/atuin/apply_config.sh

# Copy picom files

echo "Copying picom files"
mkdir -p "$HOME"/.config/picom
cp -v "$dotdir"/programs/picom/picom.conf "$HOME"/.config/picom/picom.conf
