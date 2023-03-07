#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEueo pipefail

DOT_FILES=(.zshrc .vimrc .gitconfig .gitconfig.local .tmux.conf)
DOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in ${DOT_FILES[@]}; do
    if [ ! -e "${DOT_DIR}/${file}" ]; then
    	echo "${DOT_DIR}/${file}が存在しません"
    fi

    echo "create symbolic link: ${DOT_DIR}/${file}"
    ln -sf "${DOT_DIR}/${file}" ~/
done

# .zshディレクトリ内のファイルとnvimの設定ファイル
mkdir -p ~/.zsh ~/.config/nvim
for file in ${DOT_DIR}/.{zsh,config/nvim}/*; do
    echo "create symbolic link: ${file}"
    ln -sf "${file}" ~/$(basename $(dirname ${file}))/$(basename ${file})
done

set +u
source "${HOME}"/.zshrc
set -u
