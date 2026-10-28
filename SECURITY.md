# Security policy

## Status

nirapod-sha2 is under development and has not been released. No version is
supported for production use, and none should be relied on yet. Reports are
welcome all the same, and they are handled as described below.

## Scope

In scope:

- the Jasmin sources in `src/`
- the C API in `include/` and `capi/`: argument checks, kernel selection,
  the timing mode set around each call and the register clearing after it
- the toolchain patch series in `toolchain/`, where a defect could change
  the generated code or weaken an analysis result
- a proof, analysis or test whose stated scope is wrong, or one that passes
  when it should fail

A digest or tag that differs from FIPS 180-4 or FIPS 198-1 for an input the
header accepts is a vulnerability, whatever the kernel or platform.

Timing that software can observe is in scope, including timing through the
caches and through speculative execution. Message bytes, keys, contexts,
digests and tags are treated as secret. Message and key lengths, including
the common lane length of the multi-way functions, are public: running time
depends on them by design, so a report that it does is not a vulnerability.
The constant-time checks the build runs model speculation as misprediction
of conditional branches. Other speculative variants aren't covered by those
checks, but a concrete leak through one is worth reporting.

Out of scope, with no mitigation in the library:

- fault injection of any kind, including voltage or clock glitching, laser
  and Rowhammer-style memory corruption
- physical side channels such as power, electromagnetic emanation and
  acoustics
- an attacker who can read the process's memory or registers directly
- copies the operating system makes, such as registers saved on a context
  switch, swapped pages and core dumps

The supported platforms are Linux on x86-64, Linux on AArch64 and macOS on
AArch64.

## Reporting a vulnerability

Report privately, by email to a maintainer listed in `AUTHORS`, or through
GitHub's private vulnerability reporting where the repository is hosted on
GitHub (the Security tab, then "Report a vulnerability"). Please do not open
a public issue for a suspected vulnerability.

A useful report names the revision, the architecture, the operating system
and CPU, and the kernel if you know which one ran (the testing library,
`nirapod_sha2_testing.h`, can force each one). Add a reproducer if you have
one.

We will acknowledge the report, agree a disclosure date with you, and credit
you unless you would rather not be named.
