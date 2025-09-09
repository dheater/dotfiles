# Work Patterns - Daniel Heater

## Development Approach
- **Methodology**: Pair programming with AI assistance
- **Testing**: Prefers writing tests first, then minimal implementation
- **Code Style**: Maintain consistency with existing patterns
- **Documentation**: Add comments only when rationale is non-obvious

## Problem-Solving Patterns
- **First Instinct**: Look for what can be removed/simplified
- **Architecture**: Avoid over-engineering, build for current needs
- **Debugging**: Use quality tools (sanitizers, analyzers, coverage)
- **Decision Making**: Can get analysis paralysis, needs gentle pushing

## Team Context
- **Company**: Imprivata
- **Role**: Senior Software Developer
- **Data Handling**: Company data approved for Augment Code processing
- **Sharing**: Work context can be shared with team for knowledge base

## Technology Stack
- **Languages**: C++, Rust, Zig
- **Tools**: Command-line focused, terminal-first workflow
- **Build Systems**: Adapts to project needs (Make, Just, CMake, etc.)
- **Version Control**: Git with conventional commit messages. Prefix commit messages with JIRA ticket number when one exists. Git branch name will match the JIRA ticket number

## Communication Preferences
- **Status Updates**: Brief summaries of what changed and why
- **Code Reviews**: Focus on maintainability and simplicity
- **Documentation**: Prefer inline code clarity over extensive docs
- **Meetings**: Minimal, focused on decisions not status

## Learning & Growth
- **Feedback**: Direct, actionable feedback preferred
- **Mistakes**: Learn from them but don't dwell
- **Complexity**: Actively resist feature creep and gold-plating
- **Innovation**: Balanced with pragmatism and delivery needs

## User Interaction Protocols

### The Maynor Protocol
**Trigger**: "Invoke the Maynor protocol" when AI is flailing with repeated failures
**Purpose**: Break out of failing iteration cycles and reset approach
**Response**: When invoked, AI must:
1. **STOP** current approach immediately - no more iterations
2. **Review** what has been attempted and why it's failing
3. **Learn** from the pattern of failures and extract insights
4. **Think hard** about the root cause from first principles
5. **Try something simpler** - often much simpler than previous attempts
6. **Apply subtract first principle** - remove complexity before adding solutions

The Maynor Protocol is invoked when you notice AI repeatedly trying variations of the same failing approach instead of stepping back to reconsider the problem fundamentally. It forces a complete reset to simpler thinking with the subtract first principle.

---
*Last Updated: 2025-08-27*

## Quality Gates (Pre-Commit Checklist)
**ALWAYS run before any commit or code completion - language specific:**

### Rust Projects
```bash
cargo clippy -- -D warnings && cargo fmt --check && cargo test
```
1. **Clippy (Strict)**: `cargo clippy -- -D warnings` - Must pass with zero warnings
2. **Rustfmt**: `cargo fmt --check` - Must pass with no formatting changes needed  
3. **Tests**: `cargo test` - All tests must pass

### Zig Projects
```bash
zig fmt --check . && zig build test && zig build
```
1. **Zig fmt**: `zig fmt --check .` - Must pass with no formatting changes needed
2. **Tests**: `zig build test` - All tests must pass
3. **Build**: `zig build` - Must compile without errors or warnings

### C++ Projects  
```bash
clang-format --dry-run --Werror . && clang-tidy **/*.cpp **/*.h && make test && make
```
1. **Clang-format**: `clang-format --dry-run --Werror .` - Must pass formatting check
2. **Static Analysis**: `clang-tidy **/*.cpp **/*.h` - Must pass static analysis checks
3. **Tests**: `make test` (or equivalent) - All tests must pass
4. **Build**: `make` (or equivalent) - Must compile without errors or warnings

**Critical**: Never skip quality gates. They prevent regressions and maintain code quality standards. If any gate fails, fix the issues before proceeding.

## Memory Management
**When user says "memory" or "remember"**: Store information in `~/.auggie-memory/` files
- Personal context: `~/.auggie-memory/personal/context.md`
- Work patterns: `~/.auggie-memory/work/patterns.md` 
- Design principles: `~/.auggie-memory/design-principles.md`
- Update the appropriate file based on context type

CRITICAL SAFETY RULES - DATA LOSS PREVENTION
- NEVER use ~ in paths with mkdir/save-file/str-replace-editor - Creates literal ~ directories  
- ALWAYS use absolute paths: /Users/dheater/ or $HOME/ instead of ~/
- ALWAYS verify before destructive operations: Use ls -la, file, readlink to check targets
- NEVER remove without verification: Check if symlinks point to critical directories like $HOME
