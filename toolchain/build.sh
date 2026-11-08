#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# toolchain/build.sh
# ==================
#
# Builds the pinned toolchain of toolchain/PIN:
#
#   toolchain/build.sh [--no-easycrypt] [switch | jasmin | test | all]
#
# It fetches nirapod-labs/toolchain at TOOLCHAIN_COMMIT into $WORK/src,
# checks that the checkout is that commit and records the same Jasmin and
# EasyCrypt pins as toolchain/PIN, and runs the release's own build.sh
# with the same arguments and the same $WORK. That script checks every
# download against its pin, machine-checks the Rocq development of the
# compiler and writes the tools to $WORK/bin and its records to
# $WORK/logs; docs/TOOLCHAIN.md describes what it establishes.
#
# Environment: WORK (default toolchain/work), JOBS, SWITCH and OPAMROOT,
# passed on unchanged. The build needs network access.

set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=PIN
. "$HERE/PIN"

export WORK=${WORK:-$HERE/work}
src=$WORK/src/toolchain
die() { echo "toolchain/build.sh: $*" >&2; exit 1; }

mkdir -p "$WORK/src"
if [ ! -d "$src/.git" ]; then
  git init -q "$src"
  git -C "$src" remote add origin "$TOOLCHAIN_URL"
fi
git -C "$src" fetch -q --depth 1 origin "$TOOLCHAIN_COMMIT" \
  || die "cannot fetch $TOOLCHAIN_COMMIT from $TOOLCHAIN_URL"
git -C "$src" -c advice.detachedHead=false checkout -q --force "$TOOLCHAIN_COMMIT"
git -C "$src" clean -fdxq
[ "$(git -C "$src" rev-parse HEAD)" = "$TOOLCHAIN_COMMIT" ] \
  || die "$src is not at $TOOLCHAIN_COMMIT"

# The pins recorded here must be the release's.
pin() { sed -n "s/^$1=//p" "$src/$2"; }
[ "$(pin JASMIN_COMMIT jasmin/PIN)" = "$JASMIN_COMMIT" ] \
  || die "the release pins Jasmin $(pin JASMIN_COMMIT jasmin/PIN), toolchain/PIN records $JASMIN_COMMIT"
[ "$(pin EASYCRYPT_COMMIT easycrypt/PIN)" = "$EASYCRYPT_COMMIT" ] \
  || die "the release pins EasyCrypt $(pin EASYCRYPT_COMMIT easycrypt/PIN), toolchain/PIN records $EASYCRYPT_COMMIT"
[ "$(pin COQWORD_COMMIT jasmin/PIN)" = "$COQWORD_COMMIT" ] \
  || die "the release pins coqword $(pin COQWORD_COMMIT jasmin/PIN), toolchain/PIN records $COQWORD_COMMIT"

echo "== nirapod-labs/toolchain $TOOLCHAIN_RELEASE at $TOOLCHAIN_COMMIT"
exec "$src/build.sh" "$@"
