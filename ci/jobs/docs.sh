#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/docs.sh
# ================
#
# No docs/ directory in the working tree and in any commit reachable from
# HEAD. Provenance records live next to what they describe, in
# toolchain/PROVENANCE.md, src/PROVENANCE.md and proofs/PROVENANCE.md.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

ci_need git

if [ -e docs ] || [ -L docs ]; then
  ci_fail "docs/ exists in the working tree"
fi

hits=0
commits=$(git rev-list HEAD)
for commit in $commits; do
  status=0
  git ls-tree -r --name-only "$commit" | grep -E '(^|/)docs/' > /dev/null || status=$?
  [ "$status" -le 1 ] || ci_fail "tree scan failed on $commit (status $status)"
  if [ "$status" -eq 0 ]; then
    git ls-tree -r --name-only "$commit" | grep -E '(^|/)docs/' \
      | sed "s|^|$commit: |" >&2
    hits=1
  fi
done
[ "$hits" -eq 0 ] || ci_fail "docs/ appears in the history"

ncommits=$(printf '%s\n' "$commits" | wc -l | tr -d ' ')
PASS="PASS: docs: no docs/ in the tree or in $ncommits commits"
echo "$PASS"
