# 参考記事
#
# 使い方
# ctrl+r: 過去に実行したコマンドを選択
# ctrl+f: 過去に移動したディレクトリを選択
# B: ブランチの切り替え
# H: コミットハッシュの選択
# F: 編集済みファイルの選択
# de: dockerコンテナに入る

# 過去に実行したコマンドを選択
function select-history() {
    BUFFER=$(\history -n -r 1 | fzf +m --no-sort --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
    zle clear-screen  # コマンドライン画面をクリア
    zle accept-line  # 現在の入力ラインを実行
}
zle -N select-history  # zleにselect-history関数を追加
bindkey '^r' select-history  # Ctrl+Rキーをselect-history関数にバインド

# 過去に移動したことのあるディレクトリを選択
function change-directory () {
    # 履歴の一覧を取得
    local list_number_dir="$(cdr -l)"
    # 履歴番号, ディレクトリ -> ディレクトリ
    local list_dir="$(echo "$list_number_dir" | awk '{ print $2 }')"
    # .から始まるディレクトリをパスに含む行を排除
    local list_dir_filtered="$(echo "$list_dir" | awk '{ if ($1 !~ /[\/~]\./ ){ print  $0 }}')"
    # fzfを使用してディレクトリを選択
    local selected_dir="$(echo "$list_dir_filtered" | fzf +m --no-sort --query "$LBUFFER" --prompt="cdr >")"

    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N change-directory
bindkey '^f' change-directory

# ブランチを切り替え
alias -g B='`git branch | fzf +m --query "$LBUFFER" --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

# コミットハッシュを探す
alias -g H='`git log --all --oneline | fzf +m --query "$LBUFFER" --prompt "COMMIT HASH>" | cut -d" " -f1`'

# 編集されたファイルを選択
alias -g F='`git status --short | fzf +m --query "$LBUFFER" --prompt "EDITED FILE>" | awk '\''{print $2}'\''`'

# dockerコンテナに入る
alias de='docker exec -it $(docker ps | fzf +m --query "$LBUFFER" --prompt "SELECT CONTAINER>" | cut -d " " -f 1) /bin/bash'
