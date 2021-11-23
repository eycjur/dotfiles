#!/bin/zsh

DOT_DIR=$(cd $(dirname $0); pwd)
echo $DOT_DIR

dotfiles=(.zshrc .vimrc)

for file in "${dotfiles[@]}"; do
	echo $file
	ln -sf ${DOT_DIR}/$file ~/$file
done
source ~/.zshrc

