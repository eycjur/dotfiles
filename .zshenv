# zshenvはどんな場合（シェルスクリプト等の実行）でも読み込まれる
# https://qiita.com/muran001/items/7b104d33f5ea3f75353f

export PATH="${HOME}/.pyenv/bin:${PATH}"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/go/bin:${PATH}"
export PATH="${HOME}/local/golang/bin:${PATH}"
export PATH="${HOME}/.rd/bin:${PATH}"  # rancher desktop
export PATH="${HOME}/.nodebrew/current/bin:${PATH}"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"

# Local auto detect
if locale -a | grep -q "ja_JP.UTF-8"; then
    export LANG=ja_JP.UTF-8
    export LC_CTYPE=ja_JP.UTF-8
else
    export LANG=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
fi
export COMPOSE_MENU=0
