#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The instruction-set suite: the CPU features capi/units.c declares for
# every unit and family against the instructions each export can reach,
# with its negative controls (tests/isa/check.py), in the assembly the
# pinned Jasmin compiles for every unit and system. Needs jasminc and
# python3.

set -eu

root=$(cd "$(dirname "$0")/../.." && pwd)
command -v python3 >/dev/null 2>&1 || { echo "isa: python3 not found" >&2; exit 1; }
command -v jasminc >/dev/null 2>&1 || { echo "isa: jasminc not found" >&2; exit 1; }
make -s -C "$root" asm ARCH=aarch64 SYSTEM_aarch64=macosx
make -s -C "$root" asm ARCH=aarch64 SYSTEM_aarch64=linux
make -s -C "$root" asm ARCH=x86_64
exec python3 -I "$root/tests/isa/check.py" "$root/capi/units.c" "$root/capi/internal.h" \
    "$root"/build/asm/linux/*.s "$root"/build/asm/macosx/*.s
