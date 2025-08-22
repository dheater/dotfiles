# Auggie CLI Aliases and Functions
# Source this file in your .zshrc: source ~/dotfiles/auggie/aliases.zsh

# Quick Auggie session commands
alias ac='auggie-session continue'
alias an='auggie-session new'
alias ar='auggie-session refactor'
alias at='auggie-session test'
alias af='auggie-session fix'
alias aq='auggie-session quality'

# Documentation shortcuts
alias ah='cat ~/dotfiles/auggie/commands.md'
alias aw='cat ~/dotfiles/auggie/working-agreement.md'
alias ai='cat ~/dotfiles/auggie/helix-integration.md'

# Session management
alias as='ls ~/.auggie-sessions'  # List all sessions
alias asc='find ~/.auggie-sessions -name "current.md" -exec head -5 {} \;'  # Show current sessions

# Integration with existing file tools
alias aff='auggie --context-file $(ff 2>/dev/null || echo "")'
alias afs='auggie --context-search "$(fs 2>/dev/null || echo "")"'

# Quick context helpers
auggie-here() {
    # Start Auggie with current file as context
    local current_file="${1:-$(pwd)}"
    auggie --context-file "$current_file"
}

auggie-git() {
    # Start Auggie with recent git changes as context
    local commits="${1:-5}"
    auggie --git-context "HEAD~${commits}..HEAD"
}

auggie-clean() {
    # Clean old session files
    local days="${1:-30}"
    echo "Cleaning Auggie sessions older than $days days..."
    find ~/.auggie-sessions -name "*.md" -mtime +$days -delete
    echo "Done."
}

# Helix integration helpers
hx-auggie() {
    # Open file in Helix and start Auggie session
    local file="$1"
    if [[ -n "$file" ]]; then
        hx "$file" &
        sleep 1
        auggie-session continue
    else
        echo "Usage: hx-auggie <file>"
    fi
}

# Project context helpers
auggie-project-setup() {
    # Set up AI context for current project
    local project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local context_file="$project_root/docs/ai-context.md"
    
    if [[ ! -f "$context_file" ]]; then
        mkdir -p "$(dirname "$context_file")"
        cat > "$context_file" << EOF
# AI Context for $(basename "$project_root")

## Build System
- Primary: \`make build\` (or specify your build command)
- Tests: \`make test\`
- Quality: \`just test-asan\`, \`just test-ubsan\` (if using Just)

## Code Conventions
- Language: (specify primary language)
- Style guide: (link or description)
- Formatting: (tool used, e.g., clang-format, rustfmt)

## Current Focus
- (describe current development priorities)

## Known Issues
- (list any known problems or areas of concern)

## Team Notes
- (any team-specific context or conventions)
EOF
        echo "Created AI context file: $context_file"
        echo "Edit it to add project-specific information."
    else
        echo "AI context file already exists: $context_file"
    fi
}

# Help function
auggie-help() {
    echo "Auggie CLI Aliases:"
    echo ""
    echo "Session Commands:"
    echo "  ac          - Continue current session"
    echo "  an          - Start new session"
    echo "  ar          - Refactor current selection"
    echo "  at          - Generate tests"
    echo "  af          - Fix issues"
    echo "  aq          - Run quality checks"
    echo ""
    echo "Documentation:"
    echo "  ah          - Show command reference"
    echo "  aw          - Show working agreement"
    echo "  ai          - Show Helix integration guide"
    echo ""
    echo "Session Management:"
    echo "  as          - List all sessions"
    echo "  asc         - Show current session summaries"
    echo "  auggie-clean [days] - Clean old sessions (default: 30 days)"
    echo ""
    echo "Context Helpers:"
    echo "  auggie-here [file] - Start with current file context"
    echo "  auggie-git [commits] - Start with git history context"
    echo "  auggie-project-setup - Create project AI context file"
    echo ""
    echo "Integration:"
    echo "  hx-auggie <file> - Open in Helix and start Auggie"
    echo "  aff         - Auggie with file finder integration"
    echo "  afs         - Auggie with search integration"
}

# Auto-completion for auggie-session command
if command -v compdef >/dev/null 2>&1; then
    _auggie_session() {
        local -a commands
        commands=(
            'continue:Continue current session'
            'new:Start fresh conversation thread'
            'refactor:Quick refactor current selection/function'
            'test:Generate tests for current code'
            'fix:Fix issues in current selection'
            'quality:Run quality checks'
        )
        _describe 'commands' commands
    }
    compdef _auggie_session auggie-session
fi

echo "Auggie aliases loaded. Type 'auggie-help' for available commands."
