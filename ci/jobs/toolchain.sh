#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/toolchain.sh
# ====================
#
# The tools on PATH are the pinned toolchain of toolchain/, and the
# inputs of toolchain/ are the committed ones.
#
# Checked:
#
#   toolchain/ is unmodified against HEAD;
#   every patch listed in toolchain/jasmin/SERIES has its recorded SHA-256,
#   and no unlisted patch file exists;
#   the Jasmin provenance record of the compiler on PATH names the pinned
#   commit, its tree is clean, and the commits applied on the pin are
#   exactly the SERIES, in order;
#   when EasyCrypt is installed, its pin and the coqword pin appear in the
#   EasyCrypt build record, and the EasyCrypt configuration names the
#   pinned commit;
#   the four Jasmin tools are present and run.
#
# The work directory is derived from the real path of jasminc:
#
#   <work>/bin/jasminc                 (installed build)
#   <work>/jasmin/compiler/jasminc     (build tree)
#
# SHA2_TOOLCHAIN_WORK, SHA2_TOOLCHAIN_PROVENANCE and SHA2_EASYCRYPT_WORK
# override the derived paths. A build that holds EasyCrypt under another
# work directory, as a reused build may, needs SHA2_EASYCRYPT_WORK.

set -euo pipefail
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
cd "${CI_REPO_ROOT:?}" || ci_fail "CI_REPO_ROOT is not set"

: "${CI_NEED_EASYCRYPT:=0}"

[ -z "$(git status --porcelain --untracked-files=all -- toolchain)" ] \
  || ci_fail "toolchain/ has uncommitted changes"

# shellcheck disable=SC1091
. toolchain/jasmin/PIN
# shellcheck disable=SC1091
. toolchain/easycrypt/PIN

entries=$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' toolchain/jasmin/SERIES)
count=$(printf '%s\n' "$entries" | wc -l | tr -d ' ')
[ "$count" -gt 0 ] || ci_fail "toolchain/jasmin/SERIES lists no patch"

listed=$(printf '%s\n' "$entries" | awk '{print $1}')
for f in toolchain/jasmin/patches/*.patch toolchain/jasmin/patches-simd/*.patch; do
  [ -e "$f" ] || continue
  rel=${f#toolchain/jasmin/}
  if ! printf '%s\n' "$listed" | grep -Fxq "$rel"; then
    ci_fail "$rel is not listed in toolchain/jasmin/SERIES"
  fi
done

while read -r name sum; do
  [ -n "$name" ] || continue
  [ -f "toolchain/jasmin/$name" ] || ci_fail "SERIES lists a missing file: $name"
  got=$(ci_sha256 "toolchain/jasmin/$name")
  [ "$got" = "$sum" ] || ci_fail "$name: SHA-256 $got, SERIES records $sum"
done <<EOF
$entries
EOF
echo "series: $count patches, every SHA-256 matches"

# The Jasmin work directory, from the compiler on PATH.
ci_need jasminc
bin=$(command -v jasminc)
bin=$(cd "$(dirname "$bin")" && pwd -P)/$(basename "$bin")
if [ -n "${SHA2_TOOLCHAIN_WORK:-}" ]; then
  work=$SHA2_TOOLCHAIN_WORK
elif [ "$(basename "$(dirname "$bin")")" = bin ]; then
  work=$(dirname "$(dirname "$bin")")
elif [ "$(basename "$(dirname "$bin")")" = compiler ]; then
  work=$(cd "$(dirname "$bin")/../.." && pwd -P)
else
  ci_fail "cannot tell the toolchain work directory from $bin"
fi
[ -d "$work" ] || ci_fail "toolchain work directory not found: $work"

prov=${SHA2_TOOLCHAIN_PROVENANCE:-$work/logs/provenance.txt}
[ -f "$prov" ] || ci_fail "no provenance record at $prov"
pin=$(sed -n 's/^jasmin pin: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
jhead=$(sed -n 's/^jasmin HEAD: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
tree=$(sed -n 's/^jasmin tree: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
[ "$pin" = "$JASMIN_COMMIT" ] \
  || ci_fail "$prov: jasmin pin ${pin:-none}, toolchain/jasmin/PIN records $JASMIN_COMMIT"
[ -n "$jhead" ] || ci_fail "$prov: no jasmin HEAD line"
[ -n "$tree" ] || ci_fail "$prov: no jasmin tree line"

tree_dir=$work/jasmin
git -C "$tree_dir" rev-parse --git-dir >/dev/null 2>&1 \
  || ci_fail "no Jasmin checkout at $tree_dir"
head=$(git -C "$tree_dir" rev-parse HEAD)
[ "$head" = "$jhead" ] \
  || ci_fail "$tree_dir: HEAD $head, provenance records $jhead"
now_tree=$(git -C "$tree_dir" rev-parse 'HEAD^{tree}')
[ "$now_tree" = "$tree" ] \
  || ci_fail "$tree_dir: tree $now_tree, provenance records $tree"
[ -z "$(git -C "$tree_dir" status --porcelain --untracked-files=no)" ] \
  || ci_fail "$tree_dir: tracked files differ from the recorded tree"
git -C "$tree_dir" rev-parse -q --verify "$JASMIN_COMMIT^{commit}" >/dev/null \
  || ci_fail "$tree_dir: the pin $JASMIN_COMMIT is not in the checkout"
git -C "$tree_dir" merge-base --is-ancestor "$JASMIN_COMMIT" HEAD \
  || ci_fail "$tree_dir: HEAD does not descend from the pin"

tmp=$(mktemp -d) || ci_fail "mktemp failed"
trap 'rm -rf "$tmp"' EXIT
sed -n '/^commits on the pin:/,/^[^ ]/p' "$prov" \
  | sed -n 's/^  \([0-9a-f]\{40\} .*\)$/\1/p' > "$tmp/provenance-commits"
git -C "$tree_dir" log --reverse --format='%H %s' \
  "$JASMIN_COMMIT..HEAD" > "$tmp/tree-commits"
done_count=$(wc -l < "$tmp/tree-commits" | tr -d ' ')
[ "$done_count" = "$count" ] \
  || ci_fail "the Jasmin tree holds $done_count commits on the pin, SERIES has $count"
if ! diff -u "$tmp/provenance-commits" "$tmp/tree-commits" > "$tmp/commits.diff"; then
  cat "$tmp/commits.diff" >&2
  ci_fail "the commits on the pin are not the SERIES recorded in the provenance"
fi
echo "jasmin: pin $JASMIN_COMMIT, tree $tree, $count commits, clean"

if command -v easycrypt >/dev/null 2>&1; then
  ecbin=$(command -v easycrypt)
  ecbin=$(cd "$(dirname "$ecbin")" && pwd -P)/$(basename "$ecbin")
  if [ -n "${SHA2_EASYCRYPT_WORK:-}" ]; then
    ecwork=$SHA2_EASYCRYPT_WORK
  else
    # <work>/opam/<switch>/bin/easycrypt
    ecwork=$(cd "$(dirname "$ecbin")/../../.." && pwd -P)
  fi
  ecprov=$ecwork/logs/provenance.txt
  eccfg=$ecwork/logs/easycrypt-config.txt
  [ -f "$ecprov" ] || ci_fail "no EasyCrypt provenance record at $ecprov"
  [ -f "$eccfg" ] || ci_fail "no EasyCrypt configuration record at $eccfg"
  grep -q "easycrypt.dev .*#$EASYCRYPT_COMMIT" "$ecprov" \
    || ci_fail "$ecprov: easycrypt pin is not $EASYCRYPT_COMMIT"
  grep -q "coq-mathcomp-word.dev .*#$COQWORD_COMMIT" "$ecprov" \
    || ci_fail "$ecprov: coqword pin is not $COQWORD_COMMIT"
  grep -q "git-hash:.*g${EASYCRYPT_COMMIT:0:7}" "$eccfg" \
    || ci_fail "$eccfg: EasyCrypt does not report commit ${EASYCRYPT_COMMIT:0:7}"
  ci_need jasmin2ec
  echo "easycrypt: pin $EASYCRYPT_COMMIT, work $ecwork"
elif [ "$CI_NEED_EASYCRYPT" = 1 ]; then
  ci_fail "EasyCrypt is not on PATH but the selected jobs need it"
else
  echo "easycrypt: not installed (a compiler-only toolchain)"
fi

for t in jasminc jasmin-ct jasmin-checksafety jasmin2ec; do
  ci_need "$t"
  if [ "$t" = jasminc ]; then
    out=$("$t" -version 2>&1) || ci_fail "$t -version failed"
  else
    out=$("$t" --version 2>&1) || ci_fail "$t --version failed"
  fi
  case $out in
    *Jasmin*) ;;
    *) ci_fail "$t does not report a Jasmin version: $out" ;;
  esac
done

hashes=$work/logs/binaries.sha256
[ -f "$hashes" ] || ci_fail "no binary hashes at $hashes"
for t in jasminc jasmin-ct jasmin-checksafety jasmin2ec; do
  want=$(awk -v n="$t" '$2 == n { print $1 }' "$hashes")
  [ -n "$want" ] || ci_fail "$hashes records no hash for $t"
  # The record covers the compiler binaries. An installed build puts a
  # wrapper in bin/ and the binary under jasmin/compiler/.
  if [ -f "$work/jasmin/compiler/$t" ]; then
    binary=$work/jasmin/compiler/$t
  else
    binary=$(command -v "$t")
  fi
  got=$(ci_sha256 "$binary")
  [ "$got" = "$want" ] \
    || ci_fail "$t: SHA-256 $got, $hashes records $want"
  cmd=$(command -v "$t")
  cmd=$(cd "$(dirname "$cmd")" && pwd -P)/$(basename "$cmd")
  if [ "$cmd" != "$binary" ] && ! grep -Fq "$binary" "$cmd"; then
    ci_fail "$cmd does not run the recorded binary $binary"
  fi
done
echo "binaries: jasminc jasmin-ct jasmin-checksafety jasmin2ec run and match $hashes"

PASS="PASS: toolchain: pins, patch series and binary hashes match"
echo "$PASS"
