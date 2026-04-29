# API Stability

Libraries: SemVer MAJOR.MINOR.PATCH. Applications: CalVer YYYY.MM.PATCH.
Evolve add-only. Breaking = major bump (rare, clean break).

## C API Patterns
- Symbol prefix: `mylib_` + `LIB_API` visibility macro
- Opaque handles: `typedef struct lib_ctx_* lib_ctx;` (never expose struct layout)
- Size'd structs: `uint32_t size;` + reserved fields
- Capability negotiation: feature bitset (not api_level)
- Errors: stable integer codes + `lib_strerror()`
- Memory: `lib_free()` or two-call pattern (no owned pointers)

## Versioning
MAJOR: breaking (rare) | MINOR: new features | PATCH: bugfixes
Deprecate first, remove in next major. LTS: 24-36 months per major.

## ABI Checks
- Linux: `abidiff old.so new.so`
- macOS: `nm -g new.dylib | diff - expected_symbols.txt`
- Windows: `.def` file or decorated exports
- Headers: `clang -Xclang -ast-dump=json public.h` diff against baseline
- CI: Build LTS + HEAD, run ABI diff, sanitizers, fuzz

## Checklist
- [ ] Add-only? Defaults unchanged? Error codes stable?
- [ ] Capability negotiation (not api_level)?
- [ ] Incompatible? -> Major bump
- [ ] Run abidiff / symbol checks
