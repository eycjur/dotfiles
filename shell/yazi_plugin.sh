# git.yazi プラグイン本体を取得する。init.lua / yazi.toml は.config/yazi/ に配置する。
if command -v yazi >/dev/null 2>&1; then
    if [[ ! -e "${HOME}/.config/yazi/plugins/git.yazi" ]]; then
        ya pkg add yazi-rs/plugins:git
    fi
fi
