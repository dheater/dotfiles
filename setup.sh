#!/bin/bash

echo "Setting up dotfiles..."

# Install dotfiles using stow
echo "Installing dotfiles with stow..."
stow alacritty
stow fzf
stow git
stow helix
stow jj
stow ssh
stow jetbrains
stow vim
stow wezterm
stow zed
stow zellij
stow zsh

echo "Setting up zsh plugins..."

# Install antidote if not already present
if [ ! -d "${ZDOTDIR:-~}/.antidote" ]; then
    echo "Installing antidote..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

# Install powerlevel10k if not already present
if [ ! -d ~/powerlevel10k ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

# Update antidote plugins
if command -v zsh >/dev/null 2>&1; then
    echo "Updating zsh plugins..."
    zsh -c "source ~/.antidote/antidote.zsh && antidote update"
fi

echo "Setup complete! Please restart your shell or run 'source ~/.zshrc' to apply changes."

