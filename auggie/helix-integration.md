# Helix + Auggie Integration Setup

This guide sets up seamless integration between Helix and Auggie CLI for AI-assisted development.

## Prerequisites

- Helix editor installed and configured
- Auggie CLI installed and in PATH
- WezTerm terminal (recommended)
- Zsh shell configured

## Helix Configuration

### 1. Add AI Commands to config.toml

Add these commands to your `~/.config/helix/config.toml`:

```toml
[keys.normal.space.a]
i = ":ai-continue"
n = ":ai-new" 
r = ":ai-refactor"
t = ":ai-test"
f = ":ai-fix"
q = ":ai-quality"
"?" = ":ai-help"
w = ":ai-agreement"

# Alternative bindings for common operations
[keys.normal.space.a.space]
r = ":ai-continue"  # Quick access to continue session
```

### 2. Define Custom Commands

Add to your Helix `commands` section:

```toml
[commands]
ai-continue = ":sh auggie --session current --context-buffer"
ai-new = ":sh auggie --new-session --context-buffer"
ai-refactor = ":sh auggie refactor --context-selection"
ai-test = ":sh auggie test --context-function"
ai-fix = ":sh auggie fix --context-selection"
ai-quality = ":sh auggie quality --context-file"
ai-help = ":open ~/.dotfiles/auggie/commands.md"
ai-agreement = ":open ~/.dotfiles/auggie/working-agreement.md"
```

## Session Directory Setup

### 1. Create Session Storage

```bash
# Create session directory (not version controlled)
mkdir -p ~/.auggie-sessions

# Create project-specific session dirs as needed
mkdir -p ~/.auggie-sessions/dotfiles
mkdir -p ~/.auggie-sessions/my-project
```

### 2. Session Management Scripts

Create helper script `~/.local/bin/auggie-session`:

```bash
#!/bin/bash
# Auggie session management for Helix integration

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
SESSION_DIR="$HOME/.auggie-sessions/$PROJECT_NAME"

mkdir -p "$SESSION_DIR"

case "$1" in
    "continue")
        auggie --session-dir "$SESSION_DIR" --context-file "$PROJECT_ROOT"
        ;;
    "new")
        auggie --session-dir "$SESSION_DIR" --new-session --context-file "$PROJECT_ROOT"
        ;;
    "refactor")
        auggie refactor --session-dir "$SESSION_DIR" --context-selection
        ;;
    "test")
        auggie test --session-dir "$SESSION_DIR" --context-function
        ;;
    "fix")
        auggie fix --session-dir "$SESSION_DIR" --context-selection
        ;;
    "quality")
        auggie quality --session-dir "$SESSION_DIR" --context-file
        ;;
    *)
        echo "Usage: auggie-session {continue|new|refactor|test|fix|quality}"
        ;;
esac
```

Make it executable:
```bash
chmod +x ~/.local/bin/auggie-session
```

## Context Integration

### 1. Automatic Context Detection

Auggie should automatically detect:
- Current file and cursor position
- Selected text in Helix
- Git repository information
- Project build system (Make, Just, etc.)

### 2. Project Context Files

For team-shared context, create in each project:

```bash
# In project root
mkdir -p docs
touch docs/ai-context.md
```

Example `docs/ai-context.md`:
```markdown
# AI Context for [Project Name]

## Build System
- Primary: `make build`
- Tests: `make test`
- Quality: `just test-asan`, `just test-ubsan`

## Code Conventions
- C++ Core Guidelines
- Header guards: `#pragma once`
- Public API: Pure C in `include/` directory

## Current Focus
- Socket cleanup refactoring
- Threading issue resolution
- Cross-platform compatibility

## Known Issues
- TSan finds threading races in socket handling
- Memory leaks in cleanup paths
```

## Terminal Integration

### 1. WezTerm Configuration

Add to your `~/.config/wezterm/wezterm.lua`:

```lua
-- Auggie integration
config.keys = {
  -- Quick Auggie access
  {
    key = 'a',
    mods = 'LEADER',
    action = wezterm.action.SpawnCommandInNewTab {
      args = { 'auggie-session', 'continue' },
    },
  },
  -- Other bindings...
}
```

### 2. Zsh Aliases

Add to your `~/.zshrc`:

```bash
# Auggie shortcuts
alias ac='auggie-session continue'
alias an='auggie-session new'
alias ar='auggie-session refactor'
alias at='auggie-session test'
alias af='auggie-session fix'
alias aq='auggie-session quality'
alias ah='cat ~/.dotfiles/auggie/commands.md'
```

## Workflow Examples

### 1. Starting Work Session

```bash
# In terminal
cd ~/my-project
hx src/main.cpp

# In Helix
<space>ai  # Continue previous session
```

### 2. Refactoring Workflow

```bash
# In Helix
1. Select function to refactor
2. <space>ar  # Quick refactor
3. Review changes
4. Accept or undo with 'u'
```

### 3. Quality Check Workflow

```bash
# In Helix
<space>aq  # Run quality checks
# Auggie runs sanitizers, reports issues
# Fix issues inline with suggestions
```

## Troubleshooting

### Common Issues

**Commands not found in Helix:**
- Check `config.toml` syntax
- Restart Helix after config changes
- Verify Auggie is in PATH

**Session context lost:**
- Check `~/.auggie-sessions/` permissions
- Verify project detection with `git rev-parse --show-toplevel`
- Use `:ai-history` to recover previous sessions

**Integration not working:**
- Test `auggie-session continue` in terminal first
- Check Helix command output with `:log-open`
- Verify all paths in configuration

### Getting Help

1. **In Helix**: `<space>a?` for quick reference
2. **Terminal**: `auggie --help` for CLI options
3. **Documentation**: `<space>aw` for working agreement
4. **Debug**: Check Helix logs with `:log-open`

## Advanced Configuration

### Custom Context Providers

Create project-specific context scripts:

```bash
#!/bin/bash
# .auggie/context-provider.sh
echo "## Current Build Status"
make --dry-run build 2>&1 | head -5

echo "## Recent Commits"
git log --oneline -5

echo "## Current Issues"
grep -r "TODO\|FIXME" src/ | head -3
```

### Integration with Existing Tools

```bash
# Use existing file search tools
alias aff='auggie --context-file $(ff)'  # Use your ff command
alias afs='auggie --context-search $(fs)' # Use your fs command
```

---

*This integration provides seamless AI assistance within your existing Helix workflow.*
