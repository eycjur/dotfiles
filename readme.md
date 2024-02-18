# Dotfiles

## Installation

- remote install

This command is only required for zsh and curl.

```shell
curl -sSL https://raw.githubusercontent.com/eycjur/dotfiles/main/remote-install.sh | zsh

```

- mac
```shell
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
RUN git clone https://github.com/eycjur/dotfiles.git ~/dotfiles && \
    ~/dotfiles/install.sh
CMD ["/bin/zsh"]
```

- devcontainer  
  Add the following to user settings.json  
```json
{
    "dotfiles.repository": "https://github.com/eycjur/dotfiles.git",
    "dotfiles.targetPath": "~/dotfiles",
    "dotfiles.installCommand": "install.sh",
}
```

## Customization
There are some files that are not tracked by git. You can customize them as you like.
- .zsh/custom.zsh
- .gitconfig.local
