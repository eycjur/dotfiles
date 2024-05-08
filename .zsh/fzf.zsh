# 参考記事
#
# 使い方
# ctrl+r: 過去に実行したコマンドを選択
# ctrl+f: 過去に移動したディレクトリを選択
# swz: git switch時のブランチの切り替え
# rbz: git rebase時のブランチの選択
# chz: git cherry-pick時のコミットハッシュの選択
# addz: git add時のファイルの選択
# de: dockerコンテナに入る
#
# fzfコマンドのオプション
#   --multi: 複数選択、--no-multi: 単一選択
#   --no-sort: ソートしない
#   --query: 検索文字列を指定
#   --prompt: プロンプトを指定
#   --preview: プレビューを表示
# プレビューのオプション
#   {}: 現在カーソルのある行の文字列
#   {q}: 検索文字列
#   {数字}: 現在カーソルのある行の文字列をスペースで区切った時のn番目(1始まり)の文字列

# デフォルトのオプション
export FZF_DEFAULT_OPTS="--cycle --reverse"


# 過去に実行したコマンドを選択
function select-history() {
    BUFFER=$(\history -n -r 1 | fzf --no-multi --no-sort --query "$LBUFFER" --prompt="History > ")
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
    local selected_dir="$(echo "$list_dir_filtered" | fzf --no-multi --no-sort --query "$LBUFFER" --prompt="cdr >")"

    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N change-directory
bindkey '^f' change-directory

# swz: git switch時のブランチの切り替え
function select-switch-brach() {
    local selected_branch=$(git branch | fzf --no-multi --query "$LBUFFER" --prompt "GIT BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        git switch $(echo "$selected_branch" | sed -e "s/^\*\s*//g")
    fi
}
alias swz=select-switch-brach

# swz: git rebase時のブランチの選択
function select-rebase-brach() {
    local selected_branch=$(git branch | fzf --no-multi --query "$LBUFFER" --prompt "GIT BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        git rebase $(echo "$selected_branch" | sed -e "s/^\*\s*//g")
    fi
}
alias rbz=select-rebase-brach

# rbz: git rebase時のブランチの選択
function select-rebase-branch() {
    local selected_branch
    selected_branch=$(git branch | fzf --no-multi --query "$LBUFFER" --prompt "REBASE BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        git rebase $(echo "$selected_branch" | sed -e "s/^\*\s*//g")
    fi
}
alias rbz=select-rebase-branch

# コミットハッシュを探す
function select-chrry-pick() {
    local selected_commit
    selected_commit=$(git log --all --oneline | fzf --no-multi --query "$LBUFFER" --prompt "COMMIT HASH>")
    if [ -n "$selected_commit" ]; then
        # <hash> <message> -> <hash>
        git cherry-pick $(echo "$selected_commit"  | cut -d " " -f 1)
    fi
}
alias chz=select-chrry-pick

# 編集されたファイルを選択
function select-git-add-with-preview() {
    local selected_files
    # selected_filesは改行区切りのファイル名
    selected_files=$(git status -uall --short |
        fzf --ansi --multi --query "$LBUFFER" --prompt "EDITED FILE>" --preview='
            if [[ {} =~ "^\?\?" ]]; then
                cat {2};
            else
                git diff --color {2};
            fi
        ' | awk '{print $2}')
    if [ -n "$selected_files" ]; then
        # 改行区切りを引数分割するために、echoでコマンド置換 ($(...)) を利用
        git add $(echo ${selected_files})
    fi
}
alias addz=select-git-add-with-preview

# dockerコンテナに入る
select-docker-exec() {
    local container_id
    container_id=$(docker ps | fzf --no-multi --query "$LBUFFER" --prompt "SELECT CONTAINER>")
    if [ -n "$container_id" ]; then
        # <container_id> <name> ... -> <container_id>
        docker exec -it $(echo "$container_id" | cut -d " " -f 1) /bin/bash
    fi
}
alias de=select-docker-exec
