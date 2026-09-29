#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/constants/check.py
# ========================
#
# Derives every constant table of the Jasmin source from its definition
# and compares it with the table as written under src/:
#
#   SHA256_K, SHA512_K       FIPS 180-4 sections 4.2.2 and 4.2.3: the first
#                            32 (64) bits of the fractional parts of the
#                            cube roots of the first 64 (80) primes
#   SHA256_IV                section 5.3.3: first 32 bits of the fractional
#                            parts of the square roots of the first 8 primes
#   SHA224_IV                section 5.3.2: the second 32 bits of the same
#                            for the 9th to 16th primes
#   SHA512_IV, SHA384_IV     sections 5.3.5 and 5.3.4: first 64 bits, first
#                            8 primes and 9th to 16th primes
#   SHA512_224_IV,           section 5.3.6: SHA-512 of the ASCII string
#   SHA512_256_IV            "SHA-512/t" under the SHA-512 IV with every
#                            word XORed with 0xa5a5a5a5a5a5a5a5
#   SHA256_X8_K, SHA512_X4_K the K tables with each word repeated once per
#                            lane (8 and 4), so word t of the 256-bit view
#                            is K_t in every lane
#   *_BSWAP, *_ROR8, *_LO,   PSHUFB and VPSHUFB masks, checked as the byte
#   *_HI                     permutation they perform (see MASKS)
#
# The roots are computed exactly with integer arithmetic. SHA-512/t needs a
# SHA-512 compression with a chosen IV, which hashlib does not offer, so it
# is written out here from FIPS 180-4 section 6.4.2; before it is used it
# must reproduce hashlib's SHA-512 of three messages that cover one, two and
# three blocks.
#
# Every array constant under src/ must be one of the tables above: a table
# this script does not know fails, so a new constant cannot go unchecked.
#
# Negative controls: for every table, the same comparison is run with one
# bit of one entry flipped, and must fail. A control that passes is a
# failure of the check.
#
#     check.py SRC_DIR
#
# Exit status 0 when every table matches and every control fails, 1 when a
# table differs or a control does not fail, 2 on a usage or parse error.

import hashlib
import os
import re
import struct
import sys

M32 = (1 << 32) - 1
M64 = (1 << 64) - 1


def primes(n):
    found = []
    candidate = 2
    while len(found) < n:
        if all(candidate % p for p in found):
            found.append(candidate)
        candidate += 1
    return found


def iroot(x, k):
    """The integer k-th root of x, rounded down."""
    lo, hi = 0, 1
    while hi ** k <= x:
        hi *= 2
    while lo < hi - 1:
        mid = (lo + hi) // 2
        if mid ** k <= x:
            lo = mid
        else:
            hi = mid
    return lo


def frac_bits(p, k, bits, skip=0):
    """Bits skip .. skip + bits - 1 after the binary point of p^(1/k)."""
    total = skip + bits
    root = iroot(p << (k * total), k)
    return root & ((1 << bits) - 1)


PRIMES = primes(80)
K256 = [frac_bits(p, 3, 32) for p in PRIMES[:64]]
K512 = [frac_bits(p, 3, 64) for p in PRIMES[:80]]
IV256 = [frac_bits(p, 2, 32) for p in PRIMES[:8]]
IV224 = [frac_bits(p, 2, 32, skip=32) for p in PRIMES[8:16]]
IV512 = [frac_bits(p, 2, 64) for p in PRIMES[:8]]
IV384 = [frac_bits(p, 2, 64) for p in PRIMES[8:16]]


def rotr64(x, n):
    return ((x >> n) | (x << (64 - n))) & M64


def sha512_blocks(h, message):
    """FIPS 180-4 section 6.4.2 over the padded message (section 5.1.2)."""
    length = len(message) * 8
    padded = message + b"\x80"
    padded += b"\x00" * ((112 - len(padded)) % 128)
    padded += length.to_bytes(16, "big")
    h = list(h)
    for offset in range(0, len(padded), 128):
        w = list(struct.unpack(">16Q", padded[offset:offset + 128]))
        for t in range(16, 80):
            s0 = rotr64(w[t - 15], 1) ^ rotr64(w[t - 15], 8) ^ (w[t - 15] >> 7)
            s1 = rotr64(w[t - 2], 19) ^ rotr64(w[t - 2], 61) ^ (w[t - 2] >> 6)
            w.append((s1 + w[t - 7] + s0 + w[t - 16]) & M64)
        a, b, c, d, e, f, g, hh = h
        for t in range(80):
            big_s1 = rotr64(e, 14) ^ rotr64(e, 18) ^ rotr64(e, 41)
            ch = (e & f) ^ (~e & g)
            t1 = (hh + big_s1 + ch + K512[t] + w[t]) & M64
            big_s0 = rotr64(a, 28) ^ rotr64(a, 34) ^ rotr64(a, 39)
            maj = (a & b) ^ (a & c) ^ (b & c)
            t2 = (big_s0 + maj) & M64
            hh, g, f, e, d, c, b, a = g, f, e, (d + t1) & M64, c, b, a, (t1 + t2) & M64
        h = [(x + y) & M64 for x, y in zip(h, [a, b, c, d, e, f, g, hh])]
    return h


def self_test():
    """The SHA-512 written here must agree with hashlib before it is used."""
    for message in (b"abc", bytes(range(200)), b"\x5a" * 300):
        words = sha512_blocks(IV512, message)
        mine = b"".join(x.to_bytes(8, "big") for x in words)
        if mine != hashlib.sha512(message).digest():
            raise SystemExit("check.py: the SHA-512 of this script disagrees with hashlib")


def sha512_t_iv(t):
    """FIPS 180-4 section 5.3.6."""
    h = [x ^ 0xa5a5a5a5a5a5a5a5 for x in IV512]
    return sha512_blocks(h, ("SHA-512/%d" % t).encode("ascii"))


# ---------------------------------------------------------------------
# Masks. PSHUFB and VPSHUFB select, for output byte i of each 128-bit lane,
# input byte mask[i] & 15 of the same lane, or zero when bit 7 of mask[i]
# is set. A mask is checked by the permutation it performs on one lane,
# given as the source index of every output byte (None for zero).
# ---------------------------------------------------------------------


def lane_bswap(width):
    return [i - i % width + (width - 1 - i % width) for i in range(16)]


def lane_ror8_qword():
    return [i - i % 8 + (i % 8 + 1) % 8 for i in range(16)]


def lane_dwords(placement):
    """placement[d] is the source dword of output dword d, or None."""
    out = []
    for d in range(4):
        src = placement[d]
        for b in range(4):
            out.append(None if src is None else 4 * src + b)
    return out


def mask_permutation(words, width):
    data = b"".join(w.to_bytes(width, "little") for w in words)
    lanes = []
    for lane in range(0, len(data), 16):
        perm = []
        for b in data[lane:lane + 16]:
            perm.append(None if b & 0x80 else b & 15)
        lanes.append(perm)
    return lanes


MASKS = {
    "SHA256_SHANI_BSWAP": lane_bswap(4),
    "SHA256_X8_SHANI_BSWAP": lane_bswap(4),
    "SHA256_AVX2_BSWAP": lane_bswap(4),
    "SHA256_X8_BSWAP": lane_bswap(4),
    "SHA512_AVX2_BSWAP": lane_bswap(8),
    "SHA512_X4_BSWAP": lane_bswap(8),
    "SHA512_X4_ROR8": lane_ror8_qword(),
    # dwords 0 and 2 to dwords 0 and 1 (LO) or 2 and 3 (HI), zeros elsewhere
    "SHA256_AVX2_LO": lane_dwords([0, 2, None, None]),
    "SHA256_AVX2_HI": lane_dwords([None, None, 0, 2]),
}

WORD_WIDTH = {"u8": 1, "u16": 2, "u32": 4, "u64": 8}


def expected_words(name):
    tables = {
        "SHA256_K": K256,
        "SHA512_K": K512,
        "SHA256_IV": IV256,
        "SHA224_IV": IV224,
        "SHA512_IV": IV512,
        "SHA384_IV": IV384,
        "SHA512_224_IV": sha512_t_iv(224),
        "SHA512_256_IV": sha512_t_iv(256),
        "SHA256_X8_K": [k for k in K256 for _ in range(8)],
        "SHA512_X4_K": [k for k in K512 for _ in range(4)],
    }
    return tables.get(name)


# Any line that starts an array declaration with an initialiser. Every such
# line must also be matched by TABLE_RE, so that a table written in another
# form fails rather than escapes the check.
DECL_RE = re.compile(r"^[ \t]*(global[ \t]+)?u(8|16|32|64|128|256)[ \t]*\[[^\]]*\]\s*\w+\s*=", re.M)

TABLE_RE = re.compile(
    r"^(u8|u16|u32|u64|u128|u256)\[(\d+)\]\s+(\w+)\s*=\s*\{(.*?)\};",
    re.S | re.M)


def parse_error(message):
    sys.stderr.write("check.py: %s\n" % message)
    sys.exit(2)


def read_tables(src):
    tables = []
    for root, _, files in sorted(os.walk(src)):
        for name in sorted(files):
            if not name.endswith(".jinc") and not name.endswith(".jazz"):
                continue
            path = os.path.join(root, name)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            starts = {m.start() for m in TABLE_RE.finditer(text)}
            for m in DECL_RE.finditer(text):
                if m.start() not in starts:
                    line = text.count("\n", 0, m.start()) + 1
                    parse_error("%s:%d: a table in a form this script does not read"
                                % (path, line))
            for m in TABLE_RE.finditer(text):
                body = re.sub(r"/\*.*?\*/", "", m.group(4), flags=re.S)
                items = [x.strip() for x in body.split(",") if x.strip()]
                try:
                    values = [int(x, 0) for x in items]
                except ValueError:
                    parse_error("%s: %s holds an entry that is not a number"
                                % (path, m.group(3)))
                tables.append({
                    "path": os.path.relpath(path, os.path.dirname(os.path.abspath(src))),
                    "type": m.group(1),
                    "count": int(m.group(2)),
                    "name": m.group(3),
                    "values": values,
                })
    return tables


def compare(table, values):
    """None when the table is right, else the reason it is not."""
    name = table["name"]
    if len(values) != table["count"]:
        return "%d entries for a declared size of %d" % (len(values), table["count"])
    width = WORD_WIDTH.get(table["type"])
    if width is None:
        return "word type %s is not handled" % table["type"]
    if any(v < 0 or v >> (8 * width) for v in values):
        return "an entry does not fit in %s" % table["type"]
    want = expected_words(name)
    if want is not None:
        if len(values) != len(want):
            return "%d entries, the derivation has %d" % (len(values), len(want))
        for i, (got, exp) in enumerate(zip(values, want)):
            if got != exp:
                return "entry %d is %#x, the derivation gives %#x" % (i, got, exp)
        return None
    if name in MASKS:
        lanes = mask_permutation(values, width)
        for lane, perm in enumerate(lanes):
            if perm != MASKS[name]:
                return "lane %d is not the expected byte permutation" % lane
        return None
    return "no derivation for this table"


def main(argv):
    if len(argv) != 2 or not os.path.isdir(argv[1]):
        sys.stderr.write("usage: check.py SRC_DIR\n")
        return 2
    self_test()
    tables = read_tables(argv[1])
    if not tables:
        sys.stderr.write("check.py: no constant table found under %s\n" % argv[1])
        return 2

    failures = 0
    names = set()
    for table in tables:
        names.add(table["name"])
        reason = compare(table, table["values"])
        status = "PASS" if reason is None else "FAIL"
        if reason is not None:
            failures += 1
        print("%-4s %-22s %-5s[%3d]  %s%s" % (status, table["name"], table["type"],
                                             table["count"], table["path"],
                                             "" if reason is None else ": " + reason))

    required = {"SHA256_K", "SHA512_K", "SHA256_IV", "SHA224_IV", "SHA512_IV",
                "SHA384_IV", "SHA512_224_IV", "SHA512_256_IV"}
    for name in sorted(required - names):
        print("FAIL %-22s not found under %s" % (name, argv[1]))
        failures += 1

    controls = 0
    for table in tables:
        if compare(table, table["values"]) is not None:
            continue
        values = list(table["values"])
        index = (len(values) * 5) // 7
        if table["name"] in MASKS:
            # Bit 7 of a mask byte switches it between selecting and zeroing.
            bit = 7
        else:
            bit = index % (8 * WORD_WIDTH[table["type"]])
        values[index] ^= 1 << bit
        controls += 1
        if compare(table, values) is None:
            print("FAIL control %s: one flipped bit at entry %d was not detected"
                  % (table["name"], index))
            failures += 1

    print("constants: %d tables, %d negative controls, %s"
          % (len(tables), controls, "PASS" if failures == 0 else "%d FAIL" % failures))
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
