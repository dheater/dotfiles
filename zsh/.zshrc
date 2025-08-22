# .zshrc
source ~/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
eval "$(direnv hook zsh)"

# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
antidote bundle zsh-users/zsh-autosuggestions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/powerlevel10k/powerlevel10k.zsh-theme

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# export LANGUAGE=en_US.UTF-8
# export LC_CTYPE=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

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

# Use vi mode
# bindkey -v

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

alias ls='eza -a'

# Path
export PATH=$PATH:$HOME/bin:$HOME/dotfiles/bin:/usr/local/sbin:$HOME/zig:/opt/bin:/opt/nvim:/usr/local/go/bin

# Git autocomplete
autoload -Uz compinit && compinit

# fzf options
export FZF_CTRL_R_OPTS="--reverse"
export FZF_TMUX_OPTS="-p"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview-window=right:60%"

# Custom file finder function for quick file reference
ff() {
    local file
    if command -v fd >/dev/null 2>&1; then
        # Use fd if available (faster and respects .gitignore)
        file=$(fd --type f --hidden --follow --exclude .git --exclude node_modules | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'CTRL-/ to toggle preview, Enter to copy path to clipboard')
    else
        # Fallback to find
        file=$(find . -type f -not -path '*/\.git/*' -not -path '*/node_modules/*' | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'CTRL-/ to toggle preview, Enter to copy path to clipboard')
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

# Quick content search in files
fs() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: fs <search_term>"
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
            --header 'CTRL-/ to toggle preview'
    elif command -v ag >/dev/null 2>&1; then
        # Use silver searcher if available
        ag --color --line-number "$query" | fzf \
            --ansi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'CTRL-/ to toggle preview'
    else
        # Fallback to grep
        grep -r --line-number --color=always "$query" . | fzf \
            --ansi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window=right:60%:wrap \
            --bind 'ctrl-/:toggle-preview' \
            --header 'CTRL-/ to toggle preview'
    fi
}

export PATH=$HOME/.cargo/bin:$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup zoxide
eval "$(zoxide init zsh)"

# Shortcuts for CoPilot CLI
# eval "$(github-copilot-cli alias -- "$0")"

# bun completions
[ -s "/home/dheater/.bun/_bun" ] && source "/home/dheater/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# helix-gpt
export HANDLER=copilot

# Load helix mode for zsh - fallback to local if antidote version doesn't work
if ! command -v helix_mode >/dev/null 2>&1 && [[ -f "${ZDOTDIR:-$HOME}/.zsh_helix_mode.plugin.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zsh_helix_mode.plugin.zsh"
fi


# Devbox
DEVBOX_NO_PROMPT=true
autoload -U compinit; compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/dotfiles/auggie/aliases.zsh
bindkey -M hxins "^I" expand-or-complete

# Fix right arrow key for zsh autosuggestions in helix insert mode
bindkey -M hxins "^[OC" forward-char
bindkey -M hxins "^[[C" forward-char
export PATH="$HOME/.local/bin:$PATH"
