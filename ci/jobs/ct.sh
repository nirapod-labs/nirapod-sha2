#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/ct.sh
# ==============
#
# Constant-time and speculative constant-time checks of both
# architectures: jasmin-ct and jasmin-ct --sct on every unit, with the
# requirement that every export of src/nirapod_sha2.jinc was typed by both
# checkers under the unit's namespace, and on the array test unit of each
# architecture. The checkers analyse a target, not the host, so they run
# for both targets on one host.
#
# The logs of an earlier run are removed first: a cached .ok file must not
# turn a skipped check into a pass.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need jasmin-ct

arches=$(ci_analysis_arches)
rm -rf build/ct
make ct "CT_ARCHES=$arches"

units=0
for unit in $(for a in $arches; do ci_units "$a"; done); do
  units=$((units + 1))
  [ -f "build/ct/$unit.ok" ] || ci_fail "no result for unit $unit"
  [ -f "build/ct/$unit.ct.log" ] || ci_fail "no jasmin-ct log for unit $unit"
  [ -f "build/ct/$unit.sct.log" ] || ci_fail "no jasmin-ct --sct log for unit $unit"
  sh tests/ct/exports.sh src/nirapod_sha2.jinc \
    "nirapod_sha2_jz_$(printf '%s' "$unit" | tr '-' '_')" \
    "build/ct/$unit.ct.log" "build/ct/$unit.sct.log"
done

for a in $arches; do
  [ -f "build/ct/array-$a.ok" ] || ci_fail "no result for the array unit of $a"
done

PASS="PASS: ct: jasmin-ct and --sct on $units units and the array unit of $(echo $arches)"
echo "$PASS"
