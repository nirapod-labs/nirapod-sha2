#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/ct/exports.sh
# ===================
#
# Every export of the root file was typed by both constant-time checkers.
#
#     exports.sh <root.jinc> <namespace> <ct.log> <sct.log>
#
# The exports are the names of the `export fn` lines of root.jinc.
# jasmin-ct --print lists each export it typed as `fn <namespace>::<name>`;
# jasmin-ct --sct lists every function it typed as
# `modmsf <namespace>::<name> :` or `nomodmsf ...`. The script prints every
# export missing from either log and exits 1 if there is one, or if
# root.jinc has no export at all.

set -eu

[ $# -eq 4 ] || { echo "usage: exports.sh <root.jinc> <namespace> <ct.log> <sct.log>" >&2; exit 2; }
root=$1
ns=$2
ct=$3
sct=$4

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

sed -n 's/^export fn \([a-z0-9_]*\)(.*/\1/p' "$root" | LC_ALL=C sort -u > "$tmp/want"
[ -s "$tmp/want" ] || { echo "exports.sh: no export in $root" >&2; exit 1; }

sed -n "s/^fn $ns::\\([a-z0-9_]*\\) .*/\\1/p" "$ct" | LC_ALL=C sort -u > "$tmp/ct"
sed -n "s/^[a-z]*modmsf $ns::\\([a-z0-9_]*\\) :.*/\\1/p" "$sct" | LC_ALL=C sort -u > "$tmp/sct"

status=0
for name in $(LC_ALL=C comm -23 "$tmp/want" "$tmp/ct"); do
  echo "exports.sh: $ns::$name is not in the jasmin-ct output $ct"
  status=1
done
for name in $(LC_ALL=C comm -23 "$tmp/want" "$tmp/sct"); do
  echo "exports.sh: $ns::$name is not in the jasmin-ct --sct output $sct"
  status=1
done
if [ "$status" -eq 0 ]; then
  echo "exports.sh: $ns: all $(wc -l < "$tmp/want" | tr -d ' ') exports typed by jasmin-ct and jasmin-ct --sct"
fi
exit $status
