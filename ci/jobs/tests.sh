#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/tests.sh
# =================
#
# Runs every test suite under tests/ that has a run.sh, then the smoke
# tests of the C API: once against the testing library, which forces every
# kernel the CPU offers, and once against the production library through
# the public header alone. The ABI and constant-time suites have their own
# jobs.
#
# SHA2_BASELINES is the install directory of the pinned independent
# implementations (toolchain/baselines/build.sh WORK makes WORK/install).
# The differential and long suites compare every kernel with OpenSSL,
# AWS-LC, BoringSSL and HACL* from there. They are part of this job:
# without SHA2_BASELINES, or with an implementation missing, the job fails
# rather than pass with the comparison skipped.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need cc

out=$(ci_out)
make "$out/tests/smoke" "$out/tests/smoke-public"

[ -n "${SHA2_BASELINES:-}" ] \
  || ci_fail "SHA2_BASELINES is not set: the differential suite needs the pinned implementations (toolchain/baselines/build.sh)"
. "$CI_REPO_ROOT/toolchain/baselines/PIN"
for v in OPENSSL:$OPENSSL_NAME AWSLC:$AWSLC_NAME BORINGSSL:$BORINGSSL_NAME; do
  dir=$SHA2_BASELINES/${v#*:}
  [ -f "$dir/include/openssl/sha.h" ] || ci_fail "oracle missing: $dir"
  export "ORACLE_${v%%:*}=$dir"
done
dir=$SHA2_BASELINES/$HACL_NAME
[ -f "$dir/include/hacl/Hacl_Hash_SHA2.h" ] || ci_fail "oracle missing: $dir"
export ORACLE_HACL=$dir
oracles="OpenSSL, AWS-LC, BoringSSL and HACL* from $SHA2_BASELINES"
echo "differential oracles: $oracles"

ran=0
for suite in tests/*/run.sh; do
  [ -f "$suite" ] || continue
  echo "suite: $suite"
  if [ -x "$suite" ]; then
    "$suite"
  else
    sh "$suite"
  fi
  ran=$((ran + 1))
done

echo "smoke: testing library"
"$out/tests/smoke"
echo "smoke: production library"
"$out/tests/smoke-public"

PASS="PASS: tests: smoke on both libraries, $ran suite script(s), oracles: $oracles"
echo "$PASS"
