# C++ Guidelines

C++17. Public API: C-only. Internal: RAII, const-correct, smart pointers, no raw new/delete.

## Public API (include/)
`extern "C"` linkage, opaque pointers, C types, error codes not exceptions, `#pragma once`.
- class/std::string/throw -> typedef opaque*/const char*/return error code

## Internal (src/)
- No raw new/delete. Use make_unique/make_shared.
- Ownership: unique_ptr exclusive, shared_ptr shared (sparingly), raw = non-owning.
- Async: capture `shared_from_this()`, NEVER raw `this` in lambdas (use-after-free).
- Const: all getters `const`, pass by `const&` not value.
- Thread safety: mutex + lock_guard for shared state.
- Errors: exceptions for exceptional, error codes for expected/async, optional for "not found".

## Compiler Flags
Common: `-Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Wshadow -Wcast-qual -Wcast-align`
C-only: `-Wstrict-prototypes -Wmissing-prototypes`
C++: `-Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wdeprecated-copy-dtor`
CI: `-Werror`

## Checklist
- [ ] Public: C-only? extern "C"? Opaque pointers? Error codes?
- [ ] Internal: RAII? Smart ptrs? Const-correct? Thread-safe? Async lifetimes?
