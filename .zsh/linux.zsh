source ~/.zsh/functions.zsh


if ! is_command_exists "fzf"; then
    sudo apt update && sudo apt install fzf
fi
source ~/.zsh/fzf.zsh
