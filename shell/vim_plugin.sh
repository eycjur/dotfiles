EDITORCONFIG_VIM_VERSION="v1.2.1"

if [[ ! -e ~/.vim/pack/local/start/plugin/editorconfig.vim ]]; then
    mkdir -p ~/.vim/pack/local/start
    git clone --branch "${EDITORCONFIG_VIM_VERSION}" --depth 1 \
        https://github.com/editorconfig/editorconfig-vim.git \
        ~/.vim/pack/local/start
fi
