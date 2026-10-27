#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# proofs/tools/spec_vectors.py
# ============================
#
# Writes the validation files of the specification, spec/validation/CAVP_*.ec,
# from the NIST CAVP response files in tests/vectors/cavp, and runs their
# negative controls.
#
#     spec_vectors.py write    VECTORS OUTDIR
#     spec_vectors.py check    VECTORS OUTDIR
#     spec_vectors.py controls VECTORS --easycrypt EC --flags FLAGS [--jobs N]
#
# Each file states, for a fixed selection of vectors of one function, the
# lemma that the specification's function applied to the message (and key)
# of the vector, written as a byte-list literal, equals the digest (or MAC)
# that the response file records. Every lemma is closed by `cbv delta`
# with the rewriting rules of spec/validation/SpecEval.ec: EasyCrypt
# computes the function from its definition in spec/ and compares the
# result with the literal. No lemma uses SMT, and none is admitted.
#
# The selection, per function with input block size B (64 for SHA-224 and
# SHA-256, 128 for the SHA-512 family):
#
#   ShortMsg: the messages of 0, 1, B - 9, B - 8, B - 1 and B bytes. B - 9
#             bytes is the longest message whose padding fits in one block,
#             B - 8 the shortest that needs a second one (section 5.1).
#   LongMsg:  the first vector, of several blocks (163 or 227 bytes).
#   HMAC.rsp: for HMAC-SHA-256 ([L=32]) and HMAC-SHA-512 ([L=64]), the first
#             vector with an untruncated tag (Tlen = L) for each key length
#             of the section, so keys shorter than, equal to and longer
#             than one block (FIPS 198-1 section 4, steps 1 to 3).
#
# write  verifies every response file it reads against SHA256SUMS in
#        VECTORS, then writes the files to OUTDIR.
# check  does the same into memory and fails unless every file in OUTDIR
#        equals a fresh generation and OUTDIR holds no other CAVP_*.ec.
# controls
#        requires EasyCrypt to reject, for each function, its first lemma
#        with bit 0 of the last digest byte flipped, and to reject it as a
#        proof that does not close: a parse or type error, or a failure in
#        another file, does not count. Each control runs in a scratch
#        directory and is never written to the tree.
#
# Regenerate: make -C proofs spec-vectors  (check: make -C proofs check-spec-exec)
# Exit status: 0 on success, 1 on a failed check or control, 2 on bad input.

import argparse
import hashlib
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import textwrap
import time
from concurrent.futures import ThreadPoolExecutor

PREAMBLE = """\
require import AllCore List.
from Jasmin require import JWord.
require import Bytes FIPS180_SHA2 FIPS198_HMAC SpecEval.
"""

# File, function as the specification names it, theory prefix of the
# lemma names, response files, block size, digest size.
HASHES = [
    ("CAVP_SHA224", "SHA-224", "SHA256.sha224", "sha224", "SHA224", 64),
    ("CAVP_SHA256", "SHA-256", "SHA256.sha256", "sha256", "SHA256", 64),
    ("CAVP_SHA384", "SHA-384", "SHA512.sha384", "sha384", "SHA384", 128),
    ("CAVP_SHA512", "SHA-512", "SHA512.sha512", "sha512", "SHA512", 128),
    ("CAVP_SHA512_224", "SHA-512/224", "SHA512.sha512_224", "sha512_224", "SHA512_224", 128),
    ("CAVP_SHA512_256", "SHA-512/256", "SHA512.sha512_256", "sha512_256", "SHA512_256", 128),
]
HMACS = [
    ("CAVP_HMAC_SHA256", "HMAC-SHA-256", "hmac_sha256", 32),
    ("CAVP_HMAC_SHA512", "HMAC-SHA-512", "hmac_sha512", 64),
]


def die(msg, status=2):
    sys.stderr.write("spec_vectors.py: %s\n" % msg)
    sys.exit(status)


# --------------------------------------------------------------------
# Response files

def sums(vectors):
    path = os.path.join(vectors, "SHA256SUMS")
    table = {}
    with open(path) as f:
        for line in f:
            p = line.split()
            if len(p) == 2:
                table[p[1]] = p[0]
    if not table:
        die("%s: no digests" % path)
    return table


def read_rsp(vectors, name, table):
    """The records of a response file as (section, {key: value}) pairs,
    after checking the file against SHA256SUMS."""
    path = os.path.join(vectors, name)
    data = open(path, "rb").read()
    want = table.get(name)
    if want is None:
        die("%s is not listed in SHA256SUMS" % name)
    if hashlib.sha256(data).hexdigest() != want:
        die("%s does not match its SHA256SUMS digest" % name)
    records, section, cur = [], None, {}
    for line in data.decode("ascii").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            if cur:
                records.append((section, cur))
                cur = {}
            continue
        m = re.fullmatch(r"\[(.*)\]", line)
        if m:
            section = m.group(1).replace(" ", "")
            continue
        k, _, v = line.partition("=")
        cur[k.strip()] = v.strip()
    if cur:
        records.append((section, cur))
    return records


def message(rec):
    n = int(rec["Len"])
    if n % 8:
        die("bit length %d is not a whole number of bytes" % n)
    m = bytes.fromhex(rec["Msg"])[: n // 8]
    if len(m) != n // 8:
        die("message shorter than Len = %d" % n)
    return m


# --------------------------------------------------------------------
# EasyCrypt text

def literal(b, indent):
    if not b:
        return "map W8.of_int []"
    items = ["0x%02x" % x for x in b]
    lines = [" ".join(i + ";" for i in items[k:k + 12]) for k in range(0, len(items), 12)]
    lines[-1] = lines[-1][:-1]
    pad = " " * indent
    return "map W8.of_int [\n" + "\n".join(pad + "  " + l for l in lines) + "]"


def header(fname, what, sources):
    title = fname + ".ec"
    intro = ("%s of the specification in spec/, evaluated by EasyCrypt on NIST "
             "CAVP vectors from tests/vectors/cavp (%s). Each lemma states that "
             "the function applied to the input of a vector equals the output the "
             "response file records, and is closed by reduction with the rules of "
             "SpecEval.ec, without SMT. The generator explains the selection of "
             "vectors." % (what, ", ".join(sources)))
    lines = textwrap.wrap(intro, 72)
    # The header below is written into each generated file; it is not this
    # file's licence, so REUSE skips it.
    # REUSE-IgnoreStart
    return ("(*\n"
            " * SPDX-FileCopyrightText: nirapod-sha2 contributors\n"
            " * SPDX-License-Identifier: Apache-2.0\n"
            " *\n"
            " * GENERATED FILE. DO NOT EDIT.\n"
            " *\n"
            " * %s\n * %s\n *\n" % (title, "=" * len(title))
            + "".join(" * %s\n" % l for l in lines)
            + " *\n"
            " * Generator: proofs/tools/spec_vectors.py\n"
            " * Regenerate: make -C proofs spec-vectors   (check: make -C proofs check-spec-exec)\n"
            " *)\n\n")
    # REUSE-IgnoreEnd


def hash_lemmas(vectors, table, fname, what, op, prefix, rsp, block):
    short = read_rsp(vectors, rsp + "ShortMsg.rsp", table)
    long_ = read_rsp(vectors, rsp + "LongMsg.rsp", table)
    want = [0, 1, block - 9, block - 8, block - 1, block]
    by_len = {}
    for _, r in short:
        if "Len" in r:
            by_len.setdefault(int(r["Len"]) // 8, r)
    cases = []
    for n in want:
        if n not in by_len:
            die("%sShortMsg.rsp has no message of %d bytes" % (rsp, n))
        r = by_len[n]
        cases.append(("%s_short_%d" % (prefix, n),
                      "%sShortMsg.rsp, Len = %s (%s)" % (rsp, r["Len"], nbytes(n)),
                      message(r), bytes.fromhex(r["MD"])))
    r = next(r for _, r in long_ if "Len" in r)
    m = message(r)
    cases.append(("%s_long_%d" % (prefix, len(m)),
                  "%sLongMsg.rsp, Len = %s (%s)" % (rsp, r["Len"], nbytes(len(m))),
                  m, bytes.fromhex(r["MD"])))
    out = []
    for name, src, m, d in cases:
        out.append((name, src,
                    "  %s\n    (%s)\n  = %s" % (op, literal(m, 4), literal(d, 2))))
    return out, [rsp + "ShortMsg.rsp", rsp + "LongMsg.rsp"]


def hmac_lemmas(vectors, table, fname, what, op, L):
    recs = read_rsp(vectors, "HMAC.rsp", table)
    seen, out = set(), []
    for sec, r in recs:
        if sec != "L=%d" % L or "Mac" not in r:
            continue
        klen, tlen = int(r["Klen"]), int(r["Tlen"])
        if tlen != L or klen in seen:
            continue
        seen.add(klen)
        k, m, t = bytes.fromhex(r["Key"]), bytes.fromhex(r["Msg"]), bytes.fromhex(r["Mac"])
        if len(k) != klen or len(t) != tlen:
            die("HMAC.rsp [L=%d] Count = %s: lengths do not match" % (L, r["Count"]))
        out.append(("%s_count_%s" % (op, r["Count"]),
                    "HMAC.rsp [L=%d], Count = %s, Klen = %d, Tlen = %d" % (L, r["Count"], klen, tlen),
                    "  %s\n    (%s)\n    (%s)\n  = %s"
                    % (op, literal(k, 4), literal(m, 4), literal(t, 2))))
    if not out:
        die("HMAC.rsp has no untruncated [L=%d] vector" % L)
    return out, ["HMAC.rsp"]


def nbytes(n):
    return "1 byte" if n == 1 else "%d bytes" % n


def lemma_text(name, src, stmt):
    return "(* %s *)\nlemma %s :\n%s.\nproof. by cbv delta. qed.\n" % (src, name, stmt)


def generate(vectors):
    table = sums(vectors)
    files = {}
    for fname, what, op, prefix, rsp, block in HASHES:
        cases, srcs = hash_lemmas(vectors, table, fname, what, op, prefix, rsp, block)
        files[fname] = (what, srcs, cases)
    for fname, what, op, L in HMACS:
        cases, srcs = hmac_lemmas(vectors, table, fname, what, op, L)
        files[fname] = (what, srcs, cases)
    return files


def render(fname, what, srcs, cases):
    body = "\n".join(lemma_text(*c) for c in cases)
    return header(fname, what, srcs) + PREAMBLE + "\n" + body


# --------------------------------------------------------------------
# Commands

def cmd_write(vectors, outdir):
    files = generate(vectors)
    os.makedirs(outdir, exist_ok=True)
    for fname, (what, srcs, cases) in files.items():
        with open(os.path.join(outdir, fname + ".ec"), "w") as f:
            f.write(render(fname, what, srcs, cases))
        print("spec-vectors: wrote %s.ec (%d lemmas)" % (fname, len(cases)))
    return 0


def cmd_check(vectors, outdir):
    files = generate(vectors)
    bad = 0
    present = sorted(f for f in os.listdir(outdir) if re.fullmatch(r"CAVP_.*\.ec", f))
    for f in present:
        if f[:-3] not in files:
            print("spec-vectors: %s is not a generated file" % os.path.join(outdir, f))
            bad += 1
    n = 0
    for fname, (what, srcs, cases) in files.items():
        path = os.path.join(outdir, fname + ".ec")
        n += len(cases)
        if not os.path.exists(path):
            print("spec-vectors: %s is missing" % path)
            bad += 1
        elif open(path).read() != render(fname, what, srcs, cases):
            print("spec-vectors: %s differs from a fresh generation" % path)
            bad += 1
    if bad:
        print("spec-vectors: FAIL (regenerate with make -C proofs spec-vectors)")
        return 1
    print("spec-vectors: PASS (%d files, %d lemmas, response files match SHA256SUMS)"
          % (len(files), n))
    return 0


def flip_last_bit(stmt):
    """The statement with bit 0 of the last byte of its right-hand side
    flipped."""
    m = re.search(r"0x([0-9a-f]{2})\]$", stmt)
    if not m:
        die("no output byte to flip in a statement")
    v = int(m.group(1), 16) ^ 1
    return stmt[: m.start()] + "0x%02x]" % v


def rejected(out, fname):
    crit = [l for l in out.replace("\r", "\n").splitlines() if "[critical]" in l]
    if not crit:
        return False
    pat = re.compile(r"^\[critical\] \[%s: line \d+ \([0-9-]+\)\] \[by\]: cannot close goals$"
                     % re.escape(fname))
    return all(pat.match(l.strip()) for l in crit)


def run_control(easycrypt, flags, fname, what, case):
    """(accepted, rejected as required, seconds, output) of the control
    of one file: its first lemma with one output bit flipped, compiled
    from a scratch directory."""
    name, src, stmt = case
    text = PREAMBLE + "\n" + lemma_text(name + "_flipped", src, flip_last_bit(stmt))
    tmp = tempfile.mkdtemp(prefix="spec-control-")
    try:
        path = os.path.join(tmp, "Control_" + fname[len("CAVP_"):] + ".ec")
        with open(path, "w") as f:
            f.write(text)
        start = time.monotonic()
        proc = subprocess.run([easycrypt, "compile", *flags, path],
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        seconds = time.monotonic() - start
        out = proc.stdout.decode("utf-8", errors="replace")
        return proc.returncode == 0, rejected(out, path), seconds, out
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def cmd_controls(vectors, easycrypt, flags, jobs):
    files = generate(vectors)
    flags = shlex.split(flags)
    work = [(fname, what, cases[0]) for fname, (what, srcs, cases) in files.items()]
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        results = list(pool.map(lambda w: run_control(easycrypt, flags, *w), work))
    failed = 0
    for (fname, what, case), (accepted, ok, seconds, out) in zip(work, results):
        what = "control %s, %s with one bit flipped" % (what, case[0])
        if accepted:
            print("%s: FAIL (accepted)" % what)
            failed += 1
        elif not ok:
            print("%s: FAIL (rejected for another reason)" % what)
            print(out.rstrip())
            failed += 1
        else:
            print("%s: rejected %.1f s" % (what, seconds))
    if failed:
        print("spec-controls: FAIL %d of %d controls" % (failed, len(work)))
        return 1
    print("spec-controls: PASS %d controls rejected" % len(work))
    return 0


def main(argv):
    ap = argparse.ArgumentParser(prog="spec_vectors.py")
    ap.add_argument("command", choices=["write", "check", "controls"])
    ap.add_argument("vectors")
    ap.add_argument("outdir", nargs="?")
    ap.add_argument("--easycrypt")
    ap.add_argument("--flags")
    ap.add_argument("--jobs", type=int, default=1)
    a = ap.parse_args(argv[1:])
    if a.command in ("write", "check") and a.outdir is None:
        die("%s needs OUTDIR" % a.command)
    if a.command == "write":
        return cmd_write(a.vectors, a.outdir)
    if a.command == "check":
        return cmd_check(a.vectors, a.outdir)
    if a.easycrypt is None or a.flags is None or a.jobs < 1:
        die("controls needs --easycrypt, --flags and --jobs of at least 1")
    return cmd_controls(a.vectors, a.easycrypt, a.flags, a.jobs)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
