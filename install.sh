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

set +u
source "${HOME}"/.zshrc
set -u
