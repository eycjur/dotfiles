source ~/shell/functions.sh

__prompt_prefix() {
    local prefix=""
    if [ -n "${CODESPACE_NAME:-}" ]; then
        prefix+=$'\[\033[33m\](codespace)\[\033[0m\]'
    fi
    if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
        prefix+=$'\[\033[35m\](ssh)\[\033[0m\]'
    fi
    if [ -f /.dockerenv ]; then
        prefix+=$'\[\033[36m\](docker)\[\033[0m\]'
    fi
    printf '%s' "$prefix"
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

    if git_user_part=$(git config user.name 2>/dev/null) && [ -n "$git_user_part" ]; then
        user_name=$git_user_part
    else
        user_name=$'\[\033[41m\]No User Name\[\033[0m\]'
    fi

    if ! git diff --cached --quiet 2>/dev/null; then
        staged="!"
    fi
    if ! git diff --quiet 2>/dev/null; then
        unstaged="+"
    fi

    printf '%s%s[%s(%s)]' "$staged" "$unstaged" "$branch" "$user_name"
}

__set_prompt() {
    local exit_code=$?
    local exit_part="" prefix="" git_part="" prompt_char='$' pwd_part

    [ "$(id -u)" -eq 0 ] && prompt_char='#'

    if [ "$exit_code" -ne 0 ]; then
        exit_part=$'\[\033[31m\]['"${exit_code}"$']\[\033[0m\]'
    fi

    prefix=$(__prompt_prefix)
    pwd_part=$(__prompt_pwd)
    git_part=$(__prompt_git_info)

    PS1="${prefix}${exit_part}"$'\[\033[42m\]'"${USER}@${HOSTNAME%%.*}"$'\[\033[0m\] '
    PS1+=$'\[\033[32m\]'"${pwd_part}"$'\[\033[0m\] '
    if [ -n "$git_part" ]; then
        PS1+=$'\[\033[36m\]'"${git_part}"$'\[\033[0m\]'
    fi
    PS1+=$'\n\[\033[37m\]'"${prompt_char} "$'\[\033[0m\]'
}

case $- in
    *i*)
        PROMPT_COMMAND=__set_prompt
        ;;
esac
