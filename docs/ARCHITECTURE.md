# Architecture

```text
 nirapod_sha2_sha256(out, in, len)
        │
        ▼
 capi/            argument checks, unit selection, DIT, register clearing
        │
        ▼
 export           src/nirapod_sha2.jinc, compiled once per unit
        │
        ▼
 shared layer     buffering, padding, HMAC, contexts, multi-way front ends
        │
        ▼
 kernel           compression functions, chosen by include roots
```

The shared Jasmin layer is written once. What changes between kernel
families is only the compression code underneath it, and the build swaps
that through include roots. `jasminc` and `jasmin-ct` take the same
namespaced unit, and `jasmin2ec` the same sources under the same roots,
checked token for token against it, so the assembly, the EasyCrypt models
and the leakage results are about one program.

## Units and include roots

| Unit             | `Sha256Kernel` | `Sha512Kernel` | `Sha256KernelX` | `Sha512KernelX` |
| ---------------- | -------------- | -------------- | --------------- | --------------- |
| aarch64-portable | portable       | portable       | portable        | portable        |
| aarch64-scalar   | aarch64/scalar | aarch64/scalar | aarch64/neon    | portable        |
| aarch64-sha2     | aarch64/sha2   | aarch64/sha2   | aarch64/sha2    | aarch64/sha2    |
| x86_64-portable  | portable       | portable       | portable        | portable        |
| x86_64-shani     | x86_64/shani   | x86_64/avx2    | x86_64/shani    | portable        |
| x86_64-avx2      | x86_64/avx2    | x86_64/avx2    | x86_64/avx2     | x86_64/avx2     |

Directories are under `src/`, and portable means `src` itself. `Hash` is
`src` and `HashWord` is `src/<arch>` in every unit. A multi-way root left at
`src` gives the portable front end with the unit's single-way kernel run
once per lane. The Makefile ("Units") is the source of this table, and
`make -s print-roots-<unit>` prints it.

For each unit the build writes a three-line `build/units/<unit>.jazz`:

```text
namespace nirapod_sha2_jz_<arch>_<variant> {
  from Hash require "nirapod_sha2.jinc"
}
```

so the export `sha256` of `aarch64-sha2` becomes the symbol
`nirapod_sha2_jz_aarch64_sha2__sha256`, and the three units of an
architecture link side by side. `capi/jasmin.h` declares them for C. Units
are compiled with `-stack-zero loop`, with 64-bit clearing stores except in
`x86_64-shani` and `x86_64-avx2`, whose frames are large enough that 256-bit
stores pay off ([KERNELS](KERNELS.md#avx2-multi-way)). Assembly goes to
`build/asm/<system>/<unit>.s`; neither target needs its own hardware to
compile, and `make asm-all` writes all six.

The EasyCrypt models come from an entry without the namespace, so that a
procedure has one name in every unit. The CI job `extraction` ties each
model back to the namespaced unit ([PROOFS](PROOFS.md#extraction-identity)).

## Kernels

A kernel directory replaces the portable file behind one root and provides
the same entry points under the same contracts:

| Root            | Entry points                                                             |
| --------------- | ------------------------------------------------------------------------ |
| `Sha256Kernel`  | `_sha256_compress(h, block, ms)`, `_sha256_compress_blocks(h, p, n, ms)` |
| `Sha512Kernel`  | `_sha512_compress(h, block, ms)`, `_sha512_compress_blocks(h, p, n, ms)` |
| `Sha256KernelX` | `_sha256_x8_compress`, `_sha256_x8_compress_lanes`                       |
| `Sha512KernelX` | `_sha512_x4_compress`, `_sha512_x4_compress_lanes`                       |

The portable, SHA-NI and AVX2 single-way kernels also provide
`_sha256_compress_one` (`_sha512_compress_one`), one block from memory,
which their proofs name; the AVX2 ones add `_compress_two` for a pair of
blocks. A kernel does not check that the CPU has its instructions. The C
layer does.

The portable units run the portable kernels for everything. The others
(features per family in `capi/units.c`):

* `aarch64-scalar`: SHA-256 and SHA-512 rounds in A64 three-operand form;
  8-way SHA-256 in Advanced SIMD, as two halves of four lanes; 4-way SHA-512
  as the scalar kernel per lane.
* `aarch64-sha2`: SHA256H/H2/SU0/SU1 and SHA512H/H2/SU0/SU1, single-way, and
  two lanes interleaved for 8-way and 4-way.
* `x86_64-shani`: SHA-NI for SHA-256, single-way and two lanes interleaved
  for 8-way; the AVX2 kernel for SHA-512, and per lane for 4-way.
* `x86_64-avx2`: the message schedule in AVX2 and the rounds in BMI1/BMI2
  scalar code for single-way; 8 and 4 lanes across ymm registers for
  multi-way.

The SHA-NI kernels themselves use only SSE and AVX encodings, but every
family of `x86_64-shani` needs AVX2 because its exports clear the stack with
256-bit stores. `tests/isa` compares the features `capi/units.c` declares
with the instructions each export can reach in the assembly, so dispatch
cannot hand a CPU an instruction it lacks. On Linux the AArch64 units are
assembled with `-march=armv8.2-a+sha2+sha3`, because the GNU assembler
accepts the SHA-2 mnemonics only with those extensions enabled; the flag
does not change the instructions.

[KERNELS](KERNELS.md) describes each kernel and its compiled code.

## Representations

| Object  | SHA-224, SHA-256 | SHA-384, SHA-512, SHA-512/t | Invariant                                       |
| ------- | ---------------- | --------------------------- | ----------------------------------------------- |
| `h`     | `u32[8]`         | `u64[8]`                    | $H_0, \dots, H_7$ of FIPS 180-4, native words   |
| `buf`   | `u8[64]`         | `u8[128]`                   | the first `total mod B` bytes are pending input |
| `total` | `u64`            | `u64`                       | bytes absorbed so far, always below $2^{61}$    |

Messages are read and digests written big-endian. Words inside a context are
stored as Jasmin loads and stores them, little-endian on both targets.
Contexts (`src/context.jinc`, `src/context_x.jinc`):

| Context                     | Bytes | Layout                                                        |
| --------------------------- | ----: | ------------------------------------------------------------- |
| SHA-224, SHA-256            |   112 | tag at 0, total at 8, `h` at 16, `buf` at 48                  |
| SHA-384, SHA-512, SHA-512/t |   208 | tag at 0, total at 8, `h` at 16, `buf` at 80                  |
| HMAC-SHA-256                |   144 | the SHA-256 layout for the inner hash, outer state at 112     |
| HMAC-SHA-512                |   272 | the SHA-512 layout for the inner hash, outer state at 208     |
| 8-way SHA-256               |   784 | tag, total, `h` as `u32[64]` at 16, `buf` as `u8[512]` at 272 |
| 4-way SHA-512               |   784 | tag, total, `h` as `u64[32]` at 16, `buf` as `u8[512]` at 272 |

The tag names the function and marks the context live
(`0x3268736e | f << 32 | 1 << 40`); `final` sets it to 0. Because each HMAC
layout starts with the hash layout, HMAC `update` is the hash `update` with
the HMAC tag. Multi-way state keeps word $j$ of lane $k$ at index $8j + k$
($4j + k$ for SHA-512), so one vector register holds the same word of
several lanes; lane $k$'s pending block is at `buf[64k]` (`buf[128k]`), and
all lanes share one total.

## Dispatch

`capi/dispatch.c` reads the CPU features once per process and keeps, per
family, a list of units in order of preference. A call takes the first
admitted unit whose features the CPU has.

| Family | AArch64 | x86-64 |
| --- | --- | --- |
| SHA-224, SHA-256, HMAC-SHA-256 | `aarch64-sha2`, portable | `x86_64-shani`, `x86_64-avx2`, portable |
| SHA-384, SHA-512, SHA-512/t, HMAC-SHA-512 | `aarch64-sha2`, portable | `x86_64-avx2`, portable |
| 8-way SHA-256 | `aarch64-sha2`, portable | `x86_64-shani`, `x86_64-avx2`, portable |
| 4-way SHA-512 | `aarch64-sha2`, portable | `x86_64-avx2`, portable |

A unit is admitted once its kernels have a correctness proof, a proof of
their safety contracts, passing CT and SCT checks, and native tests. Every
unit listed is. A new kernel enters with its flag clear and is reachable
only through the testing interface until it is. `aarch64-scalar` is in no
list. `x86_64-shani` is not listed for the SHA-512 families because there it
runs the same code as `x86_64-avx2`.

On x86-64, SHA, AVX2 and BMI1/BMI2 count as present only with AVX and
OSXSAVE and with the SSE and AVX state enabled in XCR0. On AArch64 the
features come from `sysctlbyname` on macOS and `getauxval(AT_HWCAP)` on
Linux.

## The C layer

`capi/api.c` holds the public functions and the argument checks,
`dispatch.c` and `units.c` the selection, `timing.c` the DIT handling and
`clear.c` the register clearing. None of it reads or writes a message, key,
digest or context byte. `libnirapod_sha2.a` links the C objects and the
host's three units into one relocatable object and localises everything but
the header's functions (`ld -r` with an exported-symbols list on Mach-O,
`ld -r` and `objcopy --keep-global-symbols` on ELF).

`nirapod_sha2_sha256(out, in, len)` on an AArch64 core with FEAT_SHA256 goes
like this. `capi/api.c` selects `aarch64-sha2` and checks the arguments;
`timing.c` sets DIT if it was clear. The export
`nirapod_sha2_jz_aarch64_sha2__sha256` runs `dsb sy; isb`, then
`_sha256_mem` loads the initial value of FIPS 180-4 5.3.3, hands every whole
block to the SHA256H/H2 kernel straight from the caller's memory, buffers
the tail, pads it (5.1.1) and stores the digest big-endian into `out`. The
compiler's clearing loop zeroes the frame. Back in C, x0 to x17 and v0 to
v31 are zeroed and DIT is put back as the caller had it.
