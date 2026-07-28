# 参考記事
#
# 使い方
# ctrl+r: 過去に実行したコマンドを選択
# ctrl+f: 過去に移動したディレクトリを選択
# ctrl+t: カレント以下のファイルを選んでコマンドラインに挿入
# swz: git switch時のブランチの切り替え
# rbz: git rebase時のブランチの選択
# rbiz: git rebase -i時のコミットハッシュの選択
# chz: git cherry-pick時のコミットハッシュの選択
# addz: git add時のファイルの選択
# spz: git stash pop時のスタッシュの選択
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

_fzf_query() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "${LBUFFER:-}"
    else
        echo "${READLINE_LINE:-}"
    fi
}

# zsh cdr / bash 共通のディレクトリ履歴（~/.cache/chpwd-recent-dirs）
__recent_dirs_file="${HOME}/.cache/chpwd-recent-dirs"

__recent_dirs_list() {
    local file="${__recent_dirs_file}"
    [ -f "$file" ] || return 0
    sed -e "s/^\$'//" -e "s/'$//" "$file" | awk '{ if ($0 !~ /[\/~]\./ ){ print $0 }}'
}

__recent_dirs_add() {
    local dir="${1:-$PWD}"
    local file="${__recent_dirs_file}"
    local escaped line tmp
    mkdir -p "${HOME}/.cache"
    escaped=${dir//\\/\\\\}
    escaped=${escaped//\'/\\\'}
    line="\$'${escaped}'"
    tmp=$(mktemp "${file}.XXXXXX") || return
    {
        printf '%s\n' "$line"
        if [ -f "$file" ]; then
            grep -Fvx -- "$line" "$file" || true
        fi
    } | head -n 1000 >"$tmp"
    mv "$tmp" "$file"
}

# デフォルトのオプション
export FZF_DEFAULT_OPTS="--cycle --reverse"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_PREVIEW_COMMAND='bat --style=numbers --line-range=:500'
fi

# $(fzf) は stdin が非TTYのため FZF_DEFAULT_COMMAND が効かないので、一覧を明示的に渡す
__fzf_list_files() {
    if [ -n "${FZF_DEFAULT_COMMAND:-}" ]; then
        eval "${FZF_DEFAULT_COMMAND}"
    else
        find . -type f ! -path '*/.git/*' 2>/dev/null | sed 's|^\./||'
    fi
}

if [ -n "${ZSH_VERSION:-}" ]; then
    # 過去に実行したコマンドを選択
    function select-history() {
        BUFFER=$(\history -n -r 1 | fzf --no-multi --no-sort --query "$(_fzf_query)" --prompt="History > ")
        CURSOR=$#BUFFER
        zle clear-screen  # コマンドライン画面をクリア
    }
    zle -N select-history  # zleにselect-history関数を追加
    bindkey '^r' select-history  # Ctrl+Rキーをselect-history関数にバインド

    # 過去に移動したことのあるディレクトリを選択
    function change-directory () {
        # 履歴の一覧を取得
        local list_number_dir="$(cdr -l)"
        # 履歴番号 ディレクトリ -> ディレクトリ（スペース区切りでスペースを含むパス対応: 2番目以降のフィールド）
        local list_dir="$(echo "$list_number_dir" | cut -d' ' -f2-)"
        # .から始まるディレクトリをパスに含む行を排除
        local list_dir_filtered="$(echo "$list_dir" | awk '{ if ($1 !~ /[\/~]\./ ){ print  $0 }}')"
        # fzfを使用してディレクトリを選択
        local selected_dir="$(echo "$list_dir_filtered" | fzf --no-multi --no-sort --query "$(_fzf_query)" --prompt="cdr >")"

        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
        fi
    }
    zle -N change-directory
    bindkey '^f' change-directory

    # カレント以下のファイルを選んでコマンドラインに挿入（末尾トークンを補完）
    function select-file() {
        local selected query prefix preview_cmd
        if [[ "$LBUFFER" =~ [[:space:]]$ ]]; then
            query=""
            prefix="$LBUFFER"
        elif [[ "$LBUFFER" == *" "* ]]; then
            query="${LBUFFER##* }"
            prefix="${LBUFFER% *} "
        else
            query="$LBUFFER"
            prefix=""
        fi
        preview_cmd="${FZF_PREVIEW_COMMAND:-cat} {}"
        selected=$(__fzf_list_files | fzf --multi --query "$query" --prompt "FILE>" --preview "$preview_cmd")
        if [ -n "$selected" ]; then
            local -a files
            files=("${(@f)selected}")
            LBUFFER="${prefix}${(j: :)${(q)files}}"
        fi
        zle reset-prompt
    }
    zle -N select-file
    bindkey '^t' select-file
elif [ -n "${BASH_VERSION:-}" ]; then
    case $- in
    *i*)
        select-history() {
            local selected
            selected=$(HISTTIMEFORMAT= history | sed 's/^ *[0-9]* *//' | tac | fzf --no-multi --no-sort --query "$(_fzf_query)" --prompt="History > ")
            if [ -n "$selected" ]; then
                READLINE_LINE=$selected
                READLINE_POINT=${#READLINE_LINE}
            fi
        }

        change-directory() {
            local selected_dir
            selected_dir=$(__recent_dirs_list | fzf --no-multi --no-sort --query "$(_fzf_query)" --prompt="cdr >")
            if [ -n "$selected_dir" ]; then
                cd -- "$selected_dir" || return
                READLINE_LINE=
                READLINE_POINT=0
            fi
        }

        # カレント以下のファイルを選んでコマンドラインに挿入（末尾トークンを補完）
        select-file() {
            local selected query prefix before after preview_cmd quoted line
            before="${READLINE_LINE:0:${READLINE_POINT}}"
            after="${READLINE_LINE:${READLINE_POINT}}"
            if [[ "$before" =~ [[:space:]]$ ]] || [ -z "$before" ]; then
                query=""
                prefix="$before"
            elif [[ "$before" == *" "* ]]; then
                query="${before##* }"
                prefix="${before% *} "
            else
                query="$before"
                prefix=""
            fi
            preview_cmd="${FZF_PREVIEW_COMMAND:-cat} {}"
            selected=$(__fzf_list_files | fzf --multi --query "$query" --prompt "FILE>" --preview "$preview_cmd")
            if [ -n "$selected" ]; then
                quoted=""
                while IFS= read -r line; do
                    [ -n "$line" ] || continue
                    quoted+=$(printf '%q ' "$line")
                done <<< "$selected"
                READLINE_LINE="${prefix}${quoted% }$after"
                READLINE_POINT=$((${#READLINE_LINE} - ${#after}))
            fi
        }

        bind -x '"\C-r": select-history'
        bind -x '"\C-f": change-directory'
        bind -x '"\C-t": select-file'
        ;;
    esac
fi

# swz: git switch時のブランチの切り替え
function select-switch-brach() {
    local selected_branch=$(git branch | fzf --no-multi --query "$(_fzf_query)" --prompt "GIT BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        git switch $(echo "$selected_branch" | sed -e "s/^\*\s*//g")
    fi
}
alias swz=select-switch-brach

# bdz: git ブランチ削除時のブランチの選択
function select-delete-branch() {
    local selected_branch
    # selected_branchは改行区切りのブランチ名
    selected_branch=$(git branch | fzf --multi --query "$(_fzf_query)" --prompt "DELETE BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        # 改行区切りを引数分割するために、echoでコマンド置換 ($(...)) を利用
        git branch -d $(echo ${selected_branch} | sed -e "s/^\*\s*//g")
    fi
}
alias bdz=select-delete-branch

# rbz: git rebase時のブランチの選択
function select-rebase-branch() {
    local selected_branch
    selected_branch=$(git branch | fzf --no-multi --query "$(_fzf_query)" --prompt "REBASE BRANCH>")
    if [ -n "$selected_branch" ]; then
        # (*| ) <branch> -> <branch>
        git rebase $(echo "$selected_branch" | sed -e "s/^\*\s*//g")
    fi
}
alias rbz=select-rebase-branch

# rbiz: git rebase -i時のコミットハッシュの選択
function select-rebase-interactive-commit() {
    local selected_commit
    selected_commit=$(git log --oneline | fzf --no-multi --query "$(_fzf_query)" --prompt "COMMIT HASH>")
    if [ -n "$selected_commit" ]; then
        # <hash> <message> -> <hash>
        git rebase -i $(echo "$selected_commit"  | cut -d " " -f 1)
    fi
}
alias rbiz=select-rebase-interactive-commit

# コミットハッシュを探す
function select-chrry-pick() {
    local selected_commit
    selected_commit=$(git log --all --oneline | fzf --no-multi --query "$(_fzf_query)" --prompt "COMMIT HASH>")
    if [ -n "$selected_commit" ]; then
        # <hash> <message> -> <hash>
        git cherry-pick $(echo "$selected_commit"  | cut -d " " -f 1)
    fi
}
alias chz=select-chrry-pick

# stashのdropを選択
function select-stash-drop() {
    local selected_stash
    selected_stash=$(git stash list | awk '{print $1}' | cut -d ':' -f1 | fzf --no-multi --query "$(_fzf_query)" --prompt "STASH>" --preview='git stash show -p --color {1}')
    if [ -n "$selected_stash" ]; then
        git stash drop $(echo "$selected_stash" | cut -d ":" -f 1)
    fi
}
alias sdz=select-stash-drop

# stashのpopを選択
function select-stash-pop() {
    local selected_stash
    selected_stash=$(git stash list | awk '{print $1}' | cut -d ':' -f1 | fzf --no-multi --query "$(_fzf_query)" --prompt "STASH>" --preview='git stash show -p --color {1}')
    if [ -n "$selected_stash" ]; then
        git stash pop $(echo "$selected_stash" | cut -d ":" -f 1)
    fi
}
alias spz=select-stash-pop

# 編集されたファイルを選択
function select-git-add-with-preview() {
    local selected_files
    # selected_filesは改行区切りのファイル名
    selected_files=$(git status -uall --short |
        fzf --ansi --multi --query "$(_fzf_query)" --prompt "EDITED FILE>" --preview='
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
function select-docker-exec() {
    local container_id
    container_id=$(docker ps | fzf --no-multi --query "$(_fzf_query)" --prompt "SELECT CONTAINER>")
    if [ -n "$container_id" ]; then
        # <container_id> <name> ... -> <container_id>
        docker exec -it $(echo "$container_id" | cut -d " " -f 1) /bin/bash
    fi
}
alias de=select-docker-exec
