echo "$(basename $0)"

# ファイルが有れば実行する関数
# $1: ファイル名
function run_if_exists() {
    if [[ -f $1 ]]; then
        . $1
    else
        echo "File not found: $1"
    fi
}

alias exp="open ."
alias C="pbcopy"
alias sed="gsed"

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin/:$PATH"
export PATH="/usr/local/opt/gawk/bin/:$PATH"

run_if_exists $(brew --prefix nvm)/nvm.sh
run_if_exists $(brew --prefix nvm)/etc/bash_completion.d/nvm
run_if_exists "${HOME}/.iterm2_shell_integration.zsh"
