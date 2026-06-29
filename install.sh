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
DOT_FILES=(.bashrc .zshrc .zshenv .vimrc .gitconfig .gitconfig.local .tmux.conf .npmrc shell/functions.sh shell/alias.sh shell/env.sh shell/fzf.sh shell/platform/* shell/bash/* shell/zsh/* .config/git/* .config/uv/*)

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

# vim plugin
source "${DOT_DIR}/shell/vim_plugin.sh"

# claude codeの設定ファイル
# sandbox環境(IS_SANDBOX)ではsandbox用の設定を使う(判定はshell/bash/prompt.shを参照)
mkdir -p ~/.claude ~/.claude/agents
if [ -n "${IS_SANDBOX:-}" ]; then
    CLAUDE_SETTINGS="claude_code/settings.sandbox.json"
else
    CLAUDE_SETTINGS="claude_code/settings.json"
fi
ln -sf "${DOT_DIR}/${CLAUDE_SETTINGS}" ~/.claude/settings.json
echo "create symbolic link: .claude/settings.json (${CLAUDE_SETTINGS})"
ln -sf "${DOT_DIR}/claude_code/statusline.sh" ~/.claude/statusline.sh
echo "create symbolic link: .claude/statusline.sh"
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
# skills/<skill_name>/SKILL.mdを~/.claude/skills/<skill_name>/SKILL.mdにシンボリックリンクする
for file in "${DOT_DIR}"/claude_code/skills/*/SKILL.md; do
    if [ -f "${file}" ]; then
        skill_name="$(basename "$(dirname "${file}")")"
        mkdir -p ~/.claude/skills/"${skill_name}"
        ln -sf "${file}" ~/.claude/skills/"${skill_name}"/SKILL.md
        echo "create symbolic link: .claude/skills/${skill_name}/SKILL.md"
    fi
done

# cursorの設定ファイル
mkdir -p ~/.cursor/commands
for file in "${DOT_DIR}"/cursor/commands/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.cursor/commands/"$(basename "${file}")"
        echo "create symbolic link: .cursor/commands/$(basename "${file}")"
    fi
done

# codexの設定ファイル
mkdir -p ~/.codex
for file in "${DOT_DIR}"/codex/*; do
    if [ -f "${file}" ]; then
        ln -sf "${file}" ~/.codex/"$(basename "${file}")"
        echo "create symbolic link: .codex/$(basename "${file}")"
    fi
done

# skillsはgh skill管理で、シンボリックリンクのみ設定する
mkdir -p ~/.claude/skills
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
