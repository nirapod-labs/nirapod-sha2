# Toolchain

The library needs a patched Jasmin. Upstream, the ARMv8-A target has no
vector registers and no SHA-2 instructions, and the safety pass and its
EasyCrypt translation are still open pull requests. The patches live in
[nirapod-labs/jasmin](https://github.com/nirapod-labs/jasmin), one topic
branch per change, and its `integration` branch merges them onto a commit
of upstream `main`. The toolchain is built from
[nirapod-labs/toolchain](https://github.com/nirapod-labs/toolchain), which
pins that compiler together with EasyCrypt, the provers and the opam
environment, and which nirapod-slhdsa uses too.

`toolchain/PIN` names the release by commit and records the commits it
builds:

| Tool      | Pin                                                                         |
| --------- | --------------------------------------------------------------------------- |
| toolchain | release 2026.11.1, `9feb334a`                                               |
| Jasmin    | `nirapod-2026.11.1`, `87a265ec`: upstream `af6e17f9` (7 November 2026) and 18 topics |
| EasyCrypt | `e7eff05d`, on `main` after r2026.09                                        |
| OCaml     | 4.14.4, opam 2.6.0 exactly                                                  |
| Rocq      | rocq-core 9.0.1, rocq-stdlib 9.0.0, mathcomp 2.4.0, mathcomp-word `86ed49ae` |
| Why3      | 1.8.2                                                                       |
| provers   | Z3 4.8.17, 4.12.6, 4.13.4, 4.16.0; CVC5 1.0.9, 1.2.1; Alt-Ergo 2.5.4, 2.6.4 |

The release's `jasmin/PIN`, `easycrypt/PIN` and `opam-packages.txt` hold
the full list of inputs and say why each version was chosen. Several
versions of each prover are installed because EasyCrypt resolves `Z3@4.12`
to the lowest installed version at least that new, and the imported
developments name different ones. The EasyCrypt pin is newer than r2026.09
because that release has tactics able to prove false judgements, fixed
since.

## The Jasmin topics

Each topic is a branch of the fork and one upstream pull request, either an
open one carried until upstream merges it or this project's own, written to
be proposed. When upstream merges a topic, the next integration drops it.
At `nirapod-2026.11.1` the topics are:

| Topic | Change |
| --- | --- |
| `feature/armv8a-simd`, `feature/armv8a-bsl-bit` | ARMv8-A Advanced SIMD: vector registers, arithmetic, permutes, the SHA-2 and SHA-3 instructions, BSL and BIT, with lemmas tying the SHA-256 and SHA-512 instructions, BSL and BIT to FIPS 180-4 |
| `fix/safety-checker`, `fix/safety-checker-shift-bounds`, `fix/safety-checker-soundness`, `feature/safety-checker-armv8a`, `feature/safety-checker-scaling`, `feature/safety-checker-pointer-tables`, `feature/safety-checker-init-prefix` | `jasmin-checksafety`: unsound verdicts fixed, false alarms removed, ARMv8-A support, exact bounds for constant shifts, options for large exports |
| `carry/safety-pass`, `carry/eclib-safety`, `feature/jasmin2ec-safety` | the safety pass with the proof that holding assertions imply safe execution, and `jasmin2ec -m safety` with the EasyCrypt lemmas it needs |
| `fix/linearization-invalid-operand`, `feature/armv8a-store-imm`, `feature/armv8a-ldrw`, `fix/armv8a-frame-pointer`, `feature/armv8a-csdb-run` | ARMv8-A code generation: a located error for an operand the target cannot express, immediate stores, LDR of a W register, x29 never allocated, one CSDB for a run of protects |
| `feature/armv8a-dit` | `PSTATE.DIT` in ARMv8-A export functions |

The fork's branches give each change's reason, test and upstream status.
Moving from the previous pin (upstream `ca253b7c` with 42 patches applied
by this repository) changed the extracted models in two ways: a `for` loop
no longer gets a separate variable for its bound, and the safety
preconditions leave out conjuncts that are trivially true. The proofs were
adjusted to both; no theorem statement changed.

## The compiler proof

The release's `build.sh jasmin` checks the whole Rocq development of the
pinned tree, including the end-to-end theorem `it_compile_prog_to_asmP`,
then deletes the extracted OCaml, extracts it again from the proofs, and
checks that the build did not change it. A change to a compiler pass is
therefore either covered by the proof or the build fails. Three files in
the release's `jasmin/` fix what the proof may rest on, and the build
stops if a fresh scan differs from them in either direction:

* `ASSUMPTIONS`, the output of `Print Assumptions` for the theorem and both
  architecture records: Rocq's primitive integers and their axioms, proof
  irrelevance, `Eq_rect_eq`, the abstract encoding of code labels, and for
  x86-64 the AES column mixing;
* `ADMITS`, every `Admitted`, `admit`, `Abort`, `Axiom`, `Parameter`,
  `Hypothesis` and `Conjecture` in the tree; there is no `Admitted`, `admit`
  or `Abort`;
* `ECLIB_AXIOMS`, every axiom of the Jasmin EasyCrypt library: abstract
  theory parameters, three memory-model axioms, the AES helpers, and two
  lemmas on horizontal addition in the x86-64 model.

The theorem says the emitted assembly behaves as the source does, for source
programs that run without error; the safety proofs supply that premise for
this library's exports. Outside it are the parser and front end, the
assembly printers, `jasmin-ct`, `jasmin-checksafety`, `jasmin2ec` and the
hand-transcribed instruction semantics. Register allocation runs in OCaml
and is validated by the proved development. The 31 lemmas of
`armv8a_simd_lemmas.v` relate the transcribed SHA-2, BSL and BIT semantics
to FIPS 180-4, and XAR to FIPS 202; they do not check the transcription
against hardware, which is what
[`tests/insn`](VALIDATION.md#instruction-models) is for.

## Building

```sh
toolchain/build.sh [--no-easycrypt] [switch | jasmin | test | all]
```

The script fetches the release at its pinned commit into `$WORK/src`,
checks that it pins the same Jasmin, EasyCrypt and coqword commits as
`toolchain/PIN`, and runs the release's own `build.sh` with the same
arguments. `switch` creates an opam switch that sees only the two pinned
package repositories and requires the installed set to equal the release's
package list; `jasmin` builds the compiler as above; `test` runs the
compiler's test suites in a fresh build directory and checks the Jasmin
EasyCrypt library with the pinned EasyCrypt; `all` does the three. Every
download is checked against its pin. Everything goes under `$WORK`
(default `toolchain/work`), with `HOME`, the XDG directories and `TMPDIR`
inside it, so no personal configuration is read. `$WORK/bin` gets
`jasminc`, `jasmin-ct`, `jasmin2ec` and `jasmin-checksafety`, and
`$WORK/logs` the provenance record and the scans.

It runs on macOS on AArch64 and Linux on x86-64. Linux on AArch64 has no
official binaries of several pinned provers, so there it runs with
`--no-easycrypt` and the proofs are checked elsewhere. The CI job
`toolchain` checks that the tools on `PATH` are this build: the provenance
record names the release and Jasmin commits of `toolchain/PIN`, the Jasmin
checkout is clean at that commit, and the binaries match their recorded
hashes.

`toolchain/baselines/build.sh` builds the oracles and benchmark baselines of
`toolchain/baselines/PIN` the same way, from pinned archives.

The `switch` and `jasmin` steps of release 2026.11.1 have run from scratch
on macOS on AArch64, with every scan equal to its list, and every proof of
the library checks with that build on all six units. The `test` step and
the Linux builds have not run on this release yet.
