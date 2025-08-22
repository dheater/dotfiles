# Set up a new machine

This is where I store files to be synched between machines.
Much of this is thanks to [Jake Weisler's videos here](https://www.youtube.com/watch?v=70YMTHAZyy4&list=PL1C97G3GhlHdANMFUIXTcFr14R7b7EBj9&pp=iAQB)

## Set up SSH keys

```
# Generate your ssh key
ssh-keygen -t ed25519
# Copy the key to Github
cat .ssh/id_ed25519.pub
```

## Install nix
Install nix (package manager) per https://nixos.org/download.html

## Setup profile
Run the `setup.sh` script to automatically:
- Install dotfiles using stow
- Set up antidote (zsh plugin manager)
- Install powerlevel10k theme
- Update zsh plugins including helix mode

```bash
./setup.sh
```

--- or ---
Manual setup:
From the `dotfiles` directory, run `nix-env -irf packages.nix` to install the default profile packages.

From the `dotfiles` directory, run `stow <dir>` for each application config desired.

## Features
- **Helix keybindings in zsh**: Automatically configured with fallback support
- **Plugin management**: Uses antidote for zsh plugins with auto-updates
- **Fuzzy file finding**: Quick file search and reference tools
- **Cross-platform**: Works on macOS and Linux

## File Search Tools

### Quick File Reference
Use these tools to quickly find and reference files:

```bash
# Interactive file finder with preview
ff

# Search file contents
fs "search term"

# Standalone file reference tool
fref                    # Interactive file finder
fref "search term"      # Search in file contents
```

**Features:**
- File preview with syntax highlighting (using `bat` if available)
- Automatic clipboard copy of file paths
- Respects `.gitignore` files
- Fast search with `fd` and `ripgrep` when available
- Keyboard shortcuts: `CTRL-/` to toggle preview

**Dependencies (optional but recommended):**
- `fd` - Fast file finder
- `rg` (ripgrep) - Fast text search
- `bat` - Syntax highlighting for previews
