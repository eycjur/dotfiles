# dotfiles

## install
```shell
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

## initial setting
- mac
```shell
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew install vim neovim git
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

- linux
```shell
apt update && apt install -y git neovim vim zsh
chsh -s /bin/zsh
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

- docker
```Dockerfile
RUN apt-get update && apt-get install -y git vim zsh neovim sudo
RUN git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
ENV SHELL /usr/bin/zsh
RUN ~/dotfiles/install.sh
CMD ["/bin/zsh"]
```
