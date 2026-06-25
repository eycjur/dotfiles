source ~/shell/functions.sh

if ! is_command_exists "fzf" || ! is_command_exists "vim" || ! is_command_exists "gh" ; then
    sudo apt update && sudo apt install -y fzf vim gh
fi
UV_VERSION="0.11.21"

if ! is_command_exists "uvx" ; then
    curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" | sh
fi
if ! is_command_exists "npx" ; then
    sudo apt install -y npm
fi

if ! is_command_exists "betterleaks"; then
    mkdir -p ~/.local/bin
    curl -fsSL https://github.com/betterleaks/betterleaks/releases/download/v1.5.0/betterleaks_1.5.0_linux_x64.tar.gz \
        | tar -xz -C ~/.local/bin betterleaks
fi

source ~/shell/fzf.sh
