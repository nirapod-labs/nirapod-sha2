#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/jobs/toolchain.sh
# ====================
#
# The tools on PATH are the build of the toolchain release that
# toolchain/PIN names, and toolchain/ is the committed one.
#
# Checked:
#
#   toolchain/ is unmodified against HEAD;
#   the provenance record of the compiler on PATH names the release commit
#   and the Jasmin commit of toolchain/PIN, and the Jasmin checkout it was
#   built from is that commit, with the recorded tree and no change;
#   when EasyCrypt is installed, its pin and the coqword pin appear in the
#   build record, and the EasyCrypt configuration names the pinned commit;
#   the four Jasmin tools are present, run, and are the recorded binaries.
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
. toolchain/PIN

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
project=$(sed -n 's/^project commit: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
jcommit=$(sed -n 's/^jasmin commit: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
tree=$(sed -n 's/^jasmin tree: \([0-9a-f]\{40\}\).*/\1/p' "$prov")
[ "$project" = "$TOOLCHAIN_COMMIT" ] \
  || ci_fail "$prov: toolchain commit ${project:-none}, toolchain/PIN records $TOOLCHAIN_COMMIT"
[ "$jcommit" = "$JASMIN_COMMIT" ] \
  || ci_fail "$prov: jasmin commit ${jcommit:-none}, toolchain/PIN records $JASMIN_COMMIT"
[ -n "$tree" ] || ci_fail "$prov: no jasmin tree line"

tree_dir=$work/jasmin
git -C "$tree_dir" rev-parse --git-dir >/dev/null 2>&1 \
  || ci_fail "no Jasmin checkout at $tree_dir"
head=$(git -C "$tree_dir" rev-parse HEAD)
[ "$head" = "$JASMIN_COMMIT" ] \
  || ci_fail "$tree_dir: HEAD $head, toolchain/PIN records $JASMIN_COMMIT"
now_tree=$(git -C "$tree_dir" rev-parse 'HEAD^{tree}')
[ "$now_tree" = "$tree" ] \
  || ci_fail "$tree_dir: tree $now_tree, provenance records $tree"
[ -z "$(git -C "$tree_dir" status --porcelain --untracked-files=no)" ] \
  || ci_fail "$tree_dir: tracked files differ from the recorded tree"
echo "jasmin: $JASMIN_TAG $JASMIN_COMMIT, tree $tree, clean (toolchain $TOOLCHAIN_RELEASE $TOOLCHAIN_COMMIT)"

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

PASS="PASS: toolchain: release, pins and binary hashes match"
echo "$PASS"
