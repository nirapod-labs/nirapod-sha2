# Validation

The library is never its own oracle. Every digest and tag it produces is
compared with published vectors or with implementations that share no code
with it, and every comparison goes through the linked library: the public
functions, and each kernel the machine can run through the testing library
([API](API.md#the-testing-interface)).

The last full runs, October 2026:

| Platform | CPU | Jobs that passed |
| --- | --- | --- |
| macOS 27.0, AArch64, native | Apple M4 | build, tests, exports |
| Ubuntu 24.04, AArch64, VM | Apple M4 | build, tests, exports |
| Ubuntu 24.04.5 under WSL2, x86-64 | AMD Ryzen 7 7700X | toolchain, build, tests, exports, ct, extraction, insn |

The analyses depend on the target, not the host, so the x86-64 machine ran
them for both architectures, and the AArch64 runs used the assembly it
produced. Execution is native everywhere: the two Linux systems are
virtualised, the instructions are not. Nothing was emulated.

## Oracles

`toolchain/baselines/build.sh` builds the pinned implementations of
`toolchain/baselines/PIN`. Each runs in its own process and prints the
identity it was built against.

| Oracle    | Version                                                |
| --------- | ------------------------------------------------------ |
| OpenSSL   | 4.0.3                                                  |
| AWS-LC    | 5.11.0                                                 |
| BoringSSL | commit `99b9d64ec023`                                  |
| HACL*     | hacl-packages 0.7.2, portable streaming SHA-2 and HMAC |

These are not four independent opinions. AWS-LC and BoringSSL descend from
OpenSSL and share much of its SHA-2 code, so a defect there could show up as
agreement among three of them; HACL* is there because it shares nothing with
them or with this library. SHA-512/224 and SHA-512/256 have OpenSSL alone:
HACL* 0.7.2 lacks them, and the other two have no digest entry point for
them.

## Vectors

The NIST CAVP byte-oriented response files for SHA-2 and HMAC
(`shabytetestvectors.zip`, `hmactestvectors.zip`): ShortMsg, LongMsg and
Monte for the six hashes, and the `[L=32]` and `[L=64]` sections of
`HMAC.rsp`. Wycheproof's `hmac_sha256_test.json` and `hmac_sha512_test.json`
from `testvectors_v1` at commit `7a325932`, valid and invalid cases alike.
Both sets include truncated tags, which are compared on their recorded
length. The files are in `tests/vectors/`, unmodified.

## Suites

`tests/validation` runs each suite on the public functions and on every
kernel the machine has.

| Suite | What it does |
| --- | --- |
| `cavp` | every record and every Monte Carlo checkpoint, on every kernel |
| `wycheproof` | every case, one-shot and incremental |
| `bounds` | lengths around each padding edge of both block sizes at one to three blocks; the empty message with NULL input; HMAC keys of 0 to 384 bytes; 1 MiB + 3 |
| `splits` | incremental against one-shot: every two-way split of three blocks + 7 bytes, a moving three-way split, one byte per update, `memcpy` forks mid-stream, HMAC keys on both sides of each block size |
| `cross` | every kernel and the public functions give identical bytes |
| `xarch` | a fixed case set hashed into `tests/vectors/xarch/manifest.txt`, which both architectures must reproduce |
| `multiway` | `sha256_x8` and `sha512_x4` lane by lane against the one-shot functions |
| `differential` | every kernel against every oracle that has the function: padding edges, random lengths, 1 MiB |
| `long` | $2^{29} + 4099$ bytes through SHA-256 and SHA-512, so the bit length exceeds 32 bits |
| `fuzz` | 20,000 seeded incremental cases, lengths biased to block edges, up to nine pieces and a fork point, against each oracle's one-shot answer |
| `negative` | API misuse, including 64 forged contexts per function placed between guard bytes |

`fuzz` is not coverage-guided, deliberately. The code branches on lengths
and offsets only, never on data, so coverage over input bytes has nothing to
steer by; the suite samples lengths and split points directly.

Outside `tests/validation`:

| Suite | Checks | Recorded |
| --- | --- | --- |
| `tests/constants` | every FIPS 180-4 table in `src/` against a derivation from first principles | 19 tables, 19 controls |
| `tests/isa` | CPU features each export's instructions need, against `capi/units.c` | 38 controls |
| `tests/residue` | no secret left on the stack or in caller-saved registers | 336 calls, controls caught |
| `tests/smoke` | the public and testing entry points against known answers | 2,931 and 770 checks |
| `tests/abi` | the production library exports exactly the header's functions | one-extra-symbol control |
| `tests/timing` | the caller's PSTATE.DIT survives a call, set or clear | Apple M4 |
| `tests/array` | the array forms at several sizes against the exports | pass |

## Negative controls

Each suite carries controls that must fail; a control that passes fails the
suite.

| Suite | Controls | Rejected |
| --- | --- | ---: |
| `cavp` | each parser re-run with one record dropped; its count must disagree with the file | 20 / 20 |
| `wycheproof` | the first case dropped; the count must disagree with `numberOfTests` | 2 / 2 |
| `negative` | six faults injected after the call on four context kinds: a byte written past the context or the output, an undocumented result, a failed update that changes the context, a final that does not zero it, a failed final that writes output | 24 / 24 |
| `long` | an extra oracle with one bit flipped, and each target compared with a flipped digest | 10 / 10 |
| `fuzz` | per function, a wrong oracle, a flipped digest, an absorb that drops a byte | 24 / 24 |

Recorded on macOS on the M4. With each injected fault made a no-op, all five
suites fail, so the controls can fail.

## Instruction models

The SHA-NI and Armv8-A kernels are proved against EasyCrypt models of their
instructions, written by hand from the manuals. `tests/insn` checks those
models against a processor.

`tests/insn/<arch>.insn` lists one instruction per line: a name, a Jasmin
statement and the mnemonic it must compile to. `insn.py` turns each line
into an export that loads its operands from a buffer, runs the statement and
stores the result; the compiled program is checked to contain each
instruction. `run.c` calls every export on edge inputs in every operand slot
(zero, all ones, alternating bits, lane sign and carry boundaries, distinct
bytes) and on 256 seeded random inputs, and prints what the processor wrote.
`jasmin2ec` extracts the same program, and for each vector `insn.py` writes
a lemma whose statement is the extracted body with the loads replaced by the
inputs and the store by an equation with the processor's output. Each lemma
is closed by `cbv delta` and proved rewriting rules for the word operators
(`WordEval.ec`), with no SMT call and no axiom. Because the lemma is the
extracted code, it tests the operator `jasmin2ec` chose and the order it
passes operands in, which is what a kernel proof sees.

EasyCrypt must reject, as a proof that does not close, one case per
instruction with bit 0 of the result flipped, one per pair of operands
exchanged, and the affected cases under each wrong model of
`<arch>.mutants`, each loaded into an otherwise unchanged copy of the
toolchain's EasyCrypt library. The wrong models change a rotation of
$\Sigma_0$, $\Sigma_1$ or $\sigma_1$, the shift of $\sigma_0$, an argument
of Ch, a term of Maj, the order of the output words, or the order of two
operands.

| Instructions | Run | Vectors | Controls rejected |
| --- | --- | ---: | ---: |
| SHA256RNDS2, SHA256MSG1, SHA256MSG2 | natively on the 7700X (`make insn-check`) | 888 | 18, of them 10 wrong models |
| 18 entries of `aarch64.insn`, SHA-2 and Advanced SIMD | recorded on an Apple M4 (`make insn-check-recorded`) | 5,292 | 86, of them 44 under 40 wrong models |

The proof tools run on x86-64, so the Armv8-A side is recorded in
`tests/insn/aarch64/`: the compiled program, the seed and count, the vectors
the M4 printed, and the host. `make insn-check-recorded` recompiles the
program and requires it byte for byte before proving the recorded vectors;
`make insn-vectors`, on any AArch64 machine, reruns it and requires the
recorded vectors exactly. Three operand pairs the instructions are symmetric
in cannot give an exchanged-operand control and are listed in
`aarch64.symmetric`.

A pass is evidence on finitely many inputs, on the processor that ran them.
The models stay in the trusted base. The AVX2, BMI1 and BMI2 models are not
checked at all.

## The specification

`proofs/spec/validation/` evaluates the EasyCrypt specification on CAVP
vectors: 52 lemmas stating that the specification maps a given message to a
given digest, each closed by `cbv delta` with the rewriting rules of
`SpecEval.ec`, with no SMT call and no axiom.

| Function | Vectors |
| --- | --- |
| SHA-224, SHA-256 | ShortMsg at 0, 1, 55, 56, 63, 64 bytes; the first LongMsg (163 bytes) |
| SHA-384, SHA-512, SHA-512/224, SHA-512/256 | ShortMsg at 0, 1, 119, 120, 127, 128 bytes; the first LongMsg (227 bytes) |
| HMAC-SHA-256 | 5 records of `HMAC.rsp`, keys of 40 to 74 bytes, full tags |
| HMAC-SHA-512 | 5 records, keys of 100 to 142 bytes, full tags |

For SHA-256, 55 and 56 bytes straddle the point where padding needs a second
block. The SHA-512 length field is 16 bytes, so for that family the point is
between 111 and 112, and these vectors miss it: 119 and 120 are $B - 9$ and
$B - 8$, the boundary only for an 8-byte length field. Adding 111 and 112 is
listed in [STATUS](STATUS.md#before-a-release).

`proofs/tools/spec_vectors.py` generates the lemma files from the vector
files, and `make -C proofs check-spec-exec` requires them to match a fresh
generation, checks them, and requires each file's first lemma with one
output bit flipped to be rejected (8 controls).

Beyond these vectors the evidence for the specification is indirect: the
constant tables it shares with the code are derived independently
(`tests/constants`), and the code is proved equal to it while agreeing with
CAVP, Wycheproof and the oracles on every case above, 111 and 112 bytes
included.

## Gaps

* Both Linux runs were in virtual machines. The instructions ran natively;
  the operating system and its timer did not.
* No CPU without FEAT_DIT, and no x86-64 CPU without SHA-NI or AVX2, has run
  the tests. For feature sets the hosts lack, only the dispatch choice is
  checked (`nirapod_sha2_testing_select_for`).
