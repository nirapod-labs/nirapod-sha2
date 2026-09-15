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
#     make ct          jasmin-ct and jasmin-ct --sct on every unit of the
#                      architectures in CT_ARCHES (default: both), with the
#                      check that every export of src/nirapod_sha2.jinc was
#                      typed by both
#     make asm-policy  properties of the AArch64 assembly the C layer relies
#                      on (x18 unused)
#     make clean       remove build/
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
#     unit               Sha2Kernel              Sha2KernelX
#     aarch64-portable   src                     src
#     aarch64-scalar     src/aarch64/scalar      src
#     aarch64-sha2       src/aarch64/sha2        src
#     x86_64-portable    src                     src
#     x86_64-shani       src/x86_64/shani        src
#     x86_64-avx2        src                     src/x86_64/avx2
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

S1_scalar := $(SRC)/aarch64/scalar
S1_sha2   := $(SRC)/aarch64/sha2
S1_shani  := $(SRC)/x86_64/shani
SX_avx2   := $(SRC)/x86_64/avx2

unit_arch    = $(word 1,$(subst -, ,$(1)))
unit_variant = $(word 2,$(subst -, ,$(1)))
unit_jarch   = $(JARCH_$(call unit_arch,$(1)))
unit_roots   = -I Hash=$(SRC) -I HashWord=$(SRC)/$(call unit_arch,$(1)) \
               -I Sha2Kernel=$(or $(S1_$(call unit_variant,$(1))),$(SRC)) \
               -I Sha2KernelX=$(or $(SX_$(call unit_variant,$(1))),$(SRC))

# -stack-zero: each export clears the stack it used before it returns
# (src/nirapod_sha2.jinc, "Stack"). $(1) is the unit, $(2) the system.
unit_flags = -arch $(call unit_jarch,$(1)) -system $(2) \
             -stack-zero loop -stack-zero-size u64
unit_asm   = $(BUILD)/asm/$(SYSTEM_$(call unit_arch,$(1)))/$(1).s

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

.PHONY: all asm asm-all asm-policy ct check clean

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

$(OUT)/obj/%.o: $(BUILD)/asm/$(HOST_SYSTEM)/%.s
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

# The AArch64 units must leave x18 alone: macOS reserves it, and clear.c
# does not clear it. A use of x18 or w18 anywhere in their assembly fails.
asm-policy: $(foreach u,$(filter $(UNITS_aarch64),$(UNITS_$(HOST_ARCH))),$(BUILD)/asm/$(HOST_SYSTEM)/$(u).s)
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
CT_ARCHES ?= aarch64 x86_64
CT_UNITS  := $(foreach a,$(CT_ARCHES),$(UNITS_$(a)))

$(BUILD)/ct/%.ok: $(BUILD)/units/%.jazz $(JASMIN_DEPS) $(TESTS)/ct/exports.sh
	@mkdir -p $(@D)
	$(JASMIN_CT) --arch $(call unit_jarch,$*) --print $(call unit_roots,$*) $< > $(BUILD)/ct/$*.ct.log 2>&1
	$(JASMIN_CT) --arch $(call unit_jarch,$*) --sct $(call unit_roots,$*) $< > $(BUILD)/ct/$*.sct.log 2>&1
	sh $(TESTS)/ct/exports.sh $(SRC)/nirapod_sha2.jinc nirapod_sha2_jz_$(subst -,_,$*) \
	  $(BUILD)/ct/$*.ct.log $(BUILD)/ct/$*.sct.log
	@touch $@

ct: $(addprefix $(BUILD)/ct/,$(addsuffix .ok,$(CT_UNITS)))
	@echo "ct: jasmin-ct and jasmin-ct --sct PASS on $(words $(CT_UNITS)) units ($(CT_UNITS))"

clean:
	rm -rf $(BUILD)
