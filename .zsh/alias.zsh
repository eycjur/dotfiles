source ~/.zsh/functions.zsh

# コマンドのオプションをデフォルトにする
alias ls='ls --color'
alias rm='rm -v'
alias cp='cp -v'
alias mv='mv -v'
alias mkdir='mkdir -p'
alias du="du -bha -d 1 . | sort -hr"
alias df="df -hT"

# 短縮コマンド
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias c="cursor"
alias cc="claude"
alias ccc="claude -c"
alias d="docker"
alias e="exit"
alias g="git"
alias h="history 1"
alias l="limactl"
alias t="tmux"
alias pc="pre-commit"
alias pca="pre-commit run --all-files"

set_alias_if_success "dc" "docker-compose"
set_alias_if_success "dc" "docker compose"
alias ll='ls -lAhF --time-style=long-iso'
alias tf="terraform"
alias his="history 1 | grep "
alias psa="ps aucr"
alias mkcd='(){mkdir -p "$@" && cd "$1"}'
alias groot="cd $(git rev-parse --show-toplevel)"
alias clear="clear && printf '\e[3J'"

alias dotfiles="cd ~/dotfiles"

# globalのalias
alias -g G='grep'
alias -g L='less'

# 設定ファイルの短縮アクセス
alias -g ssh_config='~/.ssh/config'
alias -g zshenv='~/.zshenv'
alias -g zshrc='~/.zshrc'
alias -g vimrc='~/.vimrc'
alias -g gitconfig='~/.gitconfig'
alias -g gitconfig.local='~/.gitconfig.local'
alias -g gitignore='~/.config/git/ignore'
alias -g alias.zsh='~/.zsh/alias.zsh'
alias -g git_info_exclude="$(git rev-parse --show-toplevel)/.git/info/exclude"
alias -g git_config="$(git rev-parse --show-toplevel)/.git/config"

# コマンドを上書きする
set_alias_if_success "cat" "bat -pP"
set_alias_if_success "du" "dust"
set_alias_if_success "df" "duf"
set_alias_if_success "grep" "rg"
set_alias_if_success "ls" 'eza -F'
set_alias_if_success "ll" 'eza -alhH -F=always --group --git --time-style=long-iso --color-scale=age'
set_alias_if_success "vim" "nvim"
set_alias_if_success "vi" "vim"
set_alias_if_success "diff" "difft"

# gitコマンドをgit不要にする
alias add="git add"
alias br="git br"
alias ch="git ch"
alias cm="git cm"
alias cma="git cma"
alias dff="git dff"
alias dfc="git dfc"
alias down="git down"
alias pu="git pu"
alias push="git push"
alias pushf="git pushf"
alias pull="git pull"
alias rb="git rb"
alias rbi="git rbi"
alias rs="git rs"
alias sl="git sl"
alias ss="git ss"
alias sp="git sp"
alias sp-abort="git sp-abort"
alias st="git st"
alias st-detail="GIT_TRACE=1 GIT_TRACE_PERFORMANCE=1 git st"
alias sw="git sw"
alias log="git graph"

# 掃除系コマンド
alias dprune='(docker stop $(docker ps -q) || true) && docker system prune --volumes -af && docker volume prune -af'
alias dcprune='docker compose down --rmi all --volumes --remove-orphans'
alias gprune="git fetch && git branch --merged | grep -v 'main' | grep -v 'develop' | grep -v '\*' | xargs git branch -d && git gc"
