source ~/.zsh/functions.zsh

# コマンドのオプションをデフォルトにする
alias ls='ls --color'
alias ll='ls -lahp --color'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'
alias du="du -bha -d 1 . | sort -hr"
alias -g G='| grep'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

set_alias_if_success "vim" "nvim"  # nvimがあれば利用
alias vi="vim"

alias d="docker"
set_alias_if_success "dc" "docker-compose"
set_alias_if_success "dc" "docker compose"
alias e="exit"
alias g="git"
alias t="tmux"
alias tf="terraform"
alias dotfiles="cd ~/dotfiles"
alias his="history 1000 | grep "
alias px="poetry run python -m src"

# gitコマンドをgit不要にする
alias add="git add"
alias cm="git commit"
alias commit="git commit"
alias cma="git commit --amend"
alias dfc="git diff --cached"
alias st="git status"
alias br="git branch"
alias restore="git restore"
alias sw="git switch"
alias log="git log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'"
alias push="git push origin"
