EDITORCONFIG_VIM_VERSION="v1.2.1"
# vim-gitgutterはタグを打っておらずmainブランチのみで運用されているため、コミットハッシュで固定する
VIM_GITGUTTER_COMMIT="21c977e8597c468c7dc76001389b0b430d46a4b0"

if [[ ! -e ~/.vim/pack/local/start/editorconfig-vim/plugin/editorconfig.vim ]]; then
    mkdir -p ~/.vim/pack/local/start/editorconfig-vim
    git clone --branch "${EDITORCONFIG_VIM_VERSION}" --depth 1 \
        https://github.com/editorconfig/editorconfig-vim.git \
        ~/.vim/pack/local/start/editorconfig-vim
fi

if [[ ! -e ~/.vim/pack/local/start/vim-gitgutter/plugin/gitgutter.vim ]]; then
    mkdir -p ~/.vim/pack/local/start/vim-gitgutter
    git -C ~/.vim/pack/local/start/vim-gitgutter init -q
    git -C ~/.vim/pack/local/start/vim-gitgutter remote add origin \
        https://github.com/airblade/vim-gitgutter.git
    git -C ~/.vim/pack/local/start/vim-gitgutter fetch --depth 1 origin "${VIM_GITGUTTER_COMMIT}"
    git -C ~/.vim/pack/local/start/vim-gitgutter checkout -q FETCH_HEAD
fi
