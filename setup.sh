#\!/bin/bash

set -e  # Exit on any error

echo "Setting up dotfiles..."

# Check if stow is available
if \! command -v stow >/dev/null 2>&1; then
    echo "❌ stow not found. Please install stow first."
    echo "   macOS: brew install stow"
    echo "   Ubuntu/Debian: sudo apt install stow"
    exit 1
fi

# Install all dotfiles packages using stow
echo "Installing dotfiles with stow..."
PACKAGES=(
    "auggie"
    "fzf"
    "git"
    "ghostty"
    "helix"
    "ssh"
    "vim"
    "wezterm"
    "zed"
    "zsh"
)

for package in "${PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        echo "  Stowing $package..."
        stow --adopt "$package"
    else
        echo "  ⚠ Skipping $package (directory not found)"
    fi
done

echo "✓ Dotfiles stowed successfully"

# Install mob.sh for mob programming
echo "Installing mob.sh..."
if \! command -v mob >/dev/null 2>&1; then
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

# Install oh-my-zsh and plugins
echo "Setting up zsh plugins..."

# Install oh-my-zsh if not already present
if [ \! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh-My-Zsh installed"
else
    echo "✓ Oh-My-Zsh already installed"
fi

# Install oh-my-zsh plugins
ZSH_PLUGINS=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh-helix-mode:https://github.com/Multirious/zsh-helix-mode.git"
)

for plugin_info in "${ZSH_PLUGINS[@]}"; do
    plugin_name="${plugin_info%%:*}"
    plugin_url="${plugin_info##*:}"
    plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    
    if [ \! -d "$plugin_dir" ]; then
        echo "Installing $plugin_name..."
        git clone "$plugin_url" "$plugin_dir"
        echo "✓ $plugin_name installed"
    else
        echo "✓ $plugin_name already installed"
    fi
done

echo ""
echo "🎉 Setup complete\!"
echo ""
echo "What was set up:"
echo "• All dotfiles packages stowed (including auggie memory at ~/.auggie-memory)"
echo "• mob.sh for mob programming"
echo "• oh-my-zsh with useful plugins"
echo ""
echo "Next steps:"
echo "Restart your shell or run 'source ~/.zshrc'"
