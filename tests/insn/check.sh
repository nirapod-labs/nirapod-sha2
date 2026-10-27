#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/insn/check.sh
# ===================
#
#     tests/insn/check.sh ARCH OUT
#
# Checks the EasyCrypt models of the instructions in tests/insn/ARCH.insn
# against this processor, which must be an ARCH processor, and runs the
# negative controls. Work and logs go to OUT. The steps, as
# tests/insn/README.md explains them:
#
#   1. generate the Jasmin test program, compile it with JASMINC and check
#      that each export contains its instruction;
#   2. link it with run.c, run it, and keep the vectors it prints;
#   3. extract the program with JASMIN2EC and write one EasyCrypt file of
#      cases per entry; every case must check;
#   4. controls, each of which must be rejected by EasyCrypt as a proof
#      that does not close: per entry, one case with one result bit
#      flipped, and one with each pair of its operands exchanged; per mutant of
#      tests/insn/ARCH.mutants, the cases of its entries against the
#      mutated copy of the EasyCrypt library. Before the mutants, every
#      entry's cases must check against an unchanged copy.
#
# With INSN_RECORDED=DIR (tests/insn/aarch64), the processor is the one
# DIR/host.txt names and the run of step 2 is the one recorded there: step
# 1 compiles the program for each system DIR has an assembly file for and
# requires it to equal that file byte for byte, step 2 takes DIR/vectors.txt
# instead of running anything, and steps 3 and 4 are unchanged. Such a run
# needs no ARCH processor; tests/insn/vectors.sh repeats step 2 on one and
# requires the same vectors.
#
# An entry that is symmetric in two operands gives the same result when
# they are exchanged, so that control cannot be rejected; ARCH.symmetric
# lists such pairs, one per line ("ENTRY XY reason"), and they are skipped
# with a printed reason.
#
# Tools come from the environment: JASMINC, JASMIN2EC, EASYCRYPT, CC and
# PYTHON (default: the names on PATH). INSN_SEED and INSN_RANDOM are the
# arguments of run.c (default 1 and 256). The last line is a PASS: line
# when every step and every control gave the required result.

set -euo pipefail

[ $# -eq 2 ] || { echo "usage: tests/insn/check.sh ARCH OUT" >&2; exit 2; }
ARCH=$1
OUT=$2
HERE=$(cd "$(dirname "$0")" && pwd)
JASMINC=${JASMINC:-jasminc}
JASMIN2EC=${JASMIN2EC:-jasmin2ec}
EASYCRYPT=${EASYCRYPT:-easycrypt}
CC=${CC:-cc}
PYTHON=${PYTHON:-python3}
SEED=${INSN_SEED:-1}
RANDOM_VECTORS=${INSN_RANDOM:-256}
RECORDED=${INSN_RECORDED:-}

fail() { printf 'FAIL: insn: %s\n' "$*"; exit 1; }

TABLE=$HERE/$ARCH.insn
MUTANTS=$HERE/$ARCH.mutants
[ -f "$TABLE" ] || fail "no instruction table for $ARCH ($TABLE)"
[ -f "$MUTANTS" ] || fail "no wrong models for $ARCH ($MUTANTS)"

case $(uname -m) in
  x86_64|amd64) host=x86_64 ;;
  arm64|aarch64) host=aarch64 ;;
  *) host=unknown ;;
esac
if [ -n "$RECORDED" ]; then
  RECORDED=$(cd "$RECORDED" && pwd) || fail "no recorded run in $INSN_RECORDED"
  [ -f "$RECORDED/vectors.txt" ] && [ -f "$RECORDED/host.txt" ] \
    || fail "$RECORDED has no vectors.txt and host.txt"
else
  [ "$host" = "$ARCH" ] || fail "the models of $ARCH need an $ARCH processor, this is $(uname -m)"
fi
SYMMETRIC=$HERE/$ARCH.symmetric
case $ARCH in
  x86_64) jarch=x86-64 ;;
  aarch64) jarch=armv8a ;;
  *) fail "unknown architecture $ARCH" ;;
esac

tools=("$JASMINC" "$JASMIN2EC" "$EASYCRYPT" "$PYTHON")
[ -n "$RECORDED" ] || tools+=("$CC")
for t in "${tools[@]}"; do
  command -v "$t" >/dev/null 2>&1 || fail "required tool not found: $t"
done

INSN() { "$PYTHON" -I "$HERE/insn.py" "$@"; }

rm -rf "$OUT"
mkdir -p "$OUT/cases" "$OUT/controls" "$OUT/mutants"

# The EasyCrypt library jasmin2ec's models load, as EasyCrypt reports it.
ECLIB=$("$EASYCRYPT" config 2>&1 | sed -n 's/^ *Jasmin@//p' | head -n 1)
[ -n "$ECLIB" ] && [ -f "$ECLIB/JWord.ec" ] \
  || fail "cannot find the Jasmin EasyCrypt library through '$EASYCRYPT config'"

# EasyCrypt runs in OUT with no cache files, so every check is made from
# the sources: the cases from WordEval.ec, the library from ECLIB or from
# a mutated copy.
ec() {
  local log=$1
  shift
  (cd "$OUT" && "$EASYCRYPT" compile -no-eco -I . "$@") > "$log" 2>&1
}

# A control is rejected when EasyCrypt fails on a case of the control's
# own file whose proof does not close, and on nothing else: a parse or
# type error, or a failure inside WordEval.ec or the library, would
# reject any file and prove nothing.
rejected() {
  local log=$1 file=$2
  tr '\r' '\n' < "$log" | grep -a '\[critical\]' > "$log.critical" || true
  [ -s "$log.critical" ] || return 1
  ! grep -qv "^\[critical\] \[$file: line [0-9]* ([0-9-]*)\] \[by\]: cannot close goals\$" "$log.critical"
}

# 1. Test program.
INSN jazz "$TABLE" > "$OUT/insn.jazz"
if [ -n "$RECORDED" ]; then
  systems=0
  for asm in "$RECORDED"/insn-*.s; do
    [ -f "$asm" ] || continue
    sys=${asm##*/insn-}; sys=${sys%.s}
    "$JASMINC" -arch "$jarch" -system "$sys" -o "$OUT/insn-$sys.s" "$OUT/insn.jazz" \
      || fail "$JASMINC could not compile the test program for $sys"
    cmp -s "$OUT/insn-$sys.s" "$asm" \
      || fail "the recorded $asm is not what $JASMINC compiles now"
    INSN asm "$TABLE" "$asm" | tee "$OUT/asm-$sys.txt" \
      || fail "an export of $asm does not contain its instruction"
    systems=$((systems + 1))
  done
  [ "$systems" -gt 0 ] || fail "$RECORDED has no assembly file"
else
  "$JASMINC" -arch "$jarch" -o "$OUT/insn.s" "$OUT/insn.jazz" \
    || fail "$JASMINC could not compile the test program"
  INSN asm "$TABLE" "$OUT/insn.s" | tee "$OUT/asm.txt" \
    || fail "an export does not contain its instruction"
fi

# 2. Native run, or the recorded one.
if [ -n "$RECORDED" ]; then
  cp "$RECORDED/vectors.txt" "$OUT/vectors.txt"
else
  INSN header "$TABLE" > "$OUT/insns.h"
  "$CC" -O1 -std=c99 -Wall -Wextra -Werror -I "$OUT" -o "$OUT/run" "$HERE/run.c" "$OUT/insn.s" \
    || fail "cannot build the test driver"
  "$OUT/run" "$SEED" "$RANDOM_VECTORS" > "$OUT/vectors.txt" \
    || fail "the test driver failed"
fi

# 3. Cases.
"$JASMIN2EC" --arch="$jarch" -o "$OUT/Insn.ec" "$OUT/insn.jazz" \
  || fail "$JASMIN2EC could not extract the test program"
INSN wordeval "$HERE/WordEval.ec.in" > "$OUT/WordEval.ec"
ec "$OUT/WordEval.log" WordEval.ec || fail "WordEval.ec does not check (see $OUT/WordEval.log)"

names=$(awk '!/^[[:space:]]*(#|$)/ {print $1}' "$TABLE")
total=0
for n in $names; do
  INSN lemmas "$TABLE" "$OUT/Insn.ec" "$OUT/vectors.txt" "$n" > "$OUT/case_$n.ec"
  start=$(date +%s)
  ec "$OUT/cases/$n.log" "case_$n.ec" || fail "the cases of $n do not check (see $OUT/cases/$n.log)"
  cases=$(grep -c '^lemma ' "$OUT/case_$n.ec")
  vectors=$(awk -v n="$n" '$1 == n' "$OUT/vectors.txt" | wc -l | tr -d ' ')
  [ "$cases" -eq "$vectors" ] && [ "$cases" -gt 0 ] \
    || fail "$n: $cases cases for $vectors vectors"
  total=$((total + cases))
  printf 'cases: %s: %s checked (%ss)\n' "$n" "$cases" "$(( $(date +%s) - start ))"
done

# 4. Controls.
controls=0
check_rejected() {
  local what=$1 log=$2
  shift 2
  ec "$log" "$@" && fail "control not rejected: $what (accepted)"
  rejected "$log" "${!#}" || fail "control not rejected for the expected reason: $what (see $log)"
  controls=$((controls + 1))
  printf 'control: %s: rejected\n' "$what"
}

for n in $names; do
  INSN lemmas "$TABLE" "$OUT/Insn.ec" "$OUT/vectors.txt" "$n" --flip > "$OUT/flip_$n.ec"
  check_rejected "$n, result bit flipped" "$OUT/controls/flip_$n.log" "flip_$n.ec"
  ops=$(INSN operands "$TABLE" "$n")
  for x in $ops; do
    for y in $ops; do
      [[ "$x" < "$y" ]] || continue
      if [ -f "$SYMMETRIC" ] && why=$(awk -v n="$n" -v p="$x$y" '$1 == n && $2 == p {$1 = $2 = ""; sub(/^ +/, ""); print; f = 1} END {exit !f}' "$SYMMETRIC"); then
        printf 'control: %s, operands %s and %s: not run, %s\n' "$n" "$x" "$y" "$why"
        continue
      fi
      INSN lemmas "$TABLE" "$OUT/Insn.ec" "$OUT/vectors.txt" "$n" "--swap=$x,$y" > "$OUT/swap_${n}_$x$y.ec"
      check_rejected "$n, operands $x and $y exchanged" "$OUT/controls/swap_${n}_$x$y.log" "swap_${n}_$x$y.ec"
    done
  done
done

# The copy of the library the wrong models are made from, unchanged: the
# cases must check against it, so a rejection below comes from the change
# and not from loading a copy.
INSN mutate "$MUTANTS" "$ECLIB" "$OUT/mutants/unchanged" -
for n in $names; do
  ec "$OUT/controls/unchanged_$n.log" -I "Jasmin:mutants/unchanged" "case_$n.ec" \
    || fail "the cases of $n do not check against an unchanged copy of the library"
done
printf 'control: every entry against an unchanged copy of the library: checked\n'

INSN mutants "$MUTANTS" "$TABLE" > "$OUT/mutants.txt"
mutants=0
while read -r m entries; do
  INSN mutate "$MUTANTS" "$ECLIB" "$OUT/mutants/$m" "$m"
  for n in $entries; do
    check_rejected "$n against mutant $m" "$OUT/controls/mutant_${m}_$n.log" \
      -I "Jasmin:mutants/$m" "case_$n.ec"
  done
  mutants=$((mutants + 1))
done < "$OUT/mutants.txt"
[ "$mutants" -gt 0 ] || fail "no wrong models in $MUTANTS"

entries=$(printf '%s\n' $names | wc -l | tr -d ' ')
if [ -n "$RECORDED" ]; then
  where="the run recorded in ${RECORDED#"$(cd "$HERE/../.." && pwd)/"} ($(sed -n 1p "$RECORDED/host.txt"))"
else
  where="this processor"
fi
printf 'PASS: insn: %s: %s instructions, %s cases checked against %s; %s controls rejected (%s wrong models)\n' \
  "$ARCH" "$entries" "$total" "$where" "$controls" "$mutants"
