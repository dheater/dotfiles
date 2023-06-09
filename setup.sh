# install packages
nix-env -irf packages.nix

# stow dotfiles
stow alacritty
stow fzf
stow git
stow helix
stow p10k
stow zellij
stow zsh

# add zsh as a login shell
command -v zsh | sudo tee -a /etc/shells

# use zsh as default shell
sudo chsh -s $(which zsh) $USER

# bundle zsh plugins 
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
