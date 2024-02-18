#!/bin/zsh

set -CEueo pipefail

DOTFILES_REPOSITORY="https://github.com/eycjur/dotfiles"
TARGET="${HOME}/dotfiles"

# コマンドが存在するか確認する
# $1: コマンド名
function is_command_exists() {
    command -v "$1" > /dev/null 2>&1
}

if [ -d "${TARGET}" ]; then
    echo "既に${TARGET}が存在します"
    exit 1
fi

if is_command_exists "git"; then
    git clone "${DOTFILES_REPOSITORY}" "${TARGET}"
elif is_command_exists "curl"; then
    curl -L "${DOTFILES_REPOSITORY}/archive/main.tar.gz" | tar xz
    mv dotfiles-main "${TARGET}"
else
    echo "gitまたはcurlが必要です"
    exit 1
fi

chmod +x ${TARGET}/install.sh
${TARGET}/install.sh
