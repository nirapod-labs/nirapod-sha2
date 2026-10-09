#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# table.py
# ========
#
# Reads the CSV files the benchmark driver writes and prints the table
#     workload | this library | strongest baseline | R | variability | CPU | revision
#
# R is the library's median latency divided by the strongest baseline's
# median latency for the same work; lower is better. The strongest
# baseline is the row with the lowest median among the baseline libraries,
# considering a baseline's reference row (8 or 4 single calls) as an
# implementation of a multi-way workload when it has no multi-way entry
# point itself. The variability is this library's interquartile range as a
# percentage of its median.
#
#     python3 bench/table.py [--run smoke|full] [--variant public] CSV...
#     python3 bench/table.py --stack [--run smoke|full] CSV...
#
# Several CSV files may be given; each holds one or more variants of one
# library. Rows are matched on function, mode and length, never across
# hosts: a table must hold one CPU.

import argparse
import csv
import sys
from collections import defaultdict

FUNCTION_ORDER = [
    "sha224", "sha256", "sha384", "sha512", "sha512_224", "sha512_256",
    "hmac_sha256", "hmac_sha256_key131", "hmac_sha512", "hmac_sha512_key131",
    "sha256_x8", "sha256_x8_ref", "sha512_x4", "sha512_x4_ref",
]

OURS = "nirapod-sha2"


def fmt_bytes(n):
    if n == 0:
        return "0 B"
    if n % (1 << 20) == 0:
        return "%d MiB" % (n >> 20)
    if n % (1 << 10) == 0:
        return "%d KiB" % (n >> 10)
    return "%d B" % n


def fmt_ns(ns):
    if ns >= 1e6:
        return "%.3f ms" % (ns / 1e6)
    if ns >= 1e4:
        return "%.2f us" % (ns / 1e3)
    return "%.1f ns" % ns


def workload_label(row):
    fn = row["function"]
    mode = "incremental" if row["mode"] == "incremental" else "one-shot"
    length = int(row["len"])
    if fn in ("sha256_x8", "sha512_x4", "sha256_x8_ref", "sha512_x4_ref"):
        ways = 8 if fn.startswith("sha256") else 4
        kind = "reference" if fn.endswith("_ref") else "%d-way" % ways
        return "%s %s: %s x %s" % (fn, kind, ways, fmt_bytes(length))
    return "%s %s %s" % (fn, mode, fmt_bytes(length))


def sort_key(row):
    fn = row["function"]
    order = FUNCTION_ORDER.index(fn) if fn in FUNCTION_ORDER else len(FUNCTION_ORDER)
    mode = 0 if row["mode"] != "incremental" else 1
    return (order, mode, int(row["len"]))


def read_rows(paths):
    rows = []
    fields = set()
    for path in paths:
        with open(path, newline="") as f:
            reader = csv.DictReader(f)
            if reader.fieldnames is None:
                continue
            fields.update(reader.fieldnames)
            for row in reader:
                row["_file"] = path
                rows.append(row)
    return rows, fields


def select_run(rows, run):
    labels = {r.get("run", "") for r in rows}
    labels.discard("")
    if run is not None:
        return [r for r in rows if r.get("run") == run]
    if len(labels) > 1:
        sys.exit("table.py: CSV files hold several run labels (%s); pass --run"
                 % ", ".join(sorted(labels)))
    return rows


def timing_table(rows, variant):
    ours = {}
    baselines = defaultdict(list)
    warnings = []

    for row in rows:
        if row.get("median_ns", "") == "":
            continue
        key = (row["function"], row["mode"], int(row["len"]))
        if row["library"] == OURS:
            if row["variant"] != variant:
                continue
            if key in ours:
                old = ours[key]
                if row["reps"] != old["reps"] and int(row["reps"]) > int(old["reps"]):
                    ours[key] = row
                if abs(float(row["median_ns"]) - float(old["median_ns"])) > \
                        0.2 * float(old["median_ns"]):
                    warnings.append("two rows for %s from %s and %s differ by more than 20%%"
                                    % (workload_label(row), old["_file"], row["_file"]))
            else:
                ours[key] = row
        else:
            baselines[key].append(row)

    if not ours:
        sys.exit("table.py: no rows for variant %s" % variant)

    print("| workload | this library | strongest baseline | R | variability | CPU | revision |")
    print("|---|---|---|---|---|---|---|")

    for key in sorted(ours, key=lambda k: sort_key(ours[k])):
        row = ours[key]
        candidates = []
        for cand in baselines.get(key, []):
            candidates.append(cand)
        fn = row["function"]
        if fn == "sha256_x8" or fn == "sha512_x4":
            ref = fn + "_ref"
            for cand in baselines.get((ref, row["mode"], int(row["len"])), []):
                candidates.append(cand)
        candidates = [c for c in candidates if c.get("median_ns", "") != ""]

        ours_ns = float(row["median_ns"])
        ours_cell = fmt_ns(ours_ns)
        if row.get("cycles_per_byte", "") != "":
            ours_cell += "; %s c/B" % row["cycles_per_byte"]

        if candidates:
            best = min(candidates, key=lambda r: float(r["median_ns"]))
            base_ns = float(best["median_ns"])
            base_cell = "%s %s@%s (%s" % (best["library"], best["version"],
                                           best["revision"][:12], best["variant"])
            if best["function"] != row["function"]:
                base_cell += ", %s" % best["function"]
            base_cell += ") %s" % fmt_ns(base_ns)
            r = "%.3f" % (ours_ns / base_ns) if base_ns > 0 else "-"
        else:
            base_cell = "none"
            r = "-"

        print("| %s | %s | %s | %s | %.1f%% | %s | %s |"
              % (workload_label(row), ours_cell, base_cell, r,
                 float(row["iqr_pct"]), row["cpu"], row["revision"][:12]))

    for w in warnings:
        print("table.py: warning: %s" % w, file=sys.stderr)


def stack_table(rows):
    table = defaultdict(dict)
    columns = set()
    for row in rows:
        if row.get("stack_bytes", "") == "":
            continue
        key = (row["function"], row["mode"], int(row["len"]))
        label = "%s %s" % (row["library"], row["variant"])
        table[key][label] = int(row["stack_bytes"])
        columns.add(label)
    if not table:
        sys.exit("table.py: no stack rows")
    ordered = sorted(columns)
    print("| workload | %s |" % " | ".join(ordered))
    print("|---|%s" % ("---|" * len(ordered)))
    for key in sorted(table, key=lambda k: sort_key({"function": k[0], "mode": k[1],
                                                      "len": str(k[2])})):
        row = {"function": key[0], "mode": key[1], "len": str(key[2])}
        cells = [str(table[key].get(v, "")) for v in ordered]
        print("| %s | %s |" % (workload_label(row), " | ".join(cells)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("csv", nargs="+")
    parser.add_argument("--run", choices=["smoke", "full", "stack"])
    parser.add_argument("--variant", default="public")
    parser.add_argument("--stack", action="store_true")
    parser.add_argument("-o", "--output")
    args = parser.parse_args()

    rows, fields = read_rows(args.csv)
    if args.stack:
        rows = select_run(rows, args.run) if "run" in fields else rows
        out = open(args.output, "w") if args.output else sys.stdout
        saved = sys.stdout
        sys.stdout = out
        try:
            stack_table(rows)
        finally:
            sys.stdout = saved
            if out is not sys.stdout:
                out.close()
        return

    rows = select_run(rows, args.run)
    if not rows:
        sys.exit("table.py: no rows left after the run filter")
    labels = {r.get("run", "") for r in rows}
    out = open(args.output, "w") if args.output else sys.stdout
    saved = sys.stdout
    sys.stdout = out
    try:
        if "smoke" in labels:
            print("Smoke run. These numbers check the harness, not performance.")
            print()
        first = next((r for r in rows
                      if r.get("library") == OURS and r.get("variant") == args.variant),
                     rows[0])
        print("CPU: %s (%s, %s)" % (first["cpu"], first["arch"], first["os"]))
        print("Library: %s %s at %s, variant %s"
              % (OURS, first.get("version", ""), first.get("revision", ""), args.variant))
        print()
        timing_table(rows, args.variant)
    finally:
        sys.stdout = saved
        if out is not sys.stdout:
            out.close()


if __name__ == "__main__":
    main()
