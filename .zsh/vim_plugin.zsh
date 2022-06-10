if [[ ! -e ~/.vim/pack/local/start/plugin/editorconfig.vim ]]; then
    mkdir -p ~/.vim/pack/local/start
    git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/local/start
fi
