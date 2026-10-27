#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The time limit of the local CI (ci_cap in ci/lib.sh) stops what it
# started: a command past its limit ends with status 124, and when an
# outer limit expires while an inner capped command is still running,
# no process of the inner command survives. The negative control runs the
# same nesting under a copy of the wrapper with its signal forwarding
# removed and requires the leak to be seen, so the check can fail.

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

fail() { printf 'FAIL: cicap: %s\n' "$*"; exit 1; }

# A marker no other process has, so the survivor can be found by its
# arguments without matching anything else on the host.
mark="cicap-$$-$RANDOM"

survivors() {
  # "[c]..." matches the marker but not this grep's own arguments.
  ps -eo pid=,args= | grep -- "[c]${mark#c}" | awk '{printf " %s", $1}' || true
}

nested() { # LIB: outer limit 2 s around an inner limit of 100 s
  bash -c '. "$1"; ci_cap 2 bash -c ". \"$1\"; ci_cap 100 perl -e \"sleep 60\" $2"' _ "$1" "$mark" \
    > /dev/null 2>&1 && return 1
  return 0
}

# 1. A plain expiry gives 124.
bash -c '. "$1"; ci_cap 1 sleep 30' _ "$root/ci/lib.sh" > /dev/null 2>&1 && rc=0 || rc=$?
[ "$rc" -eq 124 ] || fail "expiry gave status $rc, not 124"

# 2. Nested limits leave nothing behind.
nested "$root/ci/lib.sh" || fail "the outer limit did not expire"
sleep 4
left=$(survivors)
[ -z "$left" ] || { kill $left 2>/dev/null; fail "inner command survived the outer limit:$left"; }

# 3. Control: without signal forwarding the inner command survives.
sed '/for my $sig ("TERM", "INT", "HUP")/,/^    }$/d' "$root/ci/lib.sh" > "$work/lib.sh"
! grep -q 'for my $sig' "$work/lib.sh" || fail "control: could not remove the forwarding"
nested "$work/lib.sh" || fail "control: the outer limit did not expire"
sleep 4
left=$(survivors)
[ -n "$left" ] || fail "control: the leak without forwarding was not seen"
kill $left 2>/dev/null || true

printf 'PASS: cicap: expiry status 124; nested limits leave no process; control without forwarding leaks as expected\n'
