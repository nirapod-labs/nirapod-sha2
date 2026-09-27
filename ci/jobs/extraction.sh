#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/extraction.sh
# =====================
#
# The EasyCrypt models the proofs are written against are what jasmin2ec
# extracts from the units, and one proof per shared layer holds for every
# unit only if that layer extracts to the same text in each of them. This
# job, for every unit of both architectures and for the normal and the
# safety model (jasmin2ec -m safety):
#
#   1. extracts the models into build/extract/models (make extract);
#   2. extracts them again and requires the same bytes, so a committed
#      model can be checked against a fresh extraction at all;
#   3. requires every shared procedure, global and operator to have the
#      same text in every unit of its architecture, and each model to be
#      the program of the namespaced unit the library is compiled from
#      (make extraction-identity);
#   4. runs the negative controls of 2 and 3 (make extraction-control);
#   5. when the tree commits models (proofs/extracted), requires them to
#      equal the fresh extraction (make check-extraction).
#
# tests/extraction/models.py defines what is shared and what the
# comparison leaves out. Every unit of both architectures must have both
# models and a correspondence verdict, or the job fails. The extraction
# is per target, so one analysis host covers both architectures.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need jasmin2ec
ci_need python3

rm -rf build/extract
make extraction-identity PYTHON=python3
make check-extraction PYTHON=python3 MODELS=build/extract/models
make extraction-control PYTHON=python3

report=build/extract/identity/report.txt
[ -s "$report" ] || ci_fail "no identity report at $report"

units=0
for arch in aarch64 x86_64; do
  for unit in $(ci_units "$arch"); do
    units=$((units + 1))
    dir=build/extract/models/${unit%%-*}/${unit#*-}
    for f in NirapodSha2.ec NirapodSha2Safety.ec COMMANDS; do
      [ -s "$dir/$f" ] || ci_fail "unit $unit has no $dir/$f"
    done
    for mode in normal safety; do
      grep -q "^correspondence $unit $mode: equal to " "$report" \
        || ci_fail "no correspondence verdict for unit $unit, $mode model"
    done
  done
done
for arch in aarch64 x86_64; do
  for mode in normal safety; do
    grep -qx "shared $arch $mode: [0-9]* items over $(echo $(ci_units "$arch"))" "$report" \
      || ci_fail "no shared-item comparison over every unit of $arch, $mode model"
  done
done

if [ -d proofs/extracted ]; then
  make check-extraction PYTHON=python3 MODELS=proofs/extracted
  committed="the committed models in proofs/extracted equal it"
else
  committed="no models are committed in this tree"
fi

PASS="PASS: extraction: $units units, normal and safety models, reproducible;"
PASS="$PASS shared items identical per architecture; controls rejected; $committed"
echo "$PASS"
