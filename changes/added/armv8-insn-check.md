- The EasyCrypt models of the Armv8-A SHA-2 and Advanced SIMD
  instructions the `aarch64-sha2` kernels use are checked against an
  Apple M4: 18 instructions, 5,292 vectors proved by evaluation, 86
  negative controls rejected (`tests/insn/aarch64`, CI jobs `insn` and
  `insn-vectors`). The models stay in the trusted base; the AVX2 and
  BMI1/BMI2 models are still not tested.
