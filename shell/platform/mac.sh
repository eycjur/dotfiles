source ~/shell/functions.sh

if ! is_command_exists "fzf"; then
    brew install fzf
fi
source ~/shell/fzf.sh

alias exp="open"
alias C="pbcopy"
set_alias_if_success "sed" "gsed"
set_alias_if_success "awk" "gawk"
set_alias_if_success "date" "gdate"
set_alias_if_success "grep" "ggrep"

if is_command_exists "mise"; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        eval "$(mise activate zsh)"
    elif [ -n "${BASH_VERSION:-}" ]; then
        eval "$(mise activate bash)"
    fi
fi

if [ -n "${ZSH_VERSION:-}" ]; then
    if [ ! -f "${HOME}/.iterm2_shell_integration.zsh" ]; then
        curl -L https://iterm2.com/misc/install_shell_integration.sh | bash
        sudo chmod +x "${HOME}/.iterm2_shell_integration.zsh"
    fi
    source "${HOME}/.iterm2_shell_integration.zsh"
fi

if [ -f "${HOME}/.ssh/id_rsa" ]; then
    ssh-add --apple-use-keychain ~/.ssh/id_rsa
fi
if [ -f "${HOME}/.ssh/id_ed25519" ]; then
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
fi
