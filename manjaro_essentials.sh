# Install fundamental programs
pacman -Syu --no-confirm git zsh openssh-client vsftpd evince gparted htop xclip gvim flameshot bat nitrogen obs bitwarden telegram-desktop lxappearance netcat;

# Install and set zsh
./oh-my-zsh/zsh.sh;
./oh-my-zsh/oh-my-zsh.sh;
./oh-my-zsh/autosuggestion.sh;

# Set permanent shortcuts
./scripts/gitlola.sh;
./scripts/keyboard-us-altgr-variant.sh;

# Copy rcFiles
cp rcFiles/vimrc ~/.vimrc;
cp rcFiles/zshrc ~/.zshrc;

# Install vim vundle
./install-vundle/install.sh;

# Install all plugins
vim +PluginInstall +qall
