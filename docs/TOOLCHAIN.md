# Toolchain

The library needs a patched Jasmin. At the pinned upstream commit the
ARMv8-A target has no vector registers and no SHA-2 instructions, its
printer emits relocations the macOS assembler rejects, and the safety
checker does not run on ARMv8-A at all. Upstream Jasmin `ca253b7c` (`main`,
22 October 2026) with the 42 patches of `toolchain/jasmin/SERIES` is the
compiler of record, and EasyCrypt `e7eff05d` checks the proofs.

The pins themselves, with every input they fetch, are in
`toolchain/jasmin/PIN`, `toolchain/easycrypt/PIN` and
`toolchain/opam-packages.txt`; their comments say why each version was
chosen.

| Tool      | Pin                                                                           |
| --------- | ----------------------------------------------------------------------------- |
| Jasmin    | `ca253b7c`, then 7 patches of `patches-simd/` and 35 of `patches/`            |
| OCaml     | 4.14.4, opam 2.6.0 exactly                                                    |
| Rocq      | rocq-core 9.0.1, rocq-stdlib 9.0.0, mathcomp 2.4.0, mathcomp-word at a commit |
| EasyCrypt | `e7eff05d`, on `main` after r2026.09                                          |
| Why3      | 1.8.2                                                                         |
| provers   | Z3 4.8.17, 4.12.6, 4.13.4, 4.16.0; CVC5 1.0.9, 1.2.1; Alt-Ergo 2.5.4, 2.6.4   |

Several versions of each prover are installed because EasyCrypt resolves
`Z3@4.12` to the lowest installed version at least that new, and the
imported developments name different ones. The EasyCrypt pin is newer than
r2026.09 because that release has tactics able to prove false judgements,
fixed since; `easycrypt/PIN` lists them. The opam environment follows what
upstream Jasmin's CI uses at the pin, with yojson held below 3 for elpi
2.0.7.

## The patch series

`build.sh` applies the series with `git am` to a clean checkout of the pin
and refuses a patch whose hash differs from `SERIES` or a patch file that
`SERIES` does not list. There is no fork. A patch is either a commit of an
open upstream pull request, carried unchanged until the pin includes it, or
this project's own, written to be proposed upstream; none of the latter has
been submitted yet.

| Patches | Change | Origin |
| --- | --- | --- |
| SIMD 0001–0006 | ARMv8-A Advanced SIMD: vector registers, arithmetic, permutes, the SHA-2 and SHA-3 instructions, lemmas tying the SHA-256 and SHA-512 instructions to FIPS 180-4 | #1643 |
| SIMD 0007 | BSL and BIT, with lemmas that they compute Ch and Maj | this project |
| 0001–0002 | Mach-O relocation syntax for ARMv8-A | #1594 |
| 0003–0011, 0015–0016, 0018–0020, 0022 | safety checker: three unsound verdicts fixed, false alarms removed, ARMv8-A support, exact bounds for constant right shifts, options for large exports | #1625, #1650, this project |
| 0012–0013 | a located error for an operand the target cannot express | #1632 |
| 0014, 0017, 0021 | ARMv8-A: immediate stores through a scratch register, LDR of a W register zero-extended, x29 never allocated | this project |
| 0023–0031 | the safety pass: a total semantics, failure conditions as assertions, and the proof that holding assertions imply safe execution | #1572 |
| 0032–0033 | `jasmin2ec -m safety` and the EasyCrypt library lemmas it needs | #1170, ported |
| 0034 | ARMv8-A: one CSDB for a run of protects | this project |
| 0035 | expected outputs of the test suites on the combined tree | this project |

[`toolchain/jasmin/PATCHES.md`](../toolchain/jasmin/PATCHES.md) and
[`PATCHES-SIMD.md`](../toolchain/jasmin/PATCHES-SIMD.md) give, for each
patch, its reason, reproducer or test, how a carried commit compares with
its pull request, and its proof status.

An earlier version of the shift-bound patches accepted an out-of-bounds read
when the shifted operand was a truncating cast. The carried version requires
the operand to have exactly the width of the shift, and has that program as
a negative test. A safety verdict obtained with the earlier version is void.

## The compiler proof

`build.sh jasmin` checks the whole Rocq development of the patched tree,
including the end-to-end theorem `it_compile_prog_to_asmP`, then deletes the
extracted OCaml, extracts it again from the proofs, and checks that the
build did not change it. A patch to a compiler pass is therefore either
covered by the proof or the build fails. Three files fix what the proof may
rest on, and the build stops if a fresh scan differs from them in either
direction:

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

`switch` creates an opam switch that sees only the two pinned package
repositories and requires the installed set to equal `opam-packages.txt`;
`jasmin` builds the compiler as above; `test` runs the compiler's test
suites in a fresh build directory and checks the Jasmin EasyCrypt library
with the pinned EasyCrypt; `all` does the three. Every download is checked
against its pin, and the script refuses to start if `toolchain/` differs
from the checked-out commit. Everything goes under `$WORK` (default
`toolchain/work`), with `HOME`, the XDG directories and `TMPDIR` inside it,
so no personal configuration is read. `$WORK/bin` gets `jasminc`,
`jasmin-ct`, `jasmin2ec` and `jasmin-checksafety`, and `$WORK/logs` the
provenance record and the scans.

It runs on macOS on AArch64 and Linux on x86-64. Linux on AArch64 has no
official binaries of several pinned provers, so there it runs with
`--no-easycrypt` and the proofs are checked elsewhere. The CI job
`toolchain` checks that the tools on `PATH` are this build.

`toolchain/baselines/build.sh` builds the oracles and benchmark baselines of
`toolchain/baselines/PIN` the same way, from pinned archives.

`toolchain/build.sh all` has run from scratch on Linux on x86-64, with every
scan equal to its committed list. It has not been repeated on the current
tree, and the compiler's own assembly tests (`compiler/scripts/runtest`)
last ran on the previous pin.
