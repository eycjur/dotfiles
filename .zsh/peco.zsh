# 参考記事
# https://qiita.com/reireias/items/fd96d67ccf1fdffb24ed
# https://qiita.com/keisukee/items/9b815e56a173a281f42f
#
# 使い方
# ctrl+r:過去に実行したコマンドを選択
# ctrl+f:過去に移動したディレクトリを選択
# git switch lb:ブランチの切り替え
# de:dockerコンテナに入る

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
    # 履歴の一覧を取得
    local list_number_dir="$(cdr -l)"
    # 履歴番号, ディレクトリ -> 文字長, ディレクトリ
    local list_length_dir="$(echo "$list_number_dir" | awk '{ print length(), $2 }')"
    # .から始まるディレクトリをパスに含む行を排除
    local list_length_dir_filtered="$(echo "$list_length_dir" | awk '{ if ($2 !~ /[\/~]\./ ){ print  $0 }}')"
    # 文字長でソート
    local list_length_dir_sorted="$(echo "$list_length_dir_filtered" | sort -n)"
    # 文字長, ディレクトリ -> ディレクトリ
    local list_dir="$(echo "$list_length_dir_sorted" | awk '{ print  $2 }')"
    # pecoを使用してディレクトリを選択
    local selected_dir="$(echo "$list_dir" | peco --prompt="cdr >" --query "$LBUFFER")"

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
