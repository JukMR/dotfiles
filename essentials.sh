sudo apt install -y vim vim-gtk3 git zsh openssh-client snapd vsftpd evince gparted htop xclip

./oh-my-zsh/zsh.sh
./oh-my-zsh/oh-my-zsh.sh
./oh-my-zsh/autosuggestion.sh

./scripts/gitlola.sh
./scripts/keyboard-us-altgr-variant.sh

cp rcFiles/vimrc ~/.vimrc && sudo cp rcFiles/zshrc ~/.zshrc
