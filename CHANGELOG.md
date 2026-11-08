# Changelog

The project follows [Semantic Versioning](https://semver.org/). Before 1.0
a minor release may change the interface.

## 0.1.0 (2026-11-08)

First release.

* SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224 and SHA-512/256, one-shot
  and incremental, and HMAC-SHA-256 and HMAC-SHA-512 with keys of any
  length, in Jasmin for x86-64 and AArch64, through the C API of
  `<nirapod/sha2.h>`.
* 8-way SHA-256 and 4-way SHA-512 over messages of equal length.
* Kernels: portable on both architectures; A64 scalar and the Armv8-A SHA-2
  instructions on AArch64; SHA-NI and AVX2 on x86-64. The C layer picks one
  from the CPU features.
* EasyCrypt proofs of total correctness against FIPS 180-4 and FIPS 198-1
  and of the memory-safety contracts, for all 42 exports of all six units;
  constant time and speculative constant time verified with the Jasmin type
  systems. Scope and assumptions are in [docs/PROOFS.md](docs/PROOFS.md)
  and [docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md).
* Built with toolchain 2026.11.1 of
  [nirapod-labs/toolchain](https://github.com/nirapod-labs/toolchain).
