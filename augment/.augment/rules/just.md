# Just

Use Just's expression language. Bash = escape hatch for complex pipelines only. POSIX in recipe bodies.

## Patterns
| Use case | DO | DON'T |
|---|---|---|
| Conditional | `{{ if X == "a" { "val" } else { error("bad") } }}` | bash case statement |
| Platform | `if os() == "macos" { "arm" } else { "x86" }` | uname -s |
| Strings | `"prefix-" + var + ".ext"` | echo with shell var |
| Paths | `config_dir() / ".config"` | "$HOME/.config" |
| POSIX | `@test -x bin || exit 1` | `@if [[ ! -x bin ]]; then` |

Functions: `os()`, `arch()`, `env_var(name)`, `env_var_or_default(name, default)`, `error(message)`

## Organization
- Variables at top with `env_var_or_default`
- Recipe deps via `: dep` not `just dep` calls
- Private helpers: `_name` or `[private]`
- Doc comments: `#` directly above recipe

## Decision tree
```
Control flow? Simple -> Just expr. Complex pipeline -> Bash.
Platform? -> os()/arch()
Env var with default? -> env_var_or_default. Without? -> env_var.
```

## Checklist
- [ ] Just expr instead of bash? POSIX (not bash-isms)?
- [ ] Variables for repeated values? Private helpers? Doc comments?
