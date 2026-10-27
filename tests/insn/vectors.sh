#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/insn/vectors.sh
# =====================
#
#     tests/insn/vectors.sh ARCH OUT
#
# Repeats step 2 of tests/insn/check.sh on this processor for a recorded
# run: links run.c with the recorded test program for this system
# (tests/insn/ARCH/insn-SYSTEM.s), runs it with the recorded seed and
# count, and requires the vectors it prints to equal
# tests/insn/ARCH/vectors.txt byte for byte. Together with check.sh run
# with INSN_RECORDED=tests/insn/ARCH on the analysis host, which compiles
# the same program again and proves every recorded vector, this checks the
# models of ARCH against this processor without a Jasmin toolchain here.
# Work goes to OUT; the last line is a PASS: line.

set -euo pipefail

[ $# -eq 2 ] || { echo "usage: tests/insn/vectors.sh ARCH OUT" >&2; exit 2; }
ARCH=$1
OUT=$2
HERE=$(cd "$(dirname "$0")" && pwd)
REC=$HERE/$ARCH
CC=${CC:-cc}
PYTHON=${PYTHON:-python3}

fail() { printf 'FAIL: insn-vectors: %s\n' "$*"; exit 1; }

case $(uname -m) in
  x86_64|amd64) host=x86_64 ;;
  arm64|aarch64) host=aarch64 ;;
  *) host=unknown ;;
esac
[ "$host" = "$ARCH" ] || fail "the recorded run of $ARCH needs an $ARCH processor, this is $(uname -m)"
case $(uname -s) in
  Darwin) sys=macosx ;;
  Linux) sys=linux ;;
  *) fail "no recorded program for $(uname -s)" ;;
esac
[ -f "$REC/insn-$sys.s" ] || fail "no recorded program $REC/insn-$sys.s"
[ -f "$REC/vectors.txt" ] && [ -f "$REC/run.txt" ] || fail "$REC has no vectors.txt or run.txt"
read -r seed count < "$REC/run.txt" || fail "cannot read $REC/run.txt"
for t in "$CC" "$PYTHON"; do
  command -v "$t" >/dev/null 2>&1 || fail "required tool not found: $t"
done

rm -rf "$OUT"
mkdir -p "$OUT"
"$PYTHON" -I "$HERE/insn.py" header "$HERE/$ARCH.insn" > "$OUT/insns.h"
"$CC" -O1 -std=c99 -Wall -Wextra -Werror -I "$OUT" -o "$OUT/run" "$HERE/run.c" "$REC/insn-$sys.s" \
  || fail "cannot build the test driver"
"$OUT/run" "$seed" "$count" > "$OUT/vectors.txt" || fail "the test driver failed"
cmp -s "$OUT/vectors.txt" "$REC/vectors.txt" \
  || fail "this processor's results differ from the recorded ones ($OUT/vectors.txt)"

# The negative control: one recorded result changed must be caught.
awk 'NR == 1 { $NF = ($NF ~ /^0/) ? "1" substr($NF, 2) : "0" substr($NF, 2) } { print }' \
  "$REC/vectors.txt" > "$OUT/control.txt"
! cmp -s "$OUT/vectors.txt" "$OUT/control.txt" || fail "the control with one changed result was not caught"

n=$(wc -l < "$OUT/vectors.txt" | tr -d ' ')
printf 'PASS: insn-vectors: %s on %s: %s vectors equal the recorded run; 1 control caught\n' "$ARCH" "$sys" "$n"
