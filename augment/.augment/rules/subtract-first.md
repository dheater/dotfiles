# Subtract First

Default order: Delete -> Simplify -> Reuse -> Add (last resort).

## Rules
- No abstraction without 3+ real uses proven to reduce total code vs duplication.
- Keep interfaces small and cohesive. No micro-libraries. No convenience wrappers as public deps.
- Fail fast by default. Recovery only if specific/recurring/bounded/testable/opt-out.
- Allocations explicit. Blocking/I/O explicit. No hidden control flow.

## Checklist
- [ ] What was deleted?
- [ ] What was simplified?
- [ ] What was reused?
- [ ] Additions justified?
- [ ] Can delete more?

## Commit format
```
feat: add X
Deleted: [what]
Simplified: [what]
Reused: [what]
Added: [what and why]
```
