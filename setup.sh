#!/bin/bash

set -e  # Exit on any error

echo "Setting up dotfiles..."

# Install dotfiles using stow
echo "Installing dotfiles with stow..."
if command -v stow >/dev/null 2>&1; then
    stow --adopt fzf
    stow --adopt git
    stow --adopt ghostty
    stow --adopt helix
    stow --adopt ssh
    stow --adopt vim
    stow --adopt wezterm
    stow --adopt zed
    stow --adopt zsh



    echo "✓ Dotfiles stowed successfully"
else
    echo "❌ stow not found. Please install stow first."
    exit 1
fi

# Install mob.sh for mob programming
echo "Installing mob.sh..."
if ! command -v mob >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
        curl -sL install.mob.sh | sh
        echo "✓ mob.sh installed"
    else
        echo "⚠ curl not found, skipping mob.sh installation"
        echo "  Install manually: https://mob.sh"
    fi
else
    echo "✓ mob.sh already installed"
fi

echo "Setting up zsh plugins..."

# Install oh-my-zsh if not already present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh-My-Zsh installed"
else
    echo "✓ Oh-My-Zsh already installed"
fi

# Install oh-my-zsh plugins
echo "Installing oh-my-zsh plugins..."



# Install zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    echo "✓ zsh-autosuggestions installed"
else
    echo "✓ zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    echo "✓ zsh-syntax-highlighting installed"
else
    echo "✓ zsh-syntax-highlighting already installed"
fi

# Install zsh-helix-mode
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-helix-mode" ]; then
    git clone https://github.com/Multirious/zsh-helix-mode.git $HOME/.oh-my-zsh/custom/plugins/zsh-helix-mode
    echo "✓ zsh-helix-mode installed"
else
    echo "✓ zsh-helix-mode already installed"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your shell or run 'source ~/.zshrc'"
echo "2. Ensure ~/.local/bin is in your PATH for auggie-session"

