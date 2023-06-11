# 初期設定
# Set up the prompt

# macでdircolorsコマンドがないと言われるのでその対策
if [[ ${OSTYPE} == "darwin"* ]]; then
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

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
setopt AUTO_CD
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit
# autocompleteと競合するのでbrew以外の環境下で実行
# if [[ ${OSTYPE} == "darwin"* ]]; then
#     source ~/.zsh/autocomplete.zsh
# else
#     autoload -Uz compinit
#     compinit
# fi

# autoload colors
# colors

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


# ディレクトリ移動時の処理
chpwd() { ls -lahp --color }

# osごとの設定
case ${OSTYPE} in
    darwin*)  # mac
        source ~/.zsh/mac.zsh
        ;;
    # wsl*)  # linux, windows(wsl)
        # source ~/.zsh/wsl.zsh
        # ;;
    linux*)  # linux, windows(wsl)
        :
        ;;
    *)
        echo "ostype is not known"
        exit 1
        ;;
esac

# 環境変数
export PATH="${HOME}/.pyenv/bin:${PATH}"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${PATH}:/home/${USER}/go/bin"

source ~/.zsh/prompt.zsh
source ~/.zsh/alias.zsh
if [[ -e ~/.zsh/custom.zsh ]]; then
    source ~/.zsh/custom.zsh
fi
