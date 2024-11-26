# Dotfiles

## Installation

### Remote Install

This command is only required for zsh and curl.

```shell
curl -sSL https://raw.githubusercontent.com/eycjur/dotfiles/main/remote-install.sh | zsh

```

### Mac

```shell
brew install git neovim vim
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

### Linux

```shell
sudo apt update && sudo apt install -y git neovim vim zsh
chsh -s /bin/zsh
git clone https://github.com/eycjur/dotfiles.git ~/dotfiles
~/dotfiles/install.sh

```

### Docker

```Dockerfile
RUN apt-get update && apt-get install -y sudo git neovim vim zsh
ADD https://api.github.com/repos/eycjur/dotfiles/git/refs/heads/main version.json
RUN git clone https://github.com/eycjur/dotfiles.git ~/dotfiles && \
    ~/dotfiles/install.sh
CMD ["/bin/zsh"]
```

### Dev Container

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

- ~/dotfiles/.zsh/custom.zsh
- ~/dotfiles/.gitconfig.local
