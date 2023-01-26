# 作業はホームディレクトリに移動
cd ~ > /dev/null

# verコマンドがなければインストール
if ! type ver > /dev/null 2>&1; then
    git clone https://github.com/eycjur/cli-display-version.git
    sudo ln -s $(pwd)/cli-display-version/ver /usr/local/bin/ver
fi

# helコマンドがなければインストール
if ! type hel > /dev/null 2>&1; then
    git clone https://github.com/eycjur/cli-display-help.git
    sudo ln -s $(pwd)/cli-display-help/hel /usr/local/bin/hel
fi
