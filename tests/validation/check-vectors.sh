#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# check-vectors.sh VECTORS
# ========================
#
# Checks the vector files the validation runner reads against the SHA-256
# sums pinned beside them, before the runner starts: every *.rsp of
# VECTORS/cavp and every *.json of VECTORS/wycheproof must be listed in its
# directory's SHA256SUMS, every listed file must exist, and every sum must
# match. The sums are computed with the system's sha256sum or shasum, not
# with the library under test. Exit status 0 when all match, 1 otherwise.

set -eu

[ $# -eq 1 ] || { echo "usage: $0 VECTORS" >&2; exit 2; }
vectors=$1

if command -v sha256sum >/dev/null 2>&1; then
    sum() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
    sum() { shasum -a 256 "$1" | awk '{print $1}'; }
else
    echo "check-vectors: neither sha256sum nor shasum found" >&2
    exit 1
fi

bad=0
files=0
for spec in cavp:rsp wycheproof:json; do
    dir=$vectors/${spec%%:*}
    ext=${spec#*:}
    list=$dir/SHA256SUMS
    if [ ! -f "$list" ]; then
        echo "check-vectors: $list is missing" >&2
        bad=1
        continue
    fi
    for f in "$dir"/*."$ext"; do
        [ -f "$f" ] || { echo "check-vectors: no *.$ext in $dir" >&2; bad=1; continue; }
        if ! awk -v n="$(basename "$f")" '$2 == n { found = 1 } END { exit !found }' "$list"; then
            echo "check-vectors: $f is not listed in $list" >&2
            bad=1
        fi
    done
    while read -r want name; do
        [ -n "$name" ] || continue
        if [ ! -f "$dir/$name" ]; then
            echo "check-vectors: $dir/$name is listed but missing" >&2
            bad=1
            continue
        fi
        got=$(sum "$dir/$name")
        if [ "$got" != "$want" ]; then
            echo "check-vectors: $dir/$name has SHA-256 $got, pinned $want" >&2
            bad=1
        fi
        files=$((files + 1))
    done < "$list"
done

if [ "$bad" -ne 0 ]; then
    echo "check-vectors: FAIL"
    exit 1
fi
echo "check-vectors: PASS ($files files match their pinned SHA-256)"
