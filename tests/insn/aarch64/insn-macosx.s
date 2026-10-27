	.global	_insn_trn2_2u64
	.global	_insn_trn1_2u64
	.global	_insn_trn2_4u32
	.global	_insn_trn1_4u32
	.global	_insn_add_2u64
	.global	_insn_add_4u32
	.global	_insn_rev64_16u8
	.global	_insn_rev32_16u8
	.global	_insn_ext8_same
	.global	_insn_ext8
	.global	_insn_sha512su1
	.global	_insn_sha512su0
	.global	_insn_sha512h2
	.global	_insn_sha512h
	.global	_insn_sha256su1
	.global	_insn_sha256su0
	.global	_insn_sha256h2
	.global	_insn_sha256h
	.p2align	2
_insn_trn2_2u64:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	trn2	v0.2d, v0.2d, v1.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_trn1_2u64:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	trn1	v0.2d, v0.2d, v1.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_trn2_4u32:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	trn2	v0.4s, v0.4s, v1.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_trn1_4u32:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	trn1	v0.4s, v0.4s, v1.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_add_2u64:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	add 	v0.2d, v0.2d, v1.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_add_4u32:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	add 	v0.4s, v0.4s, v1.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_rev64_16u8:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	rev64	v0.16b, v0.16b
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_rev32_16u8:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	rev32	v0.16b, v0.16b
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_ext8_same:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ext 	v0.16b, v0.16b, v0.16b, #8
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_ext8:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ext 	v0.16b, v0.16b, v1.16b, #8
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha512su1:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha512su1	v0.2d, v1.2d, v2.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha512su0:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	sha512su0	v0.2d, v1.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha512h2:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha512h2	q0, q1, v2.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha512h:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha512h	q0, q1, v2.2d
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha256su1:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha256su1	v0.4s, v1.4s, v2.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha256su0:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	sha256su0	v0.4s, v1.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha256h2:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha256h2	q0, q1, v2.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.p2align	2
_insn_sha256h:
	str 	x30, [sp, #-16]!
	ldr 	q0, [x1]
	ldr 	q1, [x1, #16]
	ldr 	q2, [x1, #32]
	sha256h	q0, q1, v2.4s
	str 	q0, [x0]
	ldr 	x30, [sp], #16
	ret
	.ident	"Jasmin Compiler @VERSION@"
