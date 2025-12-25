# 基本的にzshを利用するが、makefileなどで利用するための最低限の設定

# コマンドの終了ステータスが0ならエイリアスを設定する
# $1: エイリアス名, $2: コマンド名（空白を含むコマンドにも対応）
function set_alias_if_success () {
    if command -v "$(echo $2 | cut -d " " -f 1)" > /dev/null 2>&1; then
        alias "$1"="$2"
    fi
}

alias ll='ls -lahp'

set_alias_if_success "sed" "gsed"
set_alias_if_success "awk" "gawk"
set_alias_if_success "date" "gdate"
set_alias_if_success "grep" "ggrep"

export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/go/bin:${PATH}"
export PATH="${HOME}/local/golang/bin:${PATH}"
export PATH="${HOME}/.rd/bin:${PATH}"  # rancher desktop
