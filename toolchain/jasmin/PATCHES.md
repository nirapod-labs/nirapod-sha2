# Jasmin patch series

The pinned compiler is upstream Jasmin at the commit in `PIN` with the
patches listed in `SERIES` applied in that order. `toolchain/build.sh jasmin`
applies them with `git am` to a clean checkout of the pin and builds the
result as upstream does: Rocq proofs, extraction of the compiler, OCaml
build.

A patch is either a commit of an upstream pull request, carried until the
pin includes it, or a patch of this project, written to be proposed
upstream. A carried commit keeps its author, date and message. Where a
carried commit is not identical to its pull request, "Identity with the pull
requests" says how it differs.

Upstream Jasmin is distributed under the MIT licence, reproduced in
`jasmin-license.txt` next to this file from the pinned commit. The patches
modify Jasmin and are distributed under the same terms.

`SERIES` lists the Advanced SIMD patches of `patches-simd/` first, then the
patches of `patches/`. The Advanced SIMD patches are described in
`PATCHES-SIMD.md`.

## Series

Pin: `ca253b7c644ebdce38d0a2a7b83a65b24cfa8e27` (jasmin-lang/jasmin, main,
2026-10-22). The environment of upstream CI (`default.nix`, `scripts/`,
`.gitlab-ci.yml`) is the same as at the previous pin, `e8f5979`, so the
opam pins of `PIN` and the EasyCrypt pin are unchanged. Open pull requests
are carried at the heads listed below, checked on 2026-10-23.

| Patches | Origin | Content | Proof status |
|---|---|---|---|
| 0001-0002 | PR #1594, head `a30c006246fc` | Mach-O relocation operators in ARMv8-A assembly | printer only (trusted) |
| 0003-0010 | PR #1625, head `02a2330a04c9` | safety checker: unsound verdicts, false alarms, CallTopHeuristic | safety checker (trusted) |
| 0011 | this project | safety checker for ARMv8-A | safety checker (trusted) |
| 0012-0013 | PR #1632, head `63a0ee596edd` | located error for an instruction argument the target cannot express | `check_rexpr`, `check_lexpr`, `check_fexpr` return the new error; same accepted arguments; theorem statements and proofs unchanged |
| 0014 | this project | ARMv8-A: store of an immediate through a scratch register | lowering proved |
| 0015-0016 | PR #1650, head `820a9b26f20d` | safety checker: exact bounds of an unsigned right shift by a constant | safety checker (trusted) |
| 0017 | this project | ARMv8-A: 32-bit load zero-extended to 64 bits (LDRW, written `LDR <Wt>`) | lowering proved; instruction semantics and printing trusted |
| 0018 | this project | safety checker: abstract values and environments shared when unchanged; relational constraints printed sorted | safety checker (trusted) |
| 0019 | this project | safety checker option `array_track_max_bytes` | safety checker (trusted) |
| 0020 | this project | safety checker option `congruence_reduction` | safety checker (trusted) |
| 0021 | this project | ARMv8-A: x29 never allocated | calling convention proved; register allocation checked by the proved development |
| 0022 | this project | safety checker options `relational_loop_vars`, `relational_loop_vars_in` | safety checker (trusted) |
| 0023-0031 | PR #1572, head `546ead43009e` | the safety pass: a total mode of the semantics, the safety conditions of the program as assertions, and the proof that the assertions imply safety | proved |
| 0032 | this project, lemmas of PR #1170 | Jasmin EasyCrypt library: lemmas for the safety model | checked by EasyCrypt |
| 0033 | this project, port of the EasyCrypt side of PR #1170 | `jasmin2ec -m safety`: the safety model and its proof skeletons | the pass of 0023-0031 is proved; masks and printing trusted |
| 0034 | this project | ARMv8-A: one CSDB for a run of protects | printer only (trusted) |
| 0035 | this project | the expected outputs of the negative and safety test suites on the combined tree | none (test data) |

"Proved" means that the Rocq development of the patched tree, checked by
`make -C proofs all`, covers the change: the compiler correctness theorem is
proved again with it. "Trusted" means the change is outside that theorem:
instruction semantics transcribed from the Arm Architecture Reference Manual,
or hand-written OCaml (printers, analysers, the extraction to EasyCrypt).

The safety-checker options of 0019, 0020 and 0022 are read from the
checker's JSON configuration file. Their defaults keep the analysis of the
pin, and each non-default value can only add alarms, never remove one.

## Previous series

Against the series on `e8f5979`, these patches were dropped because the new
pin contains them: #1624, LDP and STP with the conditions on memory
arguments (old 0001-0006, merged as `b3ff6df`, then generalised by
`9b95cf2` and the commits after it, which give every memory argument a
condition and check the load and store addresses of every target); #1617,
EXTR and the bit-field instructions (old 0017, merged as `44d1af5` and
`9b0dc71`); #1633, BIC (old 0021, `2bc3e20`); #1639, the save slots (old
0029, `88f7342`, since replaced by upstream's `e4ec817`, which uses the
load and store offset condition); and #1640, system calls and the vector
registers (old `patches-simd/0001`, `b413b9b`). The other patches were
rebased; the ones whose changed lines differ from their earlier version are
listed under "Identity with the pull requests" and in `PATCHES-SIMD.md`.
0015-0016 are the corrected version of the shift-bound patch (see below);
0023-0035 are new.

## Why each change is carried

### #1594, Mach-O relocation operators

At the pin, `jasminc -arch armv8a` prints the address of a global as
`adrp x, sym` and `add x, x, :lo12:sym`, the ELF syntax, whatever `-system`
says. The macOS assembler rejects `:lo12:`; Mach-O needs `sym@PAGE` and
`sym@PAGEOFF`. macOS on AArch64 is a supported platform and the hash kernels
read constant tables, which are globals. The pull request also adds the
`armv8a-macos` category to the compiler's assembly tests.

Reproducer: `compiler/tests/success/armv8a/global_read.jazz` with
`jasminc -arch armv8a -system macosx`, then
`clang -c -x assembler -target arm64-apple-macos` on the output.

### #1625, safety checker fixes

The verdicts of `jasmin-checksafety` are evidence for this project, so its
known defects are fixed before any verdict is used:

- unsound verdicts: a copy at an unknown slice offset kept the destination
  cells initialized although the source cells read may not be; a loop could
  be found stable before an initialization change was propagated; a memory
  range such as `[-1/0; inf]` was reported with a "safe" verdict;
- false alarms on slices of global tables and on pointers offset by a `for`
  counter;
- the CallTopHeuristic call policy aborted on its first use;
- start-up time quadratic in the size of the global tables.

### 0011, safety checker for ARMv8-A (this project)

At the pin, `jasmin-checksafety -arch armv8a` fails with "the safety checker
is not implemented for ARMv8-A" (`compiler/safetylib/safetyMain.ml`), and the
safety test runner skips ARMv8-A. The patch instantiates the analysis with the
abstraction ARMv7-M and RISC-V already use: the outputs of architecture-
specific operators are unknown, and no comparison or conditional-instruction
heuristic is applied. Unknown outputs can only cause alarms, never hide one;
memory and array accesses, initialization and alignment are checked by the
generic analysis, as on the other architectures.

Tests: the common safety tests now also run on ARMv8-A, and
`compiler/tests/safety/{success,fail}/armv8a/` cover 64-bit memory and array
accesses, alignment, the initialization of the memory LDP reads, and an
operator result used as an index with and without a mask. Upstream status:
not yet proposed.

A known limit of the generic analysis, seen on both architectures and not
addressed by this series: an array that two loops fill at run-time indices,
the second starting where the first stopped, is not recognised as
initialized, and reading it raises an `is_init` alarm although every byte is
written first. The alarm is a loss of precision, not of soundness.
Initializing the array in one pass avoids it.

### #1632, invalid instruction operands

An instruction argument, destination or condition that the target cannot
express, such as the zero-extension of a byte read through a pointer in
`x += (64u) d[0];`, failed at linearization with an internal error
(`linearization: check_rexpr`), on x86-64 and ARMv8-A alike (upstream issue
#1126). The program cannot be compiled as written; the byte must be loaded
into a register first. The pull request reports this as an error of the
program, located at the instruction. In `linearization.v` it adds the error
`invalid_operand` and redefines `check_rexpr`, `check_lexpr` and
`check_fexpr` to return it; each succeeds for exactly the arguments it
accepted before, and the statements and proofs of the theorems that use
them are unchanged. Tests: `compiler/tests/fail/common/bug_1126*.jazz`.

### 0014, store of an immediate (this project)

A64 has no store of an immediate. At the pin, assigning a constant to memory
or to a stack array on ARMv8-A (`buf[i] = 0x80;`, `[:u64 p + 8] = 0;`, any
access size) remained after lowering and was rejected at linearization. The
lowering now moves the constant to a fresh 64-bit variable, `__wtmp__`, that
the program cannot name, and stores its low bytes with STR, STRH or STRB. In
the lowering proof, the lemma `sem_lower_store_imm` states that the two
instructions end in a state equal to the one the source assignment reaches,
except for that variable; `lower_cassgn_wordP` uses it for this case.
Every such store materializes its constant (a MOVZ/MOVK sequence); a
constant stored many times is cheaper held in a register by the source. Test:
`compiler/tests/success/armv8a/store_imm.jazz`. Upstream status: not yet
proposed.

### #1650, the bounds of an unsigned right shift

The checker abstracts `x = y >> k` as `y / 2^k` with a rounding interval, so
it proves neither `2^k x <= y` nor `y <= 2^k x + 2^k - 1`, and a loop
counter computed as `n = len >> 6` loses its relation to `len`. For a
constant `0 <= k <= w`, a destination of the shift's width and a shifted
expression of that same width, the patch meets both bounds into the state
after the assignment. They hold in every concrete state, so the change only
adds constraints. The shifted expression is copied into a fresh variable
first, so `n >>= 6` keeps the old value of `n`.

The width of the shifted expression is part of the condition. A cast such as
`(8u) x` with `x : u64` is a truncation that the front end keeps as the
expression `x` with a narrower declared width; the shift `((8u) x) >> k` then
has an operand of width 64 under a shift of width 8, and bounds stated on
the untruncated `x` are false. An earlier version of this patch checked only
the destination width and accepted an out-of-bounds read
(`n = ((8u) x) >> 0; i = buf[x];` with `buf` of 300 bytes). The carried
version requires the operand to have exactly the shift's width and falls
back to the old abstraction otherwise; `fail/common/shiftcast.jazz` is that
program as a negative test, and `fail/common/shiftnarrow.jazz` a narrower
destination. Every safety verdict obtained with the earlier version has to
be obtained again with this one.

### 0017, LDRW (this project)

At the pin, `x = (64u)[:u32 p];` on ARMv8-A was rejected: zero-extending
loads were lowered for bytes (LDRB) and halfwords (LDRH) only. `LDR <Wt>`
loads a word and, because a write to a W register clears the upper half,
zero-extends it to 64 bits. The patch adds the mnemonic LDRW for that form.
Like LDRSW, it has a 64-bit destination and is valid at that operand size
only; its description gives the printed name `ldr`, used with the W name of
the destination register. The zero-extending word load is lowered to it,
and the Jasmin EasyCrypt library models it (`op LDRW`). LDRW is also listed
as a load (`armv8a_is_load`), so a zero-extending word load from a global
array is lowered to an address computation followed by the load, like the
other loads. The instruction semantics, its printing and its EasyCrypt
model are trusted, like those of the other instructions. Test:
`compiler/tests/success/armv8a/ldrw.jazz`. Upstream status: not yet
proposed.

### 0018, sharing unchanged abstract values (this project)

APRON's `Abstract1.change_environment` copied the abstract value even when
the environment was unchanged, and the environment of an expression was
rebuilt for every evaluation although its variables are nearly always
present already. The patch returns the value or the environment as it is in
those cases, caches the APRON variable of each analysed variable, and builds
array-cell names without `Format`. The checker never modifies an abstract
value in place, so sharing one is safe, and verdicts are unchanged.

Without the copy, APRON can return the constraints of a relational value in
another order, and the safety report printed them in the order returned.
The patch prints them sorted, so the report depends on the value only.
Upstream status: not yet proposed.

### 0019, `array_track_max_bytes` (this project)

Every byte of every array is a dimension of the numerical abstract state, and
the cost of each operation grows with the number of dimensions. With the
configuration option `"array_track_max_bytes": n`, the cells of arrays of
more than n bytes are not dimensions: an assignment to such a cell is
dropped, and a read gives the full range of the cell's type. Their
initialization and the bounds of indices into them are still checked. The
default, -1, tracks every array as before. Leaving cells out can only add
alarms. Test: the cram test `compiler/tests/safety/arraytrack.t`. Upstream
status: not yet proposed.

### 0020, `congruence_reduction` (this project)

The reduced product of the numerical and congruence domains meets every
congruence fact into the numerical state after every operation. With the
configuration option `"congruence_reduction": 1`, an operation that writes
variables (assignment, forgetting, repacking) passes on only the facts on
those variables, and other operations pass on all of them; with 0, none is
passed on, and the congruence domain is still used by the checks. The
default, 2, keeps the behaviour of the pin. Passing a fact on only refines
the numerical state, so lower values can only add alarms. Test: the cram
test `compiler/tests/safety/congruence.t`. Upstream status: not yet
proposed.

### 0021, x29 never allocated (this project)

x29 is the frame pointer. AAPCS64 lets each platform decide whether it must
address a valid frame record at all times, and Apple platforms require it;
a function may leave its caller's record in place by not writing x29. At
the pin, register allocation can still assign x29 to a variable: the
allocatable registers exclude only the stack pointer, and `icall_reg` in
`armv8a_decl.v` still lists R29.
That breaks stack traces taken while the function runs on macOS. The patch
reserves x29 on every platform: the OCaml register allocator never assigns
it, and `armv8a_decl.v` removes it from the registers of the internal
calling convention, so the compiler correctness theorem is checked again
with the smaller set. The allocator's result is checked by the proved
development, as before. Test: the cram test `compiler/tests/armv8a_x29.t`
compiles a function whose variables fit in the registers and one that
spills, for Linux and macOS, and finds no use of x29 or w29 in the output.
Upstream status: not yet proposed.

### 0022, `relational_loop_vars` (this project)

With static packing, the variables of every while-loop condition, with the
variables they depend on and those that depend on them, are in the
relational domain, whose operations cost far more than those of the
interval domain. With the configuration option `"relational_loop_vars":
false`, only those of the functions listed in `"relational_loop_vars_in"`
are, closed over the variables of the same functions. The default, true,
keeps the behaviour of the pin. Fewer relational variables can only add
alarms. Test: the cram test `compiler/tests/safety/loopvars.t`. Upstream
status: not yet proposed.

### #1572, the safety pass

The pull request gives the semantics a second mode, total, in which a memory
or array access out of bounds and a read of an uninitialised variable do not
fail but return a default value, and turns every condition under which the
semantics with errors can fail into an assertion of the program
(`Safety.sc_prog`). Its main theorem, in `proofs/lang/safety_proof.v`, is that
a program whose assertions all hold runs without error. The proofs are part
of `make -C proofs all`. The pass is the basis of 0033; the compiler does
not run it otherwise.

The varmap module type gains six fields and `safety_proof.v` one section
hypothesis; `ADMITS` lists them. They are of the kinds already there: fields
of a module type, implemented by its module, and a section hypothesis,
discharged when the section closes. The assumption report of the end-to-end
theorem (`ASSUMPTIONS`) does not change.

### 0032, lemmas for the safety model (this project)

Lemmas about the initialisation of byte arrays (`JByte_array.ec`), the
validity of memory ranges (`JMemory.ec`), the traces of assertions
(`Jcheck.ec`) and conjunctions over ranges (`JSafety.ec`, new), used by the
proofs of the safety model. They are taken from the Jasmin EasyCrypt library
of upstream's draft pull request #1170 (head `1e7479a2d8e8`). Every lemma is
proved; the library adds no axiom (`ECLIB_AXIOMS` is unchanged), and
`toolchain/build.sh test` checks it with the pinned EasyCrypt.

### 0033, `jasmin2ec -m safety` (this project)

`jasmin2ec -m safety` extracts a model in which every procedure carries the
assertions of the safety pass of #1572, after default contracts are added
(array parameters and results initialised). Initialisation is made explicit
by masks (`compiler/src/safety_mask.ml`): a boolean per scalar and a byte
array per array, `0xFF` where a cell is initialised, passed with array
arguments and returned with array results, including results written to a
sub-array. Each procedure records the trace of its assertions, and with
`--output-proof` the extraction emits one `<f>_spec` Hoare lemma per
contract with a proof skeleton. A proof of those lemmas in EasyCrypt shows
that the assertions hold, and by the theorem of #1572 that the program is
safe.

The printing of the model and its proof skeletons is upstream's from the
draft pull request #1170, merged into the current `toEC.ml`; on this pin
the assertions come from the proved pass instead of the draft's own
generator. `Safety.sc_prog` is added to the extraction of the proofs
(`proofs/lang/extraction.v`). What is trusted: the masks, the printing of
assertions as EasyCrypt formulas and the rest of the extraction to
EasyCrypt, which are hand-written OCaml like the existing extraction.
Upstream status: not yet proposed; it follows #1572 and #1170.

### 0034, one CSDB for a run of protects (this project)

A protect is assembled as `ORR d, a, msf` followed by `CSDB`
(`assemble_slh_protect` in `armv8a_extra.v`). No instruction after a CSDB
in program order, other than a branch, may use the results of data value or
condition flag predictions made for the instructions before it (Arm ARM,
CSDB). In a run `ORR; CSDB; ORR; CSDB; ...; ORR; CSDB` of adjacent protects,
the printer now drops every CSDB but the last, provided that no ORR of the
run reads a register written by an earlier ORR of the run. The instructions
that then come before a CSDB are register-to-register ORRs, which neither
access memory nor branch, and every use of a protected value still comes
after the last CSDB. A label or any other instruction ends a run. CSDB has
no architectural effect, so the printed code computes what the assembly
program computes; the change is in the printer
(`compiler/src/pp_arm_v8a.ml`), outside the proofs. Each protect after the
first in a run costs one instruction less.

Test: the cram test `compiler/tests/armv8a_csdb.t`: three independent
protects and two `protect_ptr` print one CSDB; a protect of the previous
protect's result, and two protects with an instruction between them, keep
both. Upstream status: not yet proposed.

### 0035, expected test outputs (this project)

The expected outputs of the negative test suite
(`compiler/tests/negative.expected`) and of the safety test runner
(`compiler/tests/safety/run.expected`) are generated by the runners. Each
patch above records the output on the base it was written on. On the
combined tree three generated parts differ: the asmgen messages of the
Advanced SIMD negative tests use upstream's newer message format, with the
address forms of a 128-bit load or store; the negative test count and the
position of two RISC-V entries follow from the tests the series adds; and
the safety report lists the ARMv8-A runs of the shift-bound tests, which
0011 adds, with their constraints sorted by 0018. No verdict changes. The
pull requests each regenerate their own files.

## Assembly checks

The compiler's own test configuration (`compiler/config/tests.config`) has
an `armv8a-macos` category, added by #1594, that compiles every ARMv8-A
success test, including those the series adds, with `-system macosx` and
assembles the result with `llvm-mc --triple=arm64-apple-macos`. It runs
with `compiler/scripts/runtest` (Python with PyYAML, and `llvm-mc` on
`PATH`); `toolchain/build.sh test` does not run it.

## Identity with the pull requests

Each carried commit was compared with its pull request's commit with
`git patch-id --stable`, at the heads in the table.

- #1625, #1650, #1572: equal for all 19 commits (0003-0010, 0015-0016,
  0023-0031). #1572 is based on the pin itself.
- #1594: 0002 is equal. 0001 has the same changed lines as the pull
  request's commit; the surrounding context differs on the new pin.
- #1632: 0013 is equal. 0012 has the same changed lines except the
  generated content of `negative.expected`, which 0035 brings to the output
  of the combined tree.
- #1643: see `PATCHES-SIMD.md`.

## Considered and not carried

- Rotation by zero on x86-64. `x <<r= 0` is printed as `rol $0, r`, an
  instruction that changes neither the value nor the flags; ARMv8-A drops it.
  It costs one instruction and is avoided in the source.
