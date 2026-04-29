# Documentation

Do NOT create unsolicited documentation.
Prefer: self-documenting code > comments > user docs.
If docs needed to explain code, improve the code first.

## When to write user docs
Write: new feature, significant architecture change, public API change, build process change.
Don't write: bug fixes, refactoring, adding tests, updating deps.

## Agent notes
Location: `.agent/notes/` (gitignored). Never project root.

## README
Include: 1-2 sentence description, quick start (install/build/test), architecture summary.
Exclude: detailed API docs, change history, implementation details, time estimates.

## Time estimates
NEVER generate. Bad at it (off 2-10x). Use: complexity (low/medium/high) + scope + deps instead.

## Before creating any .md file
1. User asked? No -> don't create
2. Agent notes? -> .agent/notes/
3. Can improve code instead? -> refactor
