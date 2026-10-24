#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/safety.sh
# ==================
#
# The memory-safety checker on every export of every unit of both
# architectures (the analysis is per target, so one host covers both).
#
# One jasmin-checksafety process per export and unit, sliced to the
# export under its namespaced name, with its own time limit, several at a
# time. An export the checker cannot finish is named with its limit
# instead of holding up the others.
#
# A run passes only when the checker reports no violation, no safety
# assumption and no alignment issue for the export, and every memory
# range it prints is within the bound the export's #[safety] contract
# gives: an input pointer may be read for at most its length argument,
# and an array pointer or a scalar is no memory region at all
# (tests/safety/ranges.py states the rule and how it is decided).
#
# Each export ends PASS, FAIL or TIMEOUT. A TIMEOUT is never a pass, an
# export without a result is a FAIL, and the summary names every export
# of every unit with its status, time and reason. Exit status: 0 when
# every export passed, 124 when none failed but at least one timed out,
# 1 otherwise.
#
# Before the exports, the controls of tests/safety/controls.jazz run on
# both architectures and must end as that file says: an exact range
# passes; a range one byte wider than the contract, a range unrelated to
# the length, an out-of-bounds array read, a read through an argument the
# contract does not name, and an export that is not in the unit all fail.
# A real export analysed under a two-second limit must end TIMEOUT.
#
# Per-export checker configurations and limits are listed in
# ci/safety-config/table.tsv, each with its reason; every other run uses
# the checker's defaults.
#
# This job is opt-in (ci/run.sh --safety) and long. It does not run on
# macOS: the checker is a heavy analysis and runs on Linux only.
#
#   CI_SAFETY_TIMEOUT  limit of one export's run, seconds (default 3600)
#   CI_SAFETY_JOBS     runs at a time (default: half the cores)
#   CI_SAFETY_UNITS    only these units, space separated (development)
#   CI_SAFETY_EXPORTS  only these exports, space separated (development)
#
# With CI_SAFETY_UNITS or CI_SAFETY_EXPORTS set, the job checks a subset:
# its last line then starts with PARTIAL:, never PASS:, so ci/run.sh does
# not count it as the full check.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

[ "$CI_HOST_SYSTEM" = linux ] \
  || ci_fail "the safety checker runs on Linux, not on $CI_HOST_SYSTEM"

ci_need make
ci_need python3
ci_need jasmin-checksafety

SRC=src/nirapod_sha2.jinc
RANGES=tests/safety/ranges.py
CONTROLS=tests/safety/controls.jazz
TABLE=ci/safety-config/table.tsv

cap=${CI_SAFETY_TIMEOUT:-3600}
case $cap in ''|*[!0-9]*|0) ci_fail "CI_SAFETY_TIMEOUT must be a positive number of seconds" ;; esac
par=${CI_SAFETY_JOBS:-$(( $(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2) / 2 ))}
case $par in ''|*[!0-9]*) ci_fail "CI_SAFETY_JOBS must be a number" ;; esac
[ "$par" -ge 1 ] || par=1

out=$CI_RUN_DIR/safety
rm -rf "$out"
mkdir -p "$out/runs" "$out/controls"

# The exports and their contract bounds. The export list is read twice,
# by ranges.py and by the pattern the other jobs use, and the two must
# agree.
python3 "$RANGES" bounds "$SRC" > "$out/contracts.tsv" \
  || ci_fail "cannot read the #[safety] contracts of $SRC"
cut -f1 "$out/contracts.tsv" | LC_ALL=C sort > "$out/exports"
sed -n 's/^export fn \([a-z0-9_]*\)(.*/\1/p' "$SRC" | LC_ALL=C sort -u > "$out/exports.sed"
cmp -s "$out/exports" "$out/exports.sed" \
  || ci_fail "the export lists of $RANGES and of $SRC differ"
[ -s "$out/exports" ] || ci_fail "$SRC has no export"

all_units=$(for a in $(ci_analysis_arches); do ci_units "$a"; done)
units=$all_units
exports=$(cat "$out/exports")
partial=0
if [ -n "${CI_SAFETY_UNITS:-}" ]; then
  for u in $CI_SAFETY_UNITS; do
    printf '%s\n' $all_units | grep -qx "$u" || ci_fail "no unit $u"
  done
  units=$CI_SAFETY_UNITS
  partial=1
fi
if [ -n "${CI_SAFETY_EXPORTS:-}" ]; then
  for e in $CI_SAFETY_EXPORTS; do
    grep -qx "$e" "$out/exports" || ci_fail "no export $e in $SRC"
  done
  exports=$CI_SAFETY_EXPORTS
  partial=1
fi

for unit in $all_units; do
  make "build/units/$unit.jazz"
done

# The configuration table: unit pattern, export, configuration file (or
# -), limit in seconds (or -), reason. Every row must be well formed and
# match at least one export of one unit.
config_rows() {
  [ -f "$TABLE" ] || return 0
  grep -v '^[[:space:]]*\(#\|$\)' "$TABLE" || true
}
config_rows | while IFS=$'\t' read -r pat exp cfg lim why; do
  [ -n "$why" ] || ci_fail "$TABLE: a row without a reason: $pat $exp"
  grep -qx "$exp" "$out/exports" || ci_fail "$TABLE: no export $exp"
  [ "$cfg" = - ] || [ -f "ci/safety-config/$cfg" ] \
    || ci_fail "$TABLE: no file ci/safety-config/$cfg"
  case $lim in -|[1-9]*) ;; *) ci_fail "$TABLE: bad limit $lim" ;; esac
  hit=0
  for u in $all_units; do
    # shellcheck disable=SC2254
    case $u in $pat) hit=1 ;; esac
  done
  [ "$hit" = 1 ] || ci_fail "$TABLE: pattern $pat matches no unit"
done

# config_for UNIT EXPORT: "CONFIG LIMIT" of the first matching row, or
# "- -".
config_for() {
  local pat exp cfg lim why
  while IFS=$'\t' read -r pat exp cfg lim why; do
    [ "$exp" = "$2" ] || continue
    # shellcheck disable=SC2254
    case $1 in $pat) printf '%s %s\n' "$cfg" "$lim"; return ;; esac
  done < <(config_rows)
  printf -- '- -\n'
}

namespace_of() {
  sed -n 's/^namespace \([A-Za-z0-9_]*\) {.*/\1/p' "build/units/$1.jazz"
}

# Seconds on the monotonic clock: the wall clock of a virtual machine may
# be stepped while a run is in progress.
now() {
  perl -MTime::HiRes=clock_gettime,CLOCK_MONOTONIC \
    -e 'printf "%.3f\n", clock_gettime(CLOCK_MONOTONIC)'
}

# run_one SRC EXPORT FUNCTION ARCH JAZZ LIMIT CONFIG BASE [ROOTS...]
# One checker run sliced to FUNCTION, and its verdict against the
# contract of EXPORT in SRC. Writes BASE.log, BASE.verdict and
# BASE.result: "STATUS SECONDS REASON".
run_one() {
  local src=$1 export=$2 function=$3 arch=$4 jazz=$5 limit=$6 config=$7 base=$8
  shift 8
  local cfgopt=() rc t0 t1 secs status why
  [ "$config" = - ] || cfgopt=("--config=ci/safety-config/$config")
  t0=$(now)
  if ci_cap "$limit" jasmin-checksafety "--arch=$arch" ${cfgopt[@]+"${cfgopt[@]}"} \
      "--slice=$function" "$@" "$jazz" > "$base.log" 2>&1; then
    rc=0
  else
    rc=$?
  fi
  t1=$(now)
  secs=$(awk -v a="$t0" -v b="$t1" 'BEGIN { printf "%.1f", b - a }')
  if [ "$rc" -eq 124 ]; then
    printf 'TIMEOUT %s no verdict within %ss\n' "$secs" "$limit" > "$base.result"
    return
  fi
  if python3 "$RANGES" verdict "$src" "$export" "$base.log" \
      --function "$function" > "$base.verdict" 2>&1; then
    status=PASS
  else
    status=FAIL
  fi
  # Reasons name source files relative to the checkout.
  why=$(head -n 1 "$base.verdict" | sed -e 's/^\(PASS\|FAIL\) //' \
    -e "s|$CI_REPO_ROOT/||g")
  if [ "$rc" -ne 0 ]; then
    status=FAIL
    why="checker exit $rc; $why"
  fi
  printf '%s %s %s\n' "$status" "$secs" "$why" > "$base.result"
}

# --- Controls ---------------------------------------------------------

# name, export, required status, a word the reason must contain
controls='exact exact PASS -
wider wider FAIL exceed
offset offset FAIL related
oob oob FAIL violation
unnamed unnamed FAIL exceed
absent exact FAIL analyse'

control_failed=0
for arch in armv8a x86-64; do
  while read -r name export want word; do
    base=$out/controls/$arch-$name
    function=$name
    [ "$name" = absent ] && function=absent
    run_one "$CONTROLS" "$export" "$function" "$arch" "$CONTROLS" 120 - "$base"
    read -r got _ why < "$base.result"
    if [ "$got" != "$want" ] || { [ "$word" != - ] && ! printf '%s' "$why" | grep -q "$word"; }; then
      echo "safety: control $arch $name: $got ($why), required $want${word:+ ($word)}"
      control_failed=1
    else
      echo "safety: control $arch $name: $got as required ($why)"
    fi
  done <<< "$controls"
done

# The timeout control: a real export whose analysis takes far longer than
# two seconds must end TIMEOUT, never PASS.
tunit=$(printf '%s\n' $all_units | head -n 1)
tns=$(namespace_of "$tunit")
# shellcheck disable=SC2046
run_one "$SRC" sha256_final "$tns::sha256_final" "$(ci_jarch "$tunit")" \
  "build/units/$tunit.jazz" 2 - "$out/controls/timeout" $(ci_unit_roots "$tunit")
read -r got _ why < "$out/controls/timeout.result"
if [ "$got" = TIMEOUT ]; then
  echo "safety: control timeout ($tunit sha256_final, 2s): TIMEOUT as required"
else
  echo "safety: control timeout ($tunit sha256_final, 2s): $got, required TIMEOUT"
  control_failed=1
fi
[ "$control_failed" -eq 0 ] || ci_fail "safety: a control did not end as required"

# --- Exports ----------------------------------------------------------

# Cheap exports first: the context set-up and the finalisations take
# seconds to minutes, the absorbing exports far longer, so the first
# results arrive early and a slow export does not delay the others.
rank() {
  case $1 in
    *_init|*_init_from|*_final) echo 0 ;;
    *) echo 1 ;;
  esac
}
tasks=$out/tasks
: > "$tasks"
for r in 0 1; do
  for e in $exports; do
    [ "$(rank "$e")" = "$r" ] || continue
    for u in $units; do
      printf '%s %s\n' "$u" "$e" >> "$tasks"
    done
  done
done
total=$(wc -l < "$tasks" | tr -d ' ')
echo "safety: $total runs, $par at a time, limit ${cap}s per export unless $TABLE says otherwise"

running=0
while read -r unit export; do
  ns=$(namespace_of "$unit")
  [ -n "$ns" ] || ci_fail "build/units/$unit.jazz has no namespace"
  read -r cfg lim < <(config_for "$unit" "$export")
  [ "$lim" = - ] && lim=$cap
  base=$out/runs/$unit.$export
  # shellcheck disable=SC2046
  run_one "$SRC" "$export" "$ns::$export" "$(ci_jarch "$unit")" \
    "build/units/$unit.jazz" "$lim" "$cfg" "$base" $(ci_unit_roots "$unit") &
  running=$((running + 1))
  if [ "$running" -ge "$par" ]; then
    wait -n || true
    running=$((running - 1))
  fi
done < "$tasks"
wait

# --- Summary ----------------------------------------------------------

summary=$out/summary.tsv
printf 'unit\texport\tstatus\tseconds\tconfig\treason\n' > "$summary"
pass=0 fail=0 tout=0
while read -r unit export; do
  base=$out/runs/$unit.$export
  read -r cfg _ < <(config_for "$unit" "$export")
  if [ -f "$base.result" ]; then
    read -r status secs why < "$base.result"
  else
    status=FAIL secs=- why="no result"
  fi
  case $status in
    PASS) pass=$((pass + 1)) ;;
    TIMEOUT) tout=$((tout + 1)) ;;
    *) status=FAIL; fail=$((fail + 1)) ;;
  esac
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$unit" "$export" "$status" "$secs" "$cfg" "$why" >> "$summary"
done < "$tasks"

echo "safety: per export (also in $summary)"
column -t -s "$(printf '\t')" "$summary" 2>/dev/null | sed 's/^/  /' \
  || sed 's/^/  /' "$summary"
echo "safety: $pass PASS, $fail FAIL, $tout TIMEOUT of $total runs"

[ "$fail" -eq 0 ] || ci_fail "safety: $fail of $total runs failed"
if [ "$tout" -ne 0 ]; then
  echo "FAIL: safety: $tout of $total runs gave no verdict within their limit" >&2
  exit 124
fi
if [ "$partial" -eq 1 ]; then
  echo "PARTIAL: safety: $total runs of a subset of units and exports passed; not the full check"
  exit 0
fi
nu=$(printf '%s\n' $units | wc -l | tr -d ' ')
ne=$(printf '%s\n' $exports | wc -l | tr -d ' ')
echo "PASS: safety: all $total runs ($nu units, $ne exports) within their contracts"
