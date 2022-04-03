# 初期設定
# Set up the prompt

# macでdircolorsコマンドがないと言われるのでその対策
if type brew > /dev/null; then
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

autoload -Uz promptinit
promptinit
# 仮想環境下で上書きしてほしくないので 手動で設定
# prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_ignore_all_dups
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


# テーマを追加
ZSH_THEME="refined"

# git関係
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"  # commitされていないファイルがある時
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"  # addされていないファイルがある時
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b]%f"  # %c: !, %u: +
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
if [[ "${USERNAME}" =~ "docker" ]]; then
    prompt="(docker)${prompt}"
fi

# カスタムエイリアス
alias ls='ls --color'
alias ll='ls -lahp --color'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'
# nvimがあれば利用
if type nvim > /dev/null; then
    alias vim="nvim"
fi
alias vi="vim"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias dotfiles="cd ~/dotfiles"
alias his="history | grep"
alias px="poetry run python -m src"

# ディレクトリ移動時の処理
chpwd() { ll }

# osごとの設定
case ${OSTYPE} in
    darwin*)  # mac
        alias exp="open ."
        alias C="pbcopy"
        alias sed="gsed"

        export PATH="/usr/local/opt/gnu-sed/libexec/gnubin/:$PATH"
        export PATH="/usr/local/opt/gawk/bin/:$PATH"

        source $(brew --prefix nvm)/nvm.sh
        source $(brew --prefix nvm)/etc/bash_completion.d/nvm
        source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source "${HOME}/.iterm2_shell_integration.zsh"
        ;;

    linux*)  # linux, windows(wsl)
        alias exp="explorer.exe ."
        alias C="sed 's/\n$//g' | clip.exe"
        ;;
esac

# 環境変数
export SVN_EDITOR="vim"
export GIT_EDITOR="vim"
export PATH="${HOME}/.pyenv/bin:${PATH}"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${PATH}:/home/${USER}/go/bin"

