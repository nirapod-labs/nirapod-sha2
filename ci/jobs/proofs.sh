#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/proofs.sh
# =================
#
# Machine-checks the EasyCrypt development:
#
#   make -C proofs check            hole scan, constant derivation, layout,
#                                   imported theories, specification, the
#                                   specification evaluated on CAVP vectors
#                                   and its controls, the
#                                   files that need no model, every unit's
#                                   files on its models, and the committed
#                                   axiom and theorem inventory of every unit
#
# The committed models in proofs/extracted are the extraction job's to
# check (make check-extraction), not this one's.
#
# This job is opt-in (ci/run.sh --proofs) and long. It does not run on
# macOS: EasyCrypt and the SMT provers run on Linux only.
#
# CI_PROOF_JOBS sets the number of files checked at a time (default: the
# number of cores, at most 8).

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

[ "$CI_HOST_SYSTEM" = linux ] \
  || ci_fail "the proofs run on Linux, not on $CI_HOST_SYSTEM"
[ -f proofs/Makefile ] \
  || ci_fail "proofs/Makefile is not present in this tree"
ci_need make
ci_need easycrypt
ci_need python3

jobs=${CI_PROOF_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')}
[ "$jobs" -le 8 ] || jobs=8

make -C proofs check J="$jobs"

PASS="PASS: proofs: check, every unit, inventories"
echo "$PASS"
