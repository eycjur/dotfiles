# 参考記事
# https://qiita.com/reireias/items/fd96d67ccf1fdffb24ed
# https://qiita.com/keisukee/items/9b815e56a173a281f42f
#
# 使い方
# ctrl+r:過去に実行したコマンドを選択
# ctrl+f:過去に異動したディレクトリを選択
# git switch lb:ブランチの切り替え
# de:dockerコンテナに入る

echo "$(basename $0)"

# 過去に実行したコマンドを選択
function peco-select-history() {
    BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
    zle accept-line
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi

# 過去に移動したことのあるディレクトリを選択
function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --prompt="cdr >" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^f' peco-cdr

# ブランチを切り替え
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

# dockerコンテナに入る
alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'
