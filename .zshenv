# zshenvはどんな場合（シェルスクリプト等の実行）でも読み込まれる
# https://qiita.com/muran001/items/7b104d33f5ea3f75353f

echo "PATH: ${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/.local/go/bin:${PATH}"
export PATH="${HOME}/go/bin:${PATH}"
export PATH="${HOME}/local/golang/bin:${PATH}"
export PATH="${HOME}/local/go/bin:${PATH}"
export PATH="${HOME}/.rd/bin:${PATH}"  # rancher desktop
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"

echo "PATH: ${PATH}"


# Local auto detect
if locale -a 2>/dev/null | grep -q "ja_JP.UTF-8"; then
    export LANG=ja_JP.UTF-8
    export LC_CTYPE=ja_JP.UTF-8
elif locale -a 2>/dev/null | grep -q "ja_JP.utf8"; then
    export LANG=ja_JP.utf8
    export LC_CTYPE=ja_JP.utf8
elif locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
    export LANG=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
elif locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    export LANG=en_US.utf8
    export LC_CTYPE=en_US.utf8
elif locale -a 2>/dev/null | grep -q "C.utf8"; then
    export LANG=C.utf8
    export LC_CTYPE=C.utf8
else
    export LANG=C
    export LC_CTYPE=C
fi
export COMPOSE_MENU=0
