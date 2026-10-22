- The benchmarks compare the 8-way SHA-256 and 4-way SHA-512 on x86-64
  with the AVX2 multi-buffer SHA-2 of the SPHINCS+ reference code
  (`sphincs-bench`, pinned in `toolchain/baselines/PIN`), as well as with
  eight or four one-shot calls of each baseline. AArch64 has no such
  baseline.
