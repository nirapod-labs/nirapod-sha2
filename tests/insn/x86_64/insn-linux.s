	.att_syntax
	.text
	.p2align	5
	.global	insn_bswap_64
	.global	insn_bswap_32
	.global	insn_rorx_64_more
	.global	insn_rorx_64_2
	.global	insn_rorx_64_1
	.global	insn_rorx_32_more
	.global	insn_rorx_32_2
	.global	insn_rorx_32_1
	.global	insn_andn_64
	.global	insn_andn_32
	.global	insn_shl_4u64_more
	.global	insn_shl_4u64_3
	.global	insn_shl_4u64_2
	.global	insn_shl_4u64_1
	.global	insn_shr_4u64_more
	.global	insn_shr_4u64_4
	.global	insn_shr_4u64_3
	.global	insn_shr_4u64_2
	.global	insn_shr_4u64_1
	.global	insn_shl_8u32_more
	.global	insn_shl_8u32_3
	.global	insn_shl_8u32_2
	.global	insn_shl_8u32_1
	.global	insn_shr_8u32_more
	.global	insn_shr_8u32_3
	.global	insn_shr_8u32_2
	.global	insn_shr_8u32_1
	.global	insn_and_256
	.global	insn_xor_256
	.global	insn_add_4u64
	.global	insn_add_8u32
	.global	insn_vpunpckh_8u32
	.global	insn_vpunpckl_8u32
	.global	insn_vpunpckh_4u64
	.global	insn_vpunpckl_4u64
	.global	insn_vpshufd_256_more
	.global	insn_vpshufd_256
	.global	insn_vpalignr_256_more
	.global	insn_vpalignr_256
	.global	insn_vperm2i128_more
	.global	insn_vperm2i128
	.global	insn_vinserti128_more
	.global	insn_vinserti128
	.global	insn_vpbroadcast_2u128
	.global	insn_vpshufb_256
	.global	insn_vmov_64
	.global	insn_vpalignr_128_more
	.global	insn_vpalignr_128
	.global	insn_vpblend_8u16_more
	.global	insn_vpblend_8u16
	.global	insn_vpunpckh_4u32
	.global	insn_vpunpckl_4u32
	.global	insn_vpunpckh_2u64
	.global	insn_vpunpckl_2u64
	.global	insn_vpadd_4u32
	.global	insn_vpshufd_128_more
	.global	insn_vpshufd_128_dd
	.global	insn_vpshufd_128
	.global	insn_vpshufb_128
	.global	insn_sha256msg2
	.global	insn_sha256msg1
	.global	insn_sha256rnds2
	.type	insn_bswap_64, %function
insn_bswap_64:
	movq	(%rsi), %rax
	bswapq	%rax
	movq	%rax, (%rdi)
	ret
	.size	insn_bswap_64, .-insn_bswap_64
	.type	insn_bswap_32, %function
insn_bswap_32:
	movl	(%rsi), %eax
	bswapl	%eax
	movl	%eax, (%rdi)
	ret
	.size	insn_bswap_32, .-insn_bswap_32
	.type	insn_rorx_64_more, %function
insn_rorx_64_more:
	movq	(%rsi), %rax
	rorx	$0, %rax, %rcx
	rorx	$1, %rax, %rdx
	rorx	$63, %rax, %rax
	movq	%rcx, (%rdi)
	movq	%rdx, 32(%rdi)
	movq	%rax, 64(%rdi)
	ret
	.size	insn_rorx_64_more, .-insn_rorx_64_more
	.type	insn_rorx_64_2, %function
insn_rorx_64_2:
	movq	(%rsi), %rax
	rorx	$39, %rax, %rcx
	rorx	$41, %rax, %rdx
	movq	%rcx, (%rdi)
	movq	%rdx, 32(%rdi)
	ret
	.size	insn_rorx_64_2, .-insn_rorx_64_2
	.type	insn_rorx_64_1, %function
insn_rorx_64_1:
	movq	(%rsi), %rax
	rorx	$14, %rax, %rcx
	rorx	$18, %rax, %rdx
	rorx	$28, %rax, %rsi
	rorx	$34, %rax, %rax
	movq	%rcx, (%rdi)
	movq	%rdx, 32(%rdi)
	movq	%rsi, 64(%rdi)
	movq	%rax, 96(%rdi)
	ret
	.size	insn_rorx_64_1, .-insn_rorx_64_1
	.type	insn_rorx_32_more, %function
insn_rorx_32_more:
	movl	(%rsi), %eax
	rorx	$0, %eax, %ecx
	rorx	$1, %eax, %edx
	rorx	$31, %eax, %eax
	movl	%ecx, (%rdi)
	movl	%edx, 32(%rdi)
	movl	%eax, 64(%rdi)
	ret
	.size	insn_rorx_32_more, .-insn_rorx_32_more
	.type	insn_rorx_32_2, %function
insn_rorx_32_2:
	movl	(%rsi), %eax
	rorx	$22, %eax, %ecx
	rorx	$25, %eax, %edx
	movl	%ecx, (%rdi)
	movl	%edx, 32(%rdi)
	ret
	.size	insn_rorx_32_2, .-insn_rorx_32_2
	.type	insn_rorx_32_1, %function
insn_rorx_32_1:
	movl	(%rsi), %eax
	rorx	$2, %eax, %ecx
	rorx	$6, %eax, %edx
	rorx	$11, %eax, %esi
	rorx	$13, %eax, %eax
	movl	%ecx, (%rdi)
	movl	%edx, 32(%rdi)
	movl	%esi, 64(%rdi)
	movl	%eax, 96(%rdi)
	ret
	.size	insn_rorx_32_1, .-insn_rorx_32_1
	.type	insn_andn_64, %function
insn_andn_64:
	movq	(%rsi), %rax
	movq	32(%rsi), %rcx
	andnq	%rcx, %rax, %rax
	movq	%rax, (%rdi)
	ret
	.size	insn_andn_64, .-insn_andn_64
	.type	insn_andn_32, %function
insn_andn_32:
	movl	(%rsi), %eax
	movl	32(%rsi), %ecx
	andnl	%ecx, %eax, %eax
	movl	%eax, (%rdi)
	ret
	.size	insn_andn_32, .-insn_andn_32
	.type	insn_shl_4u64_more, %function
insn_shl_4u64_more:
	vmovdqu	(%rsi), %ymm0
	vpsllq	$0, %ymm0, %ymm1
	vpsllq	$1, %ymm0, %ymm2
	vpsllq	$32, %ymm0, %ymm3
	vpsllq	$64, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_4u64_more, .-insn_shl_4u64_more
	.type	insn_shl_4u64_3, %function
insn_shl_4u64_3:
	vmovdqu	(%rsi), %ymm0
	vpsllq	$46, %ymm0, %ymm1
	vpsllq	$50, %ymm0, %ymm2
	vpsllq	$56, %ymm0, %ymm3
	vpsllq	$63, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_4u64_3, .-insn_shl_4u64_3
	.type	insn_shl_4u64_2, %function
insn_shl_4u64_2:
	vmovdqu	(%rsi), %ymm0
	vpsllq	$30, %ymm0, %ymm1
	vpsllq	$36, %ymm0, %ymm2
	vpsllq	$42, %ymm0, %ymm3
	vpsllq	$45, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_4u64_2, .-insn_shl_4u64_2
	.type	insn_shl_4u64_1, %function
insn_shl_4u64_1:
	vmovdqu	(%rsi), %ymm0
	vpsllq	$3, %ymm0, %ymm1
	vpsllq	$7, %ymm0, %ymm2
	vpsllq	$23, %ymm0, %ymm3
	vpsllq	$25, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_4u64_1, .-insn_shl_4u64_1
	.type	insn_shr_4u64_more, %function
insn_shr_4u64_more:
	vmovdqu	(%rsi), %ymm0
	vpsrlq	$0, %ymm0, %ymm1
	vpsrlq	$32, %ymm0, %ymm2
	vpsrlq	$63, %ymm0, %ymm3
	vpsrlq	$64, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_4u64_more, .-insn_shr_4u64_more
	.type	insn_shr_4u64_4, %function
insn_shr_4u64_4:
	vmovdqu	(%rsi), %ymm0
	vpsrlq	$42, %ymm0, %ymm1
	vpsrlq	$61, %ymm0, %ymm2
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	ret
	.size	insn_shr_4u64_4, .-insn_shr_4u64_4
	.type	insn_shr_4u64_3, %function
insn_shr_4u64_3:
	vmovdqu	(%rsi), %ymm0
	vpsrlq	$28, %ymm0, %ymm1
	vpsrlq	$34, %ymm0, %ymm2
	vpsrlq	$39, %ymm0, %ymm3
	vpsrlq	$41, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_4u64_3, .-insn_shr_4u64_3
	.type	insn_shr_4u64_2, %function
insn_shr_4u64_2:
	vmovdqu	(%rsi), %ymm0
	vpsrlq	$14, %ymm0, %ymm1
	vpsrlq	$17, %ymm0, %ymm2
	vpsrlq	$18, %ymm0, %ymm3
	vpsrlq	$19, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_4u64_2, .-insn_shr_4u64_2
	.type	insn_shr_4u64_1, %function
insn_shr_4u64_1:
	vmovdqu	(%rsi), %ymm0
	vpsrlq	$1, %ymm0, %ymm1
	vpsrlq	$2, %ymm0, %ymm2
	vpsrlq	$6, %ymm0, %ymm3
	vpsrlq	$7, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_4u64_1, .-insn_shr_4u64_1
	.type	insn_shl_8u32_more, %function
insn_shl_8u32_more:
	vmovdqu	(%rsi), %ymm0
	vpslld	$0, %ymm0, %ymm1
	vpslld	$1, %ymm0, %ymm2
	vpslld	$31, %ymm0, %ymm3
	vpslld	$32, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_8u32_more, .-insn_shl_8u32_more
	.type	insn_shl_8u32_3, %function
insn_shl_8u32_3:
	vmovdqu	(%rsi), %ymm0
	vpslld	$25, %ymm0, %ymm1
	vpslld	$26, %ymm0, %ymm2
	vpslld	$30, %ymm0, %ymm3
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	ret
	.size	insn_shl_8u32_3, .-insn_shl_8u32_3
	.type	insn_shl_8u32_2, %function
insn_shl_8u32_2:
	vmovdqu	(%rsi), %ymm0
	vpslld	$14, %ymm0, %ymm1
	vpslld	$15, %ymm0, %ymm2
	vpslld	$19, %ymm0, %ymm3
	vpslld	$21, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_8u32_2, .-insn_shl_8u32_2
	.type	insn_shl_8u32_1, %function
insn_shl_8u32_1:
	vmovdqu	(%rsi), %ymm0
	vpslld	$7, %ymm0, %ymm1
	vpslld	$10, %ymm0, %ymm2
	vpslld	$11, %ymm0, %ymm3
	vpslld	$13, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shl_8u32_1, .-insn_shl_8u32_1
	.type	insn_shr_8u32_more, %function
insn_shr_8u32_more:
	vmovdqu	(%rsi), %ymm0
	vpsrld	$0, %ymm0, %ymm1
	vpsrld	$1, %ymm0, %ymm2
	vpsrld	$31, %ymm0, %ymm3
	vpsrld	$32, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_8u32_more, .-insn_shr_8u32_more
	.type	insn_shr_8u32_3, %function
insn_shr_8u32_3:
	vmovdqu	(%rsi), %ymm0
	vpsrld	$18, %ymm0, %ymm1
	vpsrld	$19, %ymm0, %ymm2
	vpsrld	$22, %ymm0, %ymm3
	vpsrld	$25, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_8u32_3, .-insn_shr_8u32_3
	.type	insn_shr_8u32_2, %function
insn_shr_8u32_2:
	vmovdqu	(%rsi), %ymm0
	vpsrld	$10, %ymm0, %ymm1
	vpsrld	$11, %ymm0, %ymm2
	vpsrld	$13, %ymm0, %ymm3
	vpsrld	$17, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_8u32_2, .-insn_shr_8u32_2
	.type	insn_shr_8u32_1, %function
insn_shr_8u32_1:
	vmovdqu	(%rsi), %ymm0
	vpsrld	$2, %ymm0, %ymm1
	vpsrld	$3, %ymm0, %ymm2
	vpsrld	$6, %ymm0, %ymm3
	vpsrld	$7, %ymm0, %ymm0
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	vmovdqu	%ymm3, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_shr_8u32_1, .-insn_shr_8u32_1
	.type	insn_and_256, %function
insn_and_256:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpand	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_and_256, .-insn_and_256
	.type	insn_xor_256, %function
insn_xor_256:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpxor	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_xor_256, .-insn_xor_256
	.type	insn_add_4u64, %function
insn_add_4u64:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpaddq	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_add_4u64, .-insn_add_4u64
	.type	insn_add_8u32, %function
insn_add_8u32:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpaddd	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_add_8u32, .-insn_add_8u32
	.type	insn_vpunpckh_8u32, %function
insn_vpunpckh_8u32:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpunpckhdq	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpunpckh_8u32, .-insn_vpunpckh_8u32
	.type	insn_vpunpckl_8u32, %function
insn_vpunpckl_8u32:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpunpckldq	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpunpckl_8u32, .-insn_vpunpckl_8u32
	.type	insn_vpunpckh_4u64, %function
insn_vpunpckh_4u64:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpunpckhqdq	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpunpckh_4u64, .-insn_vpunpckh_4u64
	.type	insn_vpunpckl_4u64, %function
insn_vpunpckl_4u64:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpunpcklqdq	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpunpckl_4u64, .-insn_vpunpckl_4u64
	.type	insn_vpshufd_256_more, %function
insn_vpshufd_256_more:
	vmovdqu	(%rsi), %ymm0
	vpshufd	$27, %ymm0, %ymm1
	vpshufd	$228, %ymm0, %ymm2
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	ret
	.size	insn_vpshufd_256_more, .-insn_vpshufd_256_more
	.type	insn_vpshufd_256, %function
insn_vpshufd_256:
	vmovdqu	(%rsi), %ymm0
	vpshufd	$80, %ymm0, %ymm1
	vpshufd	$250, %ymm0, %ymm2
	vmovdqu	%ymm1, (%rdi)
	vmovdqu	%ymm2, 32(%rdi)
	ret
	.size	insn_vpshufd_256, .-insn_vpshufd_256
	.type	insn_vpalignr_256_more, %function
insn_vpalignr_256_more:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpalignr	$0, %ymm1, %ymm0, %ymm2
	vpalignr	$13, %ymm1, %ymm0, %ymm3
	vpalignr	$16, %ymm1, %ymm0, %ymm4
	vpalignr	$31, %ymm1, %ymm0, %ymm0
	vmovdqu	%ymm2, (%rdi)
	vmovdqu	%ymm3, 32(%rdi)
	vmovdqu	%ymm4, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_vpalignr_256_more, .-insn_vpalignr_256_more
	.type	insn_vpalignr_256, %function
insn_vpalignr_256:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpalignr	$4, %ymm1, %ymm0, %ymm2
	vpalignr	$8, %ymm1, %ymm0, %ymm3
	vmovdqu	%ymm2, (%rdi)
	vmovdqu	%ymm3, 32(%rdi)
	ret
	.size	insn_vpalignr_256, .-insn_vpalignr_256
	.type	insn_vperm2i128_more, %function
insn_vperm2i128_more:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vperm2i128	$2, %ymm1, %ymm0, %ymm2
	vperm2i128	$19, %ymm1, %ymm0, %ymm3
	vperm2i128	$24, %ymm1, %ymm0, %ymm4
	vperm2i128	$131, %ymm1, %ymm0, %ymm0
	vmovdqu	%ymm2, (%rdi)
	vmovdqu	%ymm3, 32(%rdi)
	vmovdqu	%ymm4, 64(%rdi)
	vmovdqu	%ymm0, 96(%rdi)
	ret
	.size	insn_vperm2i128_more, .-insn_vperm2i128_more
	.type	insn_vperm2i128, %function
insn_vperm2i128:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vperm2i128	$32, %ymm1, %ymm0, %ymm2
	vperm2i128	$49, %ymm1, %ymm0, %ymm3
	vmovdqu	%ymm2, (%rdi)
	vmovdqu	%ymm3, 32(%rdi)
	ret
	.size	insn_vperm2i128, .-insn_vperm2i128
	.type	insn_vinserti128_more, %function
insn_vinserti128_more:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %xmm1
	vinserti128	$0, %xmm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vinserti128_more, .-insn_vinserti128_more
	.type	insn_vinserti128, %function
insn_vinserti128:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %xmm1
	vinserti128	$1, %xmm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vinserti128, .-insn_vinserti128
	.type	insn_vpbroadcast_2u128, %function
insn_vpbroadcast_2u128:
	vbroadcasti128	(%rsi), %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpbroadcast_2u128, .-insn_vpbroadcast_2u128
	.type	insn_vpshufb_256, %function
insn_vpshufb_256:
	vmovdqu	(%rsi), %ymm0
	vmovdqu	32(%rsi), %ymm1
	vpshufb	%ymm1, %ymm0, %ymm1
	vmovdqu	%ymm1, (%rdi)
	ret
	.size	insn_vpshufb_256, .-insn_vpshufb_256
	.type	insn_vmov_64, %function
insn_vmov_64:
	movq	(%rsi), %rax
	vmovq	%rax, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vmov_64, .-insn_vmov_64
	.type	insn_vpalignr_128_more, %function
insn_vpalignr_128_more:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpalignr	$0, %xmm1, %xmm0, %xmm2
	vpalignr	$15, %xmm1, %xmm0, %xmm3
	vpalignr	$16, %xmm1, %xmm0, %xmm4
	vpalignr	$31, %xmm1, %xmm0, %xmm0
	vmovdqu	%xmm2, (%rdi)
	vmovdqu	%xmm3, 32(%rdi)
	vmovdqu	%xmm4, 64(%rdi)
	vmovdqu	%xmm0, 96(%rdi)
	ret
	.size	insn_vpalignr_128_more, .-insn_vpalignr_128_more
	.type	insn_vpalignr_128, %function
insn_vpalignr_128:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpalignr	$4, %xmm1, %xmm0, %xmm2
	vpalignr	$8, %xmm1, %xmm0, %xmm3
	vmovdqu	%xmm2, (%rdi)
	vmovdqu	%xmm3, 32(%rdi)
	ret
	.size	insn_vpalignr_128, .-insn_vpalignr_128
	.type	insn_vpblend_8u16_more, %function
insn_vpblend_8u16_more:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpblendw	$0, %xmm1, %xmm0, %xmm2
	vpblendw	$255, %xmm1, %xmm0, %xmm3
	vpblendw	$90, %xmm1, %xmm0, %xmm4
	vmovdqu	%xmm2, (%rdi)
	vmovdqu	%xmm3, 32(%rdi)
	vmovdqu	%xmm4, 64(%rdi)
	ret
	.size	insn_vpblend_8u16_more, .-insn_vpblend_8u16_more
	.type	insn_vpblend_8u16, %function
insn_vpblend_8u16:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpblendw	$15, %xmm1, %xmm0, %xmm2
	vpblendw	$240, %xmm1, %xmm0, %xmm3
	vmovdqu	%xmm2, (%rdi)
	vmovdqu	%xmm3, 32(%rdi)
	ret
	.size	insn_vpblend_8u16, .-insn_vpblend_8u16
	.type	insn_vpunpckh_4u32, %function
insn_vpunpckh_4u32:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpunpckhdq	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpunpckh_4u32, .-insn_vpunpckh_4u32
	.type	insn_vpunpckl_4u32, %function
insn_vpunpckl_4u32:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpunpckldq	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpunpckl_4u32, .-insn_vpunpckl_4u32
	.type	insn_vpunpckh_2u64, %function
insn_vpunpckh_2u64:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpunpckhqdq	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpunpckh_2u64, .-insn_vpunpckh_2u64
	.type	insn_vpunpckl_2u64, %function
insn_vpunpckl_2u64:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpunpcklqdq	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpunpckl_2u64, .-insn_vpunpckl_2u64
	.type	insn_vpadd_4u32, %function
insn_vpadd_4u32:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpaddd	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpadd_4u32, .-insn_vpadd_4u32
	.type	insn_vpshufd_128_more, %function
insn_vpshufd_128_more:
	vmovdqu	(%rsi), %xmm0
	vpshufd	$0, %xmm0, %xmm1
	vpshufd	$228, %xmm0, %xmm2
	vpshufd	$57, %xmm0, %xmm3
	vmovdqu	%xmm1, (%rdi)
	vmovdqu	%xmm2, 32(%rdi)
	vmovdqu	%xmm3, 64(%rdi)
	ret
	.size	insn_vpshufd_128_more, .-insn_vpshufd_128_more
	.type	insn_vpshufd_128_dd, %function
insn_vpshufd_128_dd:
	vmovdqu	(%rsi), %xmm0
	vpshufd	$221, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpshufd_128_dd, .-insn_vpshufd_128_dd
	.type	insn_vpshufd_128, %function
insn_vpshufd_128:
	vmovdqu	(%rsi), %xmm0
	vpshufd	$14, %xmm0, %xmm1
	vpshufd	$27, %xmm0, %xmm2
	vpshufd	$177, %xmm0, %xmm3
	vpshufd	$136, %xmm0, %xmm0
	vmovdqu	%xmm1, (%rdi)
	vmovdqu	%xmm2, 32(%rdi)
	vmovdqu	%xmm3, 64(%rdi)
	vmovdqu	%xmm0, 96(%rdi)
	ret
	.size	insn_vpshufd_128, .-insn_vpshufd_128
	.type	insn_vpshufb_128, %function
insn_vpshufb_128:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	vpshufb	%xmm1, %xmm0, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_vpshufb_128, .-insn_vpshufb_128
	.type	insn_sha256msg2, %function
insn_sha256msg2:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	sha256msg2	%xmm1, %xmm0
	vmovdqu	%xmm0, (%rdi)
	ret
	.size	insn_sha256msg2, .-insn_sha256msg2
	.type	insn_sha256msg1, %function
insn_sha256msg1:
	vmovdqu	(%rsi), %xmm0
	vmovdqu	32(%rsi), %xmm1
	sha256msg1	%xmm1, %xmm0
	vmovdqu	%xmm0, (%rdi)
	ret
	.size	insn_sha256msg1, .-insn_sha256msg1
	.type	insn_sha256rnds2, %function
insn_sha256rnds2:
	vmovdqu	(%rsi), %xmm1
	vmovdqu	32(%rsi), %xmm2
	vmovdqu	64(%rsi), %xmm0
	sha256rnds2	%xmm0, %xmm2, %xmm1
	vmovdqu	%xmm1, (%rdi)
	ret
	.size	insn_sha256rnds2, .-insn_sha256rnds2
	.ident	"Jasmin Compiler @VERSION@"
	.section	".note.GNU-stack", "", %progbits
