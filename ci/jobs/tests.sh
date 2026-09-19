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

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need make
ci_need cc

out=$(ci_out)
make "$out/tests/smoke" "$out/tests/smoke-public"

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

PASS="PASS: tests: smoke on both libraries, $ran suite script(s)"
echo "$PASS"
