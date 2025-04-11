source ~/.zsh/functions.zsh


if ! is_command_exists "fzf"; then
    sudo apt-get install fzf
fi
source ~/.zsh/fzf.zsh
