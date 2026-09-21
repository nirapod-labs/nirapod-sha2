#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/exports.sh
# ===================
#
# The production library exports exactly the functions of
# include/nirapod_sha2.h, and the check rejects a library that exports one
# more. The second half is the negative control: the same object with one
# extra global function must fail the check.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need nm

out=$(ci_out)
lib=$out/lib/libnirapod_sha2.a
control=$out/lib/exports-control.a
check=tests/abi/check-exports.sh

make "$lib" "$control"

case $CI_HOST_SYSTEM in
  macosx) prefix=_ ;;
  linux) prefix= ;;
  *) ci_fail "unsupported system: $CI_HOST_SYSTEM" ;;
esac

sh "$check" check include/nirapod_sha2.h "$lib" "$prefix"

if sh "$check" check include/nirapod_sha2.h "$control" "$prefix" \
    > "$CI_RUN_DIR/exports-control.log" 2>&1; then
  ci_fail "the negative control passed: an extra global symbol was not detected"
fi
echo "negative control: the extra global symbol was rejected"

PASS="PASS: exports: $lib and the negative control"
echo "$PASS"
