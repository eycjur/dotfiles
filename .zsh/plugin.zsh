if [ ! -e ~/.zsh/antigen ]; then
    git clone https://github.com/zsh-users/antigen.git ~/.zsh/antigen/
fi
source ~/.zsh/antigen/antigen.zsh

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# settings for syntax-highlighting
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=red'
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
