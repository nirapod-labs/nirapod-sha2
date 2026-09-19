#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/ct.sh
# ==============
#
# Constant-time and speculative constant-time checks of the host
# architecture: jasmin-ct and jasmin-ct --sct on every unit, with the
# requirement that every export of src/nirapod_sha2.jinc was typed by both
# checkers under the unit's namespace.
#
# The logs of an earlier run are removed first: a cached .ok file must not
# turn a skipped check into a pass.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need jasmin-ct

rm -rf build/ct
make ct "CT_ARCHES=$CI_HOST_ARCH"

for unit in $(ci_units "$CI_HOST_ARCH"); do
  [ -f "build/ct/$unit.ok" ] || ci_fail "no result for unit $unit"
  [ -f "build/ct/$unit.ct.log" ] || ci_fail "no jasmin-ct log for unit $unit"
  [ -f "build/ct/$unit.sct.log" ] || ci_fail "no jasmin-ct --sct log for unit $unit"
  sh tests/ct/exports.sh src/nirapod_sha2.jinc \
    "nirapod_sha2_jz_$(printf '%s' "$unit" | tr '-' '_')" \
    "build/ct/$unit.ct.log" "build/ct/$unit.sct.log"
done

units=$(ci_units "$CI_HOST_ARCH" | wc -w | tr -d ' ')
PASS="PASS: ct: jasmin-ct and --sct on $units $CI_HOST_ARCH units"
echo "$PASS"
