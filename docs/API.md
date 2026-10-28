# API

The C interface is [`include/nirapod/sha2.h`](../include/nirapod/sha2.h).
Its comment block is the contract: error codes and the order of checks,
length limits, buffer and overlap rules, context semantics, concurrency, and
what the library does about instruction timing on each kind of CPU. This
page adds what does not belong in a header, and the interface for Jasmin
programs that include the sources directly.

Include `<nirapod/sha2.h>` with `include/` on the include path and link
`build/<arch>-<system>/lib/libnirapod_sha2.a`. The archive is one
relocatable object in which only the header's functions are global.

## Examples

A one-shot digest:

```c
uint8_t d[NIRAPOD_SHA2_SHA256_BYTES];

if (nirapod_sha2_sha256(d, msg, msg_len) != NIRAPOD_SHA2_OK)
    return -1;    /* NULL msg with msg_len > 0, msg_len >= 2^61, or d overlapping msg */
```

A message that arrives in pieces. `final` zeroes the context, but a failed
`update` leaves the hash state in it, so the error path clears it with
`init`, which overwrites every byte with constants and, unlike a `memset` of
a dying object, cannot be optimised away:

```c
int digest_of_parts(uint8_t out[NIRAPOD_SHA2_SHA512_BYTES],
                    const uint8_t *const part[], const size_t len[], size_t n)
{
    nirapod_sha2_sha512_ctx ctx;
    int rc = nirapod_sha2_sha512_init(&ctx);

    for (size_t i = 0; rc == NIRAPOD_SHA2_OK && i < n; i++)
        rc = nirapod_sha2_sha512_update(&ctx, part[i], len[i]);
    if (rc == NIRAPOD_SHA2_OK)
        rc = nirapod_sha2_sha512_final(&ctx, out);
    if (rc != NIRAPOD_SHA2_OK)
        nirapod_sha2_sha512_init(&ctx);
    return rc;
}
```

A context holds no pointer, so `memcpy` forks a hash: hash a common prefix
once, copy the context, finish each copy differently. The layout is
described in [ARCHITECTURE](ARCHITECTURE.md#representations) for reviewers;
programs must not depend on it.

## DIT and short messages

On AArch64 with FEAT_DIT, every call that reads a message, a key or a
context runs its Jasmin code with PSTATE.DIT set. The library reads DIT
first and writes it only if it was clear, so a caller that already holds DIT
pays one `mrs` and no write. On an Apple M4, `aarch64-sha2` kernel, medians
of interleaved rounds:

| Operation                                          | DIT set by the library | DIT held by the caller |
| -------------------------------------------------- | ---------------------: | ---------------------: |
| SHA-256, 0 bytes, one-shot                         |                75.7 ns |                49.0 ns |
| SHA-256, 32 bytes, init, update, final             |               159.9 ns |               107.3 ns |
| HMAC-SHA-256, 32-byte key and message, three calls |               281.5 ns |               207.0 ns |

A program that hashes many short messages can set DIT once around the whole
batch and lose nothing: the Jasmin code still runs with DIT set. User code
may write DIT on a CPU that has FEAT_DIT; on one that does not, the write is
undefined, so check `hw.optional.arm.FEAT_DIT` (macOS) or `HWCAP_DIT`
(Linux) first.

For short messages prefer the one-shot functions. Each call pays the entry
fence and, unless the caller holds DIT, two writes; an incremental hash
makes three calls.

## The testing interface

`capi/testing/nirapod_sha2_testing.h` declares each public function again
with a kernel as its first argument, so tests can run every unit the CPU
supports, including units outside the default dispatch:

```c
int nirapod_sha2_testing_sha256(nirapod_sha2_testing_kernel k, uint8_t *out,
                                const uint8_t *in, size_t len);
```

The kernels are `PORTABLE`, `AARCH64_SCALAR`, `AARCH64_SHA2`, `X86_64_SHANI`
and `X86_64_AVX2`, each prefixed `NIRAPOD_SHA2_TESTING_`. A kernel not built
for this architecture, or needing a feature the CPU lacks, gives
`NIRAPOD_SHA2_TESTING_EUNAVAILABLE` (-100) before any other check. Otherwise
the call runs the same C path as the public function with the unit fixed.
`nirapod_sha2_testing_select_for(f, cpu, gated)` reports what dispatch would
pick for family `f` on a CPU with features `cpu`, so the selection can be
tested for CPUs the host is not.

These functions exist only in `libnirapod_sha2_testing.a`, which keeps every
symbol as compiled. Link it into tests and nothing else.

## Stack use

Each export clears the stack it used before returning, so the size it clears
is the most its Jasmin code takes below the C caller. The largest per unit,
read from the clearing code in the assembly:

| Unit               | Largest export | Bytes |
| ------------------ | -------------- | ----: |
| `aarch64-portable` | `hmac_sha512`  |  1120 |
| `aarch64-scalar`   | `sha256_x8`    |  1488 |
| `aarch64-sha2`     | `sha512_x4`    |  1072 |
| `x86_64-portable`  | `hmac_sha512`  |  1160 |
| `x86_64-shani`     | `hmac_sha512`  |  2496 |
| `x86_64-avx2`      | `hmac_sha512`  |  2496 |

The public functions run a dispatched unit or the portable one, so the
Jasmin part needs at most 1120 bytes on AArch64 and 2496 on x86-64. The C
frames come on top and depend on the compiler: measured from the caller on
the M4, the deepest public call, 4-way SHA-512, used 1648 bytes in all
([BENCHMARKS](BENCHMARKS.md#stack-and-code-size)).

## Using the Jasmin sources

A Jasmin program can include the library's sources instead of calling the C
API, and cite `proofs/correctness/Theorems.ec` for what it gets. It then
takes over what the C layer does: argument checks, choosing a kernel the CPU
can run, DIT, register and stack clearing.

### Include roots

Six roots select the code. `Hash` is `src`, `HashWord` is `src/x86_64` or
`src/aarch64`, and `Sha256Kernel`, `Sha512Kernel`, `Sha256KernelX` and
`Sha512KernelX` are `src` for the portable kernels or a kernel directory
([ARCHITECTURE](ARCHITECTURE.md#units-and-include-roots)). The roots of the
`aarch64-sha2` unit:

```sh
jasminc -arch armv8a -I Hash=src -I HashWord=src/aarch64 \
    -I Sha256Kernel=src/aarch64/sha2  -I Sha512Kernel=src/aarch64/sha2 \
    -I Sha256KernelX=src/aarch64/sha2 -I Sha512KernelX=src/aarch64/sha2 ...
```

`make -s print-roots-<unit>` prints them for any unit.

```text
from Hash require "sha256.jinc"
from Hash require "hmac.jinc"
```

### Conventions

* Message bytes, keys, states and outputs are secret; pointers, lengths,
  offsets and lane counts are public, and must stay public on the caller's
  own path.
* A pointer `p` with length `l` must be valid for `l` bytes and satisfy
  $p + l < 2^{64}$. Inputs and outputs must not overlap unless a function's
  contract says otherwise. No alignment is required.
* Totals stay below $2^{61}$ bytes; HMAC messages below $2^{61} - B$.
* Every function with a loop or a branch takes the misspeculation flag `ms`
  and returns it. Thread it through every call: a flag cannot pass through
  the stack, which is why even branch-free kernels take it. Pointers and
  lengths passed in must be public, not merely transient, except where a
  signature says otherwise (`_sha*_finalize` takes a transient `out`).
  Protect values reloaded from the stack before passing them on.
* HMAC's `inner`, `outer` and the finalize output are the caller's own stack
  arrays.
* A program checked by `jasmin-checksafety` must initialise all of `buf`
  once before first use: the checker cannot follow the pending-bytes
  invariant through writes at run-time offsets.

### Residue

Apart from the context `final` functions, which zero the caller's context,
nothing here clears memory. These frames hold secret-derived data on return,
and so does every caller of them:

| Function | Left in its frame |
| --- | --- |
| `_sha256_compress*`, portable | schedule words $W_{47}$ to $W_{62}$ |
| `_sha512_compress*`, portable | $W_{63}$ to $W_{78}$ |
| `_sha256_compress*`, `_sha512_compress*`, `aarch64/scalar` | $W_{48}$ to $W_{63}$ ($W_{64}$ to $W_{79}$) |
| `_sha256_compress*`, `_sha512_compress*`, `x86_64/avx2` | $W_t + K_t$ of the last two blocks |
| `_sha256_compress*`, `x86_64/shani` | nothing |
| `aarch64/sha2`, single-way and 8-way | nothing |
| `_sha256_x8_compress*`, `_sha512_x4_compress*`, `x86_64/avx2` | 16 schedule words of every lane |
| `_sha256_x8_compress*`, `aarch64/neon` | $W_{46}$ to $W_{61}$ of every lane |
| `_sha256_x8_compress*`, `x86_64/shani` | lanes 6 and 7's chaining values before their last block |
| `_sha512_x4_compress*`, `aarch64/sha2` | lanes 2 and 3's chaining values before their last block |
| portable multi-way kernels | the last lane's chaining value |
| `_sha256_mem`, `_sha512_mem` and the other one-shots | the last padded block, the final chaining value |
| `_sha256_x8_lanes`, `_sha512_x4_lanes` | every lane's last block and final chaining value |
| `_hmac_sha*_keyblock_mem` | $H(K)$ for a key longer than a block |
| `__hmac_sha*_init` | $K_0 \oplus \text{ipad}$ and $K_0 \oplus \text{opad}$ |
| `__hmac_sha*_finalize` | the inner digest |
| `_hmac_sha*_mem`, `__hmac_sha*_ctx_init` | $K_0$ |
| `__hmac_sha*_ctx_final` | the loaded and final states, and the tag |

The library's own exports get rid of all of it with `-stack-zero`.

### Array forms

Exports read input through a pointer, but a Jasmin caller usually holds it
in an array of fixed size. Each input path therefore has an array form in a
`*_ASIZE.jinc` file, instantiated inside a namespace that sets
`param int _ASIZE`:

| Memory form                                   | Array form                                   |
| --------------------------------------------- | -------------------------------------------- |
| `__fill64_mem`, `__fill128_mem` (`fill.jinc`) | `__fill64_array`, `__fill128_array`          |
| `_sha256_absorb_mem`                          | `_sha256_absorb_array` (`sha256_ASIZE.jinc`) |
| `_sha512_absorb_mem`                          | `_sha512_absorb_array` (`sha512_ASIZE.jinc`) |
| `_sha256_x8_absorb_lanes`                     | `_sha256_x8_absorb_array`                    |
| `_sha512_x4_absorb_lanes`                     | `_sha512_x4_absorb_array`                    |

Initial values, finalize and the kernels take no input and are shared.
Require the memory-form file once at top level and the array files inside
each namespace; an array file requires only `fill_ASIZE.jinc`, since a
namespace includes a file again even if the top level already has it.

```text
from Hash require "sha256.jinc"

namespace In48 {
  param int _ASIZE = 48;
  from Hash require "sha256_ASIZE.jinc"
}

h = __sha256_init(h);
total = 0;
h, buf, total, ms = In48::_sha256_absorb_array(h, buf, total, a, off, len, ms);
out, h, buf, ms = _sha256::_sha256_finalize(out, h, buf, total, ms);
```

### What can be cited

The theorems of `Theorems.ec` and the `#[safety]` contracts hold on the
model of each of the six units ([PROOFS](PROOFS.md)). The array forms are
proved correct for any size and safe at sizes 1, 64, 128 and 333. A program
with another size extracts its own instance, relates its procedures to the
generic text with `proc; sim` as
`proofs/correctness/units/<unit>/ArrayInst.ec` does, and re-runs the safety
scripts on it. The constant-time results are those of `jasmin-ct` on the
including program, which has to run the checker itself.
