# ファイルが有れば実行する関数
# $1: ファイル名
function run_if_exists() {
    if [[ -f "$1" ]]; then
        . "$1"
    else
        echo "File not found: $1"
    fi
}

# コマンドの終了ステータスが0ならエイリアスを設定する（空白を含むコマンドに対応）
# $1: エイリアス名, $2: コマンド名
function set_alias_if_success () {
    if command -v "$2" > /dev/null; then
        alias "$1"="$2"
    fi
}
