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
exec > >(tee -i $HOME/dotfiles_setup.log)
exec 2>&1

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
kitty
btop
bluez-utils
viewnior
brave-browser
xlockmore
neovim
tmux
xorg-xrandr
nm-applet
"

# Conditional package installation
for prog in $programs; do
  if ! command -v "$prog" &>/dev/null; then
    sudo pacman -Syu --noconfirm --needed $prog
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
cp ~/.zshrc ~/.old_zshrc
cp "$dotdir"/rcFiles/zshrc ~/.zshrc

# Change default shell to zsh
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s "$(which zsh)"
fi

# Backup and move awesome rc.lua config
mkdir -p "$HOME"/.config/awesome
cp -ur "$dotdir"/programs/awesome "$HOME"/.config

# Backup and move kitty config
mkdir -p "$HOME"/.config/kitty
cp "$HOME"/.config/kitty/kitty.conf "$HOME"/.config/kitty/kitty_bkp.conf || echo 'Failed to copy default kitty.conf from config. Posibly it doesnt exists'
cp "$dotdir"/programs/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf

# Configure git name and email
git config --global user.name "Julian Merida"
git config --global user.email "julianmr97@gmail.com"

# Clone awesome plugin repositories
if [ ! -d "$HOME/.config/awesome/awesome-wm-widgets" ]; then
  cd "$HOME"/.config/awesome || exit
  git clone https://github.com/streetturtle/awesome-wm-widgets "$HOME/.config/awesome/awesome-wm-widgets"
  git clone https://github.com/pltanton/net_widgets.git
else
  echo "Directory awesome-wm-widgets already exists."
fi

# Initiate cronjob wallpaper changer script
mkdir -p "$HOME"/Pictures/wallpapers
"$dotdir"/scripts/create_cronjob.sh

# Install astronvim
bash "$dotdir"/programs/astrovim/install.sh

# Copy config nvim repo
git clone https://github.com/JuKMR/nvim_plugins ~/.config/nvim/lua/user

# Enable AUR in pamac.conf
sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf

# Pamac installation packages
pamac install visual-studio-code-bin --no-confirm
pamac install spotify --no-confirm
pamac install mirage --no-confirm
