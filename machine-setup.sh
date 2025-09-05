#\!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "ℹ $1"; }
log_success() { echo -e "✓ $1"; }
log_warning() { echo -e "⚠ $1"; }
log_error() { echo -e "❌ $1"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Interactive prompts
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    local response
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response,,} # Convert to lowercase
    
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    [[ "$response" == "y" ]] || [[ "$response" == "yes" ]]
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    local response
    
    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -p "$prompt: " response
        echo "$response"
    fi
}

# Package manager detection and installation
install_package_manager() {
    local os="$1"
    
    case "$os" in
        "macos")
            if \! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                log_success "Homebrew installed"
            else
                log_success "Homebrew already installed"
            fi
            ;;
        "linux"|"wsl")
            # Assume apt-based system (Ubuntu/Debian)
            log_info "Updating package manager..."
            sudo apt update
            log_success "Package manager updated"
            ;;
        "windows")
            if \! command -v choco >/dev/null 2>&1; then
                log_warning "Chocolatey not found. Please install it manually:"
                log_warning "Run PowerShell as Administrator and execute:"
                log_warning "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
                return 1
            else
                log_success "Chocolatey already installed"
            fi
            ;;
    esac
}

# Install essential tools
install_essentials() {
    local os="$1"
    
    log_info "Installing essential tools..."
    
    case "$os" in
        "macos")
            brew install git curl wget stow zsh direnv zoxide
            ;;
        "linux"|"wsl")
            sudo apt install -y git curl wget build-essential stow zsh direnv zoxide
            ;;
        "windows")
            log_warning "Windows: Please install Git, curl, and other tools manually or via Chocolatey"
            log_warning "choco install git curl wget"
            return 1
            ;;
    esac
    
    log_success "Essential tools installed"
}

# Install development tools
install_dev_tools() {
    local os="$1"
    local install_docker="$2"
    local install_helix="$3"
    local install_wezterm="$4"
    
    if [[ "$install_docker" == "true" ]]; then
        log_info "Installing Docker..."
        case "$os" in
            "macos")
                log_warning "macOS: Please install Docker Desktop manually from https://docker.com"
                ;;
            "linux")
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                sudo usermod -aG docker $USER
                rm get-docker.sh
                log_success "Docker installed (restart shell to use without sudo)"
                ;;
            "wsl")
                log_warning "WSL: Install Docker Desktop on Windows host, or use Docker in WSL2"
                ;;
            "windows")
                log_warning "Windows: Please install Docker Desktop manually from https://docker.com"
                ;;
        esac
    fi
    
    if [[ "$install_helix" == "true" ]]; then
        log_info "Installing Helix editor..."
        case "$os" in
            "macos")
                brew install helix
                ;;
            "linux"|"wsl")
                # Install Rust first
                if \! command -v cargo >/dev/null 2>&1; then
                    log_info "Installing Rust..."
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source $HOME/.cargo/env
                fi
                
                # Build Helix from source
                if [[ \! -d $HOME/helix ]]; then
                    git clone https://github.com/helix-editor/helix $HOME/helix
                fi
                cd $HOME/helix
                source $HOME/.cargo/env
                cargo install --path helix-term --locked
                cd -
                ;;
            "windows")
                log_warning "Windows: Install Helix via choco install helix or download from GitHub"
                ;;
        esac
        log_success "Helix editor installed"
    fi
    
    if [[ "$install_wezterm" == "true" ]]; then
        log_info "Installing WezTerm..."
        case "$os" in
            "macos")
                brew install --cask wezterm
                ;;
            "linux")
                # Download latest .deb package
                WEZTERM_VERSION="20240203-110809-5046fc22"
                curl -LO "https://github.com/wez/wezterm/releases/download/$WEZTERM_VERSION/wezterm-$WEZTERM_VERSION.Ubuntu22.04.deb"
                sudo dpkg -i "wezterm-$WEZTERM_VERSION.Ubuntu22.04.deb"
                rm "wezterm-$WEZTERM_VERSION.Ubuntu22.04.deb"
                ;;
            "wsl")
                log_warning "WSL: WezTerm should be installed on Windows host"
                ;;
            "windows")
                log_warning "Windows: Install WezTerm via choco install wezterm or download from GitHub"
                ;;
        esac
        log_success "WezTerm installed"
    fi
}

# Setup shell
setup_shell() {
    local os="$1"
    local change_shell="$2"
    
    if [[ "$change_shell" == "true" ]]; then
        log_info "Setting up zsh as default shell..."
        
        case "$os" in
            "macos"|"linux"|"wsl")
                if [[ "$SHELL" \!= */zsh ]]; then
                    chsh -s $(which zsh)
                    log_success "Default shell changed to zsh (restart terminal to take effect)"
                else
                    log_success "zsh is already the default shell"
                fi
                ;;
            "windows")
                log_warning "Windows: Shell change not applicable"
                ;;
        esac
    fi
}

# Setup dotfiles
setup_dotfiles() {
    local dotfiles_repo="$1"
    local dotfiles_dir="$2"
    
    log_info "Setting up dotfiles..."
    
    if [[ \! -d "$dotfiles_dir" ]]; then
        log_info "Cloning dotfiles repository..."
        git clone "$dotfiles_repo" "$dotfiles_dir"
    else
        log_info "Updating existing dotfiles..."
        cd "$dotfiles_dir"
        git pull
        cd -
    fi
    
    # Run the setup script
    if [[ -f "$dotfiles_dir/setup.sh" ]]; then
        cd "$dotfiles_dir"
        ./setup.sh
        cd -
        log_success "Dotfiles configured"
    else
        log_warning "No setup.sh found in dotfiles directory"
    fi
}

# Apply configuration fixes
apply_config_fixes() {
    local dotfiles_dir="$1"
    local install_helix="$2"
    local install_wezterm="$3"
    
    log_info "Applying configuration fixes..."
    
    # Fix 1: Ensure zsh configuration is properly applied
    if [[ -f "$dotfiles_dir/zsh/.zshrc" ]]; then
        log_info "Fixing zsh configuration..."
        # Check if oh-my-zsh overwrote our config
        if [[ -f "$HOME/.zshrc" ]] && \! grep -q "ZSH_THEME=\"ys\"" "$HOME/.zshrc" 2>/dev/null; then
            log_info "Restoring custom zsh configuration..."
            cd "$dotfiles_dir"
            # Restore the correct zsh config if it was overwritten
            git checkout zsh/.zshrc 2>/dev/null || true
            # Re-stow to ensure proper linking
            stow -t $HOME --adopt zsh
            git checkout zsh/.zshrc 2>/dev/null || true
            cd -
            log_success "Zsh configuration restored"
        else
            log_success "Zsh configuration already correct"
        fi
    fi
    
    # Fix 2: Fix Helix runtime symlink if Helix was installed
    if [[ "$install_helix" == "true" ]]; then
        log_info "Fixing Helix configuration..."
        
        # Check if runtime symlink exists and is correct
        if [[ -L "$HOME/.config/helix/runtime" ]]; then
            local current_target=$(readlink "$HOME/.config/helix/runtime")
            local expected_target="$HOME/helix/runtime"
            
            if [[ "$current_target" \!= "$expected_target" ]] && [[ -d "$expected_target" ]]; then
                log_info "Fixing Helix runtime symlink..."
                rm "$HOME/.config/helix/runtime"
                ln -s "$expected_target" "$HOME/.config/helix/runtime"
                log_success "Helix runtime symlink fixed"
            else
                log_success "Helix runtime symlink already correct"
            fi
        elif [[ -d "$HOME/helix/runtime" ]]; then
            log_info "Creating Helix runtime symlink..."
            mkdir -p "$HOME/.config/helix"
            ln -s "$HOME/helix/runtime" "$HOME/.config/helix/runtime"
            log_success "Helix runtime symlink created"
        fi
    fi
    
    # Fix 3: Fix WezTerm color scheme if WezTerm was installed
    if [[ "$install_wezterm" == "true" ]] && [[ -f "$HOME/.config/wezterm/wezterm.lua" ]]; then
        log_info "Fixing WezTerm configuration..."
        
        # Check for invalid color scheme
        if grep -q "color_scheme = 'Default dark (base16)'" "$HOME/.config/wezterm/wezterm.lua" 2>/dev/null; then
            log_info "Fixing WezTerm color scheme..."
            sed -i "s/config.color_scheme = 'Default dark (base16)'/config.color_scheme = 'Dracula'/" "$HOME/.config/wezterm/wezterm.lua"
            log_success "WezTerm color scheme fixed"
        else
            log_success "WezTerm color scheme already correct"
        fi
        
        # Fix Helix path in WezTerm config
        if grep -q "'/usr/local/bin/hx'" "$HOME/.config/wezterm/wezterm.lua" 2>/dev/null; then
            log_info "Fixing Helix path in WezTerm config..."
            sed -i "s|'/usr/local/bin/hx'|'hx'|" "$HOME/.config/wezterm/wezterm.lua"
            log_success "Helix path in WezTerm config fixed"
        else
            log_success "Helix path in WezTerm config already correct"
        fi
        
        # Update dotfiles repo with fixes
        if [[ -f "$dotfiles_dir/wezterm/.config/wezterm/wezterm.lua" ]]; then
            cd "$dotfiles_dir"
            if grep -q "color_scheme = 'Default dark (base16)'" "wezterm/.config/wezterm/wezterm.lua" 2>/dev/null; then
                sed -i "s/config.color_scheme = 'Default dark (base16)'/config.color_scheme = 'Dracula'/" "wezterm/.config/wezterm/wezterm.lua"
            fi
            if grep -q "'/usr/local/bin/hx'" "wezterm/.config/wezterm/wezterm.lua" 2>/dev/null; then
                sed -i "s|'/usr/local/bin/hx'|'hx'|" "wezterm/.config/wezterm/wezterm.lua"
            fi
            cd -
        fi
    fi
    
    log_success "Configuration fixes applied"
}

# Create project directories
create_project_dirs() {
    local projects=("ucm" "plumbing")
    
    log_info "Creating project directories..."
    mkdir -p $HOME/src
    
    for project in "${projects[@]}"; do
        mkdir -p $HOME/src/$project
        log_success "Created $HOME/src/$project"
    done
}

# Main setup function
main() {
    log_info "🚀 Development Environment Setup"
    log_info "=============================="
    
    # Detect OS
    OS=$(detect_os)
    log_info "Detected OS: $OS"
    
    if [[ "$OS" == "unknown" ]]; then
        log_error "Unsupported operating system"
        exit 1
    fi
    
    # Gather configuration
    log_info "\nConfiguration Questions:"
    log_info "========================"
    
    DOTFILES_REPO=$(prompt_input "Dotfiles repository URL" "git@github.com:dheater/dotfiles.git")
    DOTFILES_DIR=$(prompt_input "Dotfiles directory" "$HOME/dotfiles")
    DOTFILES_DIR=${DOTFILES_DIR/#~\/$HOME/} # Expand tilde
    
    INSTALL_DOCKER=$(prompt_yes_no "Install Docker?" "y")
    INSTALL_HELIX=$(prompt_yes_no "Install Helix editor?" "y")
    INSTALL_WEZTERM=$(prompt_yes_no "Install WezTerm terminal?" "y")
    CHANGE_SHELL=$(prompt_yes_no "Change default shell to zsh?" "y")
    
    # Show configuration summary
    log_info "\nConfiguration Summary:"
    log_info "====================="
    log_info "OS: $OS"
    log_info "Dotfiles repo: $DOTFILES_REPO"
    log_info "Dotfiles dir: $DOTFILES_DIR"
    log_info "Install Docker: $INSTALL_DOCKER"
    log_info "Install Helix: $INSTALL_HELIX"
    log_info "Install WezTerm: $INSTALL_WEZTERM"
    log_info "Change shell: $CHANGE_SHELL"
    
    if \! prompt_yes_no "\nProceed with setup?" "y"; then
        log_info "Setup cancelled"
        exit 0
    fi
    
    # Platform-specific warnings
    case "$OS" in
        "windows")
            log_warning "\n⚠ Windows Limitations:"
            log_warning "• This script has limited Windows support"
            log_warning "• Many tools need manual installation"
            log_warning "• Consider using WSL2 for better compatibility"
            log_warning "• Dotfiles symlinking may not work properly"
            ;;
        "wsl")
            log_warning "\n⚠ WSL Notes:"
            log_warning "• Some GUI applications should be installed on Windows host"
            log_warning "• Docker Desktop integration recommended"
            ;;
    esac
    
    # Execute setup steps
    log_info "\n🔧 Starting setup..."
    
    install_package_manager "$OS"
    install_essentials "$OS"
    install_dev_tools "$OS" "$INSTALL_DOCKER" "$INSTALL_HELIX" "$INSTALL_WEZTERM"
    setup_shell "$OS" "$CHANGE_SHELL"
    setup_dotfiles "$DOTFILES_REPO" "$DOTFILES_DIR"
    apply_config_fixes "$DOTFILES_DIR" "$INSTALL_HELIX" "$INSTALL_WEZTERM"
    create_project_dirs
    
    log_success "\n🎉 Setup complete\!"
    log_info "\nNext steps:"
    log_info "• Restart your terminal/shell"
    log_info "• Verify tools are working: hx --version, docker --version, etc."
    log_info "• Clone your project repositories to $HOME/src/"
    
    if [[ "$INSTALL_DOCKER" == "true" ]] && [[ "$OS" == "linux" ]]; then
        log_info "• Log out and back in (or run 'newgrp docker') to use Docker without sudo"
    fi
    
    log_info "\n🔧 Configuration fixes applied:"
    log_info "• Zsh prompt configuration (ys theme)"
    log_info "• Helix color scheme and runtime"
    log_info "• WezTerm color scheme and paths"
}

# Run main function
main "$@"
