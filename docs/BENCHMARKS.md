# Benchmarks

$R$ is this library's latency divided by that of the fastest baseline for
the same function, mode and length, measured in the same pass; below 1 we
are faster. Measured in October 2026 on two machines. Absolute times are
never compared across them.

## Method

The baselines are the builds of `toolchain/baselines/PIN`: OpenSSL 4.0.3,
AWS-LC 5.11.0, BoringSSL `99b9d64ec023`, HACL* 0.7.2 and, for the multi-way
rows on x86-64, the AVX2 multi-buffer SHA-2 of the SPHINCS+ reference code.
Each runs on its default code path, which uses the SHA instructions on both
machines. Every output is checked against Python's `hashlib` before it is
timed.

A sample times a batch of calls calibrated to 5 ms. After 3 warm-up batches,
25 samples are kept and the median reported, with `CLOCK_MONOTONIC_RAW`.
Each library, and each of our kernels, ran as a 40 s run of its own,
interleaved with the others, starting order rotated over 3 passes. $R$ is
computed per pass, and the figure given is the median of the three; a range
is the range of that median over the lengths of a class. Neither machine
gives user code a core-cycle counter, so throughput is in ns per byte.

Short is 0 to 256 bytes, medium 1 to 16 KiB, long 1 MiB. One-shot is a
single call; incremental is one init, one update and one final.

`bench/` builds one driver per library, and `bench/table.py` turns their CSV
into tables. The passes above were run by invoking the drivers in rotated
order by hand; there is no script for that in `bench/` yet.

```sh
make -C bench BASELINE_ROOT=$SHA2_BASELINES
build/bench/bin/nirapod-bench --full --csv ours.csv
build/bench/bin/openssl-bench --full --csv openssl.csv
python3 bench/table.py --run full ours.csv openssl.csv
```

## Apple M4, macOS

4 performance and 6 efficiency cores, 16 GiB, macOS 27.0, Apple clang
21.0.0, on mains power; FEAT_SHA256, FEAT_SHA512, FEAT_DIT and FEAT_SB. The
public functions run `aarch64-sha2`. The machine was not quiet: with a load
average around 2, absolute times moved by up to 7% between passes, so a few
percent either way is noise here.

| $R$                 | SHA-224, SHA-256 | SHA-384, SHA-512, SHA-512/t |
| ------------------- | ---------------: | --------------------------: |
| short, one-shot     |     1.63 to 2.60 |                1.11 to 1.69 |
| short, incremental  |     2.49 to 5.46 |                1.68 to 2.83 |
| medium, one-shot    |     1.04 to 1.19 |                1.00 to 1.10 |
| medium, incremental |     1.06 to 1.45 |                1.02 to 1.26 |
| long, one-shot      |     1.03 to 1.04 |                1.00 to 1.03 |
| long, incremental   |     1.04 to 1.05 |                1.00 to 1.05 |

HMAC, $R$ one-shot / incremental, from an earlier campaign on the same
kernel when the machine was busier:

| $R$                        |        32 B |       1 KiB |       1 MiB |
| -------------------------- | ----------: | ----------: | ----------: |
| HMAC-SHA-256, 32-byte key  | 1.31 / 3.26 | 1.08 / 1.48 | 1.03 / 1.03 |
| HMAC-SHA-256, 131-byte key | 1.24 / 2.30 | 1.09 / 1.40 | 1.02 / 1.02 |
| HMAC-SHA-512, 32-byte key  | 1.14 / 1.73 | 1.04 / 1.24 | 1.03 / 1.02 |
| HMAC-SHA-512, 131-byte key | 1.11 / 1.54 | 1.04 / 1.23 | 1.01 / 1.02 |

Multi-way, against eight (four) one-shot calls of the fastest baseline,
which here beat HACL*'s 128-bit 8-way SHA-256:

| $R$              |  below 1 KiB |  1 to 16 KiB | 1 MiB |
| ---------------- | -----------: | -----------: | ----: |
| SHA-256, 8 lanes | 1.23 to 1.77 | 0.81 to 0.90 |  0.80 |
| SHA-512, 4 lanes | 1.00 to 1.30 | 0.73 to 0.81 |  0.72 |

At 1 MiB one-shot SHA-256 runs at 0.32 ns/B and SHA-512 at 0.58. The table
puts us up to 4% behind there (341.9 against 322.0 µs for SHA-256), but our
own passes spread by 7.2% on that row, an earlier campaign found 0.98 to
1.01, and an interleaved probe gave 349.7 against 352.7 µs. We read it as
parity within what this machine resolves.

## AMD Ryzen 7 7700X, Linux

Zen 4, 8 cores, 16 threads; Linux 6.18 under WSL2, 19 GiB for the VM, GCC
13.3. SHA-NI, AVX2, BMI2 and AVX-512 (unused). Each run was pinned to one
core with `taskset` and started with the one-minute load below 1.0; pass
medians agree within 1% on almost every row. The public functions run
`x86_64-shani` for SHA-256 and 8-way, `x86_64-avx2` for SHA-512 and 4-way.
Zen 4 has no DOITM and the library writes no mode register on x86-64, so the
short rows carry no mode switch.

| $R$                 | SHA-224, SHA-256 | SHA-384, SHA-512, SHA-512/t |
| ------------------- | ---------------: | --------------------------: |
| short, one-shot     |     1.06 to 1.33 |                0.79 to 1.03 |
| short, incremental  |     1.26 to 2.02 |                0.90 to 1.25 |
| medium, one-shot    |     1.00 to 1.02 |                1.01 to 1.03 |
| medium, incremental |     1.00 to 1.10 |                1.01 to 1.11 |
| long, one-shot      |             1.00 |                        1.01 |
| long, incremental   |             1.00 |                        1.01 |

| $R$, one-shot / incremental |        32 B |       1 KiB |       1 MiB |
| --------------------------- | ----------: | ----------: | ----------: |
| HMAC-SHA-256, 32-byte key   | 1.08 / 1.37 | 1.03 / 1.13 | 1.00 / 0.99 |
| HMAC-SHA-256, 131-byte key  | 1.00 / 1.16 | 1.01 / 1.10 | 1.00 / 1.00 |
| HMAC-SHA-512, 32-byte key   | 0.75 / 0.82 | 0.88 / 1.05 | 1.01 / 1.01 |
| HMAC-SHA-512, 131-byte key  | 0.80 / 0.88 | 0.92 / 1.02 | 1.01 / 1.01 |

Multi-way is compared with the fastest baseline doing the same work at each
length: HACL*'s AVX2 8-way and 4-way code, eight one-shot SHA-NI calls of
BoringSSL or AWS-LC, or the SPHINCS+ AVX2 code (`sha2-avx2/` at
`7ec789ace687`, `-O3 -mavx2`). SHA-256 on 8 lanes is at $R$ 0.56 to 0.79
below 1 KiB and 0.50 to 0.52 above. For SHA-512 on 4 lanes, SPHINCS+ is the
fastest baseline at every length:

| $R$ against SPHINCS+ |   0 to 111 B | 112 to 200 B | 256 B | 1 KiB to 1 MiB |
| -------------------- | -----------: | -----------: | ----: | -------------: |
| SHA-256, 8 lanes     | 0.65 to 0.76 | 0.58 to 0.70 |  0.54 |   0.47 to 0.50 |
| SHA-512, 4 lanes     | 1.04 to 1.06 | 1.01 to 1.02 |  0.98 |   0.93 to 0.95 |

SPHINCS+ has no plain 4-way SHA-512, so its seeded function was given the
FIPS 180-4 initial value and a zero byte count; every output matched
`hashlib`. It makes no constant-time or speculation claim and runs without a
fence or register clearing.

ns per byte at 1 MiB, one-shot:

|                            | nirapod-sha2 | OpenSSL | AWS-LC | BoringSSL | HACL* |
| -------------------------- | -----------: | ------: | -----: | --------: | ----: |
| SHA-256                    |        0.382 |   0.384 |  0.383 |     0.383 | 0.381 |
| SHA-512                    |        0.785 |   0.776 |  1.106 |     1.101 | 1.262 |
| SHA-256, 8 lanes, per byte |        0.192 |         |        |           | 0.464 |
| SHA-512, 4 lanes, per byte |        0.445 |         |        |           | 0.573 |

HACL*'s SHA-256 figure is EverCrypt dispatching to SHA-NI.

## Short messages

Separate interleaved probes on the M4, outside the campaign above, timed
SHA-256 of 0 bytes at 75.7 ns here and 27.1 ns in BoringSSL, a ratio of 2.8
where the campaign's short rows reach 2.60. The parts:

| Part                                |    Cost |
| ----------------------------------- | ------: |
| setting and restoring PSTATE.DIT    | 24.6 ns |
| `dsb sy; isb` at the export's entry | 16.5 ns |
| register clearing                   |  2.0 ns |
| argument checks and dispatch        |   ~2 ns |
| the export without its fence        | 27.5 ns |

The hashing itself is level with BoringSSL. The DIT writes and the fence
together cost more than BoringSSL's whole call, and both are part of the
guarantee, so the library keeps them, and on one-block messages they alone
keep $R$ above 1. A caller that holds DIT itself saves the 24.6 ns
([API](API.md#dit-and-short-messages)). Incremental rows suffer most, since
init, update and final each pay the fence and the writes.

On the 7700X there is no DIT write and the overhead is about 10 ns per call
(47.8 against 38.1 ns at 0 bytes). We expect the fence, register clearing
and argument checks behind it, but have not measured them apart.

Two costs were measured and left as they are:

* The multi-way front ends load and protect each lane pointer in turn,
  between other loads, so patch 0034 cannot share one CSDB among them: 145
  of 375 ns for 8-way SHA-256 at 0 bytes, 89 of 383 ns for 4-way SHA-512.
  Loading all lane pointers first would need one CSDB, but the change
  touches proved source and every result above it.
* With FEAT_SB, `sb` could replace `dsb sy; isb` as the entry fence (7.45
  against 15.2 ns). The compiler chooses the fence per target, not per CPU,
  so this would take a second set of AArch64 units, each with its own checks
  and proofs.

## Gaps against R ≤ 1

Every class where some row is above 1:

* Short messages on both machines, one-shot and incremental, and HMAC at 32
  bytes. The fixed cost per call above explains the M4; on the 7700X the
  parts are not measured.
* Medium messages: on the M4, up to 1.19 one-shot and 1.45 incremental for
  SHA-256, and HMAC at 1 KiB up to 1.09 one-shot and 1.48 incremental; on
  the 7700X, up to 1.03 one-shot and 1.13 incremental, HMAC included. The
  fixed cost per call is still a large part of the time at these lengths.
* Long messages: on the M4 up to 1.05, within what that machine resolves
  (see above); on the 7700X, SHA-512 and HMAC-SHA-512 at 1.01, 0.785 against
  OpenSSL's 0.776 ns/B, a pass range of 1.009 to 1.013 that does not cross
  1, cause unknown.
* Multi-way on the M4 below 1 KiB, 1.23 to 1.77 for 8-way SHA-256 and up to
  1.30 for 4-way SHA-512, against eight (four) one-shot calls on the SHA-2
  instructions.
* 4-way SHA-512 on the 7700X below 256 bytes, up to 1.06 against SPHINCS+
  (284.5 against 273.5 ns at 0 bytes). The per-call fence and clearing are
  the likely cause; that is a guess, not a measurement.

## Other kernels

Through the testing library, not the public functions.

On the 7700X, `x86_64-avx2` runs SHA-256 at 1.23 ns/B, $R$ 3.2 against
baselines that use SHA-NI. `x86_64-portable` gives $R$ 4.9 for SHA-256 and
1.5 for SHA-512.

On the M4, `aarch64-portable` gives $R$ 6.35 to 11.55 for the SHA-256 family
and 2.08 to 3.84 for SHA-512. `aarch64-scalar`, against OpenSSL and AWS-LC
forced off the SHA-2 instructions (`OPENSSL_armcap=0`) over 2 passes: $R$
1.08 for SHA-256 and 1.11 for SHA-512 at 1 MiB, 1.14 to 1.56 short one-shot,
1.08 to 1.46 HMAC, 0.40 to 0.61 for its Advanced SIMD 8-way SHA-256, 1.10 to
1.30 for 4-way SHA-512. Its round function keeps the schedule in memory (344
loads and stores per SHA-256 block, 440 per SHA-512,
[KERNELS](KERNELS.md#a64-scalar)) where the OpenSSL and AWS-LC integer code
keeps the window in registers. We think that is the gap; it is not measured.

## Stack and code size

Bytes of stack below the call site on the M4, C function included, by the
paint-and-scan method of `bench --stack`:

| Operation        | `aarch64-sha2` | public | OpenSSL |  AWS-LC | BoringSSL |   HACL* |
| ---------------- | -------------: | -----: | ------: | ------: | --------: | ------: |
| SHA-256          |            272 |    336 |     792 |     336 |   496–512 | 512–576 |
| SHA-512          |            368 |    496 |     792 | 336–608 |   496–512 |     744 |
| HMAC-SHA-256     |            768 |    720 |    1240 |    1888 |      1424 | 784–800 |
| HMAC-SHA-512     |           1184 |   1200 |    1240 |    1888 |      1424 |    1224 |
| SHA-256, 8 lanes |           1392 |   1552 |         |         |           |    1168 |
| SHA-512, 4 lanes |           1600 |   1648 |         |         |           |         |

Code and read-only data on macOS: `aarch64-portable` 101,148 bytes,
`aarch64-scalar` 78,816, `aarch64-sha2` 62,108, and the C layer about 10.8
KB without the testing interface. OpenSSL's SHA-2 and HMAC objects come to
18,308 bytes and the SHA-2 assembly of AWS-LC and BoringSSL to 10,852. Each
Jasmin export inlines its whole path, which is most of the difference.
