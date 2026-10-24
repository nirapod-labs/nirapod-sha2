/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * tests/residue/regs.S
 * ====================
 *
 * The register side of the residue test (residue.c). C cannot see the
 * registers a function leaves behind: the compiler may use any of them
 * between the call and the first statement after it. These two routines
 * are written in assembly for that reason.
 *
 *     void residue_call(void (*fn)(void), const uint64_t args[6],
 *                       uint8_t dump[RESIDUE_DUMP_BYTES], unsigned mode)
 *
 *         Loads the six argument registers from args, calls fn, and
 *         before any other instruction stores every register a callee may
 *         leave changed into dump: the general registers at offset 0, one
 *         8-byte slot each, the vector registers from offset 256.
 *
 *             AArch64   x0-x17, then q0-q31 (16 bytes each); mode unused
 *             x86-64    rax, rcx, rdx, rsi, rdi, r8-r11, then by mode:
 *                       0 xmm0-xmm15 (16 bytes each, SSE stores)
 *                       1 ymm0-ymm15 (32 bytes each, AVX stores)
 *                       2 zmm0-zmm31 (64 bytes each, AVX-512 stores)
 *
 *     int residue_leak(const uint8_t *p)
 *
 *         The negative control: returns 0 with the first 8 bytes at p in
 *         a caller-saved general register (x9, rcx) and the first 16 in a
 *         caller-saved vector register (v20, xmm5).
 */

#if defined(__APPLE__)
#define SYM(x) _##x
#else
#define SYM(x) x
#endif

#if defined(__aarch64__)

    .text
    .p2align 2
    .globl SYM(residue_call)
SYM(residue_call):
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    mov     x19, x2
    mov     x16, x0
    mov     x20, x1
    ldp     x0, x1, [x20]
    ldp     x2, x3, [x20, #16]
    ldp     x4, x5, [x20, #32]
    blr     x16
    stp     x0, x1, [x19]
    stp     x2, x3, [x19, #16]
    stp     x4, x5, [x19, #32]
    stp     x6, x7, [x19, #48]
    stp     x8, x9, [x19, #64]
    stp     x10, x11, [x19, #80]
    stp     x12, x13, [x19, #96]
    stp     x14, x15, [x19, #112]
    stp     x16, x17, [x19, #128]
    add     x9, x19, #256
    stp     q0, q1, [x9]
    stp     q2, q3, [x9, #32]
    stp     q4, q5, [x9, #64]
    stp     q6, q7, [x9, #96]
    stp     q8, q9, [x9, #128]
    stp     q10, q11, [x9, #160]
    stp     q12, q13, [x9, #192]
    stp     q14, q15, [x9, #224]
    stp     q16, q17, [x9, #256]
    stp     q18, q19, [x9, #288]
    stp     q20, q21, [x9, #320]
    stp     q22, q23, [x9, #352]
    stp     q24, q25, [x9, #384]
    stp     q26, q27, [x9, #416]
    stp     q28, q29, [x9, #448]
    stp     q30, q31, [x9, #480]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret

    .p2align 2
    .globl SYM(residue_leak)
SYM(residue_leak):
    ldr     x9, [x0]
    ldr     q20, [x0]
    mov     x0, #0
    ret

#elif defined(__x86_64__)

    .text
    .p2align 4
    .globl SYM(residue_call)
SYM(residue_call):
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    pushq   %r13
    pushq   %r14
    movq    %rdx, %r12
    movl    %ecx, %r13d
    movq    %rdi, %r10
    movq    %rsi, %rax
    movq    (%rax), %rdi
    movq    8(%rax), %rsi
    movq    16(%rax), %rdx
    movq    24(%rax), %rcx
    movq    32(%rax), %r8
    movq    40(%rax), %r9
    call    *%r10
    movq    %rax, (%r12)
    movq    %rcx, 8(%r12)
    movq    %rdx, 16(%r12)
    movq    %rsi, 24(%r12)
    movq    %rdi, 32(%r12)
    movq    %r8, 40(%r12)
    movq    %r9, 48(%r12)
    movq    %r10, 56(%r12)
    movq    %r11, 64(%r12)
    leaq    256(%r12), %r14
    cmpl    $2, %r13d
    je      .Lresidue_zmm
    cmpl    $1, %r13d
    je      .Lresidue_ymm
    movdqu  %xmm0, 0(%r14)
    movdqu  %xmm1, 16(%r14)
    movdqu  %xmm2, 32(%r14)
    movdqu  %xmm3, 48(%r14)
    movdqu  %xmm4, 64(%r14)
    movdqu  %xmm5, 80(%r14)
    movdqu  %xmm6, 96(%r14)
    movdqu  %xmm7, 112(%r14)
    movdqu  %xmm8, 128(%r14)
    movdqu  %xmm9, 144(%r14)
    movdqu  %xmm10, 160(%r14)
    movdqu  %xmm11, 176(%r14)
    movdqu  %xmm12, 192(%r14)
    movdqu  %xmm13, 208(%r14)
    movdqu  %xmm14, 224(%r14)
    movdqu  %xmm15, 240(%r14)
    jmp     .Lresidue_done
.Lresidue_ymm:
    vmovdqu %ymm0, 0(%r14)
    vmovdqu %ymm1, 32(%r14)
    vmovdqu %ymm2, 64(%r14)
    vmovdqu %ymm3, 96(%r14)
    vmovdqu %ymm4, 128(%r14)
    vmovdqu %ymm5, 160(%r14)
    vmovdqu %ymm6, 192(%r14)
    vmovdqu %ymm7, 224(%r14)
    vmovdqu %ymm8, 256(%r14)
    vmovdqu %ymm9, 288(%r14)
    vmovdqu %ymm10, 320(%r14)
    vmovdqu %ymm11, 352(%r14)
    vmovdqu %ymm12, 384(%r14)
    vmovdqu %ymm13, 416(%r14)
    vmovdqu %ymm14, 448(%r14)
    vmovdqu %ymm15, 480(%r14)
    vzeroupper
    jmp     .Lresidue_done
.Lresidue_zmm:
    vmovdqu64 %zmm0, 0(%r14)
    vmovdqu64 %zmm1, 64(%r14)
    vmovdqu64 %zmm2, 128(%r14)
    vmovdqu64 %zmm3, 192(%r14)
    vmovdqu64 %zmm4, 256(%r14)
    vmovdqu64 %zmm5, 320(%r14)
    vmovdqu64 %zmm6, 384(%r14)
    vmovdqu64 %zmm7, 448(%r14)
    vmovdqu64 %zmm8, 512(%r14)
    vmovdqu64 %zmm9, 576(%r14)
    vmovdqu64 %zmm10, 640(%r14)
    vmovdqu64 %zmm11, 704(%r14)
    vmovdqu64 %zmm12, 768(%r14)
    vmovdqu64 %zmm13, 832(%r14)
    vmovdqu64 %zmm14, 896(%r14)
    vmovdqu64 %zmm15, 960(%r14)
    vmovdqu64 %zmm16, 1024(%r14)
    vmovdqu64 %zmm17, 1088(%r14)
    vmovdqu64 %zmm18, 1152(%r14)
    vmovdqu64 %zmm19, 1216(%r14)
    vmovdqu64 %zmm20, 1280(%r14)
    vmovdqu64 %zmm21, 1344(%r14)
    vmovdqu64 %zmm22, 1408(%r14)
    vmovdqu64 %zmm23, 1472(%r14)
    vmovdqu64 %zmm24, 1536(%r14)
    vmovdqu64 %zmm25, 1600(%r14)
    vmovdqu64 %zmm26, 1664(%r14)
    vmovdqu64 %zmm27, 1728(%r14)
    vmovdqu64 %zmm28, 1792(%r14)
    vmovdqu64 %zmm29, 1856(%r14)
    vmovdqu64 %zmm30, 1920(%r14)
    vmovdqu64 %zmm31, 1984(%r14)
    vzeroupper
.Lresidue_done:
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret

    .p2align 4
    .globl SYM(residue_leak)
SYM(residue_leak):
    movq    (%rdi), %rcx
    movdqu  (%rdi), %xmm5
    xorl    %eax, %eax
    ret

#else
#error "regs.S: unsupported architecture"
#endif

#if defined(__linux__) && defined(__ELF__)
    .section .note.GNU-stack, "", %progbits
#endif
