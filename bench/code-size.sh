#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# code-size.sh
# ============
#
# Writes the code size of each unit object and each C layer object of a
# build as CSV:
#
#     sh code-size.sh BUILD/<arch>-<system> [OUT.csv]
#
# The size reported is the bytes the object's code and its read-only data
# take: __text and __const on Mach-O, .text and .rodata* on ELF. The
# Jasmin units carry the SHA-2 round constants in read-only data, so both
# are counted. Objects that make up the public archive are named by the
# unit they implement; the C layer's files follow their object names.

set -eu

libdir=${1:?usage: code-size.sh LIBDIR [OUT.csv]}
out=${2:-"$libdir/code-size.csv"}

mkdir -p "$(dirname "$out")"

system=$(uname -s)

macho_sizes()
{
    file=$1
    text=$(size -m "$file" 2>/dev/null | sed -n 's/.*Section (__TEXT, __text): //p')
    const=$(size -m "$file" 2>/dev/null | sed -n 's/.*Section (__TEXT, __const): //p')
    [ -n "$text" ] || text=0
    [ -n "$const" ] || const=0
}

elf_sizes()
{
    file=$1
    text=$(size -A "$file" 2>/dev/null | awk '$1 == ".text" { print $2; exit }')
    const=$(size -A "$file" 2>/dev/null | awk '$1 ~ /^\.rodata/ { sum += $2 } END { print sum + 0 }')
    [ -n "$text" ] || text=0
    [ -n "$const" ] || const=0
}

printf 'unit,text_bytes,const_bytes,total_bytes\n' > "$out"

for file in "$libdir"/obj/*.o; do
    [ -f "$file" ] || continue
    name=$(basename "$file" .o)
    case $name in
    libnirapod_sha2) continue ;;
    esac
    if [ "$system" = Darwin ]; then
        macho_sizes "$file"
    else
        elf_sizes "$file"
    fi
    printf '%s,%s,%s,%s\n' "$name" "$text" "$const" "$((text + const))" >> "$out"
done

for file in "$libdir"/obj/c/*.o; do
    [ -f "$file" ] || continue
    name="c/$(basename "$file" .o)"
    if [ "$system" = Darwin ]; then
        macho_sizes "$file"
    else
        elf_sizes "$file"
    fi
    printf '%s,%s,%s,%s\n' "$name" "$text" "$const" "$((text + const))" >> "$out"
done

printf 'code-size: %s\n' "$out"
