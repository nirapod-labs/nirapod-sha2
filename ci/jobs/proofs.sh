#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/proofs.sh
# =================
#
# Machine-checks the EasyCrypt development:
#
#   make -C proofs check            hole scan, constant derivation, imported
#                                   theories, specification, correctness for
#                                   every extracted model
#   make -C proofs check-extraction a fresh extraction equals the committed
#                                   models
#   make -C proofs check-inventory  the committed axiom and theorem
#                                   inventory equals a fresh run
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
ci_need jasmin2ec
ci_need python3

jobs=${CI_PROOF_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')}
[ "$jobs" -le 8 ] || jobs=8

make -C proofs check check-extraction check-inventory J="$jobs"

PASS="PASS: proofs: check, extraction identity and inventory"
echo "$PASS"
