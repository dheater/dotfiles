# Testing

Sanitizers on all tests. Fuzz parsers/decoders. Golden tests for invariants.
Property tests > exhaustive examples. Test at seams not internals.

## Sanitizers
```bash
zig build test -Dsanitize=address    # memory errors
zig build test -Dsanitize=undefined  # UB
zig build test -Dsanitize=thread     # races
zig build test -Dsanitize=memory     # uninitialized reads
```
CI: run all tests with each sanitizer in matrix.

## Fuzzing
Always fuzz: parsers, decoders, handshakes, input validation.
```zig
export fn LLVMFuzzerTestOneInput(data: [*]const u8, size: usize) c_int {
    _ = parser.parse(data[0..size]) catch return 0;
    return 0;
}
```
CI: 60s short run. Nightly: 1hr. Version-control minimal corpus.

## Golden Tests
Test ordering, idempotence, error code mapping, serialization round-trips.
Use `@embedFile("golden/x.txt")` for stable baselines.

## Property Tests
One property > 100 examples. Properties: round-trip, inverse, commutativity, associativity.

## Seams
Test public API / observable behavior at boundaries, not internals.

## Checklist
- [ ] Tests for public API? Error paths?
- [ ] Sanitizers: ASan/UBSan/TSan?
- [ ] Fuzz targets for parsers?
- [ ] Golden tests for invariants?
- [ ] Property tests where applicable?
