#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/insn-vectors.sh
# =======================
#
# The processor's side of a recorded instruction check (tests/insn/<host
# arch>/): links tests/insn/run.c with the recorded test program for this
# system, runs it with the recorded seed and count, and requires exactly
# the recorded vectors, which the insn job proves in EasyCrypt on the
# analysis host (make insn-vectors, tests/insn/vectors.sh). It needs a C
# compiler and python3, and no Jasmin tool. The PASS: line is the one
# tests/insn/vectors.sh prints.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

[ -f "tests/insn/$CI_HOST_ARCH/vectors.txt" ] \
  || ci_fail "tests/insn has no recorded run for $CI_HOST_ARCH"
ci_need make
ci_need cc
ci_need python3

make insn-vectors PYTHON=python3
