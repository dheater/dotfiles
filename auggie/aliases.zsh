# Personal AI-related aliases and functions
# Simple, practical shortcuts for AI-assisted development

# Quick access to working agreement
alias ai-agreement='hx ~/dotfiles/auggie/working-agreement.md'

# Project-specific AI workflow (when it exists)
alias ai-workflow='[[ -f docs/ai-workflow.md ]] && hx docs/ai-workflow.md || echo "No project AI workflow found"'

# Auggie with sequential-thinking MCP server enabled globally
alias auggie-think="auggie --mcp-config ~/dotfiles/auggie/mcp-config.json"
