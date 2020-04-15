sudo apt install -y vim vim-gtk3 git zsh openssh-client snapd vsftpd evince gparted htop xclip

sudo ./oh-my-zsh/zsh.sh
sudo ./oh-my-zsh/oh-my-zsh.sh
sudo ./oh-my-zsh/autosuggestion.sh

sudo ./scripts/gitlola.sh
sudo ./scripts/keyboard-us-altgr-variant.sh

sudo cp rcFiles/vimrc ~/.vimrc && sudo cp rcFiles/zshrc ~/.zshrc
