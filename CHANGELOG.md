# Changelog

Notable changes to nirapod-sha2, newest first. The project will follow
[Semantic Versioning](https://semver.org/) from its first release.

Changes not yet in a release are described one per file under
[`changes/`](changes/README.md). A release collects them into its own
section here.

## Unreleased

Nothing has been released. What exists today:

- SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224 and SHA-512/256, one-shot
  and incremental, and HMAC-SHA-256 and HMAC-SHA-512 with keys of any
  length, through the C API in `include/nirapod/sha2.h`.
- 8-way SHA-256 and 4-way SHA-512 over messages of equal length.
- Kernels: portable on both architectures; scalar and SHA-2 instructions
  on AArch64; SHA-NI and AVX2 on x86-64. The C layer picks one by CPU
  feature, and the testing library forces each in turn.
- EasyCrypt proofs of functional correctness against FIPS 180-4 and
  FIPS 198-1, and of the memory-safety contracts, for all 42 exports on
  every unit; `jasmin-ct` and `jasmin-ct --sct` on every export of both
  architectures.
- Tests against the NIST CAVP and Wycheproof vectors and differential
  tests against OpenSSL, AWS-LC, BoringSSL and HACL*.
