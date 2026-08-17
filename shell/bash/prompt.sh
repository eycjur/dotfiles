# zsh から誤って source されても zsh プロンプトを壊さない
[ -n "${BASH_VERSION:-}" ] || return 0

source ~/shell/functions.sh

__bash_prompt_prefix() {
    __prompt_env_prefix bash
}

__prompt_pwd() {
    case $PWD in
        "$HOME") printf '~' ;;
        "$HOME"/*) printf '~%s' "${PWD#$HOME}" ;;
        *) printf '%s' "$PWD" ;;
    esac
}

__prompt_git_info() {
    is_command_exists git || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local branch staged="" unstaged="" user_name git_user_part

    branch=$(git branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi

    # zsh vcs_info と同じ: ! = magenta (staged), + = yellow (unstaged)
    if ! git diff --cached --quiet 2>/dev/null; then
        staged=$'\[\033[35m\]!\[\033[0m\]'
    fi
    if ! git diff --quiet 2>/dev/null; then
        unstaged=$'\[\033[33m\]+\[\033[0m\]'
    fi

    if git_user_part=$(git config user.name 2>/dev/null) && [ -n "$git_user_part" ]; then
        user_name=$git_user_part
    else
        user_name=$'\[\033[41m\]No User Name\[\033[0m\]\[\033[36m\]'
    fi

    printf '%s%s\[\033[36m\][%s(%s)]\[\033[0m\]' "$staged" "$unstaged" "$branch" "$user_name"
}

__set_prompt() {
    local exit_code=${1:-$?}
    local exit_part="" prefix="" git_part="" prompt_char='$' pwd_part host

    [ "$(id -u)" -eq 0 ] && prompt_char='#'

    if [ "$exit_code" -ne 0 ]; then
        exit_part=$'\[\033[31m\]['"${exit_code}"$']\[\033[0m\]'
    fi

    prefix=$(__bash_prompt_prefix)
    pwd_part=$(__prompt_pwd)
    git_part=$(__prompt_git_info)
    host="${HOSTNAME%%.*}"
    [ -n "$host" ] || host=$(hostname -s 2>/dev/null || hostname)

    # prefix + 赤exit + 緑背景 user@host + 緑pwd + git
    # （zsh は user@host が青背景）
    PS1="${prefix}${exit_part}"$'\[\033[42m\]'"${USER}@${host}"$'\[\033[0m\] '
    PS1+=$'\[\033[32m\]'"${pwd_part}"$'\[\033[0m\]'
    if [ -n "$git_part" ]; then
        PS1+=" ${git_part}"
    fi
    PS1+=$'\n\[\033[37m\]'"${prompt_char} "$'\[\033[0m\]'
}

# 直前の出力が改行なしだと prompt が同じ行に続くのを防ぐ（zsh の PROMPT_SP 相当）
__bash_prompt_ensure_newline() {
    local _esc _row _col
    [ -t 1 ] || return 0
    IFS='[;' read -rsd R -p $'\e[6n' _esc _row _col || return 0
    if [ -n "${_col:-}" ] && [ "$_col" -ne 1 ] 2>/dev/null; then
        printf '\033[7m%%\033[0m\n'
    fi
}

# ディレクトリ移動時に ll（zsh の chpwd 相当）
__LAST_PWD=$PWD
__bash_prompt_command() {
    local exit_code=$?
    __bash_prompt_ensure_newline
    if [ "$__LAST_PWD" != "$PWD" ]; then
        if command -v __recent_dirs_add >/dev/null 2>&1; then
            __recent_dirs_add "$PWD"
        fi
        ll
        __LAST_PWD=$PWD
    fi
    __set_prompt "$exit_code"
}

case $- in
    *i*)
        PROMPT_COMMAND=__bash_prompt_command
        ;;
esac
