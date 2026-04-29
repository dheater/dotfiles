# Portability

Broad, boring compatibility. Stable platform APIs. Runtime feature detection. Pinned toolchains.

## Support Matrix
| Platform | Minimum | Arch |
|---|---|---|
| Linux | glibc >= 2.28 | x86_64, arm64 |
| Windows | Win10 22H2+ | x64, arm64 |
| macOS | macOS 11+ | x86_64, arm64 |

## Platform Rules
- Linux: build against old glibc. Validate: `readelf -V binary | grep GLIBC`
- Windows: pin toolchain (MSVC/MinGW). No private APIs, no hardcoded paths.
- macOS: `MACOSX_DEPLOYMENT_TARGET=11.0`. No private frameworks.

## Linking
TLS/Crypto -> dynamic link to system libs. Others -> follow dependency budget.

## Feature Detection
Runtime: check CPU features via platform APIs, use generic fallback.
Capability struct: `typedef struct LibCaps { uint32_t size; uint64_t features; } LibCaps;`
Never repurpose semantics: new behavior is opt-in via flags.

## Checklist
- [ ] Builds on oldest OS? Tested on latest?
- [ ] No private/unstable APIs?
- [ ] Toolchain pinned, offline build works?
- [ ] Feature detection for optional capabilities?
