echo "$(basename $0)"

if type starships > /dev/null; then
    curl -sS https://starship.rs/install.sh | sh

    # フォントの文字化けを直す
    mkdir -p ~/programing/git
    cd ~/programing/git
    git clone --branch=master --depth 1 https://github.com/ryanoasis/nerd-fonts.git
    cd nerd-fonts
    ./install.sh
fi
eval "$(starship init zsh)"
