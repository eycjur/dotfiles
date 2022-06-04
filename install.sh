#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEeuxo pipefail

DOT_FILES=(.zsh .zshrc .vimrc .gitconfig .tmux.conf)
DOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in ${DOT_FILES[@]}; do
    ln -sf "${DOT_DIR}/${file}" ~/"${file}"
done

# nvimの設定ファイルは別のディレクトリ
mkdir -p ~/.config
echo "${DOT_DIR}/${file}"
for file in .config/*; do
    ln -sf "${DOT_DIR}/${file}" ~/${file}
done

set +ux
source "${HOME}"/.zshrc
set -ux

