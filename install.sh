#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEeuxo pipefail

DOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in .zshrc .vimrc; do
  ln -sf "${DOT_DIR}/${file}" ~/"${file}"
done

set +ux
source "${HOME}"/.zshrc
set -ux
