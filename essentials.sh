# Install fundamental programs
sudo apt install -y vim vim-gtk3 git zsh openssh-client snapd vsftpd evince gparted htop xclip;

# Install and set zsh
./oh-my-zsh/zsh.sh;
./oh-my-zsh/oh-my-zsh.sh;
./oh-my-zsh/autosuggestion.sh;

# Set permanent shortcuts
./scripts/gitlola.sh;
./scripts/keyboard-us-altgr-variant.sh;

# Copy rcFiles
cp rcFiles/vimrc ~/.vimrc; cp rcFiles/zshrc ~/.zshrc;

# Install vim vundle
./install-vundle/install.sh;

# Install all plugins
vim +PluginInstall +qall
