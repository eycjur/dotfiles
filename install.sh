#!/bin/sh
# dotfileをシンボリックリンクでホームディレクトリに置いて適用する
# zsh があれば zsh、なければ bash で実行する
if [ -z "${ZSH_VERSION:-}" ]; then
    if command -v zsh >/dev/null 2>&1; then
        exec zsh "$0" "$@"
    elif [ -z "${BASH_VERSION:-}" ] && command -v bash >/dev/null 2>&1; then
        exec bash "$0" "$@"
    fi
fi

set -euo pipefail

cd "$(dirname "$0")"
DOT_DIR="$(pwd)"
DOT_FILES=(.bashrc .zshrc .zshenv .vimrc .gitconfig .gitconfig.local .tmux.conf .npmrc .config/git/* .config/uv/* .config/nvim/* .config/herdr/*)

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

echo "create symbolic link: shell"
ln -sf "${DOT_DIR}/shell" ~/shell

# vim plugin
source "${DOT_DIR}/shell/vim_plugin.sh"

# claude codeの設定ファイル
# sandbox環境(IS_SANDBOX)ではsandbox用の設定を使う(判定はshell/bash/prompt.shを参照)
mkdir -p ~/.claude
for file in "${DOT_DIR}"/claude/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.claude/"$(basename "${file}")"
        echo "create symbolic link: .claude/$(basename "${file}")"
    fi
done
if [ -n "${IS_SANDBOX:-}" ]; then
    ln -sf "${DOT_DIR}/claude/settings.sandbox.json" ~/.claude/settings.json
    echo "create symbolic link: .claude/settings.json (claude/settings.sandbox.json)"
fi
# skillsはgh skillと共存するため、skillディレクトリ単位でリンクする
mkdir -p ~/.claude/skills
for dir in "${DOT_DIR}"/claude/skills/*/; do
    [ -d "${dir}" ] || continue
    skill_name="$(basename "${dir%/}")"
    ln -sf "${dir%/}" ~/.claude/skills/"${skill_name}"
    echo "create symbolic link: .claude/skills/${skill_name}"
done

# codexの設定ファイル
mkdir -p ~/.codex
for file in "${DOT_DIR}"/codex/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.codex/"$(basename "${file}")"
        echo "create symbolic link: .codex/$(basename "${file}")"
    fi
done

# codex/cursorのskillsは~/.claude/skillsを参照する(gh skill管理)
mkdir -p ~/.cursor
ln -sfn "${HOME}/.claude/skills" "${HOME}/.codex/skills"
ln -sfn "${HOME}/.claude/skills" "${HOME}/.cursor/skills"

# 設定を読み込んで適用する
set +u
if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC1091
    source "${HOME}/.zshrc"
elif [ -f "${HOME}/.bashrc" ]; then
    # shellcheck disable=SC1091
    source "${HOME}/.bashrc"
fi
set -u
