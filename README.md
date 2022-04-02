# Set up a new machine

## Set up SSH keys

```
# Generate your ssh key
ssh-keygen -t rsa
# Copy the key to Github
cat .ssh/id_rsa.pub
```

## Intiallize the dotfiles

Install `chezmoi`: https://www.chezmoi.io

Run `$ chezmoi init --apply https://github.com/username/dotfiles.git` to do a straght install or lool at the instructions as [Chezmoi](https://www.chezmoi.io) for other setup options.

## Setup Vim

Install `vim`

Then pull in the plugins using [Vundle](https://github.com/VundleVim/Vundle.vim)
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
```
