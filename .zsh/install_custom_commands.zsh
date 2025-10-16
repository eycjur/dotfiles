# verコマンドがなければインストール
if ! type ver > /dev/null 2>&1; then
    if [ ! -e "~/cli-display-version" ]; then
        git clone https://github.com/eycjur/cli-display-version.git ~/cli-display-version
        sudo ln -sf ~/cli-display-version/ver "${HOME}/.local/bin/ver"
    fi
fi

# helコマンドがなければインストール
if ! type hel > /dev/null 2>&1; then
    if [ ! -e "~/cli-display-help" ]; then
        git clone https://github.com/eycjur/cli-display-help.git ~/cli-display-help
        sudo ln -sf ~/cli-display-help/hel "${HOME}/.local/bin/hel"
    fi
fi
