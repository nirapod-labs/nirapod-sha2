# Status

This is the state of release 0.1.0, at the commit tagged `v0.1.0`, with
toolchain 2026.11.1. On the x86-64 machine below every job of
`ci/run.sh --all` passed at that commit. On the M4 the default jobs passed;
the proof job runs on Linux only.
The toolchain itself was built from scratch on the x86-64 machine by
`toolchain/build.sh all`, including its Rocq proofs and the scans for
assumptions and admitted proofs.

## Units

AArch64, on an Apple M4 under macOS, natively:

|                        | `aarch64-portable` | `aarch64-scalar` | `aarch64-sha2` |
| ---------------------- | ------------------ | ---------------- | -------------- |
| tests, macOS           | pass               | pass             | pass           |
| `jasmin-ct`, `--sct`   | pass               | pass             | pass           |
| safety, EasyCrypt      | proved             | proved           | proved         |
| correctness, EasyCrypt | proved             | proved           | proved         |
| assembly inspected     | yes                | yes              | yes            |
| benchmarked, macOS     | yes                | yes              | yes            |
| default dispatch       | fallback           | no               | every family   |

x86-64, on an AMD Ryzen 7 7700X under Linux (WSL2):

|                        | `x86_64-portable` | `x86_64-shani` | `x86_64-avx2`                  |
| ---------------------- | ----------------- | -------------- | ------------------------------ |
| tests, Linux           | pass              | pass           | pass                           |
| `jasmin-ct`, `--sct`   | pass              | pass           | pass                           |
| safety, EasyCrypt      | proved            | proved         | proved                         |
| correctness, EasyCrypt | proved            | proved         | proved                         |
| assembly inspected     | yes               | yes            | yes                            |
| benchmarked, Linux     | yes               | yes            | yes                            |
| default dispatch       | fallback          | SHA-256, 8-way | SHA-512, 4-way; SHA-256 second |

The proofs cover both architectures and ran on the x86-64 machine;
`jasmin-ct` and the extraction check cover both and ran on both machines.
The instruction models were checked against the processor they describe:
the x86-64 ones natively on the 7700X, and the Armv8-A ones natively on the
M4, which also reproduced the recorded run.

`aarch64-scalar` is for A64 cores without the SHA-2 instructions. It has
passed everything the dispatched units have, and only the testing library
reaches it. [ARCHITECTURE](ARCHITECTURE.md#dispatch) gives the dispatch
order and [KERNELS](KERNELS.md) the inspection notes.

Memory safety rests on the EasyCrypt proofs of the `#[safety]` contracts
([PROOFS](PROOFS.md#memory-safety)).

## Not repeated for this release

* Linux on AArch64. The tests passed there, in a virtual machine on the M4,
  in October 2026 on an earlier revision; they were not run at the release
  revision.
* The benchmarks in [BENCHMARKS](BENCHMARKS.md) and the assembly
  inspection in [KERNELS](KERNELS.md) were done in October 2026 with the
  previous toolchain. Comparing the assembly of the nine unit and
  system pairs, 2026.11.1 assigns some registers differently and, in the
  x86-64 portable and SHA-NI units, changes three register-to-register
  moves each. No other instruction changed.

## Known limitations

* Every call pays an entry fence and, on AArch64, two writes of PSTATE.DIT.
  On short messages this costs more than a whole BoringSSL call
  ([BENCHMARKS](BENCHMARKS.md#short-messages)); a caller that keeps DIT set
  saves the writes ([API](API.md#dit-and-short-messages)).
* The speculative check models conditional-branch misprediction only. The C
  layer calls each export through a function pointer, and indirect-branch
  speculation is left to the platform
  ([SECURITY-MODEL](SECURITY-MODEL.md#speculation)).
* The assembly carries no CET or BTI markings.
* Fault injection and physical side channels are out of scope.
* The C layer is tested, not proved.
