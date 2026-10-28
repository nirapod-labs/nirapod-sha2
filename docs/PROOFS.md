# Proofs

Each of the 42 exports has a total-correctness theorem, checked on the
extracted model of every unit. For the one-shot SHA-256 export:

```text
lemma sha256_export_total (p0 l0 : W64.t) :
  phoare [M.sha256 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61
           ==>
           BArray32.to_list res =
             SHA256.sha256 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))
         ] = 1%r.
```

`M` is the model `jasmin2ec` extracts from the unit, `SHA256.sha256` is the
FIPS 180-4 function of `proofs/spec/FIPS180_SHA2.ec`, and `memread` is the
byte reader of the crypto-specs `JWordList` theory. Every statement in
[`proofs/correctness/Theorems.ec`](../proofs/correctness/Theorems.ec) is
written in those terms only: the operators of `spec/`, byte lists, and
`memread`. The definitions under `correctness/lib/` are each tied to `spec/`
by a proved equation, so `spec/` is all a reader has to trust.

The specification itself is checked by evaluation on CAVP vectors inside
EasyCrypt ([VALIDATION](VALIDATION.md#the-specification)).

## The statements

`Theorems.ec` states 129 lemmas at top level, claimed on every unit, and 14
more in the abstract theory `ArrayTheorems`, of which 10 are instantiated at
four sizes on the two portable units. They cover, from the bottom up:

* the kernel interface: `sha256_compress_total`,
  `sha256_compress_blocks_total` and their SHA-512 counterparts;
* initial values, absorbing from memory, finalize for each digest length,
  and the one-shot hashes over memory (`sha256_mem_total`, ...);
* the HMAC key block and HMAC over memory, keys of any length;
* the contexts of every function, single-way and multi-way;
* the array forms, in the abstract theory `ArrayTheorems` with the array
  size left abstract;
* the 42 exports at their own arguments: `<f>_export_total`, and
  `<f>_init_export_total`, `<f>_update_export_total`,
  `<f>_final_export_total`, for each hash, each HMAC and both multi-way
  functions, with `<f>_init_from_export_total` for the multi-way ones.

State that lives across calls is described by predicates defined in the same
terms (`sha256_ctx`, `hmac256_ctx`, `sha256_x8_ctx`, ...), each proved equal
to the representation the proofs use internally. An `update` theorem says
three things. A nonzero status leaves the context array as it was. A context
whose tag is not the function's gives status 1. A context that represents
`m` and accepts $\ell$ more bytes ends up representing
`m ++ memread mem p l`, or gives status 2 if the total would reach $2^{61}$.
A `final` theorem gives the digest of everything absorbed and a context that
is zero in every byte. The multi-way theorems state lane $k$'s digest as
bytes $[32k, 32k+32)$ of the output, $[64k, 64k+64)$ for SHA-512.

Every procedure takes the misspeculation flag, and every theorem holds for
any value of it. Leakage is not a theorem here; it is the result of
`jasmin-ct` ([SECURITY-MODEL](SECURITY-MODEL.md#constant-time)).

## Domain

Memory arguments are a pointer $p$ and a length $\ell$ with
$p + \ell < 2^{64}$ as integers. Correctness is about `memread` of those
bytes; that they may be read is the safety half.

| Function        | Domain                                                                  |
| --------------- | ----------------------------------------------------------------------- |
| one-shot hashes | $\ell < 2^{61}$                                                         |
| `update`        | $t + \ell < 2^{61}$ for a context holding $t$ bytes, otherwise status 2 |
| HMAC-SHA-256    | key below $2^{61}$, message below $2^{61} - 64$                         |
| HMAC-SHA-512    | key below $2^{61}$, message below $2^{61} - 128$                        |
| multi-way       | $\ell < 2^{61}$, and $p_k + \ell < 2^{64}$ for every lane               |
| array forms     | $0 <$ `asize` $< 2^{64}$ and `off + len <= asize`                       |

For SHA-384, SHA-512 and SHA-512/t the bound is the library's, not FIPS
180-4's ($2^{125}$ bytes): the byte count is kept in one 64-bit word.

## Kernels and instruction models

A kernel is proved once against the FIPS 180-4 compression function, in the
proof directory that mirrors its source directory. The shared layers above
it are replayed on every unit through four interface files in
`correctness/units/<unit>/`. The top of
[`proofs/Makefile`](../proofs/Makefile) explains how a unit's file list is
put together.

| Kernel                                        | Proofs                        |
| --------------------------------------------- | ----------------------------- |
| portable SHA-256, SHA-512, per-lane multi-way | `correctness/portable/`       |
| A64 scalar SHA-256, SHA-512                   | `correctness/aarch64/scalar/` |
| Advanced SIMD 8-way SHA-256                   | `correctness/aarch64/neon/`   |
| Armv8-A SHA-2 instructions, all four forms    | `correctness/aarch64/sha2/`   |
| SHA-NI, single-way and 8-way SHA-256          | `correctness/x86_64/shani/`   |
| AVX2 and BMI1/BMI2, all four forms            | `correctness/x86_64/avx2/`    |

That is seventeen kernels. The multi-way ones are proved lane by lane
against the single-way specification.

The kernels on dedicated instructions rest on lemmas about the toolchain's
EasyCrypt models of those instructions, stated in the operand order the
kernels use: `correctness/x86_64/ShaNi.ec` for SHA256RNDS2, SHA256MSG1 and
SHA256MSG2, and `correctness/aarch64/Sha2Insn.ec` for SHA256H, SHA256H2,
SHA256SU0, SHA256SU1 and their four SHA-512 counterparts. They show that the
models compute FIPS 180-4 rounds and schedule steps. Whether the models
describe the hardware is a separate question, answered on test vectors only
([VALIDATION](VALIDATION.md#instruction-models)), and the models stay in the
trusted base.

## Memory safety

`jasmin2ec -m safety` extracts a second model per unit in which every
failure condition of the program is an assertion, with one lemma statement
per `#[safety]` contract (toolchain patch 0033). `proofs/safety/` proves
them in the same layout as `correctness/`: the contracts of the shared
layers and of every export on every unit, the kernel contracts of each
replacement kernel, and the array forms at sizes 1, 64, 128 and 333 on the
portable units. An export's precondition is the caller's side of the C
contract: `is_mem_init` on each input, context and output arrays of the
sizes the header gives, and the length bounds above.

The array forms are proved correct for every size but safe only at those
sizes. The safety scripts do not depend on the size, so a program with
another one re-runs them on its own extraction, as
`correctness/units/<unit>/ArrayInst.ec` does for correctness.

The pass that inserts the assertions is proved in Rocq (patches 0023 to
0031). Printing them to EasyCrypt is not.

## Extraction identity

The CI job `extraction` checks, on every unit of both architectures, that

* the committed models equal a fresh extraction, byte for byte;
* each model is the program of the namespaced unit the library is built
  from, token for token;
* every procedure outside the kernel files has the same text in every unit
  of an architecture, so a proof of a shared layer is a proof about each
  unit.

Four negative controls have to be rejected.

## Axioms and holes

`make -C proofs scan-holes` fails on `admit`, `admitted`, `pragma`, `exit`
or `fail` outside a comment. The only `axiom` declarations in `correctness/`
are parameters of abstract theories: `dsize_ok` in the finalize theories,
discharged by each digest instance, and `asize_ok`, the array theorems' own
hypothesis on the size.

`proofs/inventory/<arch>/<variant>/inventory.txt` holds what the pinned
EasyCrypt prints for each unit: every axiom in scope and every claimed
theorem. `make -C proofs check` regenerates them and fails on any
difference.

| Unit               | Axioms in scope | Claimed theorems |
| ------------------ | --------------: | ---------------: |
| `aarch64-portable` |             848 |              169 |
| `aarch64-scalar`   |             848 |              129 |
| `aarch64-sha2`     |             848 |              129 |
| `x86_64-portable`  |             863 |              169 |
| `x86_64-shani`     |             844 |              129 |
| `x86_64-avx2`      |             901 |              129 |

They come from the EasyCrypt standard library, the Jasmin EasyCrypt library
(words, memory, instruction models), the array theories `jasmin2ec`
generates, and the definitional axioms of `JWordList`. None comes from this
project's theories.

## Checking

The pinned EasyCrypt and provers have to be on `PATH`, and the proofs run on
Linux.

```sh
make -C proofs check J=8                          # everything
make -C proofs check-unit UNIT=x86_64-avx2 J=8    # one unit
make -C proofs print-unit UNIT=aarch64-sha2       # its load path and files
```

Use a clean checkout. EasyCrypt does not re-check a theory it loads with
`require`, and `-no-eco` still reads `.eco` files that exist, so in a used
tree a stale `.eco` can stand in for a file that no longer checks. Each file
is checked in its own process, from a copy that ends with a trivial lemma:
EasyCrypt accepts a file that stops with `clone ... proof *` obligations
unrealized, but not one with a command after them.

The last full run took 73 minutes at `J=7` on a Ryzen 7 7700X under WSL2,
with other jobs on the machine. EasyCrypt time per unit, summed over files:

| Unit               | Files | Seconds |
| ------------------ | ----: | ------: |
| `aarch64-portable` |    48 |    3295 |
| `aarch64-scalar`   |    49 |    2738 |
| `aarch64-sha2`     |    50 |    2231 |
| `x86_64-portable`  |    48 |    3347 |
| `x86_64-shani`     |    48 |    2993 |
| `x86_64-avx2`      |    57 |    4712 |

The specification and the files without a model add about 460 s. The
evaluation of the specification on CAVP vectors came after that run; it
takes 356 s on its own at `J=4`.

Every `smt` call also passes with the prover timeout halved
(`EC_TIMEOUT=5`), so a result does not depend on machine load.

## Not covered

* The C layer: argument checks, dispatch, DIT, register clearing.
* The stack clearing of `-stack-zero`, which is outside the compiler's
  theorem. `tests/residue` tests it.
* The faithfulness of `jasmin2ec` and of the instruction models.
* The specification beyond the vectors it is evaluated on.
* Constant time, which is a type-checker result here, not a theorem.
