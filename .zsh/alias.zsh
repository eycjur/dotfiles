source ~/.zsh/functions.zsh

# コマンドを上書きする
set_alias_if_success "cat" "bat"
set_alias_if_success "curl" "http"
set_alias_if_success "du" "dust"
set_alias_if_success "df" "duf"
set_alias_if_success "find" "fd"
set_alias_if_success "grep" "rg"
set_alias_if_success "top" "btm"
set_alias_if_success "top" "htop"
set_alias_if_success "vim" "nvim"
set_alias_if_success "vi" "vim"

# コマンドのオプションをデフォルトにする
alias ls='ls --color'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'
alias du="du -bha -d 1 . | sort -hr"

# 短縮コマンド
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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
alias ll='ls -lahp'
alias tf="terraform"
alias his="history 1 | grep "
alias psa="ps aucr"

alias dotfiles="cd ~/dotfiles"

# |の短縮コマンド
alias -g G='| grep'
alias -g L='| less'

# gitコマンドをgit不要にする
alias add="git add"
alias br="git branch"
alias ch="git cherry-pick"
alias cm="git commit"
alias cma="git commit --amend"
alias dff="git diff"
alias dfc="git diff --cached"
alias push="git push"
alias pusho="git push origin"
alias pull="git pull"
alias rs="git restore"
alias ss="git stash"
alias st="git status"
alias st-detail="GIT_TRACE=1 GIT_TRACE_PERFORMANCE=1 git st"
alias sw="git switch"
alias log="git log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'"

# dockerコマンドをdocker不要にする
alias dprune="docker system prune --volumes -af"
alias gprune="git fetch -a && git branch --merged | grep 'feature' | grep -v '*' | xargs git branch -d && git gc"
