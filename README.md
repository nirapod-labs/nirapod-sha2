# nirapod-sha2

SHA-2 and HMAC for x86-64 and AArch64, written in
[Jasmin](https://github.com/jasmin-lang/jasmin) and proved correct in
[EasyCrypt](https://github.com/EasyCrypt/easycrypt), with a small C API.

The library implements SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224 and
SHA-512/256 (FIPS 180-4) and HMAC-SHA-256 and HMAC-SHA-512 with keys of any
length (FIPS 198-1), one-shot and incremental, plus 8-way SHA-256 and 4-way
SHA-512 over messages of equal length. Everything that reads a message, a
key or a hash state is Jasmin. The C layer checks arguments, picks a kernel
for the CPU, sets PSTATE.DIT on AArch64 and clears registers on return.

There has been no release. Do not use this in production yet.

## Verification scope

The Jasmin code is compiled as six units, one per architecture and kernel
family, and every unit carries the same 42 exports. For each export of each
unit:

* total correctness is proved in EasyCrypt against a transcription of FIPS
  180-4 and FIPS 198-1, on the model `jasmin2ec` extracts from the unit's
  sources and roots, checked token for token against the unit that is linked
  into the library;
* its `#[safety]` contract is proved in EasyCrypt on the unit's safety
  model;
* `jasmin-ct` and `jasmin-ct --sct` accept it, with `--doit`.

The theorems hold for inputs below $2^{61}$ bytes (a block less for the HMAC
message) in buffers that do not wrap the address space. Nothing is admitted.
They rest on EasyCrypt and its SMT solvers, on `jasmin2ec`, and on the
EasyCrypt models of the instructions the kernels use: those for SHA-NI and
the Armv8-A SHA-2 and Advanced SIMD instructions are tested against hardware
rather than proved, and upstream's AVX2, BMI1 and BMI2 models are not tested
here. The C layer is tested, not verified. `jasmin-checksafety`, run as a
second check, so far passes on fewer than half of the 252 export-unit pairs
([docs/STATUS.md](docs/STATUS.md)).

The statements and their preconditions are in
[docs/PROOFS.md](docs/PROOFS.md), the threat model and the trusted base in
[docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md).

## Building

You need Jasmin and EasyCrypt at the commits pinned under `toolchain/`, a
C99 compiler and GNU make. The pinned Jasmin carries a patch series: without
it the compiler has no Armv8-A vector or SHA-2 instructions and no safety
checker for that target. `toolchain/build.sh` builds both tools, with the
patches applied, in an opam switch of its own
([docs/TOOLCHAIN.md](docs/TOOLCHAIN.md)).

With the tools on `PATH`:

```sh
make                         # build/<arch>-<system>/lib/libnirapod_sha2.a
make check                   # exported symbols, smoke tests, DIT handling
make ct                      # jasmin-ct and --sct on this architecture's units
make -C proofs check J=8     # every proof on every unit (Linux, over an hour)
ci/run.sh --all              # every gate, proofs and checksafety included, as jobs
```

The API is [include/nirapod/sha2.h](include/nirapod/sha2.h); its comment
block is the contract.

## Documentation

* [Status](docs/STATUS.md): what holds for each unit, what is missing
* [API](docs/API.md): using the library from C and from Jasmin
* [Architecture](docs/ARCHITECTURE.md): units, roots, dispatch, data layout
* [Kernels](docs/KERNELS.md): kernel design and the code it compiles to
* [Security model](docs/SECURITY-MODEL.md): threats, leakage, trusted base
* [Proofs](docs/PROOFS.md): the theorems, their domain, how to check them
* [Validation](docs/VALIDATION.md): tests, oracles, instruction-model checks
* [Benchmarks](docs/BENCHMARKS.md): latency against the fastest baselines
* [Toolchain](docs/TOOLCHAIN.md): pins and the Jasmin patch series

## License

Apache-2.0, except the two EasyCrypt theories under
`third_party/crypto-specs` (CC0-1.0) and the test vectors, which keep the
terms of their sources ([REUSE.toml](REUSE.toml)).
