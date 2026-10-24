# Jasmin patch series: Advanced SIMD for ARMv8-A

These patches add the AArch64 SIMD&FP register file and Advanced SIMD and
cryptographic-extension instructions to Jasmin's `armv8a` target. They are
listed in `SERIES` before the patches of `patches/` (see `PATCHES.md`), with
their SHA-256, and `build.sh` applies them with `git am` on the same pinned
commit. Like that series they modify Jasmin and are distributed under its MIT
licence.

Upstream's `armv8a` target has only general-purpose registers. The vector
register class and the calling convention, lowering, register allocation,
stack allocation and assembly generation it needs are already generic in
Jasmin (the x86-64 target uses them for its XMM/YMM registers); these patches
fill them in for AArch64 and add the instructions.

## Series

Patches 0001 to 0006 are the last six commits of jasmin-lang/jasmin pull
request #1643, at its head `06eae3de97487e0ac8bd4e0847dddaa7c9ac5d44`,
which is based on upstream `main` at `b1a56f315`, rebased on the pin. The
pull request is open, not merged (head checked on 2026-10-23). Its first
commit, "Do not assume that system calls preserve the vector registers",
was merged upstream separately as #1640 (`b413b9b`) and is in the pin; so
are the shared BIC recogniser of #1633 and the save-slot test of #1639,
which the series builds on.

Patch 0007 is this project's. It comes after the pull request's commits,
is written in the same form, and is meant to be proposed as an addition
to it; it has not been proposed yet.

| Patch | Content | Proof status |
|---|---|---|
| 0001 | SIMD&FP registers V0-V31 as 128-bit vector registers; calling convention; MOV (vector), LDR and STR of a Q register; lowering of u128 moves, loads and stores; saving of callee-saved vector registers; `reg u256` rejected on ARMv8-A | lowering, linearization and assembly generation proved; instruction semantics trusted |
| 0002 | AND, BIC, ORR, EOR, NOT, ADD, SUB, SHL, USHR, SSHR, SRI, SLI, MOVI; lowering of the u128 bitwise operators, element-wise addition and subtraction, shifts by a constant and the constant zero | lowering proved; instruction semantics trusted |
| 0003 | EXT, REV32, REV64, TRN1, TRN2, ZIP1, ZIP2, UZP1, UZP2, DUP (general and element), INS (general and element), UMOV | instruction semantics trusted; element operands printed by the trusted printer |
| 0004 | SHA256H, SHA256H2, SHA256SU0, SHA256SU1, SHA512H, SHA512H2, SHA512SU0, SHA512SU1; lemmas relating them to FIPS 180-4; a known-answer test | instruction semantics trusted; the FIPS 180-4 lemmas are proved about those semantics |
| 0005 | EOR3, BCAX, RAX1, XAR; a lemma relating XAR to the ρ rotation of FIPS 202 | instruction semantics trusted; the lemma is proved about the semantics |
| 0006 | changelog entries | none |
| 0007 | BSL and BIT (bitwise select, insert if true), as intrinsics; lemmas that they select bits and that they compute Ch and Maj | instruction semantics trusted; the lemmas are proved about the semantics |

Intrinsic names: the bitwise instructions, moves and Q-register loads and
stores are `V` followed by the mnemonic, with no suffix (`#VEOR`, `#VLDR`);
an instruction that exists at several element sizes takes the arrangement as
a suffix (`#VADD_4u32` is `ADD Vd.4S`); the cryptographic instructions keep
their assembly name (`#SHA256H`). An instruction whose destination is also a
source takes it as its first argument: `d = #SHA256SU0(d, n);`.

### Lowering

A u128 move, load or store becomes MOV, LDR or STR of a Q register. `&`,
`|`, `^` and `!` become AND, ORR, EOR and NOT; `a & !b` and `!b & a`
become one BIC through the recogniser that #1633 shares between the
targets. Element-wise `+` and `-` become ADD and SUB. A shift by a constant
is lowered only when its amount fits the immediate form: 0 to esize - 1 for
`<<` (SHL), 1 to esize for `>>` (USHR) and `>>s` (SSHR), where a shift by
esize gives what the Jasmin operator gives. The constant 0 becomes
`MOVI Vd.2D, #0`, the only immediate MOVI accepts. Any other u128 operator,
including a shift by a register amount, a multiplication or a comparison,
remains a compile error.

### Adaptations to the pin

The pull request is based on an older upstream `main` than the pin, which
has since changed the conditions on memory arguments, the instruction
descriptors and the save slots. Against the pull request's commits, the
rebased patches differ in these places (`git range-diff`), each in the
commit that needs it:

- Address of a Q-register load or store. The pull request added its own
  condition, `CAmemC_armv8a_q`. The pin checks the address of every load
  and store with `CAmemC_armv8a_ldst ws` (upstream `3671e33`), whose rule
  for a 16-byte access is the same set of forms: an offset that is a
  multiple of 16 from 0 to 65520 or lies in [-256, 255], or an index
  register. VLDR and VSTR use `CAmemC_armv8a_ldst U128`, and 0001 adds the
  description of that case to the error message (`armv8a_camem_cond_pp`),
  which on the pin had none for 16 bytes. The condition also accepts an
  index scaled by 16, which A64 can encode; assembly generation only
  represents the scales 1, 2, 4 and 8 and never produces it.
- Callee-saved registers. On the pin `armv8a_call_conv` names the saved
  general-purpose registers once, as `saved_regs`, for `callee_saved` and
  for `syscall_preserved`; 0001 adds V8-V15 to `callee_saved` only, so a
  system call is still assumed to preserve no vector register.
- Save slots. On the pin `is_save_slot_offset` takes the size of the saved
  register; 0001 passes `Uptr` for the stack pointer and the size of each
  saved register for the others.
- Instruction descriptors. The pin no longer has the field `id_safe_wf`;
  the new descriptors do not set it.
- Tests. The generated `negative.expected` is brought to the output of the
  combined tree by `patches/0035`. The success tests
  `save_slot_offset_q.jazz`, `simd_permute.jazz`, `simd_exec.jazz` and
  `bic_lowering.jazz` were adjusted to the pin in the rebase.

### Syscalls and the vector registers

Since #1640, which the pin includes, a system call such as `#randombytes`
is assumed to preserve only the callee-saved registers that are not vector
registers (`syscall_preserved` in `arch_decl.v`), in the semantics and in
register allocation, because AAPCS64 requires only the low 64 bits of
V8-V15 to be preserved. On ARMv8-A, an export function that issues a
system call therefore saves and restores q8-q15 (16 instructions and 128
bytes of frame), and a u128 value cannot stay in a register across the
call. `callee_saved` keeps the vector registers V8-V15.

### Register allocation

The 32 new registers shift the identifiers of the variables created after
them, so register allocation can break ties differently, on every
architecture. The allocations are checked by the proved development as
before; the emitted code may name other registers.

### What is proved, what is trusted

Proved, by `make -C proofs all` on the patched tree: the compiler correctness
theorem (`it_compile_prog_to_asmP`) with the patched ARMv8-A parameters
(`armv8a_h_params`). This covers the new
lowering cases (each lowered u128 expression computes the value of the source
expression), the saving and restoring of 128-bit registers in function
prologues and epilogues, and assembly generation for the new register class
and argument conditions. `Print Assumptions` for the theorem and for both
architecture records lists the names of `ASSUMPTIONS`, as without the
series. The patches add no `Admitted` proof and no `Axiom` (`ADMITS` and
`ECLIB_AXIOMS` are unchanged).

Trusted, as for every instruction of the target:

- The instruction semantics. Each is a transcription of the operational
  pseudocode of the Arm Architecture Reference Manual for A-profile
  architecture (DDI 0487 M.d, C7.2, with the shared pseudocode of J1.4),
  cited beside its description in `armv8a_instr_decl.v` with the semantics
  stated in our own words; the word-level helpers are in `armv8a_simd.v`.
  The SHA-256 functions Σ0, Σ1, σ0, σ1, Ch and Maj are those of Jasmin's
  `sha256.v`, and the EasyCrypt models use those of `SHA.ec`.
- The encodability conditions on immediates and addresses
  (`armv8a_check_CAimm`, `armv8a_check_CAmem`), transcribed from the same
  document. A Q-register load or store takes an offset that is a multiple
  of 16 from 0 to 65520 or lies in [-256, 255], or an index register.
  A condition that is too permissive makes the assembler reject the output;
  it cannot change what an accepted instruction means. EXT is the
  exception: llvm-mc accepts a byte position above 15 and encodes it
  modulo 16, so the compiler's check is the only guard.
- The assembly printer (`pp_arm_v8a.ml`), which prints a vector operand from
  the element size its description pairs with it: `v0.16b`, `v0.8h`,
  `v0.4s`, `v0.2d`, or `q0`, and an element operand of DUP, INS and UMOV as
  `v0.s[1]` from the register and the index that follows it.
- The EasyCrypt operators of `eclib/JModel_armv8a.ec` used by `jasmin2ec`.
  They are written to match the Rocq semantics; no proof relates the two
  for all inputs. They are checked on concrete vectors (see Tests).
- Alignment: Q-register loads and stores are modelled without an alignment
  requirement, as the general-purpose ones are, which matches the hardware
  for Normal memory when alignment checking is disabled (user mode on Linux
  and macOS).

Proved about the semantics, in `proofs/compiler/armv8a_simd_lemmas.v`: a
file outside the compiler, which nothing extracted depends on. Its 31
lemmas are each closed under the global context (`Print Assumptions`). They
state that the elements of a packed vector are the packed words; that the
SHA-2 functions of the Arm pseudocode are those of FIPS 180-4; that SHA256H
and SHA256H2 perform four SHA-256 rounds (FIPS 180-4, 6.2.2 step 3) and
SHA256SU0 followed by SHA256SU1 computes four message-schedule words (step
1); that SHA512H, SHA512H2 and an element-wise addition perform two SHA-512
rounds and SHA512SU0 followed by SHA512SU1 computes two message-schedule
words (6.4.2); and that XAR by 64 - r rotates each 64-bit element left by r
(the ρ step of Keccak-f[1600], FIPS 202, 3.2.2; XAR by 0 when r is 0);
and that BSL and BIT select bits, BIT(g, f, e) computing the Ch(e, f, g)
and BSL(b XOR c, a, b) the Maj(a, b, c) of FIPS 180-4 (4.1.2, 4.1.3) on
the whole register, hence in every element. The
SHA-2 statements are made both about the helper functions and about the
`id_semi` of the instruction descriptions, so the role of each operand is
part of what is proved. The SHA-512 pair packs the state as `[a; b]`,
`[c; d]`, `[e; f]`, `[g; h]`, first element in element 0:
`SHA512H([g + k1; h + k0], [f; g], [d; e])`, then `SHA512H2` of that,
`[c; d]` and `[a; b]`; `[f; g]` and `[d; e]` are `EXT #8` of adjacent state
registers. These lemmas are about the transcribed semantics; they do not
check the transcription against the hardware.

Not implied: anything about the timing of the instructions beyond what the
architecture states (below), and the behaviour of the D, S, H and B views of
the registers, which no instruction of the series writes.

### Assembling

The SHA-2 and SHA-3 instructions need the corresponding architecture
features enabled in the assembler; the printed assembly does not enable
them, and the compiler does not check that the target implements them.
Apple's assembler enables them for `arm64-apple-macos`; for Linux, assemble
with `-march=armv8.2-a+sha2+sha3` or an equivalent `.arch` directive. The
compiler's own assembly tests pass `-mattr=+sha2,+sha3` to llvm-mc, which
places SHA-512 under `sha3`. Running them requires FEAT_SHA256,
FEAT_SHA512 and FEAT_SHA3 on the processor.

### Constant time

An instruction is data-independent-time only if the Operational information
of its description in DDI 0487 M.d says so (B1.5.6, "About PSTATE.DIT").
Every instruction of the series but MOVI has that statement, and is marked
so that `jasmin-ct --doit` accepts it. MOVI has no Operational information
section and is not on the list; the only form the series accepts is
`MOVI Vd.2D, #0`, whose sole input is the constant, so it consumes no data.
The constant-time and speculative constant-time checkers treat the
instructions as other operators: their outputs carry the join of the
security levels of their inputs.

The architecture makes these instructions data-independent-time only while
PSTATE.DIT is set. Compiled Jasmin code does not set PSTATE.DIT, and the
series adds no instruction that could. The caller must set it around calls
that handle secret data and restore it afterwards.

### Calling convention

Vector arguments are passed in V0-V7 and results returned in V0-V3, as in the
procedure call standard for 128-bit short vectors; a function returning
several vectors corresponds to a C function returning a homogeneous
short-vector aggregate of that many 128-bit members, which a C compiler
returns in V0 upward. On the C side, a u128 argument is a short vector type
such as `uint8x16_t`, not `__int128`, which AAPCS64 passes in a pair of X
registers. V8-V15 are callee-saved: the standard requires their low 64 bits
to be preserved, the compiler saves and restores all 128 bits. The other
vector registers are caller-saved.

## Tests

In the Jasmin tree:

- 0001: `success/armv8a/simd_moves.jazz`,
  `success/armv8a/large_stack/save_slot_offset_q.jazz`, seven programs
  under `fail/asmgen/armv8a/` with a Q-register address that cannot be
  encoded, and `fail/register_allocation/armv8a/syscall_live_u128.jazz` and
  `u256_reg.jazz`;
- 0002: `success/armv8a/simd_ops.jazz`, `bic_lowering.jazz` extended to
  vectors, and six programs under `fail/asmgen/armv8a/` with a shift amount
  out of range or a nonzero MOVI immediate;
- 0003: `success/armv8a/simd_permute.jazz` and five programs under
  `fail/asmgen/armv8a/` with an element index or EXT position out of range;
- 0004: `success/armv8a/simd_sha2_kat.jazz` and `simd_exec.jazz`, evaluated
  with the semantics of the compiler by `compiler/tests/exec/exec_armv8a.ml`:
  the SHA-256 and SHA-512 digests of "abc", computed with the SHA-2
  instructions, must equal the published ones, and the permutations and
  element moves must give the values of `exec_armv8a.expected`;
- 0005: `success/armv8a/simd_sha3.jazz`, `fail/asmgen/armv8a/xar_rotation_range.jazz`,
  and the SHA-3 instructions of `simd_exec.jazz` in the same
  evaluation;
- 0007: BSL and BIT in `success/armv8a/simd_ops.jazz`, and
  `bitsel_ops` of `simd_exec.jazz` in the same evaluation, on inputs in
  which every combination of three bits occurs; its expected values were
  produced by the two instructions on an Apple M4, not by the semantics
  under test.

`toolchain/build.sh test` runs the negative suite, which checks that the
fail tests are rejected as `negative.expected` records, and the evaluation
of `exec_armv8a.ml`. It does not compile the success tests: that is
`compiler/scripts/runtest` with the categories `test-armv8a`,
`test-armv8a-macos` and `test-x86-64-windows` of `compiler/config/tests.config`
(see "Assembly checks" in `PATCHES.md`). On the previous pin, `e8f5979`,
on an Apple M4, every success test of those categories compiled and
assembled with LLVM's assembler, 46 for each ARMv8-A category and 3 for
Windows, and the Windows fail test was rejected; the ELF shared-library link
that the script also does was not run there. This has not been repeated on
the current pin.

Run on an Apple M4 (macOS 27.0, native), with harnesses that are not part
of this repository:

- a differential test executes each instruction of the series and each
  lowered operator, MOVI, SSHR and both BIC operand orders included,
  natively over random and boundary inputs (2,468 cases over three seeds)
  and compares the result with the Jasmin interpreter, which evaluates the
  extracted Rocq semantics, and with an independent model written from the
  same pseudocode; all three agree on every case. Each case's instruction
  is found in its assembly, except 18 vector moves that register allocation
  removed. Mutating the extracted semantics changes the interpreter's
  result for every instruction family; mutating the lowering (BIC with its
  operands swapped, SSHR emitted as USHR) changes the native results; a
  MOVI immediate of 1 is rejected at assembly generation;
- for each case of the differential test, EasyCrypt proves by computation
  that the operator expression `jasmin2ec` extracts for it, applied to the
  case's inputs, equals the value the processor produced; for each
  instruction, the same statement with one result bit flipped is rejected;
- the SHA-256 and SHA-512 digests of the FIPS 180-4 example messages (the
  empty message, "abc", and a two-block message), computed with the SHA-2
  instructions natively and with the interpreter, equal the published ones.
  Mutating the extracted semantics of SHA256H or of SHA512H changes the
  three interpreter digests of that algorithm, and calling SHA512H with the
  wrong state operands changes the three SHA-512 digests;
- a native test of the calling convention: vector arguments and results,
  calls between Jasmin functions, preservation of V8-V15, vector stack
  variables and spills, and the accepted address forms of a Q-register load
  and store;
- `jasmin-ct`, `jasmin-ct --doit` and `jasmin-ct --sct` accept programs
  that pass secret data through the instructions of the series and reject
  the controls with a secret address; `jasmin2ec` extracts them in the
  normal, CT and CTG modes and EasyCrypt checks the result.

These runs used upstream `main` at `b1a56f315` with the seven commits of
the pull request, not this pin, and have not been repeated on it; on this
pin the patches differ by the adaptations above. They do not cover 0007,
whose instruction semantics and EasyCrypt operators are trusted in the
same way.
