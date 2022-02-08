#!/bin/bash

dotdir="$HOME/dotfiles/"
# Install fundamental programs
sudo pacman -Syu --noconfirm --needed git zsh openssh vsftpd evince gparted htop xclip gvim flameshot bat nitrogen obs-studio bitwarden telegram-desktop lxappearance netcat awesome playerctl wireless_tools &&

# Install and set zsh
$dotdir/programs/oh-my-zsh/zsh.sh &&
$dotdir/programs/oh-my-zsh/oh-my-zsh-unattended.sh &&
$dotdir/programs/oh-my-zsh/autosuggestion.sh ;

# Set permanent shortcuts
$dotdir/scripts/gitlola.sh &&
$dotdir/scripts/keyboard-us-altgr-variant.sh &&

# Copy rcFiles
cp $dotdir/rcFiles/vimrc ~/.vimrc &&
cp $dotdir/rcFiles/zshrc ~/.zshrc &&

# Install vim vundle
$dotdir/programs/install-vundle/install.sh ;

# Install all plugins
vim +PluginInstall +qall &&

# Install kitty terminal
mkdir -p $HOME/.local/bin &&
mkdir -p $HOME/.local/share/applications &&
$dotdir/programs/kitty/install.sh

# Change default shell to zsh
if [ "$SHELL" != "/bin/zsh" ]
then
  chsh -s $(which zsh)
fi

# Move awesome rc.lua config
mkdir -p $HOME/.config/awesome &&
cp -ur $dotdir/programs/awesome $HOME/.config

# Configure git name and email
git config --global user.name "Julian Merida"
git config --global user.email "julianmr97@gmail.com"
