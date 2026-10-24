# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# Makefile
# ========
#
# The benchmark harness. It builds the library through the top-level
# Makefile and links one driver per library under test.
#
#     make                this library, and the baselines under
#                         BASELINE_ROOT when it is set
#     make nirapod-bench  this library only
#     make check          verify every output of every variant, time nothing
#     make smoke          short runs, CSV in build/bench/results
#     make stack          stack use per operation, CSV in build/bench/results
#     make code-size      code size per unit, CSV in build/bench/results
#     make clean          remove build/bench
#
# BASELINE_ROOT points at an install tree of the pinned baselines:
#
#     install/openssl-4.0.3
#     install/aws-lc-5.11.0
#     install/boringssl-99b9d64
#     install/hacl-star-0.7.2
#     install/sphincsplus-7ec789a     x86-64 only
#
# The paths are a property of the host, not of the library, so they are
# not in this file. The baseline versions and revisions below are the pins
# the baselines were built at.
#
# AArch64 macOS has no user-space cycle counter. The run targets pass
# BENCH_GHZ to the driver when it is set, and the driver then labels the
# cycle columns as derived from time at that frequency. Without it the
# cycle columns are empty.

ROOT := ..
CC ?= cc

MACHINE := $(shell uname -m)
KERNEL := $(shell uname -s)

ifneq ($(filter arm64 aarch64,$(MACHINE)),)
HOST_ARCH := aarch64
else ifeq ($(MACHINE),x86_64)
HOST_ARCH := x86_64
else
$(error unsupported machine $(MACHINE))
endif

ifeq ($(KERNEL),Darwin)
HOST_SYSTEM := macosx
else ifeq ($(KERNEL),Linux)
HOST_SYSTEM := linux
else
$(error unsupported system $(KERNEL))
endif

BUILD ?= $(ROOT)/build
OUT ?= $(BUILD)/bench
LIBDIR := $(BUILD)/$(HOST_ARCH)-$(HOST_SYSTEM)
RESULTS ?= $(OUT)/results
TESTLIB := $(LIBDIR)/lib/libnirapod_sha2_testing.a
BENCH := $(OUT)/bin

BENCH_REVISION ?= $(shell git -C $(ROOT) rev-parse HEAD 2>/dev/null || echo unknown)
BENCH_VERSION ?= $(shell git -C $(ROOT) describe --always --dirty 2>/dev/null || echo unknown)

WARN := -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wmissing-prototypes \
        -Wstrict-prototypes -Wpointer-arith -Werror
CFLAGS ?= -O2
CPPFLAGS_BENCH := -I$(ROOT)/include -I$(ROOT)/capi/testing

BASELINE_ROOT ?=

OPENSSL_DIR := $(BASELINE_ROOT)/install/openssl-4.0.3
AWSL_DIR    := $(BASELINE_ROOT)/install/aws-lc-5.11.0
BORING_DIR  := $(BASELINE_ROOT)/install/boringssl-99b9d64
HACL_DIR    := $(BASELINE_ROOT)/install/hacl-star-0.7.2
SPHINCS_DIR := $(BASELINE_ROOT)/install/sphincsplus-7ec789a

OPENSSL_LIB := $(firstword $(wildcard $(OPENSSL_DIR)/lib/libcrypto.a \
                                      $(OPENSSL_DIR)/lib64/libcrypto.a))
AWSL_LIB    := $(firstword $(wildcard $(AWSL_DIR)/lib/libcrypto.a))
BORING_LIB  := $(firstword $(wildcard $(BORING_DIR)/lib/libcrypto.a))
HACL_LIB    := $(firstword $(wildcard $(HACL_DIR)/lib/libhacl_static.a))

# The SPHINCS+ multi-way code is AVX2, and toolchain/baselines/build.sh
# builds it only on x86-64. Its headers need the parameter set the archive
# was compiled with (SPHINCS_PARAMS in toolchain/baselines/PIN).
ifeq ($(HOST_ARCH),x86_64)
SPHINCS_LIB := $(firstword $(wildcard $(SPHINCS_DIR)/lib/libsphincs_sha2_avx2.a))
else
SPHINCS_LIB :=
endif
SPHINCS_PARAMS := sphincs-sha2-256f

ifeq ($(HOST_SYSTEM),macosx)
PTHREAD_LIB :=
DL_LIB      :=
CXX_LIB     := -lc++
MATH_LIB    := -lm
else
PTHREAD_LIB := -lpthread
DL_LIB      := -ldl
CXX_LIB     := -lstdc++
MATH_LIB    := -lm
endif

ifeq ($(HOST_SYSTEM),linux)
HACL_DEFS := -D_GNU_SOURCE
else
HACL_DEFS :=
endif

# Third-party headers use extensions that clang reports under -Wpedantic:
# HACL*'s headers include LowStar_Endianness.h with a different case from
# the file name, and BoringSSL's digest.h uses an anonymous union. The
# files are in the pinned baselines, not in this repository.
ifeq ($(shell $(CC) -dM -E - </dev/null 2>/dev/null | grep -c __clang__),1)
BASELINE_WARN := -Wno-nonportable-include-path -Wno-c11-extensions
else
BASELINE_WARN := -Wno-pedantic
endif

BASELINE_BINS := \
    $(if $(OPENSSL_LIB),$(BENCH)/openssl-bench) \
    $(if $(AWSL_LIB),$(BENCH)/aws-lc-bench) \
    $(if $(BORING_LIB),$(BENCH)/boringssl-bench) \
    $(if $(HACL_LIB),$(BENCH)/hacl-bench) \
    $(if $(SPHINCS_LIB),$(BENCH)/sphincs-bench)

# The pinned HACL* archive does not contain every multi-way entry point on
# every architecture: the AArch64 build here has the 4-way SHA-256
# Vec128 code and no Vec256 code. Check the archive rather than assume.
NM ?= nm
HACL_VEC256 := $(shell if [ -n "$(HACL_LIB)" ] && $(NM) -g "$(HACL_LIB)" 2>/dev/null | grep -q 'Hacl_SHA2_Vec256_sha256_8'; then echo 1; else echo 0; fi)
HACL_VEC128 := $(shell if [ -n "$(HACL_LIB)" ] && $(NM) -g "$(HACL_LIB)" 2>/dev/null | grep -q 'Hacl_SHA2_Vec128_sha256_4'; then echo 1; else echo 0; fi)

.PHONY: all clean check smoke stack code-size nirapod-bench

all: $(BENCH)/nirapod-bench $(BASELINE_BINS)

nirapod-bench: $(BENCH)/nirapod-bench

$(TESTLIB):
	$(MAKE) -C $(ROOT) all

$(OUT)/obj/bench.o: bench.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(CFLAGS) $(CPPFLAGS_BENCH) -c -o $@ bench.c

$(OUT)/obj/bench_kat.o: bench_kat.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(CFLAGS) $(CPPFLAGS_BENCH) -c -o $@ bench_kat.c

$(OUT)/obj/backend_nirapod.o: backend_nirapod.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(CFLAGS) $(CPPFLAGS_BENCH) \
	      -DBENCH_VERSION='"$(BENCH_VERSION)"' \
	      -DBENCH_REVISION='"$(BENCH_REVISION)"' \
	      -c -o $@ backend_nirapod.c

$(BENCH)/nirapod-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                        $(OUT)/obj/backend_nirapod.o $(TESTLIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_nirapod.o $(TESTLIB)

$(OUT)/obj/backend_evp_openssl.o: backend_evp.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(BASELINE_WARN) $(CFLAGS) -Wno-deprecated-declarations \
	      -DBENCH_OPENSSL -DBENCH_HAVE_SHA512_224 \
	      -DBENCH_LIBRARY='"openssl"' -DBENCH_VERSION='"4.0.3"' \
	      -DBENCH_REVISION='"af1775b60dfa141a4ad762585052cabeb9f37e9e"' \
	      -I$(OPENSSL_DIR)/include -c -o $@ backend_evp.c

$(OUT)/obj/backend_evp_awsl.o: backend_evp.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(BASELINE_WARN) $(CFLAGS) -Wno-deprecated-declarations \
	      -DBENCH_AWSLC -DBENCH_HAVE_SHA512_224 \
	      -DBENCH_LIBRARY='"aws-lc"' -DBENCH_VERSION='"5.11.0"' \
	      -DBENCH_REVISION='"fa9bc8d6f7cfb2cf849b247fb06bbbfc41ecc9d6"' \
	      -I$(AWSL_DIR)/include -c -o $@ backend_evp.c

$(OUT)/obj/backend_evp_boring.o: backend_evp.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(BASELINE_WARN) $(CFLAGS) -Wno-deprecated-declarations \
	      -DBENCH_BORINGSSL -DBENCH_LIBRARY='"boringssl"' \
	      -DBENCH_VERSION='"99b9d64"' \
	      -DBENCH_REVISION='"99b9d64ec02384c4c939f264b40e91d6cb5ca904"' \
	      -I$(BORING_DIR)/include -c -o $@ backend_evp.c

$(OUT)/obj/backend_hacl.o: backend_hacl.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(BASELINE_WARN) $(CFLAGS) $(HACL_DEFS) \
	      -DBENCH_HACL_VEC256=$(HACL_VEC256) -DBENCH_HACL_VEC128=$(HACL_VEC128) \
	      -DBENCH_VERSION='"0.7.2"' \
	      -DBENCH_REVISION='"86a0aed822bd80b03e4810e23518181f0edec5f6"' \
	      -I$(HACL_DIR)/include -I$(HACL_DIR)/include/hacl \
	      -I$(HACL_DIR)/include/krml -c -o $@ backend_hacl.c

$(OUT)/obj/backend_sphincs.o: backend_sphincs.c bench.h Makefile | $(OUT)/obj
	$(CC) $(WARN) $(BASELINE_WARN) $(CFLAGS) -DPARAMS=$(SPHINCS_PARAMS) \
	      -DBENCH_VERSION='"7ec789a"' \
	      -DBENCH_REVISION='"7ec789ace6874d875f4bb84cb61b81155398167e"' \
	      -I$(SPHINCS_DIR)/include -c -o $@ backend_sphincs.c

$(BENCH)/openssl-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                        $(OUT)/obj/backend_evp_openssl.o $(OPENSSL_LIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_evp_openssl.o $(OPENSSL_LIB) $(PTHREAD_LIB) $(DL_LIB)

$(BENCH)/aws-lc-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                       $(OUT)/obj/backend_evp_awsl.o $(AWSL_LIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_evp_awsl.o $(AWSL_LIB) $(PTHREAD_LIB) $(DL_LIB)

$(BENCH)/boringssl-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                          $(OUT)/obj/backend_evp_boring.o $(BORING_LIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_evp_boring.o $(BORING_LIB) $(CXX_LIB)

$(BENCH)/hacl-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                     $(OUT)/obj/backend_hacl.o $(HACL_LIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_hacl.o $(HACL_LIB) $(MATH_LIB)

$(BENCH)/sphincs-bench: $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
                        $(OUT)/obj/backend_sphincs.o $(SPHINCS_LIB) | $(BENCH)
	$(CC) $(CFLAGS) -o $@ $(OUT)/obj/bench.o $(OUT)/obj/bench_kat.o \
	      $(OUT)/obj/backend_sphincs.o $(SPHINCS_LIB)

$(OUT)/obj $(BENCH) $(RESULTS):
	@mkdir -p $@

check: $(BENCH)/nirapod-bench $(BASELINE_BINS)
	@set -e; for b in $(BENCH)/nirapod-bench $(BASELINE_BINS); do \
	  echo "== $$b"; "$$b" --selftest; \
	done

smoke: $(BENCH)/nirapod-bench $(BASELINE_BINS) | $(RESULTS)
	@set -e; for b in $(BENCH)/nirapod-bench $(BASELINE_BINS); do \
	  name=$$(basename $$b -bench); \
	  extra=; if [ -n "$(BENCH_GHZ)" ]; then extra="--ghz $(BENCH_GHZ)"; fi; \
	  echo "== $$name"; "$$b" --smoke $$extra --csv "$(RESULTS)/$$name-smoke.csv"; \
	done

stack: $(BENCH)/nirapod-bench $(BASELINE_BINS) | $(RESULTS)
	@set -e; for b in $(BENCH)/nirapod-bench $(BASELINE_BINS); do \
	  name=$$(basename $$b -bench); \
	  echo "== $$name"; "$$b" --stack --csv "$(RESULTS)/$$name-stack.csv"; \
	done

code-size:
	@sh code-size.sh "$(LIBDIR)" "$(RESULTS)/code-size.csv"

clean:
	rm -rf $(OUT)
