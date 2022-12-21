#!/bin/bash

dotdir=$HOME/dotfiles


diff -su --color $dotdir/rcFiles/zshrc ~/.zshrc
diff -su --color $dotdir/rcFiles/vimrc ~/.vimrc
diff -su --color $dotdir/rcFiles/bashrc ~/.bashrc

diff -su --color $dotdir/programs/kitty/kitty.conf ~/.config/kitty/kitty.conf
diff -su --color $dotdir/programs/awesome/rc.lua ~/.config/awesome/rc.lua