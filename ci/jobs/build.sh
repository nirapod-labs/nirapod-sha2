#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/build.sh
# =================
#
# Builds the host architecture's units and both libraries.
#
#   make asm   the assembly of the host's three units,
#              compiled by the pinned Jasmin
#   make all   the host objects, the production library and the testing
#              library, from that assembly
#
# Then checks that every expected file exists, and on AArch64 that the
# assembly does not touch x18, which macOS reserves and the C layer does
# not clear.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need cc
ci_need ar

jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '4')
[ "$jobs" -le 8 ] || jobs=8

ci_need jasminc
make -j"$jobs" asm
echo "assembly: build/asm/$CI_HOST_SYSTEM"
make -j"$jobs" all

out=$(ci_out)
missing=0
for unit in $(ci_units "$CI_HOST_ARCH"); do
  if [ "$asm" = jasmin ]; then
    [ -f "build/units/$unit.jazz" ] || { echo "missing build/units/$unit.jazz"; missing=1; }
  fi
  [ -f "$root/asm/$CI_HOST_SYSTEM/$unit.s" ] \
    || { echo "missing $root/asm/$CI_HOST_SYSTEM/$unit.s"; missing=1; }
done
for lib in libnirapod_sha2.a libnirapod_sha2_testing.a; do
  [ -f "$out/lib/$lib" ] || { echo "missing $out/lib/$lib"; missing=1; }
done
[ "$missing" -eq 0 ] || ci_fail "the build did not produce every expected file"

units=0
for unit in $(ci_units "$CI_HOST_ARCH"); do
  units=$((units + 1))
done

if [ "$CI_HOST_ARCH" = aarch64 ]; then
  bad=0
  for f in "$root"/asm/"$CI_HOST_SYSTEM"/aarch64-*.s; do
    [ -f "$f" ] || continue
    if grep -E -n '(^|[^a-z0-9_])[xw]18([^0-9]|$)' "$f"; then
      echo "asm-policy: $f uses x18"
      bad=1
    fi
  done
  [ "$bad" -eq 0 ] || ci_fail "the AArch64 assembly uses x18"
  echo "asm-policy: x18 unused in the $CI_HOST_SYSTEM AArch64 units"
else
  echo "asm-policy: not applicable to $CI_HOST_ARCH (the rule is AArch64)"
fi

echo "units: $units assembly files, $out/lib/libnirapod_sha2.a, $out/lib/libnirapod_sha2_testing.a"
PASS="PASS: build: $units $CI_HOST_ARCH units ($asm assembly) and both libraries"
echo "$PASS"
