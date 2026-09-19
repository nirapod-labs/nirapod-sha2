#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/safety.sh
# ==================
#
# The memory-safety checker gives a verdict on every export of the host
# architecture. One run per unit; without --slice the checker takes every
# export function of the unit, and the job requires each export of
# src/nirapod_sha2.jinc to appear in the run.
#
# This job is opt-in (ci/run.sh --safety) and long. It does not run on
# macOS: the checker is a heavy analysis and runs on Linux only.
#
# CI_SAFETY_TIMEOUT caps one unit, in seconds (default 14400).

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

[ "$CI_HOST_SYSTEM" = linux ] \
  || ci_fail "the safety checker runs on Linux, not on $CI_HOST_SYSTEM"

ci_need make
ci_need jasmin-checksafety

cap=${CI_SAFETY_TIMEOUT:-14400}
exports=$CI_RUN_DIR/safety-exports
sed -n 's/^export fn \([a-z0-9_]*\)(.*/\1/p' src/nirapod_sha2.jinc \
  | LC_ALL=C sort -u > "$exports"
[ -s "$exports" ] || ci_fail "src/nirapod_sha2.jinc has no export"

for unit in $(ci_units "$CI_HOST_ARCH"); do
  jazz=build/units/$unit.jazz
  log=$CI_RUN_DIR/safety-$unit.log
  roots=$(ci_unit_roots "$unit")
  make "$jazz"
  echo "safety: $unit (limit ${cap}s)"
  # shellcheck disable=SC2086
  if ci_cap "$cap" jasmin-checksafety "--arch=$(ci_jarch "$unit")" \
      $roots "$jazz" > "$log" 2>&1; then
    rc=0
  else
    rc=$?
  fi
  if [ "$rc" -eq 124 ]; then
    tail -n 5 "$log" | sed 's/^/  /'
    echo "FAIL: $unit exceeded CI_SAFETY_TIMEOUT=${cap}s" >&2
    exit 124
  fi
  if [ "$rc" -ne 0 ]; then
    tail -n 15 "$log" | sed 's/^/  /'
    ci_fail "$unit: jasmin-checksafety exited $rc"
  fi
  if grep -q 'Possible Safety Violation' "$log"; then
    grep -n 'Possible Safety Violation' "$log" | head -20 >&2
    ci_fail "$unit: possible safety violation"
  fi
  grep -q 'No Safety Violation' "$log" \
    || ci_fail "$unit: no verdict in $log"

  sed -n 's/.*Analyzing function \(.*\)$/\1/p' "$log" \
    | sed 's/.*:://' | LC_ALL=C sort -u > "$CI_RUN_DIR/safety-$unit.analyzed"
  missing=$(LC_ALL=C comm -23 "$exports" "$CI_RUN_DIR/safety-$unit.analyzed")
  if [ -n "$missing" ]; then
    printf '%s\n' "$missing" | sed 's/^/  not analyzed: /' >&2
    ci_fail "$unit: the checker did not reach every export"
  fi
  echo "safety: $unit: No Safety Violation, $(wc -l < "$exports" | tr -d ' ') exports"
done

units=$(ci_units "$CI_HOST_ARCH" | wc -w | tr -d ' ')
PASS="PASS: safety: $units $CI_HOST_ARCH units, every export checked"
echo "$PASS"
