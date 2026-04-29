# Dependencies & Seams

Runtime deps <=5/project (excl. OS/stdlib).
Order: Duplicate (<=200 LOC) -> Vendor -> Static -> Dynamic (last resort).
All runtime libs expose stable C ABIs.

## Decision Tree
```
Need functionality?
  Duplicate <=200 LOC? -> yes: duplicate
  Vendor (header-only/source C)? -> yes: vendor
  Static link? -> yes: static
  Essential? -> yes: dynamic (justify in docs) | no: redesign
```
Exception: TLS/Crypto -> dynamic link to system libs.

## Library Boundary
Stable C ABI: opaque handles, size'd structs, error codes. Evolve add-only. Breaking = major bump.

## Seams
Process: fault/upgrade/language isolation, dep tree isolation.
Library: in-process perf, shared memory, tight coupling OK.
Design: thin interface, cohesive module, no micro-libs, add-only evolution.

## Offline Builds
Pin versions (lock files/vendored). Local caches. No network after cache populated.

## Checklist
- Before dep: duplicate/vendor possible? <=5 budget? Stable? Offline build?
- Before seam: one-pager (purpose, ops, invariants, errors, threading/lifetime).
