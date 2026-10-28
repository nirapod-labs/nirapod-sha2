# Security model

The attacker runs code on the same machine, or times the library from
outside. It sees how long calls take, which cache lines they touch and what
mispredicted branches leave behind, chooses the public inputs, and wants the
secret ones. The library's answer is that no branch, loop bound or memory
address depends on a secret, on the architectural path or on a mispredicted
conditional branch, and that secrets reach only instructions the
architecture lists as data-independent in time.

Out of scope, with no mitigation and no claim:

* fault injection, glitching, Rowhammer;
* power, electromagnetic and acoustic channels;
* an attacker who reads the process's memory or registers;
* copies made by the operating system: saved register state, swap, core
  dumps;
* speculation other than conditional-branch misprediction
  ([below](#speculation)).

## Classification

| Data                              | Class                               |
| --------------------------------- | ----------------------------------- |
| message and key bytes             | secret                              |
| contexts, except tag and total    | secret                              |
| digests and tags                  | secret; the caller may publish them |
| pointers, message and key lengths | public                              |
| context tag and total             | public, by declassification         |
| return codes                      | public, computed from public data   |

Lengths decide the number of compressions, and with it the running time. Key
length is public as well: HMAC hashes a key longer than one block first, and
branches on that. A caller whose key length is secret has to bring keys to
one length before the call.

## Constant time

The CI job `ct` runs `jasmin-ct` and `jasmin-ct --sct`, both with `--doit`,
on every unit of both architectures and on the array test unit
(`make ct CT_ARCHES="aarch64 x86_64"`), and requires every export of
`src/nirapod_sha2.jinc` to appear in both checkers' output, so that none
drops out unnoticed. All pass.

`--doit` admits a secret operand only for instructions the target marks as
data-independent: Intel's DOIT list on x86-64, Arm's DIT list on AArch64.
The Advanced SIMD and SHA-2 instructions that the toolchain adds are all on
Arm's list except MOVI, which the toolchain accepts only as `MOVI Vd.2D, #0`
and which therefore reads no data (`toolchain/jasmin/PATCHES-SIMD.md`).

The checkers assume a safe program, so their results hold for executions
that meet the `#[safety]` contracts; the EasyCrypt safety proofs supply that
for every caller that meets the preconditions
([PROOFS](PROOFS.md#memory-safety)).

## Declassification

There is one site. `__sha2_ctx_open` in `src/context.jinc` releases two
words of a context, the tag at offset 0 and the total at offset 8, and
protects both with the misspeculation flag. The checkers type them as secret
because they are loads from caller memory, but neither depends on a message,
key or state byte. The tag is fixed by which `init`, `update` and `final`
calls the caller made; the total is the HMAC block size plus the sum of the
update lengths, which are public. Releasing them lets `update` and `final`
branch on the tag, bound their loops by the total and index the buffer at
`total mod B`.

This restates a public-data contract. It releases nothing secret-derived,
and it relies on callers keeping update lengths public. If a caller writes
its own bytes into the first 16 bytes of a context, those bytes are what is
released, and they were the caller's already.

## Speculation

Every export starts with `#init_msf`: `lfence` on x86-64, `dsb sy; isb` on
AArch64. After it the export's arguments are not transient. Values reloaded
from the stack are, and are protected before they become an address, a bound
or a length. On AArch64 a protect is an OR with the flag and a CSDB, one
CSDB per run of adjacent protects (toolchain patch 0034).

`jasmin-ct --sct` covers misprediction of conditional branches, in the
Jasmin source. Indirect jumps and returns, store bypass and the other
variants are outside it, and the library claims nothing about them.

The C layer is analysed by no checker. Its argument checks branch on public
values, and the export's entry fence stops a mispredicted path through them
from running into the Jasmin code; that is an argument from the fence's
definition, not a checked result. The C layer reaches every export through a
function pointer in a constant table (`capi/units.c`), so a mispredicted
indirect branch could start some other export. The library adds no
mitigation for that and depends on the platform's.

## Instruction timing

| Platform | The library | The caller |
| --- | --- | --- |
| AArch64 with FEAT_DIT | sets PSTATE.DIT for each call that reads a secret | nothing more |
| AArch64 without FEAT_DIT | nothing | relies on the CPU |
| x86-64 with DOITM | nothing; the MSR is not writable from user mode | has the OS or platform enable DOITM |
| other x86-64 | nothing | relies on the CPU |

FEAT_DIT is read from the operating system once per process
(`hw.optional.arm.FEAT_DIT`, `HWCAP_DIT`), since writing DIT without it is
undefined. The write uses the system register's encoding, so the code
assembles for Armv8.0-A. An `init` that only writes constants runs without
DIT. The cost of the two writes, and how a caller avoids it, is in
[API](API.md#dit-and-short-messages).

## Registers and stack

Right after each export, inside the DIT window where there is one,
`capi/clear.c` zeroes the registers the ABI lets a callee change: x0 to x17
and v0 to v31 on AArch64 (the low halves of v8 to v15 come back from the
epilogue with their upper halves zero), and rax, rcx, rdx, rsi, rdi, r8 to
r11 and xmm0 to xmm15 on x86-64, or ymm0 to ymm15 with VZEROALL after AVX
code. On a CPU with AVX-512, zmm16 to zmm31 are zeroed too, because other
code in the process may have left secrets there. Not cleared: x18, which
macOS reserves and the Jasmin code never touches (`make asm-policy` checks);
the flags; the AVX-512 mask registers.

The Jasmin functions leave secret-derived data in their frames
([API](API.md#residue) lists it). Every unit is compiled with
`-stack-zero loop`, so each export zeroes the stack it used before it
returns, with 64-bit stores, or 256-bit stores in the two AVX units. The C
frames around the exports hold no message, key, digest or context bytes.

`tests/residue` calls every operation, through the public functions and
through each kernel, with a random message and keys of 37 and 300 bytes, and
searches every caller-saved register and a painted region of the stack for
the secrets, the padded key block and its ipad and opad forms: 336 calls,
nothing found, and its two planted leaks are caught. That is a test. The
clearing pass of `-stack-zero` is outside the compiler's proved theorem.

`final` zeroes the whole context. A context abandoned before `final` still
holds the chaining value and the pending bytes, or for HMAC both key-derived
states, and the caller should clear it.

## Memory safety

The caller provides what cannot be checked: pointers valid for the lengths
passed, buffers that do not wrap, contexts aligned as their type, and no
context shared by two threads at once. Before calling Jasmin, the C layer
rejects NULL pointers, lengths over the limits and any output or context
that overlaps an input or another output (`capi/api.c`), and it copies the
multi-way lane table so that the pointers checked are the pointers used.
Inside Jasmin the tag and total are checked before any store, and the buffer
is indexed by `total mod B`, so a context with a valid tag and forged
contents gives a wrong digest and nothing worse.

The evidence for the `#[safety]` contracts is the EasyCrypt proof on each
unit's safety model ([PROOFS](PROOFS.md#memory-safety)).
`jasmin-checksafety` is run as a second, independent check, one run per
export and unit, and each memory range it prints must fall within the
export's contract. It does not pass everywhere yet
([STATUS](STATUS.md#before-a-release)), and on the four exports that read
lanes through a pointer table it cannot, since its memory model gives each
argument one region.

## Trusted base

| Component | What depends on it | What checks it |
| --- | --- | --- |
| EasyCrypt, Z3, CVC5, Alt-Ergo | every proof | nothing; pinned past the r2026.09 soundness fixes |
| `jasmin2ec`, including the safety model's printing | the link from the source to every model | extraction identity ([PROOFS](PROOFS.md#extraction-identity)); the instruction-model test, for the instructions it covers |
| SHA-NI models | the SHA-NI kernel | 888 vectors run natively, 18 controls rejected |
| Armv8-A SHA-2 and Advanced SIMD models | the AArch64 vector kernels | 18 instructions on 5,292 vectors recorded on an Apple M4, 86 controls rejected |
| AVX2, BMI1, BMI2 models | the AVX2 kernels | nothing here |
| `BSWAP` and `REV` models | byte order everywhere | proved to reverse bytes (`ArchWord.ec`); emission trusted |
| `JWordList` axioms | reading bytes of memory | listed in each unit's inventory |
| Jasmin front end, assembly printers, `jasmin-ct`, `jasmin-checksafety`, `-stack-zero` | compilation outside the proved passes, the leakage results, stack clearing | tests; the compiler theorem covers the passes in between ([TOOLCHAIN](TOOLCHAIN.md#the-compiler-proof)) |
| assembler, linker, `objcopy` | the objects | the tests, the exported-symbol check, `tests/isa` |
| `capi/`, about 1,500 lines | argument checks, dispatch, DIT, register clearing | the `negative` suite, `tests/residue`, the smoke tests |
| CPUID, XCR0, `sysctlbyname`, `getauxval` | kernel choice and DIT | nothing |
| the processor's timing | constant time on real hardware | nothing |

The models are written by hand from the vendors' manuals; the test vectors
are evidence about them, not a proof
([VALIDATION](VALIDATION.md#instruction-models)).
