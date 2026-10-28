# Kernels

What each kernel computes is fixed by its proof. These notes are about how:
the shape of the code the pinned compiler emits for it, and the measurements
behind the source choices. They were read from this tree's units as
`make asm-all` writes them to `build/asm/<system>/<unit>.s`, and must be
read again when the compiler or a kernel changes. The Linux and macOS
AArch64 files differ only in assembler syntax (`.L` and `L` labels, `:lo12:`
and `@PAGEOFF`, the leading underscore, ELF directives); normalised, they
are identical instruction for instruction.

A kernel is a local function, so its code runs from its label to the first
`ret`, and labels carry the unit's namespace. The registers the A64 scalar
SHA-256 rounds name, for instance:

```sh
sed -n '/^\.*L[a-z0-9_]*___sha256_rounds_a64\$1:/,/^[[:space:]]*ret/p' \
    build/asm/linux/aarch64-scalar.s | grep -oE '\<[xw][0-9]+\>' | sort -u
```

Two properties of the assembly are checked mechanically: no AArch64 unit
uses x18 (`make asm-policy`, part of `make check`), and no export can reach
an instruction needing a CPU feature that `capi/units.c` does not declare
for it (`tests/isa`, in the CI `tests` job, with 38 negative controls).

## Portable

Each $\Sigma$ and $\sigma$ is a copy of the word and a rotate or shift in
place, Ch and Maj are the forms without a complement, and $K_t$ is loaded
from the table by round number. The rounds are inlined into both
`_sha256_compress` and `_sha256_compress_one`, so each is straight-line code
with every round and schedule step unrolled. For SHA-256 that is 3,455
instructions on A64 and 3,439 and 3,432 on x86-64; for SHA-512, 4,383, and
4,380 and 4,363.

An A64 round is 37 instructions, and from round 16 a schedule step adds 22.
Register copies are a large share of that: 9 per round and 4 per schedule
step, 768 MOV per SHA-256 block, because the compiler keeps every copy the
two-operand source writes instead of using the three-operand ROR or a
rotated EOR operand. With the table address formed again in every round, a
block takes about 1.7 times the instructions of the A64 scalar kernel.
x86-64 has the same shape with LEA and SHR, and 9 or 10 copies per round.

Each function names 13 general registers, none callee-saved on A64; on
x86-64 the exports save rbx, rbp and r12 to r15. Nothing is spilled. The
only stack traffic is the 16-word schedule window at fixed offsets from sp:
a SHA-256 block is 304 loads and 71 stores in all, and a SHA-512 block 384
loads and 87 stores. Every address is a base register plus an immediate,
never an index register. Each message word is byte-reversed once, between
its load and its store to the window.

`_compress_blocks` spills `p` and `n` around each call to `_compress_one`
and protects both on reload: ORR with the flag and one CSDB on A64, OR with
the mask on x86-64. The portable multi-way kernels unroll their lane loop
into 8 (4) calls of the single-way kernel, with 44 instructions per lane
around each call on A64 and 43 on x86-64.

## A64 scalar

The `aarch64/scalar` kernels use the three-operand forms: $\Sigma$ and
$\sigma$ are one ROR and two EORs with a rotated or shifted operand, Ch is
AND and BIC, Maj carries $a \oplus b$ into the next round, and the constants
come through a pointer. A round is 20 instructions, a schedule step 14, and
the round functions have no MOV at all: 2,001 instructions for SHA-256,
2,545 for SHA-512, straight-line.

They name 15 general registers: pointers to `h`, the constants and the
window, and twelve values (the working variables, the two alternating
$a \oplus b$, temporaries). x19 is among them, saved by every export.
Nothing is spilled and nothing is addressed relative to sp. The window lives
in the frame of `_compress_blocks`, which fills it before each call with 16
loads, 16 REV and 16 stores, and which keeps `p` and `n` in registers the
round function does not write. A SHA-256 block is 304 loads and 72 stores.
There is no CSDB, DSB or ISB in `_sha256_rounds_a64`, `_sha512_rounds_a64`
or the `_compress` and `_compress_blocks` functions that call them.

## Advanced SIMD 8-way SHA-256

The `aarch64/neon` kernel, used by `aarch64-scalar`, holds word $j$ of four
lanes in one vector, which is the context layout, so the state needs no
transpose. The message does: REV32, then TRN1 and TRN2 on 32- and 64-bit
elements. The two halves of four lanes are interleaved instruction by
instruction; run one after the other each round is a single dependency
chain, and a C prototype of that form was about 1.4 times slower on an Apple
M4. ROTR is SHL and SRI. Ch is one BIT and Maj one BSL.

One block of all eight lanes, `_sha256_x8_block`, is about 5,600
instructions. The state, the carried $a \oplus b$ of each half, the
constants and the temporaries fit the 32 vector registers with no copies;
the 16-word windows of both halves would not, and stay in memory. BIT
overwrites `g`, which is dead once `g` + $K_{t+1}$ has been formed, so the
state rotates through nine vectors per half. With BIT and BSL the rounds are
5,045 vector instructions per block, against 5,427 with AND, BIC and EOR,
and the kernel took 4% less time at one compression per lane and 7 to 8%
less from 256 bytes per lane. Against the portable 8-way kernel it is 1.94
times as fast at one compression per lane and 2.6 to 2.7 times from 1 KiB
per lane. Those numbers are from the M4; the cores this unit is for, A64
cores without the SHA-2 instructions, were not measured.

EOR3 would fold the three-way XORs of $\Sigma$ and $\sigma$, but it is a
SHA-3 instruction, and FEAT_SHA3 implies FEAT_SHA256 (DDI 0487 M.d, A2), so
any core that has it runs `aarch64-sha2` instead.

## Armv8-A SHA-2 instructions

The single-way kernels inline a block's rounds into the loop of
`_compress_blocks`. The loop calls nothing and touches no stack. The state
is loaded into vector registers once per call and stored once at the end,
not per block; inside the loop the only memory accesses are 128-bit loads of
the message and the constants, at a base register plus an immediate.

A SHA-256 block is 122 instructions: 16 each of SHA256H and SHA256H2, 12
each of SHA256SU0 and SHA256SU1, 18 vector ADD, 18 MOV, 20 loads, 4 REV32
and the loop. Sixteen of the MOVs copy `abcd`, which SHA256H2 needs after
SHA256H has overwritten it; two save the state for the feed-forward. Ten
vector registers. A SHA-512 block is 486 instructions, 152 of them EXT: 40
swap the halves of $W + K$, 80 build the $[f; g]$ and $[d; e]$ operands and
32 the SHA512SU1 operand. Twenty vector registers, and only the four state
saves as copies.

The multi-way kernels interleave two lanes, since one lane's rounds are a
chain of dependent SHA256H/H2 (SHA512H/H2). The 8-way SHA-256 kernel names
23 vector registers and has no stack references. The 4-way SHA-512 kernel
needs 28, and the eight saved state vectors no longer fit: they go to the
stack once per block. Four lanes per group also allocate, at 27 registers,
but ran 1 to 3% slower than two on the M4.

## SHA-NI

One lane's rounds are a chain of 32 dependent SHA256RNDS2, so a single-way
block costs that chain's latency. `_compress_blocks` keeps the state in two
xmm registers across all blocks: storing and reloading `h` per block would
put the layout shuffles and a store-forwarding delay on the chain, about a
tenth of a block on Zen 4. It uses 10 xmm registers and no stack.
`_sha256_compress` reads the block buffer with 64-bit loads, because
`fill.jinc` writes that buffer in 64-bit words and bytes, and a 128-bit load
spanning two stores waits for both to reach the cache.

The 8-way kernel runs lanes in pairs, which makes SHA256RNDS2 throughput the
limit: on Zen 4 a pair takes about as long per block as one lane. Fifteen
xmm registers; the four state values saved for the feed-forward are its only
stack traffic, and its copies are one $W + K$ into XMM0 per lane and group
of four rounds. Four lanes per group were 1 to 4% faster from 1 KiB per lane
and 4 to 15% slower at 256 bytes and below, so the kernel keeps two.

The SHA instructions have only legacy-SSE encodings and the AVX2 kernels
return with dirty upper ymm halves. No export runs both, and the C layer
issues VZEROALL after every export of an AVX unit.

## AVX2 single-way

The design follows OpenSSL's `sha512_block_data_order_avx2`: the schedule of
two blocks in ymm registers, $W_t + K_t$ of both stored to the stack, the
rounds in general registers with RORX and ANDN. A round is 6 RORX, 1 ANDN, 2
AND, 6 XOR, 7 ADD and 2 MOV. Thirteen general registers and the flag; `h` is
stored before a block's rounds and reloaded after them, the only spill.

Instruction order decided the speed on Zen 4, measured against OpenSSL 4.0.3
at 1 MiB in one process, alternating. With $\Sigma_0(a)$ added at the end of
its own round and each schedule step issued as one run of vector
instructions, SHA-512 ran at 0.88 to 0.90 of OpenSSL's speed. Adding
$\Sigma_0(a)$ at the start of the next round brought it to 0.95, and weaving
each schedule step between the scalar instructions of the rounds to 0.97 to
1.00; SHA-256 with both changes runs at 0.99 to 1.00. Loops of 16 rounds
instead of full unrolling, a third of the code, were not faster.

## AVX2 multi-way

`_sha256_x8_block` and `_sha512_x4_block` are about 1,530 instructions each:
rounds 0 to 15 unrolled, then three (SHA-512: four) passes of a loop over 16
unrolled rounds. Fully unrolled, they were as fast on long messages and 4%
(SHA-256) to 11% (SHA-512) slower on one-block messages on a Ryzen 7 7700X,
where the kernel shares the instruction cache with the rest of the call.
They use 14 ymm registers for SHA-256 and 15 for SHA-512, no copies, and no
stack traffic besides the schedule window. Rotations are two shifts and an
XOR, except $\sigma_0$'s rotation by 8 in SHA-512, which is one VPSHUFB; Maj
reuses the previous round's $a \oplus b$. Those two save 5% of the vector
operations of a SHA-512 block and 2% of a SHA-256 block. `_compress_lanes`
loads each lane's rows from the caller's memory straight into the transpose.

These units clear the stack with 256-bit stores. On the 7700X a loop of
64-bit stores over the 1.5 KiB frame of a one-shot multi-way export cost
about 65 ns, a fifth of a one-block call; 256-bit stores cost about 8 ns.
The zeroing VPXOR on ymm registers is AVX2, which is why every family of
both units needs AVX2.

## Values across calls

Kernels are local functions, and the register allocator sees caller and
callee together: a value live across a call keeps a register the callee does
not write, or the program is rejected. Where the shared code moves a value
through the stack instead (`#spill`, `#unspill`), the reloaded value is
transient and is protected before it is used as an address, bound or length.
Since a protect costs a CSDB on AArch64 (patch 0034 shares one only between
adjacent protects), absorb hands all its whole blocks to one
`_compress_blocks` call and protects its own state once per call. Inside
that call the portable kernels still spill and protect `p` and `n` per
block, the A64 scalar, Armv8-A SHA-2 and SHA-NI kernels keep them in
registers, and the AVX2 single-way kernels spill them once per pair of
blocks.
