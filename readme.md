# Dotfiles

## Quick Start
```shell
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

## Installation
- mac
```shell
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install git neovim vim
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

- linux
```shell
sudo apt update && sudo apt install -y git neovim vim zsh
chsh -s /bin/zsh
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

- docker
```Dockerfile
RUN apt-get update && apt-get install -y sudo git neovim vim zsh
ADD https://api.github.com/repos/eycjur/dotfiles/git/refs/heads/main version.json
RUN git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
RUN ~/dotfiles/install.sh
CMD ["/bin/zsh"]
```
