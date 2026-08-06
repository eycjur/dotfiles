source ~/shell/functions.sh

# TTYなし（非対話）・SLURM・sudo権限なしでは apt インストールを避ける
if [ -t 0 ] && [ -z "${SLURM_CONF_SERVER:-}" ] && command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    if ! is_command_exists "fzf" || ! is_command_exists "vim" || ! is_command_exists "gh" || ! is_command_exists "jq" ; then
        sudo apt update && sudo apt install -y fzf vim gh jq
    fi
    if ! is_command_exists "npx" ; then
        sudo apt install -y npm
    fi
fi

UV_VERSION="0.11.21"
FZF_VERSION="0.74.0"
JQ_VERSION="1.8.2"

if ! is_command_exists "uvx" ; then
    curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" | sh
fi

if ! is_command_exists "fzf"; then
    case "$(uname -m)" in
        aarch64|arm64) fzf_arch="arm64" ;;
        x86_64|amd64)  fzf_arch="amd64" ;;
        *)             fzf_arch="" ;;
    esac
    if [ -n "${fzf_arch}" ]; then
        mkdir -p ~/.local/bin
        curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${fzf_arch}.tar.gz" \
            | tar -xz -C ~/.local/bin fzf
    fi
fi

if ! is_command_exists "betterleaks"; then
    case "$(uname -m)" in
        aarch64|arm64) betterleaks_arch="arm64" ;;
        x86_64|amd64)  betterleaks_arch="x64" ;;
        *)             betterleaks_arch="" ;;
    esac
    if [ -n "${betterleaks_arch}" ]; then
        mkdir -p ~/.local/bin
        curl -fsSL "https://github.com/betterleaks/betterleaks/releases/download/v1.5.0/betterleaks_1.5.0_linux_${betterleaks_arch}.tar.gz" \
            | tar -xz -C ~/.local/bin betterleaks
    fi
fi

source ~/shell/fzf.sh
