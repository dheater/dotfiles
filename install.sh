# install nix
curl -L https://nixos.org/nix/install | sh && nix-daemon &

# source nix
. ~/.nix-profile/etc/profile.d/nix.sh

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
