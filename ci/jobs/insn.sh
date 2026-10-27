#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/insn.sh
# ===============
#
# The proofs about the SHA-NI kernel rest on EasyCrypt models of the
# instructions it uses, and nothing proves those models right: they are
# checked against the processor instead. This job runs make insn-check,
# which, for the instructions of tests/insn/<host arch>.insn:
#
#   1. compiles a Jasmin program with one export per instruction and
#      requires each export to contain its instruction;
#   2. runs it natively on edge and random inputs;
#   3. requires EasyCrypt to prove, by computation, that the operators
#      jasmin2ec extracts for each export give, on each input, the result
#      the processor produced;
#   4. requires EasyCrypt to reject every negative control: a result bit
#      flipped, two operands exchanged, and each wrong model of
#      tests/insn/<host arch>.mutants.
#
# The architecture is the host's, since the instructions must execute;
# a host without a table for its architecture fails.
#
# It then runs make insn-check-recorded: the same four steps for each run
# recorded on another processor under tests/insn/<arch>/ (the Armv8-A
# instructions), with step 1 requiring the recorded program to be what the
# pinned jasminc compiles now and step 2 taking the recorded vectors. The
# job insn-vectors repeats step 2 on such a processor. Each check prints
# its own PASS: line.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

[ -f "tests/insn/$CI_HOST_ARCH.insn" ] \
  || ci_fail "tests/insn has no instruction table for $CI_HOST_ARCH"
ci_need make
ci_need jasminc
ci_need jasmin2ec
ci_need easycrypt
ci_need python3

make insn-check PYTHON=python3
make insn-check-recorded PYTHON=python3
