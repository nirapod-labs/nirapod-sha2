#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/safety.sh
# ==================
#
# The memory-safety checker gives a verdict on every export of both
# architectures (the analysis is per target, so one host covers both).
# One run per unit; without --slice the checker takes every export
# function of the unit, and the job requires each export of
# src/nirapod_sha2.jinc to appear in the run.
#
# This job is opt-in (ci/run.sh --safety) and long. It does not run on
# macOS: the checker is a heavy analysis and runs on Linux only.
#
# CI_SAFETY_TIMEOUT caps one unit, in seconds (default 14400).
# CI_SAFETY_JOBS units are checked at a time (default: half the cores).

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

arches=$(ci_analysis_arches)
units=$(for a in $arches; do ci_units "$a"; done)
for unit in $units; do
  make "build/units/$unit.jazz"
done

# check_unit UNIT: one checker run and its verdict. Writes the outcome to
# $CI_RUN_DIR/safety-UNIT.result: PASS, TIMEOUT or FAIL with the reason.
check_unit() {
  local unit=$1 jazz log roots rc missing result
  jazz=build/units/$unit.jazz
  log=$CI_RUN_DIR/safety-$unit.log
  result=$CI_RUN_DIR/safety-$unit.result
  roots=$(ci_unit_roots "$unit")
  echo "safety: $unit started (limit ${cap}s)"
  # shellcheck disable=SC2086
  if ci_cap "$cap" jasmin-checksafety "--arch=$(ci_jarch "$unit")" \
      $roots "$jazz" > "$log" 2>&1; then
    rc=0
  else
    rc=$?
  fi
  if [ "$rc" -eq 124 ]; then
    echo "TIMEOUT exceeded CI_SAFETY_TIMEOUT=${cap}s" > "$result"; return
  fi
  if [ "$rc" -ne 0 ]; then
    echo "FAIL jasmin-checksafety exited $rc" > "$result"; return
  fi
  if grep -q 'Possible Safety Violation' "$log"; then
    echo "FAIL possible safety violation" > "$result"; return
  fi
  if ! grep -q 'No Safety Violation' "$log"; then
    echo "FAIL no verdict in $log" > "$result"; return
  fi
  sed -n 's/.*Analyzing function \(.*\)$/\1/p' "$log" \
    | sed 's/.*:://' | LC_ALL=C sort -u > "$CI_RUN_DIR/safety-$unit.analyzed"
  missing=$(LC_ALL=C comm -23 "$exports" "$CI_RUN_DIR/safety-$unit.analyzed")
  if [ -n "$missing" ]; then
    printf '%s\n' "$missing" > "$CI_RUN_DIR/safety-$unit.missing"
    echo "FAIL the checker did not reach every export" > "$result"; return
  fi
  echo "PASS No Safety Violation, $(wc -l < "$exports" | tr -d ' ') exports" > "$result"
}

# The runs are independent and single-threaded: CI_SAFETY_JOBS of them at
# a time (default: half the cores, at most the number of units).
par=${CI_SAFETY_JOBS:-$(( $(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2) / 2 ))}
[ "$par" -ge 1 ] || par=1
running=0
for unit in $units; do
  rm -f "$CI_RUN_DIR/safety-$unit.result"
  check_unit "$unit" &
  running=$((running + 1))
  if [ "$running" -ge "$par" ]; then
    wait -n || true
    running=$((running - 1))
  fi
done
wait

failed=0
timeout=0
n=0
for unit in $units; do
  n=$((n + 1))
  r=$CI_RUN_DIR/safety-$unit.result
  [ -f "$r" ] || { echo "safety: $unit: no result"; failed=1; continue; }
  echo "safety: $unit: $(cat "$r")"
  case $(cut -d' ' -f1 "$r") in
    PASS) ;;
    TIMEOUT) timeout=1; tail -n 5 "$CI_RUN_DIR/safety-$unit.log" | sed 's/^/  /' ;;
    *) failed=1
       grep -n 'Possible Safety Violation' "$CI_RUN_DIR/safety-$unit.log" | head -20 | sed 's/^/  /'
       [ -f "$CI_RUN_DIR/safety-$unit.missing" ] \
         && sed 's/^/  not analyzed: /' "$CI_RUN_DIR/safety-$unit.missing"
       ;;
  esac
done
[ "$failed" -eq 0 ] || ci_fail "safety: at least one unit failed"
if [ "$timeout" -ne 0 ]; then
  echo "FAIL: a unit exceeded CI_SAFETY_TIMEOUT=${cap}s" >&2
  exit 124
fi

PASS="PASS: safety: $n units of $(echo $arches), every export checked"
echo "$PASS"
