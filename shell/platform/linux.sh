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

source ~/shell/fzf.sh
