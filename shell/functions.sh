# ファイルが有れば実行する関数
# $1: ファイル名
function run_if_exists() {
    if [[ -f "$1" ]]; then
        . "$1"
    else
        echo "File not found: $1"
    fi
}

# コマンドが存在するか確認する
# $1: コマンド名
function is_command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# コマンドの終了ステータスが0ならエイリアスを設定する
# $1: エイリアス名, $2: コマンド名（空白を含むコマンドにも対応）
function set_alias_if_success () {
    if command -v "$(echo $2 | cut -d " " -f 1)" > /dev/null 2>&1; then
        alias "$1"="$2"
    fi
}

# コマンドがなければ、fallbackコマンドを設定する
# $1: コマンド名（空白を含むコマンドにも対応）, $2: フォールバックコマンド
function set_alias_if_not_exists () {
    if ! command -v "$(echo $1 | cut -d " " -f 1)" > /dev/null 2>&1; then
        alias "$1"="$2"
    fi
}

# Apple container VM 内か（/proc/cmdline の init=/sbin/vminitd — 非公式ヒューリスティック）
function is_apple_container() {
    case "${__APPLE_CONTAINER_CACHED:-}" in
        1) return 0 ;;
        0) return 1 ;;
    esac
    if [ -r /proc/cmdline ] && grep -q 'init=/sbin/vminitd' /proc/cmdline 2>/dev/null; then
        __APPLE_CONTAINER_CACHED=1
        return 0
    fi
    __APPLE_CONTAINER_CACHED=0
    return 1
}
