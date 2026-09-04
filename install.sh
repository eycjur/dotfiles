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
DOT_FILES=(.bashrc .zshrc .zshenv .vimrc .gitconfig .gitconfig.local .tmux.conf .npmrc .config/git/* .config/uv/* .config/nvim/* .config/herdr/* .config/agentsb/* .config/yazi/*)

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
ln -sfn "${DOT_DIR}/shell" ~/shell

# vim plugin
source "${DOT_DIR}/shell/vim_plugin.sh"

# yazi plugin
source "${DOT_DIR}/shell/yazi_plugin.sh"


# claude codeの設定ファイル
mkdir -p ~/.claude
for file in "${DOT_DIR}"/claude/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.claude/"$(basename "${file}")"
        echo "create symbolic link: .claude/$(basename "${file}")"
    fi
done
# sandbox or docker環境ではsandbox用の設定を使う
if [ -n "${IS_SANDBOX:-}" ] || [ -f /.dockerenv ]; then
    ln -sf "${DOT_DIR}/claude/settings.sandbox.json" ~/.claude/settings.json
    echo "create symbolic link: .claude/settings.json (claude/settings.sandbox.json)"
fi

# codexの設定ファイル
mkdir -p ~/.codex
for file in "${DOT_DIR}"/codex/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.codex/"$(basename "${file}")"
        echo "create symbolic link: .codex/$(basename "${file}")"
    fi
done

# skill-lock.jsonを読み込んでskillsを追加する
# Hack: lockファイルの更新端末のみdotfiles/.skill-lock.jsonを~/.agentsにsymlinkしている
mkdir -p ~/.agents/skills ~/.claude/skills ~/.codex/skills

if command -v jq >/dev/null 2>&1 && command -v npx >/dev/null 2>&1 && npx -y -- skills --help >/dev/null 2>&1; then
    jq -r '.skills|to_entries[]|"npx skills add \(.value.source) -g -s \(.key) -a codex -a cursor -a claude-code -y"' "${DOT_DIR}/.skill-lock.json" | sh
    # ローカルのskillsを追加する
    npx skills add ./skills -g -s '*' -a codex -a cursor -a claude-code -y
fi

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
