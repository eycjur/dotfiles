alias exp="explorer.exe"
alias C="sed 's/\n$//g' | clip.exe"

if ! command -v betterleaks >/dev/null 2>&1; then
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
