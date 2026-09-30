# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# Makefile
# ========
#
# Build and run the validation suite against the library this worktree
# built. The library is built first if it is missing.
#
#     make check
#
# The differential suite needs independent implementations. Name their
# install prefixes, each with include/openssl and lib/libcrypto.a:
#
#     make check ORACLE_OPENSSL=/opt/openssl-4.0.2 \
#                ORACLE_AWSLC=/opt/aws-lc-5.8.0
#
# Variables: VECTORS (default ../vectors), ITERATIONS, LARGE, SUITES,
# BUILD, CC. SUITES holds suite names from `make list`.

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../..)
HERE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

CC ?= cc
CFLAGS ?= -O2
BUILD ?= $(ROOT)/build

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
else ifeq ($(HOST_KERNEL),Linux)
HOST_SYSTEM := linux
else
$(error unsupported system $(HOST_KERNEL))
endif

OUT    := $(BUILD)/$(HOST_ARCH)-$(HOST_SYSTEM)
LIB    := $(OUT)/lib/libnirapod_sha2_testing.a
RUNNER := $(OUT)/tests/validation
OBJDIR := $(OUT)/obj/validation
ORACLE_BIN := $(OUT)/tests/oracles

VECTORS    ?= $(ROOT)/tests/vectors
ITERATIONS ?= 200
LARGE      ?= 1048579
SUITES     ?=

SRCS := util.c json.c oracle.c cavp.c wycheproof.c bounds.c splits.c cross.c \
        negative.c multiway.c diff.c xarch.c main.c
OBJS := $(addprefix $(OBJDIR)/,$(SRCS:.c=.o))
DEPS := $(wildcard $(HERE)/*.h) $(ROOT)/include/nirapod_sha2.h \
        $(ROOT)/capi/testing/nirapod_sha2_testing.h

CWARN := -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wmissing-prototypes \
         -Wstrict-prototypes -Wpointer-arith -Werror
CPPFLAGS += -I$(ROOT)/include -I$(ROOT)/capi -I$(ROOT)/capi/testing -I$(HERE)

# --------------------------------------------------------------------
# Oracle programs
# --------------------------------------------------------------------

ORACLE_OPENSSL ?=
ORACLE_AWSLC ?=
ORACLE_BORINGSSL ?=
ORACLE_LIBS ?= -lpthread
ifeq ($(HOST_SYSTEM),linux)
ORACLE_LIBS += -ldl
endif
ifeq ($(HOST_SYSTEM),macosx)
BORINGSSL_LIBS := $(ORACLE_LIBS) -lc++
else
BORINGSSL_LIBS := $(ORACLE_LIBS) -lstdc++
endif

ORACLE_CFLAGS := -O2 -I$(HERE)
ORACLES :=
ORACLE_ARGS :=

oracle_lib = $(firstword $(wildcard $(1)/lib/libcrypto.a $(1)/lib64/libcrypto.a \
               $(1)/lib/x86_64-linux-gnu/libcrypto.a $(1)/lib/aarch64-linux-gnu/libcrypto.a))

ifneq ($(strip $(ORACLE_OPENSSL)),)
ORACLES += $(ORACLE_BIN)/oracle-openssl
ORACLE_ARGS += --oracle $(ORACLE_BIN)/oracle-openssl
$(ORACLE_BIN)/oracle-openssl: FORCE $(HERE)/oracle-main.c $(HERE)/oracle-protocol.h
	@mkdir -p $(@D)
	$(CC) $(ORACLE_CFLAGS) -I$(ORACLE_OPENSSL)/include -o $@ $(HERE)/oracle-main.c \
	  $(call oracle_lib,$(ORACLE_OPENSSL)) $(ORACLE_LIBS)
endif

ifneq ($(strip $(ORACLE_AWSLC)),)
ORACLES += $(ORACLE_BIN)/oracle-awslc
ORACLE_ARGS += --oracle $(ORACLE_BIN)/oracle-awslc
$(ORACLE_BIN)/oracle-awslc: FORCE $(HERE)/oracle-main.c $(HERE)/oracle-protocol.h
	@mkdir -p $(@D)
	$(CC) $(ORACLE_CFLAGS) -I$(ORACLE_AWSLC)/include -o $@ $(HERE)/oracle-main.c \
	  $(call oracle_lib,$(ORACLE_AWSLC)) $(ORACLE_LIBS)
endif

ifneq ($(strip $(ORACLE_BORINGSSL)),)
ORACLES += $(ORACLE_BIN)/oracle-boringssl
ORACLE_ARGS += --oracle $(ORACLE_BIN)/oracle-boringssl
$(ORACLE_BIN)/oracle-boringssl: FORCE $(HERE)/oracle-main.c $(HERE)/oracle-protocol.h
	@mkdir -p $(@D)
	$(CC) $(ORACLE_CFLAGS) -I$(ORACLE_BORINGSSL)/include -o $@ $(HERE)/oracle-main.c \
	  $(call oracle_lib,$(ORACLE_BORINGSSL)) $(BORINGSSL_LIBS)
endif

# --------------------------------------------------------------------
# Runner
# --------------------------------------------------------------------

.PHONY: all check clean list FORCE

# The oracle binaries depend on the prefix they are linked against, which
# is a command-line variable. Rebuild them on every run: it costs a link.
FORCE:

all: $(RUNNER)

$(LIB):
	$(MAKE) -C $(ROOT)

$(OBJDIR)/%.o: $(HERE)/%.c $(DEPS)
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CWARN) $(CFLAGS) -c -o $@ $<

$(RUNNER): $(OBJS) $(LIB)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIB)

SUITE_ARGS := $(foreach s,$(SUITES),--suite $(s))

check: $(RUNNER) $(ORACLES)
	sh $(HERE)/check-vectors.sh $(VECTORS)
	$(RUNNER) --vectors $(VECTORS) --iterations $(ITERATIONS) --large $(LARGE) \
	  $(if $(strip $(ORACLES)),--require-oracle,) $(ORACLE_ARGS) $(SUITE_ARGS)

list: $(RUNNER)
	$(RUNNER) --list

clean:
	rm -rf $(OBJDIR) $(RUNNER) $(ORACLE_BIN)
