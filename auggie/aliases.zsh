# Personal AI-related aliases and functions
# Simple, practical shortcuts for AI-assisted development

# Quick access to working agreement
alias ai-agreement='hx ~/dotfiles/auggie/working-agreement.md'

# Project-specific AI workflow (when it exists)
alias ai-workflow='[[ -f docs/ai-workflow.md ]] && hx docs/ai-workflow.md || echo "No project AI workflow found"'

# Auggie with sequential-thinking MCP server enabled globally
alias auggie-think="auggie --mcp-config ~/dotfiles/auggie/mcp-config.json"

# Carl - Auggie with personal context and critical persona pre-loaded
carl() {
    # Handle resume command
    if [[ "$1" == "resume" ]]; then
        ~/dotfiles/auggie/list-sessions.sh
        return
    fi

    local context_prompt="Be my critical Carl persona - direct, honest feedback, challenge complexity, advocate for simplicity. No excessive praise or validation."

    # Check if context files exist and are readable
    if [[ ! -r ~/.auggie-memory/personal/context.md ]] || [[ ! -r ~/.auggie-memory/work/patterns.md ]]; then
        echo "Warning: Context files not found or not readable"
        auggie "$context_prompt"
        return
    fi

    # Load context files and pass to auggie
    local personal_context=$(cat ~/.auggie-memory/personal/context.md 2>/dev/null)
    local work_patterns=$(cat ~/.auggie-memory/work/patterns.md 2>/dev/null)

    if [[ -n "$personal_context" && -n "$work_patterns" ]]; then
        auggie "$context_prompt

Personal Context:
$personal_context

Work Patterns:
$work_patterns"
    else
        echo "Warning: Failed to load context files, falling back to basic prompt"
        auggie "$context_prompt"
    fi
}

