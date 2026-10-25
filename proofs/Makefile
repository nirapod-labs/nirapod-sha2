# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# proofs/Makefile
#
# Machine-checks the EasyCrypt development, once per unit of the library.
# Every target fails closed: a file that does not check, a prover that is
# missing, a timeout, a proof hole, a command that skips checking
# (tools/scan_holes.py) or a proof file that no target checks stops the run
# with a non-zero status.
#
#   make check             everything below, in this order
#   make scan-holes        fail if a checked file contains admit, admitted,
#                          pragma, exit or fail outside a comment
#   make check-constants   re-derive the FIPS 180-4 constant tables
#   make check-layout      every proof file is checked by some target, the
#                          kernel directories hold only kernel files, and
#                          no theory name occurs twice on a unit's load path
#   make check-imported    the imported crypto-specs theories
#   make check-spec        the specification files
#   make check-spec-exec   the specification evaluated on CAVP vectors
#                          (spec/validation/): the generated files equal a
#                          fresh generation, every file checks, and each
#                          negative control is rejected
#   make spec-vectors      rewrite the generated files of spec/validation/
#   make check-lib         the files that need no model, once each
#   make check-units       the files that need a model, once per unit
#   make check-unit UNIT=<unit>   one unit only
#   make check-inventory   fail unless the committed inventory of each unit
#                          equals a fresh run
#   make inventory         rewrite the inventory files
#   make print-unit UNIT=<unit>   the load path and the files of one unit
#
# Units
# -----
#
# A unit is one architecture and kernel variant of the library, with the
# include roots the top-level Makefile gives it (`make print-roots-<unit>`;
# its table is not repeated here). Each unit has a normal and a safety model
# in extracted/<arch>/<variant>/, NirapodSha2.ec and NirapodSha2Safety.ec,
# extracted from the same entry with the unit's roots by
# tests/extraction/models.py, so a procedure has the same name in every
# unit. A proof file requires a model by its theory name and finds the
# unit's copy through the load path, so one proof text is replayed on the
# model of every unit it applies to.
#
# For a tree T (correctness, safety), the files a unit checks are
#
#   T/*.ec                  the shared layers, on every unit
#   T/<arch>/*.ec           the files of the unit's architecture that need a
#                           model (they name NirapodSha2 or
#                           NirapodSha2Safety); the others are checked once
#                           by check-lib
#   T/<kernel dir>/<family files>
#                           for each kernel root of the unit, the files of
#                           that kernel's family in the proof directory of
#                           the root's source directory
#   T/units/<unit>/*.ec     the unit's own files (its kernel interface)
#
# The proof directory of a kernel root is the root's path below src/, so
# src/x86_64/shani gives T/x86_64/shani; the root src itself, where the
# base kernels live (src/*_compress.jinc), gives T/portable. A family's
# files are named by its prefix:
#
#   Sha256Kernel   SHA256_*.ec, except SHA256_X8_*.ec
#   Sha512Kernel   SHA512_*.ec, except SHA512_X4_*.ec
#   Sha256KernelX  SHA256_X8_*.ec
#   Sha512KernelX  SHA512_X4_*.ec
#
# so a unit that takes one family from a directory and another family from
# elsewhere (x86_64-shani takes SHA-512 from src/x86_64/avx2) checks only
# the first. Every directory of the unit's list that exists is on its load
# path, with spec/, the crypto-specs theories, T/lib and the model
# directory. Two files with the same theory name on one load path would make
# a `require` ambiguous; check-layout rejects that.
#
# The files that need no model, spec/, T/lib/ and the rest of T/<arch>/,
# are checked once, without any model on the load path: one that reaches a
# model through another theory fails rather than being checked against an
# arbitrary unit.
#
# Each file is compiled on its own with -no-eco. EasyCrypt does not re-check
# the proofs of a theory it loads through `require`, and a cached .eco would
# hide a stale result; compiling every file separately is what makes a
# passing run mean that every proof in the tree was checked by this run.
# Files are checked J at a time (tools/check_files.py), each in its own
# EasyCrypt process.
#
# The models are not made here. `make extract EXTRACT=proofs/extracted` at
# the top level writes them, and `make check-extraction` there (the CI job
# extraction) requires the committed ones to equal a fresh extraction.
#
# Variables: EASYCRYPT (the binary of the pinned toolchain), EC_PROVERS and
# EC_TIMEOUT (this project's proofs), IMPORTED_PROVERS and
# IMPORTED_TIMEOUT (the imported crypto-specs theories), PYTHON, J (files
# at a time), UNITS (which units to check; default all).

EASYCRYPT ?= easycrypt
PYTHON    ?= python3
J         ?= 1

CRYPTO_SPECS := ../third_party/crypto-specs
TREES        := correctness safety

# Provers and SMT timeout (seconds). Prover names carry a minimum version;
# EasyCrypt runs the lowest installed version that satisfies it, so with
# the provers of the EasyCrypt pin these select fixed binaries. The
# imported theories keep the selection recorded with their import.
EC_PROVERS       ?= -p Z3@4.16
EC_TIMEOUT       ?= 10
IMPORTED_PROVERS ?= -p CVC5@1.2 -p Z3@4.8
IMPORTED_TIMEOUT ?= 30

EC_COMMON      := -no-eco -R spec -R $(CRYPTO_SPECS)/common
OWN_FLAGS      := $(EC_COMMON) $(EC_PROVERS) -timeout $(EC_TIMEOUT)
IMPORTED_FLAGS := -no-eco -R $(CRYPTO_SPECS)/common $(IMPORTED_PROVERS) -timeout $(IMPORTED_TIMEOUT)

ec_files = $(sort $(wildcard $(addsuffix /*.ec,$(1))))

# The specification proper; spec/validation/ is checked by check-spec-exec.
SPEC_FILES     := $(shell find spec -path spec/validation -prune -o -name '*.ec' -print 2>/dev/null | LC_ALL=C sort)
EXEC_DIR       := spec/validation
EXEC_FILES     := $(sort $(wildcard $(EXEC_DIR)/*.ec))
CAVP_VECTORS   := ../tests/vectors/cavp
IMPORTED_FILES := $(shell find $(CRYPTO_SPECS)/common -name '*.ec' 2>/dev/null | LC_ALL=C sort)
TREE_FILES     := $(shell find $(TREES) -name '*.ec' 2>/dev/null | LC_ALL=C sort)

# ------------------------------------------------------------------
# Units, read from the top-level Makefile

top_query = $(shell MAKEFLAGS= $(MAKE) -s --no-print-directory -C .. $(1))

ARCHS     := aarch64 x86_64
$(foreach a,$(ARCHS),$(eval UNITS_$(a) := $(call top_query,print-units ARCH=$(a))))
ALL_UNITS := $(foreach a,$(ARCHS),$(UNITS_$(a)))
$(foreach u,$(ALL_UNITS),$(eval ROOTS_$(u) := $(call top_query,print-roots-$(u))))
UNITS     ?= $(ALL_UNITS)

ifeq ($(strip $(ALL_UNITS)),)
$(error no units: `make print-units` in the top-level directory printed nothing)
endif

FAMILIES := Sha256Kernel Sha512Kernel Sha256KernelX Sha512KernelX
FAM_IN_Sha256Kernel   := SHA256_%
FAM_OUT_Sha256Kernel  := SHA256_X8_%
FAM_IN_Sha512Kernel   := SHA512_%
FAM_OUT_Sha512Kernel  := SHA512_X4_%
FAM_IN_Sha256KernelX  := SHA256_X8_%
FAM_OUT_Sha256KernelX :=
FAM_IN_Sha512KernelX  := SHA512_X4_%
FAM_OUT_Sha512KernelX :=

unit_arch    = $(word 1,$(subst -, ,$(1)))
unit_variant = $(word 2,$(subst -, ,$(1)))
unit_model   = extracted/$(call unit_arch,$(1))/$(call unit_variant,$(1))
# The source directory of root $(2) of unit $(1), from `-I Name=dir`.
unit_root    = $(patsubst $(2)=%,%,$(filter $(2)=%,$(ROOTS_$(1))))
# The proof directory, below a tree, of a source kernel directory.
kernel_dir   = $(if $(filter src,$(1)),portable,$(patsubst src/%,%,$(1)))
# The files of family $(2) in directory $(1).
family_files = $(foreach f,$(call ec_files,$(1)),\
                 $(if $(filter $(FAM_IN_$(2)),$(notdir $(f))),\
                   $(if $(and $(FAM_OUT_$(2)),$(filter $(FAM_OUT_$(2)),$(notdir $(f)))),,$(f))))
# The kernel proof directories of unit $(1) in tree $(2), one per family.
unit_kdirs   = $(foreach fam,$(FAMILIES),$(2)/$(call kernel_dir,$(call unit_root,$(1),$(fam))))

# Files that name a model.
MODEL_FILES := $(if $(TREE_FILES),$(shell grep -lwE 'NirapodSha2|NirapodSha2Safety' $(TREE_FILES)))

arch_model_files = $(filter $(MODEL_FILES),$(call ec_files,$(addsuffix /$(1),$(TREES))))

unit_files = $(sort \
  $(call ec_files,$(TREES)) \
  $(call arch_model_files,$(call unit_arch,$(1))) \
  $(foreach t,$(TREES),$(foreach fam,$(FAMILIES),\
    $(call family_files,$(t)/$(call kernel_dir,$(call unit_root,$(1),$(fam))),$(fam)))) \
  $(call ec_files,$(addsuffix /units/$(1),$(TREES))))

unit_dirs = $(wildcard $(TREES) $(addsuffix /lib,$(TREES)) \
  $(addsuffix /$(call unit_arch,$(1)),$(TREES)) \
  $(sort $(foreach t,$(TREES),$(call unit_kdirs,$(1),$(t)))) \
  $(addsuffix /units/$(1),$(TREES))) $(call unit_model,$(1))

unit_flags = $(EC_COMMON) $(addprefix -I ,$(call unit_dirs,$(1))) \
             $(EC_PROVERS) -timeout $(EC_TIMEOUT)

# Files that need no model: T/lib and the rest of T/<arch>, once each.
LIB_DIRS   = $(wildcard $(addsuffix /lib,$(TREES)))
arch_lib_files = $(filter-out $(MODEL_FILES),$(call ec_files,$(addsuffix /$(1),$(TREES))))
lib_flags  = $(EC_COMMON) $(addprefix -I ,$(LIB_DIRS) $(wildcard $(addsuffix /$(1),$(TREES)))) \
             $(EC_PROVERS) -timeout $(EC_TIMEOUT)

# ------------------------------------------------------------------
# Proof targets

.PHONY: check scan-holes check-constants check-layout check-imported check-spec
.PHONY: check-spec-exec spec-vectors
.PHONY: check-lib check-units check-unit print-unit

check: scan-holes check-constants check-layout check-imported check-spec \
       check-spec-exec check-lib check-units check-inventory

scan-holes:
	@$(PYTHON) -I tools/scan_holes.py \
	  $(shell find spec $(TREES) extracted $(CRYPTO_SPECS) \( -name '*.ec' -o -name '*.eca' \) 2>/dev/null) \
	  && echo "scan-holes: PASS" \
	  || { echo "scan-holes: FAIL"; exit 1; }

check-constants:
	@$(PYTHON) -I tools/sha2_constants.py spec/FIPS180_SHA2.ec

# The files of every unit, the files checked once, and the files on disk
# must agree: a proof file in a directory no unit reads, or named for no
# family in a kernel directory, would otherwise never be checked.
LIB_FILES     = $(call ec_files,$(LIB_DIRS)) $(foreach a,$(ARCHS),$(call arch_lib_files,$(a)))
COVERED_FILES = $(sort $(LIB_FILES) $(foreach u,$(ALL_UNITS),$(call unit_files,$(u))))
UNCHECKED     = $(filter-out $(COVERED_FILES),$(TREE_FILES))

check-layout:
	@test -z "$(strip $(UNCHECKED))" || \
	  { echo "check-layout: FAIL (no target checks: $(strip $(UNCHECKED)))"; exit 1; }
	@$(foreach u,$(ALL_UNITS), \
	  test -d $(call unit_model,$(u)) || \
	    { echo "check-layout: FAIL (unit $(u) has no models in $(call unit_model,$(u)))"; exit 1; }; \
	  dup=$$(for d in $(call unit_dirs,$(u)); do ls "$$d"; done | grep '\.ec$$' | LC_ALL=C sort | uniq -d); \
	  test -z "$$dup" || \
	    { echo "check-layout: FAIL (unit $(u): theory names twice on the load path: $$dup)"; exit 1; };) \
	echo "check-layout: PASS ($(words $(TREE_FILES)) proof files, $(words $(ALL_UNITS)) units)"

check-imported:
	@$(MAKE) --no-print-directory LABEL=check-imported FILES="$(IMPORTED_FILES)" \
	  FLAGS="$(IMPORTED_FLAGS)" compile-files

check-spec:
	@$(MAKE) --no-print-directory LABEL=check-spec FILES="$(SPEC_FILES)" \
	  FLAGS="$(OWN_FLAGS)" compile-files

# The specification evaluated on NIST CAVP vectors. SpecEval.ec holds the
# rewriting rules, each a proved lemma; tools/spec_vectors.py generates
# the CAVP_*.ec files from tests/vectors/cavp, after checking the response
# files against their SHA256SUMS. Each lemma there is closed by cbv with
# those rules. The controls, one per generated file, are its first lemma
# with one output bit flipped, which EasyCrypt must reject as a proof that
# does not close; they are written to scratch directories only.
check-spec-exec:
	@$(PYTHON) -I tools/spec_vectors.py check $(CAVP_VECTORS) $(EXEC_DIR)
	@$(MAKE) --no-print-directory LABEL=check-spec-exec FILES="$(EXEC_FILES)" \
	  FLAGS="$(OWN_FLAGS)" compile-files
	@$(PYTHON) -I tools/spec_vectors.py controls $(CAVP_VECTORS) --jobs $(J) \
	  --easycrypt "$(EASYCRYPT)" --flags "$(OWN_FLAGS)"

spec-vectors:
	@$(PYTHON) -I tools/spec_vectors.py write $(CAVP_VECTORS) $(EXEC_DIR)

check-lib:
	@files="$(call ec_files,$(LIB_DIRS))"; \
	if [ -n "$$files" ]; then \
	  $(MAKE) --no-print-directory LABEL="check-lib" FILES="$$files" \
	    FLAGS="$(call lib_flags,)" compile-files || exit 1; \
	fi
	@$(foreach a,$(ARCHS),files="$(call arch_lib_files,$(a))"; \
	if [ -n "$$files" ]; then \
	  $(MAKE) --no-print-directory LABEL="check-lib $(a)" FILES="$$files" \
	    FLAGS="$(call lib_flags,$(a))" compile-files || exit 1; \
	fi;)

check-units:
	@for u in $(UNITS); do \
	  $(MAKE) --no-print-directory UNIT=$$u check-unit || exit 1; \
	done

check-unit:
	@test -n "$(UNIT)" || { echo "check-unit: UNIT not set"; exit 1; }
	@test -n "$(filter $(UNIT),$(ALL_UNITS))" || { echo "check-unit: $(UNIT) is not a unit"; exit 1; }
	@test -d $(call unit_model,$(UNIT)) || \
	  { echo "check-unit: $(call unit_model,$(UNIT)) is missing (make extract EXTRACT=proofs/extracted, top level)"; exit 1; }
	@$(MAKE) --no-print-directory LABEL="check-unit $(UNIT)" \
	  FILES="$(call unit_files,$(UNIT))" FLAGS="$(call unit_flags,$(UNIT))" compile-files

print-unit:
	@test -n "$(filter $(UNIT),$(ALL_UNITS))" || { echo "print-unit: UNIT=$(UNIT) is not a unit"; exit 1; }
	@echo "roots: $(ROOTS_$(UNIT))"
	@echo "load path: $(call unit_dirs,$(UNIT))"
	@echo "files: $(call unit_files,$(UNIT))"

.PHONY: compile-files
# Each file is checked on its own, from a scratch copy that ends with a
# trivial lemma, J at a time (tools/check_files.py). EasyCrypt accepts a
# file that ends while obligations of a `clone ... proof *` are still
# unrealized, and then treats them as proven; any command after them is
# rejected, so the sentinel lemma makes such a file fail.
compile-files:
	@test -n "$(LABEL)" || { echo "compile-files: LABEL not set"; exit 1; }
	@$(PYTHON) -I tools/check_files.py --label "$(LABEL)" --jobs $(J) \
	  --easycrypt "$(EASYCRYPT)" --flags "$(FLAGS)" $(FILES)

# ------------------------------------------------------------------
# Axiom, theorem and definition inventory
#
# One file per unit, inventory/<arch>/<variant>/inventory.txt. For a unit
# with claimed theorems (THEOREMS_<unit>), tools/inventory.py requires
# every theory checked for that unit and records every axiom in scope, the
# statements of the claimed theorems and the definitions of the
# hand-written theories. The committed file is the reviewed list;
# check-inventory regenerates it and fails on any difference.
#
# Every unit claims the theorems of correctness/Theorems.ec outside its
# abstract ArrayTheorems theory: the representation equations and the total
# correctness theorem of every layer and export. The two portable units also
# claim the array-form theorems of their four checked sizes
# (units/<unit>/ArrayInst.ec). A unit with no claimed theorem would have a
# fixed inventory that says so.

THEOREMS_COMMON := \
  Theorems.words256E Theorems.words512E Theorems.sha256_stateE \
  Theorems.sha512_stateE Theorems.sha256_compress_total \
  Theorems.sha256_compress_blocks_total Theorems.sha512_compress_total \
  Theorems.sha512_compress_blocks_total Theorems.sha256_absorb_mem_total \
  Theorems.sha256_init_total Theorems.sha224_init_total \
  Theorems.sha512_init_total Theorems.sha384_init_total \
  Theorems.sha512_224_init_total Theorems.sha512_256_init_total \
  Theorems.sha256_finalize_total Theorems.sha224_finalize_total \
  Theorems.sha512_absorb_mem_total Theorems.sha512_finalize_total \
  Theorems.sha384_finalize_total Theorems.sha512_224_finalize_total \
  Theorems.sha512_256_finalize_total Theorems.sha256_mem_from_total \
  Theorems.sha224_mem_from_total Theorems.sha512_mem_from_total \
  Theorems.sha384_mem_from_total Theorems.sha512_224_mem_from_total \
  Theorems.sha512_256_mem_from_total Theorems.sha256_mem_total \
  Theorems.sha224_mem_total Theorems.sha512_mem_total \
  Theorems.sha384_mem_total Theorems.sha512_224_mem_total \
  Theorems.sha512_256_mem_total Theorems.hmac_sha256_keyblock_total \
  Theorems.hmac_sha512_keyblock_total Theorems.hmac_sha256_mem_total \
  Theorems.hmac_sha512_mem_total Theorems.sha256_ctxE Theorems.sha512_ctxE \
  Theorems.hmac256_ctxE Theorems.hmac512_ctxE Theorems.hmac256_tagE \
  Theorems.hmac512_tagE Theorems.sha256_ctx_init_total \
  Theorems.sha256_ctx_update_total Theorems.sha224_ctx_final_total \
  Theorems.sha256_ctx_final_total Theorems.sha512_ctx_init_total \
  Theorems.sha512_ctx_update_total Theorems.sha512_ctx_final_total \
  Theorems.sha384_ctx_final_total Theorems.sha512_224_ctx_final_total \
  Theorems.sha512_256_ctx_final_total Theorems.hmac_sha256_ctx_init_total \
  Theorems.hmac_sha256_ctx_final_total Theorems.hmac_sha512_ctx_init_total \
  Theorems.hmac_sha512_ctx_final_total Theorems.lane256E Theorems.lane512E \
  Theorems.sha256_x8_stateE Theorems.sha512_x4_stateE \
  Theorems.sha256_x8_ctxE Theorems.sha512_x4_ctxE Theorems.sha2_tagE \
  Theorems.tag2E Theorems.tag9E Theorems.tag4E Theorems.tag10E \
  Theorems.sha256_x8_init_total Theorems.sha256_x8_from_total \
  Theorems.sha256_x8_absorb_total Theorems.sha256_x8_finalize_total \
  Theorems.sha256_x8_lanes_total Theorems.sha256_x8_ctx_init_total \
  Theorems.sha256_x8_ctx_from_total Theorems.sha256_x8_ctx_update_total \
  Theorems.sha256_x8_ctx_final_total Theorems.sha512_x4_init_total \
  Theorems.sha512_x4_from_total Theorems.sha512_x4_absorb_total \
  Theorems.sha512_x4_finalize_total Theorems.sha512_x4_lanes_total \
  Theorems.sha512_x4_ctx_init_total Theorems.sha512_x4_ctx_from_total \
  Theorems.sha512_x4_ctx_update_total Theorems.sha512_x4_ctx_final_total \
  Theorems.sha224_export_total Theorems.sha256_export_total \
  Theorems.sha384_export_total Theorems.sha512_export_total \
  Theorems.sha512_224_export_total Theorems.sha512_256_export_total \
  Theorems.sha224_init_export_total Theorems.sha224_update_export_total \
  Theorems.sha224_final_export_total Theorems.sha256_init_export_total \
  Theorems.sha256_update_export_total Theorems.sha256_final_export_total \
  Theorems.sha384_init_export_total Theorems.sha384_update_export_total \
  Theorems.sha384_final_export_total Theorems.sha512_init_export_total \
  Theorems.sha512_update_export_total Theorems.sha512_final_export_total \
  Theorems.sha512_224_init_export_total \
  Theorems.sha512_224_update_export_total \
  Theorems.sha512_224_final_export_total \
  Theorems.sha512_256_init_export_total \
  Theorems.sha512_256_update_export_total \
  Theorems.sha512_256_final_export_total Theorems.hmac_sha256_export_total \
  Theorems.hmac_sha256_init_export_total \
  Theorems.hmac_sha256_update_export_total \
  Theorems.hmac_sha256_final_export_total Theorems.hmac_sha512_export_total \
  Theorems.hmac_sha512_init_export_total \
  Theorems.hmac_sha512_update_export_total \
  Theorems.hmac_sha512_final_export_total Theorems.sha256_x8_export_total \
  Theorems.sha256_x8_init_export_total \
  Theorems.sha256_x8_init_from_export_total \
  Theorems.sha256_x8_update_export_total \
  Theorems.sha256_x8_final_export_total Theorems.sha512_x4_export_total \
  Theorems.sha512_x4_init_export_total \
  Theorems.sha512_x4_init_from_export_total \
  Theorems.sha512_x4_update_export_total \
  Theorems.sha512_x4_final_export_total

THEOREMS_ARRAY := \
  ArrayInst.a1_fill64_array_total ArrayInst.a1_fill128_array_total \
  ArrayInst.a1_sha256_absorb_array_total \
  ArrayInst.a1_sha512_absorb_array_total \
  ArrayInst.a1_sha256_x8_absorb_array_total \
  ArrayInst.a1_sha512_x4_absorb_array_total ArrayInst.a1_sha256_total \
  ArrayInst.a1_sha512_total ArrayInst.a1_sha256_x8_total \
  ArrayInst.a1_sha512_x4_total ArrayInst.a64_fill64_array_total \
  ArrayInst.a64_fill128_array_total ArrayInst.a64_sha256_absorb_array_total \
  ArrayInst.a64_sha512_absorb_array_total \
  ArrayInst.a64_sha256_x8_absorb_array_total \
  ArrayInst.a64_sha512_x4_absorb_array_total ArrayInst.a64_sha256_total \
  ArrayInst.a64_sha512_total ArrayInst.a64_sha256_x8_total \
  ArrayInst.a64_sha512_x4_total ArrayInst.a128_fill64_array_total \
  ArrayInst.a128_fill128_array_total \
  ArrayInst.a128_sha256_absorb_array_total \
  ArrayInst.a128_sha512_absorb_array_total \
  ArrayInst.a128_sha256_x8_absorb_array_total \
  ArrayInst.a128_sha512_x4_absorb_array_total ArrayInst.a128_sha256_total \
  ArrayInst.a128_sha512_total ArrayInst.a128_sha256_x8_total \
  ArrayInst.a128_sha512_x4_total ArrayInst.a333_fill64_array_total \
  ArrayInst.a333_fill128_array_total \
  ArrayInst.a333_sha256_absorb_array_total \
  ArrayInst.a333_sha512_absorb_array_total \
  ArrayInst.a333_sha256_x8_absorb_array_total \
  ArrayInst.a333_sha512_x4_absorb_array_total ArrayInst.a333_sha256_total \
  ArrayInst.a333_sha512_total ArrayInst.a333_sha256_x8_total \
  ArrayInst.a333_sha512_x4_total

$(foreach u,$(ALL_UNITS),$(eval THEOREMS_$(u) ?= $(THEOREMS_COMMON)))
THEOREMS_x86_64-portable  += $(THEOREMS_ARRAY)
THEOREMS_aarch64-portable += $(THEOREMS_ARRAY)

inventory_file = inventory/$(call unit_arch,$(1))/$(call unit_variant,$(1))/inventory.txt

# The inventory of a unit with no claimed theorem, $(1) its <arch>/<variant>.
empty_inventory = printf '%s\n' \
  '\# SPDX-FileCopyrightText: nirapod-sha2 contributors' \
  '\# SPDX-License-Identifier: Apache-2.0' \
  '\#' \
  '\# GENERATED FILE. DO NOT EDIT.' \
  '\#' \
  '\# Inventory of the $(1) proofs. No theorem is claimed for this unit, so' \
  '\# no axiom, theorem statement or definition is listed.' \
  '\#' \
  '\# Generator: proofs/Makefile, target inventory' \
  '\# Regenerate: make -C proofs inventory   (check: make -C proofs check-inventory)' \
  '' \
  'theorems 0'

.PHONY: inventory check-inventory check-inventory-files inventory-unit
inventory:
	@for u in $(UNITS); do \
	  $(MAKE) --no-print-directory UNIT=$$u MODE=write inventory-unit || exit 1; \
	done

check-inventory: check-inventory-files
	@for u in $(UNITS); do \
	  $(MAKE) --no-print-directory UNIT=$$u MODE=check inventory-unit || exit 1; \
	done
	@echo "check-inventory: PASS"

check-inventory-files:
	@expected="$(foreach u,$(ALL_UNITS),$(call inventory_file,$(u)))"; \
	for f in $$(find inventory -type f 2>/dev/null | LC_ALL=C sort); do \
	  case " $$expected " in *" $$f "*) ;; \
	    *) echo "check-inventory-files: FAIL ($$f is not the inventory of a unit)"; exit 1;; \
	  esac; \
	done; echo "check-inventory-files: PASS"

inventory-unit:
	@test -n "$(filter $(UNIT),$(ALL_UNITS))" || { echo "inventory-unit: UNIT=$(UNIT) is not a unit"; exit 1; }
	@case "$(MODE)" in write|check) ;; *) echo "inventory-unit: MODE must be write or check"; exit 1;; esac
ifeq ($(strip $(THEOREMS_$(UNIT))),)
	@out=$(call inventory_file,$(UNIT)); \
	tmp=$$(mktemp) || exit 1; \
	$(call empty_inventory,$(call unit_arch,$(UNIT))/$(call unit_variant,$(UNIT))) > "$$tmp"; \
	if [ "$(MODE)" = write ]; then \
	  mkdir -p "$$(dirname "$$out")" && mv "$$tmp" "$$out" && \
	  echo "inventory $(UNIT): wrote $$out (no theorem claimed)"; \
	elif cmp -s "$$tmp" "$$out"; then \
	  rm -f "$$tmp"; echo "inventory $(UNIT): PASS (no theorem claimed)"; \
	else \
	  rm -f "$$tmp"; echo "inventory $(UNIT): FAIL, $$out differs (no theorem claimed)"; exit 1; \
	fi
else
	@mkdir -p $(dir $(call inventory_file,$(UNIT)))
	@$(PYTHON) -I tools/inventory.py --pair $(call unit_arch,$(UNIT))/$(call unit_variant,$(UNIT)) \
	  --easycrypt "$(EASYCRYPT)" --flags "$(call unit_flags,$(UNIT))" --generated extracted \
	  --theorems "$(THEOREMS_$(UNIT))" --$(MODE) $(call inventory_file,$(UNIT)) \
	  $(SPEC_FILES) $(IMPORTED_FILES) $(call ec_files,$(LIB_DIRS)) \
	  $(call arch_lib_files,$(call unit_arch,$(UNIT))) $(call unit_files,$(UNIT))
endif
