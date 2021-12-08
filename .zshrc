# 初期設定
# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
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

# 以下加筆
# テーマを追加
ZSH_THEME="refined"

# カスタムエイリアス
alias ll='ls -lap'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias exp="explorer.exe ."
alias C="sed 's/\n$//g' | clip.exe"
alias dotfiles="cd ~/dotfiles"

# ディレクトリ移動時の処理
chpwd() { ls -lah }

# デバイスごとの設定
uname_tail="$(uname -n | rev | cut -c 1-2 | rev)"

BASE_DIR=""
case "${uname_tail}" in
  "JS") BASE_DIR="/mnt/c/Users/${USER}/wsl";;
  "HI") BASE_DIR="/mnt/d"
    alias download="cd /mnt/d/${USER}/download";; 
  *) echo "this computer is not registered";;
esac

# 研究関連のディレクトリへのエイリアス
analysis_dir="sotsuken/redmine/branch_analysis/analysis"
thesis_dir="sotsuken/redmine/branch_thesis/Thesis"

if [[ "${BASE_DIR}" != "" ]]; then
  alias analysis="cd ${BASE_DIR}/${analysis_dir}"
  alias thesis="cd ${BASE_DIR}/${thesis_dir}"
else
  echo "could not put an alias in the graduate research directory"
fi

# 環境変数
export SVN_EDITOR="vim"
export GIT_EDITOR="vim"
export DOCKER_CONTENT_TRUST=1
export PATH="${HOME}/.pyenv/bin:${PATH}"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${PATH}:/home/${USER}/go/bin"
