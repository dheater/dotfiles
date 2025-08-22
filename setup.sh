#!/bin/bash

set -e  # Exit on any error

echo "Setting up dotfiles..."

# Check if Nix is available and install packages
if command -v nix-env >/dev/null 2>&1; then
    echo "Installing Nix packages..."
    if [ -f "packages.nix" ]; then
        nix-env -irf packages.nix
        echo "✓ Nix packages installed"
    else
        echo "⚠ packages.nix not found, skipping Nix package installation"
    fi
else
    echo "⚠ Nix not found. Install Nix first: https://nixos.org/download.html"
    echo "  Continuing with dotfiles setup..."
fi

# Install dotfiles using stow
echo "Installing dotfiles with stow..."
if command -v stow >/dev/null 2>&1; then
    stow fzf
    stow git
    stow helix
    stow jj
    stow ssh
    stow jetbrains
    stow vim
    stow wezterm
    stow zed
    stow zsh

    # Stow p10k if directory exists
    if [ -d "p10k" ]; then
        stow p10k
        echo "✓ P10k configuration stowed"
    fi

    echo "✓ Dotfiles stowed successfully"
else
    echo "❌ stow not found. Please install stow first."
    exit 1
fi

echo "Setting up zsh plugins..."

# Install antidote if not already present
if [ ! -d "${ZDOTDIR:-~}/.antidote" ]; then
    echo "Installing antidote..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
    echo "✓ Antidote installed"
else
    echo "✓ Antidote already installed"
fi

# Install powerlevel10k if not already present
if [ ! -d ~/powerlevel10k ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo "✓ Powerlevel10k installed"
else
    echo "✓ Powerlevel10k already installed"
fi

# Update antidote plugins
if command -v zsh >/dev/null 2>&1; then
    echo "Updating zsh plugins..."
    zsh -c "source ~/.antidote/antidote.zsh && antidote update" 2>/dev/null || echo "⚠ Plugin update failed (this is normal on first run)"
    echo "✓ Zsh plugins updated"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your shell or run 'source ~/.zshrc'"
echo "2. Run 'p10k configure' to customize your prompt"
echo "3. Ensure ~/.local/bin is in your PATH for auggie-session"

