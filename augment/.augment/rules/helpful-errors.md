# Helpful Errors

Error messages: WHAT failed + WHY it matters + HOW to fix + CONTEXT (codes/values/paths).
Default: fail fast. Recovery only for specific, recurring, bounded, testable failures.

## Template
```
[WHAT] operation that failed
[WHY] why it matters / what was expected
[HOW] actionable fix
[CONTEXT] codes, values, paths
```

## Examples
- "error: Invalid" -> "error: Cannot use []Type as comptime value. Use: const x: []const T = &[_]T{a, b};"
- "Connection failed" -> "SSH_AUTH_FAILED: Public key rejected by 10.0.1.50. Check ~/.ssh/id_rsa perms (0600)"
- "Parse error" -> "JSON parse error line 42 col 15: Expected '}' found ','. Missing brace at line 38."

## Error Codes (C)
```c
typedef int32_t lib_err_t;
#define LIB_OK 0
#define LIB_ERR_NETWORK -1
const char* lib_strerror(lib_err_t code);
```

## Recovery: add only if
Specific recurring failure + bounded attempts + explicit backoff + testable + caller can opt out.

## Checklist
- [ ] What/Why/How/Context included? User can fix without reading source?
- [ ] Error codes stable?
- [ ] Recovery: bounded? testable? opt-out?
