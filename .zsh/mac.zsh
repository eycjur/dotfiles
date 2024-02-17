source ~/.zsh/functions.zsh
source ~/.zsh/fzf.zsh

alias exp="open"
alias C="pbcopy"
set_alias_if_success "sed" "gsed"
set_alias_if_success "awk" "gawk"
set_alias_if_success "date" "gdate"
set_alias_if_success "grep" "ggrep"

run_if_exists "${HOME}/.iterm2_shell_integration.zsh"
