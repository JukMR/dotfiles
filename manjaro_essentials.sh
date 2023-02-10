#!/bin/bash

dotdir="$HOME/dotfiles/"


# Install fundamental programs
programs="git
zsh
openssh
vsftpd
evince
gparted
htop
xclip
gvim
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
micro
kitty
btop
bluez-utils
viewnior
"
sudo pacman -Syu --noconfirm --needed $programs &&

# Install and set zsh
$dotdir/programs/oh-my-zsh/zsh.sh &&
$dotdir/programs/oh-my-zsh/oh-my-zsh-unattended.sh &&
$dotdir/programs/oh-my-zsh/autosuggestion.sh ;

# Set permanent shortcuts
$dotdir/scripts/gitlola.sh &&
$dotdir/scripts/keyboard-us-altgr-variant.sh &&

# Copy rcFiles
cp $dotdir/rcFiles/vimrc ~/.vimrc &&
cp ~/.zshrc ~/.old_zshrc &&
cp $dotdir/rcFiles/zshrc ~/.zshrc &&

# Install vim vundle
$dotdir/programs/install-vundle/install.sh ;

# Install all plugins
vim +PluginInstall +qall &&

# Install kitty terminal
# mkdir -p $HOME/.local/bin &&
# mkdir -p $HOME/.local/share/applications &&
# $dotdir/programs/kitty/install.sh

# Change default shell to zsh
if [ "$SHELL" != "/bin/zsh" ]
then
  chsh -s $(which zsh)
fi

# Move awesome rc.lua config
mkdir -p $HOME/.config/awesome &&
cp -ur $dotdir/programs/awesome $HOME/.config

# Move kitty config
mkdir -p $HOME/.config/kitty &&
cp $dotdir/programs/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

# Configure git name and email
git config --global user.name "Julian Merida"
git config --global user.email "julianmr97@gmail.com"

# Clone awesome plugin repositories
cd $HOME/.config/awesome
git clone https://github.com/streetturtle/awesome-wm-widgets
git clone https://github.com/pltanton/net_widgets.git

# Initiate cronjob wallpaper changer script
mkdir -p $HOME/Pictures/wallpapers
$dotdir/scripts/create_cronjob.sh

# Pamac installation packages
# Find a way to install programs if one wasn't found
# pamac_programs="
# mirage
# visual-studio-code-bin
# spotify
# "

pamac install visual-studio-code-bin
pamac install spotify
pamac install mirage

