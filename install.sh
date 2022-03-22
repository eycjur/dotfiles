#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEeuxo pipefail

DOT_FILES=(.zshrc .vimrc .gitconfig)
DOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in ${DOT_FILES[@]}; do
  ln -sf "${DOT_DIR}/${file}" ~/"${file}"
done

# nvimの設定ファイルは別のディレクトリ
mkdir -p ~/.config/nvim
ln -sf "${DOT_DIR}/.vimrc" ~/.config/nvim/init.vim


set +ux
source "${HOME}"/.zshrc
set -ux
