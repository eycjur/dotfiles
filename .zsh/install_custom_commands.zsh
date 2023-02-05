# verコマンドがなければインストール
if ! type ver > /dev/null 2>&1; then
    git clone https://github.com/eycjur/cli-display-version.git ~/cli-display-version
    sudo ln -s ~/cli-display-version/ver /usr/local/bin/ver
fi

# helコマンドがなければインストール
if ! type hel > /dev/null 2>&1; then
    git clone https://github.com/eycjur/cli-display-help.git ~/cli-display-help
    sudo ln -s ~/cli-display-help/hel /usr/local/bin/hel
fi
