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

## Setup profile
Run the `setup.sh` script to automatically:
- Install dotfiles using stow
- Set up oh-my-zsh (zsh plugin manager and themes)
- Install zsh plugins including helix mode
- Install mob.sh for mob programming

```bash
./setup.sh
```

--- or ---
Manual setup:
From the `dotfiles` directory, run `stow <dir>` for each application config desired.

## Features
- **Helix keybindings in zsh**: Full helix editor experience in your shell
- **Plugin management**: Uses oh-my-zsh for reliable, cross-platform zsh plugins
- **Fuzzy file finding**: Quick file search and reference tools (`ff` and `fs`)
- **Mob programming**: Includes mob.sh for collaborative development
- **Enhanced compatibility**: Custom fixes for zsh-autosuggestions cursor issues
- **Cross-platform**: Works on macOS, Linux, and Windows

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
