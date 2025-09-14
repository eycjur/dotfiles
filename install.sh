#!/bin/zsh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する

set -CEueo pipefail

cd "$(dirname "$0")"
DOT_DIR="$(pwd)"
DOT_FILES=(.bashrc .zshrc .zshenv .vimrc .gitconfig .gitconfig.local .tmux.conf .zsh/* .config/git/*)

for file in ${DOT_FILES[@]}; do
    if [ ! -e "${DOT_DIR}/${file}" ]; then
        echo "${file}が存在しません"
        continue
    fi

    # ディレクトリが含まれる場合はディレクトリを作成
    if [[ "$(dirname "${file}")" != "." ]]; then
        mkdir -p ~/"$(dirname "${file}")"
    fi

    echo "create symbolic link: ${file}"
    ln -sf "${DOT_DIR}/${file}" ~/"${file}"
done

# nvimの設定ファイル
mkdir -p ~/.config/nvim
ln -sf "${DOT_DIR}/.vimrc" ~/.config/nvim/init.vim
echo "create symbolic link: nvim/init.vim"

# claude codeの設定ファイル
mkdir -p ~/.claude ~/.claude/agents
ln -sf "${DOT_DIR}/claude_code/settings.json" ~/.claude/settings.json
CLAUDE_DIRS=(agents commands)
for dir in ${CLAUDE_DIRS[@]}; do
    mkdir -p ~/.claude/"${dir}"
    for file in "${DOT_DIR}"/claude_code/"${dir}"/*; do
        if [ -f "${file}" ]; then
            ln -sf "${file}" ~/.claude/"${dir}"/"$(basename "${file}")"
            echo "create symbolic link: .claude/${dir}/$(basename "${file}")"
        fi
    done
done

# codexの設定ファイル
mkdir -p ~/.codex
for file in "${DOT_DIR}"/codex/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.codex/"$(basename "${file}")"
        echo "create symbolic link: .codex/$(basename "${file}")"
    fi
done

set +u
source "${HOME}"/.zshrc
set -u
