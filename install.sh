#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEeuxo pipefail

DOT_FILES=(.zshrc .vimrc .gitconfig .tmux.conf)
DOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in ${DOT_FILES[@]}; do
    echo "${DOT_DIR}/${file}"
    ln -sf "${DOT_DIR}/${file}" ~/
done

# .zshディレクトリ内のファイル
mkdir -p ~/.zsh
for file in ${DOT_DIR}/.zsh/*; do
    echo $file
    ln -sf "${file}" ~/.zsh/$(basename ${file})
done

# nvimの設定ファイルは別のディレクトリ
mkdir -p ~/.config
for file in ${DOT_DIR}/.config/*; do
    echo $file
    ln -sf "${file}" ~/.config/$(basename ${file})
done

set +ux
source "${HOME}"/.zshrc
set -ux
