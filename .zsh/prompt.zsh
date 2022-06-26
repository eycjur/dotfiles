# テーマを追加
ZSH_THEME="refined"

# git関係
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"  # commitされていないファイルがある時
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"  # addされていないファイルがある時
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b($(git config user.name))]%f"  # %c: !, %u: +
zstyle ':vcs_info:*' actionformats '[%b|%a]'  # ブランチ|アクション
precmd () { vcs_info }

# ターミナル画面をカスタマイズ
prompt='%K{blue}%n@%m%k %F{green}%~%f %F{cyan}$vcs_info_msg_0_%f
%F{white} %# %f'
# %n: ユーザー名
# %m: ホスト名
# %#: % or #
# %~: カレントディレクトリ
# %F{color}%f: 色を変える
# %K{color}%k: 背景色を変える
# %B...%b: 太字
# %97<...<target: targetの長さに最大文字数制限をつける
if [ -n "${SSH_CLIENT}" ]; then
    prompt="(ssh)${prompt}"
fi

if [ -n "${CONTAINER_NAME}" ]; then
    prompt="(docker)${prompt}"
fi
