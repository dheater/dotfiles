# Auggie CLI Quick Reference

## Helix Integration Commands

### Leader Key Bindings (`<space>a`)

| Key | Command | Description |
|-----|---------|-------------|
| `i` | `:ai-continue` | Continue current session (default) |
| `n` | `:ai-new` | Start fresh conversation thread |
| `r` | `:ai-refactor` | Quick refactor current selection/function |
| `t` | `:ai-test` | Generate tests for current code |
| `f` | `:ai-fix` | Fix issues in current selection |
| `q` | `:ai-quality` | Run quality checks (sanitizers, etc.) |
| `?` | `:ai-help` | Show this command reference |
| `w` | `:ai-agreement` | Open working agreement |

### Session Management

#### `:ai-continue`
- **Use when**: Picking up previous conversation
- **Context**: Loads conversation history and project context
- **Default**: This is the primary command for ongoing work

#### `:ai-new`
- **Use when**: Starting completely different topic
- **Action**: Archives current session, starts fresh
- **Context**: Clean slate, but can reference previous work if needed

#### `:ai-history`
- **Use when**: Need to reference past conversations
- **Action**: Browse and select from previous sessions
- **Context**: Interactive session picker

## Natural Language Patterns

### Code Operations
```
"refactor this function to be more readable"
"add error handling to this block"
"optimize this loop for performance"
"extract this into a separate function"
"add unit tests for this class"
```

### Quality & Analysis
```
"run sanitizers on this code"
"check for memory leaks"
"analyze this for threading issues"
"validate cross-platform compatibility"
"review this code for best practices"
```

### Context-Aware Requests
```
"make this faster" → performance optimization
"add tests" → test generation for current code
"fix this" → debug current selection
"document this" → add documentation
"clean this up" → refactor for clarity
```

## CLI Commands (Terminal)

### Basic Usage
```bash
# Continue current session
auggie

# Start new session
auggie --new-session

# Session with specific context
auggie --context-file docs/ai-context.md

# Quick operations
auggie refactor --file src/main.cpp --function parse_args
auggie test --file src/parser.cpp
```

### Session Management
```bash
# List sessions
auggie sessions list

# Switch to specific session
auggie sessions switch <session-name>

# Archive current session
auggie sessions archive

# Clean old sessions
auggie sessions clean --older-than 30d
```

## File Context Integration

### Automatic Context
- Current file and cursor position
- Git repository information
- Project build system detection
- Recent conversation history

### Manual Context
```bash
# Add specific files to context
auggie --include src/parser.h src/parser.cpp

# Include build output
auggie --include-build-log

# Reference specific commit
auggie --git-context HEAD~3..HEAD
```

## Quality Check Integration

### Common Quality Commands
```bash
# Through Auggie
auggie quality --asan          # AddressSanitizer
auggie quality --ubsan         # UndefinedBehaviorSanitizer  
auggie quality --tsan          # ThreadSanitizer
auggie quality --leaks         # Memory leak detection
auggie quality --all           # Run all available checks

# Direct integration with existing tools
auggie run "just test-asan"    # Use your existing Just commands
auggie run "make test-coverage" # Use your existing Make targets
```

## Tips & Best Practices

### Effective Communication
- Be specific about what you want to achieve
- Mention constraints or preferences upfront
- Ask for multiple options when unsure
- Reference previous conversations when relevant

### Context Management
- Use `:ai-continue` as your default command
- Start `:ai-new` for unrelated topics
- Keep sessions focused on related work
- Archive completed work regularly

### Code Quality
- Let Auggie run quality checks automatically
- Review changes in Helix before accepting
- Use `u` to undo unwanted changes
- Ask for explanations of complex changes

### Session Organization
- Name sessions descriptively when archiving
- Use project-specific context files for team work
- Keep conversation history for reference
- Clean up old sessions periodically

## Troubleshooting

### Common Issues
- **Lost context**: Use `:ai-history` to find previous conversation
- **Wrong project**: Check current directory, switch if needed
- **Build failures**: Auggie will stop and ask for guidance
- **Unclear changes**: Ask for explanation before applying

### Getting Help
- `:ai-help` - Show this reference in Helix
- `auggie --help` - CLI help
- `:ai-agreement` - Review working agreement
- Ask Auggie directly: "How do I...?"

---

*Quick access: `<space>a?` in Helix or `auggie help` in terminal*
