echo "$(basename $0)"

if [ ! -e ~/.zsh/zsh-autocomplete ]; then
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/zsh-autocomplete
fi
source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
