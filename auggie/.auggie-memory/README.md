# Carl's Memory System

This directory contains Carl's long-term memory files that define personality, preferences, and working patterns.

## Structure

```
.auggie-memory/
├── personal/
│   └── context.md     # Personal preferences, work style, AI interaction patterns, protocols
├── work/
│   └── patterns.md    # Development patterns, team context, debugging preferences
└── README.md          # This file
```

## Usage

The `carl` command automatically loads these files to provide context-aware AI assistance:

```bash
carl "Help me debug this compiler error"
# Loads personal context + work patterns, including the Tarik and Maynor Protocols
```

## Stow Integration

These files are managed by GNU stow as part of the `auggie` package:

```bash
cd ~/dotfiles
stow auggie  # Creates ~/.auggie-memory and other auggie symlinks
```

This approach:
- ✅ Files are backed up in Git (in dotfiles)
- ✅ Auggie finds them at the expected location (`~/.auggie-memory`)
- ✅ Uses standard dotfiles management (stow)
- ✅ No custom bash scripting for symlinks
- ✅ Easy to version control AI interaction patterns

Run `~/dotfiles/setup.sh` to set up everything automatically.

## Security Note

⚠️ **These files are version controlled and potentially public**
- No passwords, API keys, or secrets
- No sensitive personal information
- Company name (Imprivata) is acceptable as it's already in Git commits
- Focus on work patterns and preferences, not confidential data

## Key Components

### Personal Context (`personal/context.md`)
- Technical preferences (Helix, terminal-first workflow)
- Communication style (direct, critical feedback)
- Work patterns and energy management
- AI interaction preferences
- **Core Principles**: Subtract First Principle, 10x Rule
- **User Interaction Protocols**: Tarik and Maynor protocols

### Work Patterns (`work/patterns.md`)
- Development methodology and testing approach
- Problem-solving patterns and debugging preferences
- Team communication and collaboration patterns
- Technology stack and tool preferences

## Core Principles

### Subtract First Principle
Remove before adding - apply when tackling new tasks or when Maynor is invoked

### 10x Rule
Everything we do can be done 10x better - apply when reviewing completed work

## User Interaction Protocols

### The Tarik Protocol (formerly Wingnut)
Systematic compiler debugging approach triggered by "invoke the Tarik protocol"

### The Maynor Protocol
Anti-flailing protocol triggered by "invoke the Maynor protocol" - stops iteration cycles and forces simpler thinking

## Maintenance

- Update dates when making changes
- Keep content focused on patterns, not specific projects
- Sanitize any potentially sensitive information
- Version control changes to track evolution of working relationship
- Use `stow auggie` to update symlinks after changes

---
*Memory system established: 2025-08-27*
*Stow integration: 2025-08-27*
