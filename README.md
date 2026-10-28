# nirapod-sha2

[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-x86--64%20%7C%20AArch64-lightgrey)](docs/STATUS.md)
[![Status](https://img.shields.io/badge/status-unreleased-orange)](docs/STATUS.md)

## About

nirapod-sha2 implements SHA-2 and HMAC for x86-64 and AArch64 in Jasmin, with
a small C API. Its exported procedures are proved correct and memory safe in
EasyCrypt, and checked constant-time and speculative constant-time with the
Jasmin type systems.

What is proved, and under which assumptions, is in
[docs/PROOFS.md](docs/PROOFS.md). What is done and what is still missing is in
[docs/STATUS.md](docs/STATUS.md).

## Building

The pinned toolchain and its patch series are described in
[docs/TOOLCHAIN.md](docs/TOOLCHAIN.md).

If you just want to build and test the library, here is a TL;DR:

- build the pinned Jasmin and EasyCrypt

  ```sh
  toolchain/build.sh
  ```

- build the library and run the checks

  ```sh
  make && make check
  ```

- check the proofs (Linux)

  ```sh
  make -C proofs check
  ```

## Getting support

Questions and bug reports go to the
[issue tracker](https://github.com/nirapod-labs/nirapod-sha2/issues).
Security problems go privately, as [SECURITY.md](SECURITY.md) describes.

## License

nirapod-sha2 is free software, licensed under the
[Apache License 2.0](LICENSE). A few third-party files keep their own
licences, listed in [REUSE.toml](REUSE.toml).
