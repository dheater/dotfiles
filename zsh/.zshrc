# .zshrc
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme - using built-in oh-my-zsh theme for simplicity
ZSH_THEME="ys"

# Oh-My-Zsh plugins
plugins=(command-not-found git direnv)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# Load additional plugins
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source ~/.oh-my-zsh/custom/plugins/zsh-helix-mode/zsh-helix-mode.plugin.zsh 2>/dev/null

# Configure zsh-autosuggestions compatibility with zsh-helix-mode
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
  zhm_history_prev
  zhm_history_next
  zhm_prompt_accept
  zhm_accept
  zhm_accept_or_insert_newline
)
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(
  zhm_move_right
)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
  zhm_move_next_word_start
  zhm_move_next_word_end
)

# Fix syntax highlighting compatibility
zhm-add-update-region-highlight-hook 2>/dev/null

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR=vi
else
  export EDITOR=hx
fi

# Make globbing case insenstive
setopt NO_CASE_GLOB
# and make it work like bash
setopt GLOB_COMPLETE

SAVEHIST=5000
HISTSIZE=2000
# store times in history
setopt EXTENDED_HISTORY
# Do not share history across multiple zsh sessions
setopt nosharehistory
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST 
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS
# verify we are substituting the command we expect on ! (bang)
setopt HIST_VERIFY

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias grep='grep --color=auto'
fi

alias ls='ls --color'

# Path - dynamically determine dotfiles location
if [[ -L "${(%):-%N}" ]]; then
    # If .zshrc is a symlink (stow-managed), resolve dotfiles location
    DOTFILES_DIR="$HOME/$(dirname "$(dirname "$(readlink "${(%):-%N}")")")"
else
    # Fallback to common locations
    if [[ -d "$HOME/dotfiles" ]]; then
        DOTFILES_DIR="$HOME/dotfiles"
    elif [[ -d "$HOME/src/dheater/main/dotfiles" ]]; then
        DOTFILES_DIR="$HOME/src/dheater/main/dotfiles"
    else
        DOTFILES_DIR="$HOME/dotfiles"  # Default fallback
    fi
fi
export PATH=$PATH:$HOME/bin:$DOTFILES_DIR/bin:/usr/local/sbin:$HOME/zig:/opt/bin:/opt/nvim:/usr/local/go/bin

# Git autocomplete
autoload -Uz compinit && compinit

# fzf options
export FZF_CTRL_R_OPTS="--reverse"
export FZF_TMUX_OPTS="-p"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview-window=right:60%"

# Interactive file finder with fuzzy search and preview
# Usage: ff [--help]
# 
# Features:
# - Searches all files recursively (respects .gitignore when using fd)
# - Live preview with syntax highlighting via bat
# - Copies selected file path to clipboard automatically
# - Fast search using fd (falls back to find if fd not available)
#
# Controls:
# - CTRL-/ : Toggle preview pane
# - Enter  : Select file and copy path to clipboard
# - Esc    : Cancel and exit
ff() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "ff - Interactive File Finder"
        echo ""
        echo "USAGE:"
        echo "  ff [--help]"
        echo ""
        echo "DESCRIPTION:"
        echo "  Fuzzy search through all files in the current directory tree."
        echo "  Respects .gitignore when fd is available. Shows live preview"
        echo "  with syntax highlighting and copies selected path to clipboard."
        echo ""
        echo "CONTROLS:"
        echo "  CTRL-/  Toggle preview pane"
        echo "  Enter   Select file and copy path to clipboard"
        echo "  Esc     Cancel and exit"
        echo ""
        echo "DEPENDENCIES:"
        echo "  Recommended: fd, bat (for better performance and highlighting)"
        echo "  Fallback: find, cat"
        return 0
    fi
    local file
    if command -v fd >/dev/null 2>&1; then
        # Use fd if available (faster and respects .gitignore)
        file=$(fd --type f --hidden --follow --exclude .git --exclude node_modules | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'File Finder | CTRL-/ toggle preview | Enter to copy path to clipboard')
    else
        # Fallback to find
        file=$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'File Finder | CTRL-/ toggle preview | Enter to copy path to clipboard')
    fi

    if [[ -n "$file" ]]; then
        echo "$file"
        # Copy to clipboard if available
        if command -v pbcopy >/dev/null 2>&1; then
            echo "$file" | pbcopy
            echo "📋 Path copied to clipboard!"
        elif command -v xclip >/dev/null 2>&1; then
            echo "$file" | xclip -selection clipboard
            echo "📋 Path copied to clipboard!"
        fi
    fi
}

# Interactive content search across files with fuzzy matching
# Usage: fs <search_term> [--help]
# 
# Features:
# - Searches file contents using ripgrep/ag/grep (in order of preference)
# - Shows matching lines with context and syntax highlighting
# - Live preview of matches with highlighted search terms
# - Fast search with smart case matching
#
# Controls:
# - CTRL-/ : Toggle preview pane
# - Enter  : View file at matching line
# - Esc    : Cancel and exit
fs() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "fs - Interactive Content Search"
        echo ""
        echo "USAGE:"
        echo "  fs <search_term> [--help]"
        echo ""
        echo "DESCRIPTION:"
        echo "  Fuzzy search through file contents in the current directory tree."
        echo "  Shows matching lines with context and syntax highlighting."
        echo "  Uses ripgrep, ag, or grep (in order of preference)."
        echo ""
        echo "CONTROLS:"
        echo "  CTRL-/  Toggle preview pane"
        echo "  Enter   View file at matching line"
        echo "  Esc     Cancel and exit"
        echo ""
        echo "DEPENDENCIES:"
        echo "  Recommended: ripgrep (rg), bat (for better performance and highlighting)"
        echo "  Alternative: ag (silver searcher)"
        echo "  Fallback: grep"
        echo ""
        echo "EXAMPLES:"
        echo "  fs "function main"     # Search for function definitions"
        echo "  fs "TODO"             # Find TODO comments"
        echo "  fs "import.*numpy"    # Search with regex patterns"
        return 0
    fi

    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: fs <search_term>"
        echo "  Interactive search through file contents"
        echo "  Shows matching lines with preview and context"
        echo ""
        echo "Run 'fs --help' for detailed usage information"
        return 1
    fi
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: fs <search_term>"
        echo "  Interactive search through file contents"
        echo "  Shows matching lines with preview and context"
        return 1
    fi

    if command -v rg >/dev/null 2>&1; then
        # Use ripgrep if available
        rg --color=always --line-number --no-heading --smart-case "$query" | fzf \
            --ansi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header "Content Search: \"$query\" | CTRL-/ toggle preview | Enter to view"
    elif command -v ag >/dev/null 2>&1; then
        # Use silver searcher if available
        ag --color --line-number "$query" | fzf \
            --ansi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header "Content Search: \"$query\" | CTRL-/ toggle preview | Enter to view"
    else
        # Fallback to grep
        grep -r --line-number --color=always "$query" . | fzf \
            --ansi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header "Content Search: \"$query\" | CTRL-/ toggle preview | Enter to view"
    fi
}

export PATH=$HOME/.cargo/bin:$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup zoxide
eval "$(zoxide init zsh)"

# helix-gpt (if using)
export HANDLER=copilot

# CUSTOM FIX: Enhanced zsh-autosuggestions compatibility with zsh-helix-mode
# This addresses cursor synchronization issues not yet fixed upstream
# See: https://github.com/Multirious/zsh-helix-mode/issues/31
# The helix mode plugin interferes with autosuggestion cursor positioning
function zhm_autosuggest_accept {
  local suggestion=""

  # Get suggestion using the history strategy
  if (( $+functions[_zsh_autosuggest_strategy_history] )); then
    _zsh_autosuggest_strategy_history "$BUFFER"
  fi

  if [[ -n "$suggestion" ]]; then
    # Accept the suggestion by updating buffer and cursor
    BUFFER="$suggestion"
    CURSOR=${#BUFFER}

    # Sync helix mode cursor tracking
    if (( $+zhm_cursors_pos )); then
      zhm_cursors_pos[${ZHM_PRIMARY_CURSOR_IDX:-1}]=$CURSOR
      zhm_cursors_selection_left[${ZHM_PRIMARY_CURSOR_IDX:-1}]=$CURSOR
      zhm_cursors_selection_right[${ZHM_PRIMARY_CURSOR_IDX:-1}]=$CURSOR
      (( $+functions[__zhm_update_last_moved] )) && __zhm_update_last_moved
      (( $+functions[__zhm_update_region_highlight] )) && __zhm_update_region_highlight
    fi
  else
    # No suggestion, just move forward one character
    zle forward-char
  fi
}
zle -N zhm_autosuggest_accept

# Apply the fix after helix mode loads
function zhm_setup_autosuggestions {
  if (( $+functions[zhm_insert] )); then
    bindkey -M hxins "^[OC" zhm_autosuggest_accept  # Right arrow
    bindkey -M hxins "^[[C" zhm_autosuggest_accept  # Right arrow (alternate)
    precmd_functions=(${precmd_functions:#zhm_setup_autosuggestions})
  fi
}
precmd_functions+=(zhm_setup_autosuggestions)

# Jira CLI
alias jmine='jira issue list -a$(jira me) -s~Done -s~Closed'

export PATH="$HOME/.local/bin:$PATH"
