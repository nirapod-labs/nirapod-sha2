# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# Makefile
# ========
#
# Build of the library and its checks. GNU make 3.81 or later.
#
#     make             build/<host>/lib/libnirapod_sha2.a and
#                      build/<host>/lib/libnirapod_sha2_testing.a
#     make check       the symbol check of libnirapod_sha2.a (with its
#                      negative control), the assembly policy, the smoke
#                      tests on this host, through the testing library and
#                      through the production library, and the DIT test
#     make asm         assembly of the units of ARCH (default: the host's);
#                      SYSTEM_aarch64=linux gives Linux AArch64 assembly
#     make asm-all     assembly of the units of both architectures
#     make ct          jasmin-ct and jasmin-ct --sct, both with --doit, on
#                      every unit of the architectures in CT_ARCHES
#                      (default: the host's, ARCH), with the check that
#                      every export of src/nirapod_sha2.jinc was typed by
#                      both, and on the array test unit of those
#                      architectures
#     make array-test  tests/array/array.c against the library, through
#                      the array test unit (src/*_ASIZE.jinc instantiated)
#     make asm-policy  properties of the AArch64 assembly the C layer relies
#                      on (x18 unused)
#     make extract     the EasyCrypt models of every unit (normal and
#                      safety) into build/extract/models; with
#                      check-extraction, extraction-identity and
#                      extraction-control, the checks on them (see
#                      "EasyCrypt models" below)
#     make insn-check  the EasyCrypt models of the host's instructions
#                      against this processor (see "Instruction models")
#     make clean       remove build/
#
# Assembly comes from the Jasmin sources, compiled by JASMINC.
#
# <host> is <arch>-<system>: aarch64-macosx, aarch64-linux or
# x86_64-linux. Assembly for the other architecture needs no target
# hardware; objects, libraries and tests are made for the host only.
#
# Tools: JASMINC and JASMIN_CT must be the Jasmin build that
# toolchain/build.sh makes from the pins under toolchain/. CC must accept
# C99.

.DEFAULT_GOAL := all

JASMINC   ?= jasminc
JASMIN_CT ?= jasmin-ct
CC        ?= cc
AR        ?= ar
LD        ?= ld
OBJCOPY   ?= objcopy
NM        ?= nm

SRC     := src
CAPI    := capi
INCLUDE := include
TESTS   := tests
BUILD   ?= build

# --------------------------------------------------------------------
# Host
# --------------------------------------------------------------------

HOST_MACHINE := $(shell uname -m)
HOST_KERNEL  := $(shell uname -s)

ifneq ($(filter arm64 aarch64,$(HOST_MACHINE)),)
HOST_ARCH := aarch64
else ifeq ($(HOST_MACHINE),x86_64)
HOST_ARCH := x86_64
else
$(error unsupported machine $(HOST_MACHINE))
endif

ifeq ($(HOST_KERNEL),Darwin)
HOST_SYSTEM := macosx
FORMAT      := macho
else ifeq ($(HOST_KERNEL),Linux)
HOST_SYSTEM := linux
FORMAT      := elf
else
$(error unsupported system $(HOST_KERNEL))
endif

ARCH ?= $(HOST_ARCH)
OUT  := $(BUILD)/$(HOST_ARCH)-$(HOST_SYSTEM)

# --------------------------------------------------------------------
# Units
# --------------------------------------------------------------------
#
# One unit per architecture and kernel variant. Each wraps
# src/nirapod_sha2.jinc in the namespace nirapod_sha2_jz_<arch>_<variant>,
# so every unit has the full set of exports under its own names
# (capi/jasmin.h). A unit's kernels are chosen by its include roots
# (src/README.md):
#
#     unit               Sha256Kernel        Sha512Kernel        Sha256KernelX, Sha512KernelX
#     aarch64-portable   src                 src                 src
#     aarch64-scalar     src/aarch64/scalar  src/aarch64/scalar  src/aarch64/neon, src
#     aarch64-sha2       src/aarch64/sha2    src/aarch64/sha2    src/aarch64/sha2
#     x86_64-portable    src                 src                 src
#     x86_64-shani       src/x86_64/shani    src/x86_64/avx2     src/x86_64/shani, src
#     x86_64-avx2        src/x86_64/avx2     src/x86_64/avx2     src/x86_64/avx2
#
# Hash is src and HashWord src/<arch> for every unit. The assembly of a
# unit goes to build/asm/<system>/<unit>.s. The system of each
# architecture is the one it is supported on, x86-64 Linux and AArch64 the
# host's (macosx or linux); SYSTEM_aarch64=linux on a Mac gives the Linux
# AArch64 assembly.

UNITS_aarch64 := aarch64-portable aarch64-scalar aarch64-sha2
UNITS_x86_64  := x86_64-portable x86_64-shani x86_64-avx2
ALL_UNITS     := $(UNITS_aarch64) $(UNITS_x86_64)

SYSTEM_aarch64 ?= $(HOST_SYSTEM)
SYSTEM_x86_64  ?= linux
JARCH_aarch64  := armv8a
JARCH_x86_64   := x86-64

K256_scalar := $(SRC)/aarch64/scalar
K512_scalar := $(SRC)/aarch64/scalar
X256_scalar := $(SRC)/aarch64/neon
K256_sha2   := $(SRC)/aarch64/sha2
K512_sha2   := $(SRC)/aarch64/sha2
X256_sha2   := $(SRC)/aarch64/sha2
X512_sha2   := $(SRC)/aarch64/sha2
K256_shani  := $(SRC)/x86_64/shani
X256_shani  := $(SRC)/x86_64/shani
K512_shani  := $(SRC)/x86_64/avx2
K256_avx2   := $(SRC)/x86_64/avx2
K512_avx2   := $(SRC)/x86_64/avx2
X256_avx2   := $(SRC)/x86_64/avx2
X512_avx2   := $(SRC)/x86_64/avx2

unit_arch    = $(word 1,$(subst -, ,$(1)))
unit_variant = $(word 2,$(subst -, ,$(1)))
unit_jarch   = $(JARCH_$(call unit_arch,$(1)))
unit_roots   = -I Hash=$(SRC) -I HashWord=$(SRC)/$(call unit_arch,$(1)) \
               -I Sha256Kernel=$(or $(K256_$(call unit_variant,$(1))),$(SRC)) \
               -I Sha512Kernel=$(or $(K512_$(call unit_variant,$(1))),$(SRC)) \
               -I Sha256KernelX=$(or $(X256_$(call unit_variant,$(1))),$(SRC)) \
               -I Sha512KernelX=$(or $(X512_$(call unit_variant,$(1))),$(SRC))

# Queries for the CI scripts, so that the unit list and the include roots
# are written in this file only: `make -s print-units ARCH=x86_64`,
# `make -s print-roots-x86_64-avx2`.
print-units:
	@echo $(UNITS_$(ARCH))

print-roots-%:
	@echo $(call unit_roots,$*)

# -stack-zero: each export clears the stack it used before it returns
# (src/nirapod_sha2.jinc, "Stack"). $(1) is the unit, $(2) the system.
# The clearing stores are 64-bit words, except in the units every family
# of which needs AVX2 (capi/units.c), the x86_64 shani and avx2 units: they
# clear with 256-bit stores, since the frames of their multi-way exports
# and of the AVX2 single-way kernels (W + K on the stack) are 1.5 KiB or
# more and a 64-bit store loop over them is a large share of a short call
# (src/README.md, "Kernel notes").
ZERO_shani := u256
ZERO_avx2  := u256
unit_flags = -arch $(call unit_jarch,$(1)) -system $(2) \
             -stack-zero loop -stack-zero-size $(or $(ZERO_$(call unit_variant,$(1))),u64)
unit_asm   = $(BUILD)/asm/$(SYSTEM_$(call unit_arch,$(1)))/$(1).s

ASM_ROOT := $(BUILD)

JASMIN_DEPS := $(shell find $(SRC) -name '*.jinc') Makefile

$(BUILD)/units/%.jazz: Makefile
	@mkdir -p $(@D)
	@printf 'namespace nirapod_sha2_jz_%s {\n  from Hash require "nirapod_sha2.jinc"\n}\n' \
	  $(subst -,_,$*) > $@

# The stem is <system>/<unit>; every unit file is a prerequisite, since
# make 3.81 cannot name just the one the stem selects.
UNIT_FILES := $(addprefix $(BUILD)/units/,$(addsuffix .jazz,$(ALL_UNITS)))

$(BUILD)/asm/%.s: $(UNIT_FILES) $(JASMIN_DEPS)
	@mkdir -p $(@D)
	$(JASMINC) $(call unit_flags,$(notdir $*),$(patsubst %/,%,$(dir $*))) \
	  $(call unit_roots,$(notdir $*)) -o $@ $(BUILD)/units/$(notdir $*).jazz

.PHONY: all asm asm-all asm-policy ct check clean array-test print-units dit-check residue-check

# Generated units and assembly are kept, not removed as intermediates.
.SECONDARY:
all: $(OUT)/lib/libnirapod_sha2.a $(OUT)/lib/libnirapod_sha2_testing.a

asm: $(foreach u,$(UNITS_$(ARCH)),$(call unit_asm,$(u)))
asm-all: $(foreach u,$(ALL_UNITS),$(call unit_asm,$(u)))

# The Linux assemblers accept the A64 SHA-2 mnemonics only with the
# extensions enabled (+sha2: FEAT_SHA256; +sha3: FEAT_SHA512). The option
# widens what the assembler accepts; the instructions are those of the .s
# file, and the C layer runs the sha2 unit only on CPUs with the features.
UNIT_ASFLAGS := $(if $(filter aarch64-linux,$(HOST_ARCH)-$(HOST_SYSTEM)),-march=armv8.2-a+sha2+sha3)

HOST_UNITS := $(UNITS_$(HOST_ARCH))
JOBJ := $(addprefix $(OUT)/obj/,$(addsuffix .o,$(HOST_UNITS)))

$(OUT)/obj/%.o: $(ASM_ROOT)/asm/$(HOST_SYSTEM)/%.s
	@mkdir -p $(@D)
	$(CC) $(UNIT_ASFLAGS) -c -o $@ $<

# --------------------------------------------------------------------
# C layer and libraries
# --------------------------------------------------------------------
#
#     libnirapod_sha2.a          the C objects and the host's units, linked
#                                into one relocatable object in which only
#                                the functions of include/nirapod_sha2.h
#                                stay global; every other symbol, Jasmin
#                                exports included, is made local (ld -r
#                                with an exported-symbols list on Mach-O;
#                                ld -r, then objcopy --keep-global-symbols
#                                on ELF)
#     libnirapod_sha2_testing.a  the same objects with their symbols as
#                                compiled, and capi/testing/testing.c
#                                (nirapod_sha2_testing.h); for tests only

CFLAGS ?= -O2
CWARN  := -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wmissing-prototypes \
          -Wstrict-prototypes -Wpointer-arith -Werror
CPPFLAGS += -I$(INCLUDE) -I$(CAPI) -I$(CAPI)/testing

CAPI_FILES := api clear dispatch timing units
CAPI_DEPS  := $(wildcard $(CAPI)/*.h) $(INCLUDE)/nirapod_sha2.h
COBJ       := $(addprefix $(OUT)/obj/c/,$(addsuffix .o,$(CAPI_FILES)))
TOBJ       := $(OUT)/obj/c/testing.o

$(OUT)/obj/c/%.o: $(CAPI)/%.c $(CAPI_DEPS)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) -c -o $@ $<

$(TOBJ): $(CAPI)/testing/testing.c $(CAPI)/testing/nirapod_sha2_testing.h $(CAPI_DEPS)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) -c -o $@ $<

LIB         := $(OUT)/lib/libnirapod_sha2.a
TESTING_LIB := $(OUT)/lib/libnirapod_sha2_testing.a
LIB_OBJ     := $(OUT)/obj/libnirapod_sha2.o
EXPORTS     := $(OUT)/lib/exports.txt
SYM_PREFIX  := $(if $(filter macho,$(FORMAT)),_,)
CHECK_EXPORTS := sh $(TESTS)/abi/check-exports.sh

$(EXPORTS): $(INCLUDE)/nirapod_sha2.h $(TESTS)/abi/check-exports.sh
	@mkdir -p $(@D)
	$(CHECK_EXPORTS) list $< $(SYM_PREFIX) > $@

ifeq ($(FORMAT),macho)
$(LIB_OBJ): $(COBJ) $(JOBJ) $(EXPORTS) Makefile
	$(LD) -r -o $@ $(COBJ) $(JOBJ) -exported_symbols_list $(EXPORTS)
else
$(LIB_OBJ): $(COBJ) $(JOBJ) $(EXPORTS) Makefile
	$(LD) -r -o $@.all $(COBJ) $(JOBJ)
	$(OBJCOPY) --keep-global-symbols=$(EXPORTS) $@.all $@
	rm -f $@.all
endif

$(LIB): $(LIB_OBJ)
	@mkdir -p $(@D)
	rm -f $@
	$(AR) rcs $@ $^

$(TESTING_LIB): $(COBJ) $(TOBJ) $(JOBJ)
	@mkdir -p $(@D)
	rm -f $@
	$(AR) rcs $@ $^

# Negative control of the symbol check: the production object plus one
# more global function, which the check must reject.
EXPORTS_CONTROL := $(OUT)/lib/exports-control.a

$(EXPORTS_CONTROL): $(LIB_OBJ)
	@mkdir -p $(OUT)/obj/exports-control
	printf 'int nirapod_sha2_extra(void);\nint nirapod_sha2_extra(void) { return 0; }\n' \
	  > $(OUT)/obj/exports-control/extra.c
	$(CC) -c -o $(OUT)/obj/exports-control/extra.o $(OUT)/obj/exports-control/extra.c
	rm -f $@
	$(AR) rcs $@ $(LIB_OBJ) $(OUT)/obj/exports-control/extra.o

# --------------------------------------------------------------------
# Checks
# --------------------------------------------------------------------

# Smoke tests (tests/smoke/smoke.c): built once against the testing
# library, where they also force every kernel this CPU runs, and once
# against the production library with only the public header.
SMOKE         := $(OUT)/tests/smoke
SMOKE_PUBLIC  := $(OUT)/tests/smoke-public
SMOKE_SRC     := $(TESTS)/smoke/smoke.c $(TESTS)/smoke/vectors.h

$(SMOKE): $(SMOKE_SRC) $(TESTING_LIB)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) -DSMOKE_TESTING -o $@ $(TESTS)/smoke/smoke.c $(TESTING_LIB)

$(SMOKE_PUBLIC): $(SMOKE_SRC) $(LIB)
	@mkdir -p $(@D)
	$(CC) -I$(INCLUDE) $(CWARN) $(CFLAGS) -o $@ $(TESTS)/smoke/smoke.c $(LIB)

# The data-independent timing test (tests/timing/dit.c): a call leaves the
# caller's PSTATE.DIT as it found it, set or clear. Linked with the testing
# library because it reads the feature cache through capi/internal.h. On
# x86-64 it reports NOT APPLICABLE.
DIT_TEST := $(OUT)/tests/dit

$(DIT_TEST): $(TESTS)/timing/dit.c $(TESTING_LIB)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) -o $@ $(TESTS)/timing/dit.c $(TESTING_LIB)

check: $(LIB) $(EXPORTS_CONTROL) $(SMOKE) $(SMOKE_PUBLIC) $(DIT_TEST) asm-policy
	$(CHECK_EXPORTS) check $(INCLUDE)/nirapod_sha2.h $(LIB) $(SYM_PREFIX)
	@if $(CHECK_EXPORTS) check $(INCLUDE)/nirapod_sha2.h $(EXPORTS_CONTROL) $(SYM_PREFIX) \
	    > $(OUT)/lib/exports-control.log 2>&1; then \
	  echo "check-exports negative control: the extra global symbol was not detected" >&2; exit 1; \
	else echo "check-exports negative control: rejected, as required"; fi
	$(SMOKE)
	$(SMOKE_PUBLIC)
	$(DIT_TEST)

# The DIT test alone, for the tests job (tests/timing/run.sh).
dit-check: $(DIT_TEST)
	$(DIT_TEST)

# Stack and register residue (tests/residue/residue.c): after every public
# operation, through the public functions and with each kernel built here,
# no secret is left on the stack or in a register the call may change, and
# the stack below the C frames is cleared. regs.S makes the calls and
# records the registers. Linked with the testing library to force kernels.
RESIDUE_TEST := $(OUT)/tests/residue

# The residue test paints a large local array and reads it back after a
# call. Stack clash protection (the default of some Linux compilers)
# probes each page of such an array when its frame is made, which
# overwrites the paint, so the test is built without it where the
# compiler has the option.
NO_STACK_PROBES := $(shell $(CC) -Werror -fno-stack-clash-protection -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-clash-protection)

$(RESIDUE_TEST): $(TESTS)/residue/residue.c $(TESTS)/residue/regs.S $(TESTING_LIB)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) $(NO_STACK_PROBES) -o $@ $(TESTS)/residue/residue.c \
	  $(TESTS)/residue/regs.S $(TESTING_LIB)

residue-check: $(RESIDUE_TEST)
	$(RESIDUE_TEST)

# The AArch64 units must leave x18 alone: macOS reserves it, and clear.c
# does not clear it. A use of x18 or w18 anywhere in their assembly fails.
asm-policy: $(foreach u,$(filter $(UNITS_aarch64),$(UNITS_$(HOST_ARCH))),$(ASM_ROOT)/asm/$(HOST_SYSTEM)/$(u).s)
	@for f in $^; do \
	  if grep -E -n '(^|[^a-z0-9_])[xw]18([^0-9]|$$)' $$f; then echo "asm-policy: $$f uses x18" >&2; exit 1; fi; \
	done; echo "asm-policy: PASS ($(words $^) AArch64 units, x18 unused)"

# Constant-time checks. Every unit of each architecture in CT_ARCHES is
# typed by jasmin-ct (with --print, which also lists the type of each
# export) and by jasmin-ct --sct, for its own target's analysis model and
# with its own include roots. tests/ct/exports.sh then requires every
# export of src/nirapod_sha2.jinc to appear, under the unit's namespace,
# in both logs, so an export cannot drop out of the check unnoticed. A
# type error, a checker error or a missing export fails the target.
# Logs: build/ct/<unit>.{ct,sct}.log.
CT_ARCHES ?= $(ARCH)
CT_UNITS  := $(foreach a,$(CT_ARCHES),$(UNITS_$(a)))
# --doit also requires every instruction that receives a secret to be one
# the target's description marks as data-independent in time (the Intel
# DOIT list on x86-64, the Arm DIT list on AArch64).
CT_FLAGS  ?= --doit

$(BUILD)/ct/%.ok: $(BUILD)/units/%.jazz $(JASMIN_DEPS) $(TESTS)/ct/exports.sh
	@mkdir -p $(@D)
	$(JASMIN_CT) $(CT_FLAGS) --arch $(call unit_jarch,$*) --print $(call unit_roots,$*) $< > $(BUILD)/ct/$*.ct.log 2>&1
	$(JASMIN_CT) $(CT_FLAGS) --arch $(call unit_jarch,$*) --sct $(call unit_roots,$*) $< > $(BUILD)/ct/$*.sct.log 2>&1
	sh $(TESTS)/ct/exports.sh $(SRC)/nirapod_sha2.jinc nirapod_sha2_jz_$(subst -,_,$*) \
	  $(BUILD)/ct/$*.ct.log $(BUILD)/ct/$*.sct.log
	@touch $@

ct: $(addprefix $(BUILD)/ct/,$(addsuffix .ok,$(CT_UNITS) $(addprefix array-,$(CT_ARCHES))))
	@echo "ct: jasmin-ct and jasmin-ct --sct ($(CT_FLAGS)) PASS on $(words $(CT_UNITS)) units ($(CT_UNITS)) and the array unit of $(CT_ARCHES)"

# The array instance files (src/*_ASIZE.jinc, src/README.md "Array
# instances"). Their test unit, tests/array/array.jazz, instantiates every
# one at several array sizes behind test exports. It is compiled with the
# portable kernels (build/array/<arch>-<system>.s), typed by jasmin-ct and --sct with the units (make ct), and
# linked only into the array test, never into a library.
ARRAY_JAZZ := $(TESTS)/array/array.jazz
ARRAY_ASM  := $(ASM_ROOT)/array/$(HOST_ARCH)-$(HOST_SYSTEM).s
ARRAY_OBJ  := $(OUT)/obj/array.o
ARRAY_TEST := $(OUT)/tests/array

# The stem is <arch>-<system>.
$(BUILD)/array/%.s: $(ARRAY_JAZZ) $(JASMIN_DEPS)
	@mkdir -p $(@D)
	$(JASMINC) $(call unit_flags,$(call unit_arch,$*)-portable,$(word 2,$(subst -, ,$*))) \
	  $(call unit_roots,$(call unit_arch,$*)-portable) -o $@ $(ARRAY_JAZZ)

$(ARRAY_OBJ): $(ARRAY_ASM)
	@mkdir -p $(@D)
	$(CC) $(UNIT_ASFLAGS) -c -o $@ $<

$(ARRAY_TEST): $(TESTS)/array/array.c $(ARRAY_OBJ) $(LIB)
	@mkdir -p $(@D)
	$(CC) -I$(INCLUDE) $(CWARN) $(CFLAGS) -o $@ $(TESTS)/array/array.c $(ARRAY_OBJ) $(LIB)

array-test: $(ARRAY_TEST)
	$(ARRAY_TEST)

# Typing of the array test unit for one architecture (the stem), with the
# requirement that every export of the unit was typed by both checkers.
$(BUILD)/ct/array-%.ok: $(ARRAY_JAZZ) $(JASMIN_DEPS)
	@mkdir -p $(@D)
	$(JASMIN_CT) $(CT_FLAGS) --arch $(JARCH_$*) --print $(call unit_roots,$*-portable) $(ARRAY_JAZZ) \
	  > $(BUILD)/ct/array-$*.ct.log 2>&1
	$(JASMIN_CT) $(CT_FLAGS) --arch $(JARCH_$*) --sct $(call unit_roots,$*-portable) $(ARRAY_JAZZ) \
	  > $(BUILD)/ct/array-$*.sct.log 2>&1
	@n=$$(grep -c '^ *export fn' $(ARRAY_JAZZ) || true); \
	t=$$(grep -c '^fn A[0-9]*::[a-z0-9_]* ' $(BUILD)/ct/array-$*.ct.log || true); \
	s=$$(grep -cE '^[a-z]+ A[0-9]+::[a-z0-9_]+ :' $(BUILD)/ct/array-$*.sct.log || true); \
	if [ "$$n" -eq 0 ] || [ "$$t" -lt "$$n" ] || [ "$$s" -lt "$$n" ]; then \
	  echo "array unit, $*: $$n exports, $$t typed by jasmin-ct, $$s by --sct" >&2; exit 1; fi; \
	echo "array unit, $*: jasmin-ct and --sct PASS ($$n exports)"
	@touch $@

# EasyCrypt models (tests/extraction/models.py). Each unit has a normal
# model and a safety model (jasmin2ec -m safety), extracted from an entry
# that requires src/nirapod_sha2.jinc with no namespace, under the unit's
# include roots, so a procedure has one name in every unit:
#
#     make extract              both models of every unit into EXTRACT
#                               (default build/extract/models), as
#                               <arch>/<variant>/NirapodSha2.ec,
#                               NirapodSha2Safety.ec and the array theories,
#                               and for the portable units ArraySha2.ec
#                               and ArraySha2Safety.ec, the two models of
#                               tests/array/array.jazz
#     make check-extraction     extract again and require MODELS (default
#                               proofs/extracted) to hold the same files,
#                               byte for byte: a stale, hand-edited or
#                               missing model fails
#     make extraction-identity  every procedure, global and operator outside
#                               the kernel files extracts to the same text in
#                               every unit of an architecture, in both
#                               models, and each model is the program of the
#                               namespaced unit the library is compiled from
#     make extraction-control   the negative controls of the two checks
#                               (tests/extraction/control.py): a shared
#                               procedure altered in one unit, models
#                               extracted from altered sources, a model
#                               edited by hand, and a unit given another
#                               unit's models must each be rejected
#
# models.py states what is shared, what the comparison leaves out and why.
# The identity work and its report are under build/extract/identity, the
# controls' work under build/extract/control. JASMIN2EC must be the build
# of the pinned toolchain, as JASMINC must.
JASMIN2EC ?= jasmin2ec
PYTHON    ?= python3
EXTRACT   ?= $(BUILD)/extract/models
MODELS    ?= proofs/extracted

EXTRACT_ENTRY := $(BUILD)/extract/nirapod_sha2.jazz
EXTRACT_UNITS := $(foreach u,$(ALL_UNITS),--unit '$(u):$(call unit_jarch,$(u)):$(call unit_roots,$(u))')
MODELS_PY     := $(PYTHON) -I $(TESTS)/extraction/models.py --jasmin2ec $(JASMIN2EC) \
                 --entry $(EXTRACT_ENTRY) --units $(BUILD)/units \
                 --array-entry $(TESTS)/array/array.jazz

$(EXTRACT_ENTRY): Makefile
	@mkdir -p $(@D)
	@printf 'from Hash require "nirapod_sha2.jinc"\n' > $@

.PHONY: extract check-extraction extraction-identity extraction-control

extract: $(EXTRACT_ENTRY) $(UNIT_FILES)
	$(MODELS_PY) extract --out $(EXTRACT) $(EXTRACT_UNITS)

check-extraction: $(EXTRACT_ENTRY) $(UNIT_FILES)
	$(MODELS_PY) check --models $(MODELS) $(EXTRACT_UNITS)

extraction-identity: extract
	$(MODELS_PY) identity --models $(EXTRACT) --work $(BUILD)/extract/identity $(EXTRACT_UNITS)

extraction-control: extract
	$(PYTHON) -I $(TESTS)/extraction/control.py --jasmin2ec $(JASMIN2EC) \
	  --entry $(EXTRACT_ENTRY) --units $(BUILD)/units --src $(SRC) \
	  --array-entry $(TESTS)/array/array.jazz \
	  --models $(EXTRACT) --work $(BUILD)/extract/control $(EXTRACT_UNITS)

# --------------------------------------------------------------------
# Instruction models
# --------------------------------------------------------------------
#
#     make insn-check   the EasyCrypt models of the instructions listed in
#                       tests/insn/<host arch>.insn, evaluated on inputs
#                       and results of this processor, with the negative
#                       controls (tests/insn/README.md)
#
# The table lists the x86-64 SHA-NI instructions, so the check runs on an
# x86-64 processor with SHA-NI. It needs JASMINC, JASMIN2EC and EASYCRYPT
# of the pinned toolchain. INSN_SEED and INSN_RANDOM choose the random
# vectors.
EASYCRYPT   ?= easycrypt
INSN_SEED   ?= 1
INSN_RANDOM ?= 256

.PHONY: insn-check

insn-check:
	JASMINC='$(JASMINC)' JASMIN2EC='$(JASMIN2EC)' EASYCRYPT='$(EASYCRYPT)' \
	  CC='$(CC)' PYTHON='$(PYTHON)' INSN_SEED='$(INSN_SEED)' INSN_RANDOM='$(INSN_RANDOM)' \
	  $(TESTS)/insn/check.sh $(HOST_ARCH) $(BUILD)/insn/$(HOST_ARCH)

clean:
	rm -rf $(BUILD)
