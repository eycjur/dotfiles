source ~/shell/functions.sh

__zsh_prompt_prefix() {
    __prompt_env_prefix zsh
}

# テーマを追加
ZSH_THEME="refined"

# git関係
if is_command_exists "git"; then
    if [ "$(git config user.name)" ]; then
        USER_NAME=$(git config user.name)
    else
        USER_NAME="%K{red}No User Name%k"
    fi
else
    USER_NAME=""
fi

autoload -Uz vcs_info
setopt prompt_subst
# 直前の出力が改行なしでも prompt を次行から始める（欠落改行は反転 % で明示）
setopt prompt_sp prompt_cr
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"  # commitされていないファイルがある時
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"  # addされていないファイルがある時
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b(${USER_NAME})]%f"  # %c: !, %u: +
zstyle ':vcs_info:*' actionformats '[%b|%a]'  # ブランチ|アクション
precmd () { vcs_info }

# ターミナル画面をカスタマイズ
prompt='$(__zsh_prompt_prefix)%F{red}%(?..[%?])%f%K{blue}%n@%m%k %F{green}%~%f %F{cyan}$vcs_info_msg_0_%f
%F{white} %# %f'
# %n: ユーザー名
# %m: ホスト名
# %#: % or #
# %~: カレントディレクトリ
# %F{color}%f: 色を変える
# %K{color}%k: 背景色を変える
# %B...%b: 太字
# %97<...<target: targetの長さに最大文字数制限をつける
