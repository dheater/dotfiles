# Personal AI-related aliases and functions
# Simple, practical shortcuts for AI-assisted development

# Quick access to working agreement
alias ai-agreement='hx $HOME/.auggie-memory/../working-agreement.md'

# Project-specific AI workflow (when it exists)
alias ai-workflow='[[ -f docs/ai-workflow.md ]] && hx docs/ai-workflow.md || echo "No project AI workflow found"'

# Auggie with sequential-thinking MCP server enabled globally
alias auggie-think="auggie --mcp-config $HOME/.auggie-memory/../mcp-config.json"

# Carl - Auggie with personal context and critical persona pre-loaded
carl() {
    # Handle resume command
    if [[ "$1" == "resume" ]]; then
        $HOME/.auggie-memory/../list-sessions.sh
        return
    fi

    echo "🔥 Carl loaded - Design role models: Andrew Kelly (Zig) & Casey Muratori"
    echo "   Direct feedback, challenge complexity, advocate simplicity"
    echo ""

    local context_prompt="Be my critical Carl persona - direct, honest feedback, challenge complexity, advocate for simplicity. No excessive praise or validation."

    # Load context files directly without testing first
    local personal_context=$(cat $HOME/.auggie-memory/personal/context.md 2>/dev/null)
    local work_patterns=$(cat $HOME/.auggie-memory/work/patterns.md 2>/dev/null)

    if [[ -n "$personal_context" && -n "$work_patterns" ]]; then
        auggie "$context_prompt

Personal Context:
$personal_context

Work Patterns:
$work_patterns"
    else
        echo "Warning: Failed to load context files, falling back to basic prompt"
        echo "Personal context loaded: $([[ -n "$personal_context" ]] && echo "yes" || echo "no")"
        echo "Work patterns loaded: $([[ -n "$work_patterns" ]] && echo "yes" || echo "no")"
        auggie "$context_prompt"
    fi
}
