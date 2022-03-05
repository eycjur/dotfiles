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
prompt="%K{blue}%n@%m%k %B%F{green}%97<...<%~
%}%F{white} %# %b%f%k"

if [[ "${USERNAME}" =~ "docker" ]]; then
    prompt="(docker)${prompt}"
fi

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
		# nvm
		[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"
		[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && . "$(brew --prefix nvm)/etc/bash_completion.d/nvm"
		export PATH="/usr/local/opt/gnu-sed/libexec/gnubin/:$PATH"
		export PATH="/usr/local/opt/gawk/bin/:$PATH"
		test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
		;;
	linux*)  # linux, windows(wsl)
		alias exp="explorer.exe ."
		alias C="sed 's/\n$//g' | clip.exe"
		;;
esac

# デバイスごとの設定
uname_tail="$(uname -n | rev | cut -c 1-2 | rev)"

BASE_DIR=""
case "${uname_tail}" in
	"JS") BASE_DIR="/mnt/c/Users/${USER}/wsl";;
	"HI") BASE_DIR="/mnt/d"
		alias download="cd /mnt/d/${USER}/download";;
	"al") BASE_DIR="${HOME}/programing";;
	*) echo "this computer is not registered";;
esac

# 研究関連のディレクトリへのエイリアス
analysis_dir="sotsuken/redmine/branch_analysis/analysis"
thesis_dir="sotsuken/redmine/branch_thesis/Thesis"

if [[ "${BASE_DIR}" != "" ]]; then
	alias analysis="cd ${BASE_DIR}/${analysis_dir} && poetry shell"
	alias thesis="cd ${BASE_DIR}/${thesis_dir}"
else
	echo "could not put an alias in the graduate research directory"
fi

# 環境変数
export SVN_EDITOR="vim"
export GIT_EDITOR="vim"
export PATH="${HOME}/.pyenv/bin:${PATH}"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="${HOME}/.poetry/bin:${PATH}"
export PATH="${PATH}:/home/${USER}/go/bin"
