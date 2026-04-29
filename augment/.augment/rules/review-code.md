# Code Review

Trigger: "review code"
Modes:
- Interactive ("review code"): review -> wait for approval -> make changes
- Analysis ("review project"): review -> report findings -> NO changes

## Checklist

### 1. Dead Code -> Delete (no exceptions)
Unused imports/functions/types/variables, commented-out code, unreachable code,
tests that always pass, stale comments, unused exports.

### 2. Duplication -> Extract/unify/delete
Identical blocks, copy-pasted logic, functions differing by one param.

### 3. Comments -> Delete narration, keep WHY
Delete: repeats function name / states what next line does.
Keep: explains WHY/constraint/workaround/public API docs/bug refs/business rules.
Always OK: closing brace comments, #endif comments -- conventional markers.

### 4. Simplification
Delete entirely? Merge similar functions? Simpler types? Remove params?
Make invalid states unrepresentable? Type system instead of runtime checks?
Wrapper functions adding no value? Unused options/params?

### 5. API Design
Too many ways to do same thing? Inconsistent names? Missing defaults?
Complex functions needing split? Wrappers adding no value?

### 6. Critical Issues
Unused params, silently failing error handling, missing error propagation,
potential panics that could be errors, type safety violations, memory leaks.

## Type System vs Runtime
"Can we avoid this error through API design?"
Keep runtime errors for: I/O failures, resource exhaustion, external commands, user input.
Delete runtime errors for: type mismatches, invalid combos, missing required fields.

## Output Format
```
## Code Review
### Dead Code
1. **Line X: desc** - why dead. Delete.
### Duplication
1. **Lines X,Y: desc** - what duplicated. Extract.
### Unnecessary Comments
1. **Line X: text** - why unnecessary. Delete.
### Simplification
1. **Name** - current complexity. Simpler alternative.
### Critical Issues
1. **Line X: issue** - what wrong. How to fix.
**Total savings: ~N lines**
```

## After Review
Interactive: "Wait for your input before making changes." No changes, hedging, praise, apologies.
Analysis: Report with file/line refs, P0/P1/P2. No changes, no asking approval.
