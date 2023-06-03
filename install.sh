# install nix
curl -L https://nixos.org/nix/install | sh && nix-daemon &

# source nix
. ~/.nix-profile/etc/profile.d/nix.sh

# install packages
nix-env -iA \
  nixpkgs.antibody \
  nixpkgs.bat \
  nixpkgs.direnv \
  nixpkgs.delta \
  nixpkgs.exa \
  nixpkgs.fzf \
  nixpkgs.fd \
  nixpkgs.git \
  nixpkgs.helix \
  nixpkgs.jq \
  nixpkgs.openssh \
  nixpkgs.ripgrep \
  nixpkgs.stow \
  nixpkgs.tmux \
  nixpkgs.unzip \
  nixpkgs.vim \
  nixpkgs.wget \
  nixpkgs.zellij \
  nixpkgs.zoxide \
  nixpkgs.zsh \
  
# stow dotfiles
stow alacrity
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
