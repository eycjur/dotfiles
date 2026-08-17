# ファイルが有れば実行する関数
# $1: ファイル名
function run_if_exists() {
    if [[ -f "$1" ]]; then
        . "$1"
    else
        echo "File not found: $1"
    fi
}

# ファイルが存在するか確認する
# $1: ファイル名
function is_file_exists() {
    [[ -f "$1" ]]
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

# prompt 用に色付き文字列を組み立てる。
# $1: ANSI 色, $2: 表示文字列
# 呼び出し元の so / se / c_reset（幅計算用の囲みとリセット）を参照する。
function __prompt_paint() {
    printf '%s' "${so}${1}${se}${2}${so}${c_reset}${se}"
}

# bash / zsh 共通の環境タグ。色は ANSI 共通、幅計算用の囲みだけ kind で切り替える。
# $1: bash | zsh
# $2: 任意。タグ列の先頭に足す文字列。省略時、bash なら青字 (bash) を付与。
#
# 表示例（複数条件が同時に真なら連結。IS_SANDBOX は常に先頭）:
#   🛡 (bash)(job:123, gpu:1)(cnode)(ssh)(docker)...
function __prompt_env_prefix() {
    local kind="${1:?}" extra="${2:-}"
    local prefix="" tags="" so se

    # prompt の見かけ幅からエスケープを除外する囲み（bash: \[ \], zsh: %{ %}）
    case "$kind" in
        zsh) so='%{' ; se='%}' ;;
        bash) so='\[' ; se='\]' ;;
        *) return 1 ;;
    esac

    # ANSI（両シェル共通）
    local c_blue=$'\033[34m'
    local c_magenta=$'\033[35m'
    local c_cyan=$'\033[36m'
    local c_red=$'\033[31m'
    local c_orange=$'\033[38;5;208m'
    local c_orange_bg_black=$'\033[48;5;208;30m'  # オレンジ背景・黒字
    local c_reset=$'\033[0m'

    # bash: → 青字 (bash)（引数 extra が空のときのデフォルト）
    if [ "$kind" = bash ] && [ -z "$extra" ]; then
        extra="$(__prompt_paint "$c_blue" "(bash)")"
    fi
    # SLURM job/gpu: → オレンジ背景・黒字。あるものだけ表示
    #   SLURM_JOBID → (job:<id>…)
    #   SLURM_GPUS  → (…, gpu:<n>)
    if [ -n "${SLURM_JOBID:-}" ] || [ -n "${SLURM_GPUS:-}" ]; then
        local slurm_tag=""
        if [ -n "${SLURM_JOBID:-}" ]; then
            slurm_tag="job:${SLURM_JOBID}"
        fi
        if [ -n "${SLURM_GPUS:-}" ]; then
            [ -n "$slurm_tag" ] && slurm_tag+=", "
            slurm_tag+="gpu:${SLURM_GPUS}"
        fi
        tags+="$(__prompt_paint "$c_orange_bg_black" "(${slurm_tag})")"
    fi
    # SLURM node: → オレンジ背景・黒字 (cnode)  ※計算ノード
    if [ -n "${SLURM_NODEID:-}" ]; then
        tags+="$(__prompt_paint "$c_orange_bg_black" "(cnode)")"
    fi
    # SSH: → 紫字 (ssh)
    if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
        tags+="$(__prompt_paint "$c_magenta" "(ssh)")"
    fi
    # DOCKER: → 水色 (docker)
    if [ -f /.dockerenv ]; then
        tags+="$(__prompt_paint "$c_cyan" "(docker)")"
    fi
    # APPTAINER: → 赤字 (apptainer)
    if [ -n "${APPTAINER_CONTAINER:-}" ]; then
        tags+="$(__prompt_paint "$c_red" "(apptainer)")"
    fi
    # DOCKER SANDBOX: → 水色 (sbx)
    # APPLE CONTAINER: → 赤字 (apple/container)
    # （両方該当しうるので docker sandbox を優先）
    if [ -n "${SANDBOX_VM_ID:-}" ]; then
        tags+="$(__prompt_paint "$c_cyan" "(sbx)")"
    elif is_apple_container; then
        tags+="$(__prompt_paint "$c_red" "(apple/container)")"
    fi

    prefix="${extra}${tags}"
    # SANDBOX: → 先頭にオレンジ 🛡
    # 🛡️(U+FE0F付き)はzshの幅計算が1になり次の文字と重なる。単一コードポイント+スペース
    if [ -n "${IS_SANDBOX:-}" ]; then
        prefix="$(__prompt_paint "$c_orange" "🛡 ")${prefix}"
    fi
    printf '%s' "$prefix"
}
