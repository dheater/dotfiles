# Comments

Default: zero. Explain WHY not WHAT.
Add only for: surprising behavior / non-obvious constraint / workaround / security+perf.
Delete if: narrates code / repeats names / tracks history (use git).

## Public API
Must have doc comments (C/C++: Doxygen, Zig: `///`, Python: docstrings).
Include: purpose, params/return/errors, preconditions, thread safety.
Exclude: implementation details, obvious params, repeating function name.

## TODO/FIXME/HACK
```
// TODO(user): description - Issue #N
// FIXME(user): description - Issue #N
// HACK(user): description - Remove when X fixed
```

## Rules
- Use `//` not `/* */`
- Before adding: explains WHY? narrating? tracking history? can improve code instead? -> delete/refactor
- Prefer: better names > simpler code > log messages > comments
