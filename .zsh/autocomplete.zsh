if [ ! -e ~/programing/git/zsh-autocomplete ]; then
    mkdir -p ~/programing/git
    cd ~/programing/git
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git
    source ~/programing/git/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

