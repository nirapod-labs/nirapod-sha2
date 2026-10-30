# Status

No release yet. The results below were recorded in October 2026. Since then
only comments, the header path and the documentation have changed, and the
full CI run has not been repeated.

## Units

AArch64, on an Apple M4 (macOS natively, Linux in a virtual machine):

|                        | `aarch64-portable` | `aarch64-scalar` | `aarch64-sha2` |
| ---------------------- | ------------------ | ---------------- | -------------- |
| tests, macOS and Linux | pass               | pass             | pass           |
| `jasmin-ct`, `--sct`   | pass               | pass             | pass           |
| safety, EasyCrypt      | proved             | proved           | proved         |
| `jasmin-checksafety`   | partial            | partial          | partial        |
| correctness, EasyCrypt | proved             | proved           | proved         |
| assembly inspected     | yes                | yes              | yes            |
| benchmarked, macOS     | yes                | yes              | yes            |
| default dispatch       | fallback           | no               | every family   |

x86-64, on an AMD Ryzen 7 7700X (Linux under WSL2):

|                        | `x86_64-portable` | `x86_64-shani` | `x86_64-avx2`                  |
| ---------------------- | ----------------- | -------------- | ------------------------------ |
| tests, Linux           | pass              | pass           | pass                           |
| `jasmin-ct`, `--sct`   | pass              | pass           | pass                           |
| safety, EasyCrypt      | proved            | proved         | proved                         |
| `jasmin-checksafety`   | partial           | partial        | partial                        |
| correctness, EasyCrypt | proved            | proved         | proved                         |
| assembly inspected     | yes               | yes            | yes                            |
| benchmarked, Linux     | yes               | yes            | yes                            |
| default dispatch       | fallback          | SHA-256, 8-way | SHA-512, 4-way; SHA-256 second |

`aarch64-scalar` is for A64 cores without the SHA-2 instructions. It has
passed everything the dispatched units have, and only the testing library
reaches it. [ARCHITECTURE](ARCHITECTURE.md#dispatch) gives the dispatch
order and [KERNELS](KERNELS.md) the inspection notes.

Memory safety rests on the EasyCrypt proofs. The `jasmin-checksafety` row
is a second opinion, not part of the evidence;
[SECURITY-MODEL](SECURITY-MODEL.md#memory-safety) says where it stops.

## Before a release

* Spec vectors at the SHA-512 padding boundary. The specification is
  executed in EasyCrypt on 52 CAVP vectors, and for the SHA-512 family they
  include 119 and 120 bytes but not 111 and 112, where the 16-byte length
  field forces the second block
  ([VALIDATION](VALIDATION.md#the-specification)). The compiled code is
  tested on both lengths.
* A from-scratch toolchain build and `ci/run.sh --all` at the release
  revision, on all three platforms.
* The AVX2, BMI1 and BMI2 models are upstream Jasmin's and have not been run
  against a processor here.

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
