#!/bin/bash

# Script to set up a new Linux environment
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

# Check for root
#   if [[ $EUID -ne 0 ]]; then
#       echo "This script must be run as root"
#       exit 1
#   fi

dotdir="$HOME/dotfiles"

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
    sudo pacman -S --noconfirm --needed yay
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
base-devel
rofi
ripgrep
"

# Array to store programs that need installation
to_install=()

# Loop through each program
for prog in $programs; do
    if ! command -v "$prog" &>/dev/null; then
        to_install+=("$prog") # Add program to installation list
    else
        echo "$prog is already installed."
    fi
done

# Check if there are programs to install
if [ ${#to_install[@]} -gt 0 ]; then
    # Join array elements with space to form a single string
    programs_to_install=$(
        IFS=' '
        echo "${to_install[*]}"
    )

    # Perform installation using pacman
    sudo pacman -Syyu --noconfirm --needed "$programs_to_install"
else
    echo "All specified programs are already installed."
fi

# Install and set zsh
if [ ! -d ~/.oh-my-zsh ] || [ ! -f ~/.zshrc ]; then
    # If either the .oh-my-zsh directory or the .zshrc file doesn't exist, run the installation scripts
    "$dotdir"/programs/oh-my-zsh/zsh.sh
    "$dotdir"/programs/oh-my-zsh/oh-my-zsh-unattended.sh
    "$dotdir"/programs/oh-my-zsh/autosuggestion.sh
fi

# Install vim-like-mode plugin for zsh
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-vim-mode ]; then
    "$dotdir"/programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh
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

# Add call in zshrc to load vim-like-mode plugin
# Make sure this is done before loading atuin and zoxide
# Check if line doesn't exist, if not add it
# shellcheck disable=SC2016
grep -q 'source $HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh' "$HOME/.zshrc" ||
    echo 'source $HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh' >>"$HOME/.zshrc"

# Backup and move awesome rc.lua config
mkdir -pv "$HOME"/.config/awesome
cp -uvr "$dotdir"/programs/awesome "$HOME"/.config

# Backup and move kitty config
KITTY_CONF_FOLDER="$HOME/.config/kitty"
KITTY_CONF_FILE="$KITTY_CONF_FOLDER/kitty.conf"

mkdir -pv KITTY_CONF_FOLDER
cp -v "$KITTY_CONF_FILE" "$HOME"/.config/kitty/kitty_bkp.conf || echo 'Failed to copy default kitty.conf from config. Posibly it doesnt exists'
cp -v "$dotdir"/programs/kitty/kitty.conf "$KITTY_CONF_FILE"

# Configure git name and email
GIT_NAME="Julian Merida"
GIT_EMAIL="julianmr97@gmail.com"

echo "Configuring git name: $GIT_NAME and email: $GIT_EMAIL"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Add git alias configs
git config --global alias.final-branches '!git for-each-ref --format="%(objectname)^{commit}" | git cat-file --batch-check="%(objectname)^!" | grep -v missing | git log --oneline --stdin'

# Add git undo alias
git config --global alias.undo 'reset --soft HEAD^'

# Install git-diff-image
bash "$dotdir"/programs/git-diff-image/install.sh

# Clone awesome plugin repositories
if [ ! -d "$HOME/.config/awesome/awesome-wm-widgets" ]; then
    echo "Cloning awesome-wm-widgets repository"
    cd "$HOME"/.config/awesome || exit
    git clone https://github.com/streetturtle/awesome-wm-widgets "$HOME/.config/awesome/awesome-wm-widgets"
    git clone https://github.com/pltanton/net_widgets.git
    git clone https://github.com/softmoth/zsh-vim-mode.git
else
    echo "Directory awesome-wm-widgets already exists."
fi

# Initiate cronjob wallpaper changer script
echo "Initiating cronjob wallpaper changer script"
mkdir -pv "$HOME"/Pictures/wallpapers
"$dotdir"/scripts/create_cronjob.sh

# Install astrovim
echo "Installing astrovim"
bash "$dotdir"/programs/neovim/astrovim/install.sh

# Copy config nvim repo
echo "Copying nvim config"
mkdir -pv ~/.config/nvim/lua/user
git clone https://github.com/JuKMR/nvim_plugins ~/.config/nvim/lua/user

# Enable AUR in pamac.conf

sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf

# Pamac installation packages
yay -S --noconfirm visual-studio-code-bin

# Install atuin and register
echo "Installing atuin"
bash "$dotdir"/programs/atuin/install.sh

echo "Login in into atuin"
# NOTE: disabling this until we fix how to login correctly
# bash "$dotdir"/programs/atuin/login.sh

# Disabling this for now
echo "Enable ctrl_n_shortcuts in autin"
bash "$dotdir"/programs/atuin/apply_config.sh

# Copy picom files

echo "Copying picom files"
mkdir -pv "$HOME"/.config/picom
cp -v "$dotdir"/programs/picom/picom.conf "$HOME"/.config/picom/picom.conf

# Installing zoxide
echo "Installing zoxide"
bash "$dotdir"/programs/zoxide/install.sh

echo "All commmands run successfully!"
