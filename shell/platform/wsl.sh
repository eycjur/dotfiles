alias exp="explorer.exe"
alias C="sed 's/\n$//g' | clip.exe"

if ! command -v betterleaks >/dev/null 2>&1; then
    mkdir -p ~/.local/bin
    curl -fsSL https://github.com/betterleaks/betterleaks/releases/download/v1.5.0/betterleaks_1.5.0_linux_x64.tar.gz \
        | tar -xz -C ~/.local/bin betterleaks
fi
