#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/extraction/control.py
# ===========================
#
# Negative controls of tests/extraction/models.py. Each one makes a defect
# the checks exist to catch and requires the check to reject it, with exit
# status 1 (a verdict, not a tool error) and for the expected reason:
#
#   shared      a copy of src/ in which one shared procedure, __sha2_room
#               of context.jinc, compares with <= instead of <. The last
#               unit of each architecture is extracted from the copy, the
#               others from src/. identity must report that procedure, and
#               nothing else, as differing in both modes of every
#               architecture, between the altered unit and the others.
#   stale       every unit's models extracted from the altered copy, as a
#               model committed before the change would be. check against
#               src/ must report both models of every unit as differing,
#               naming __sha2_room and no other item.
#   edited      the fresh models with one operator of one model changed by
#               hand (the first \ult becomes \ule). check must report that
#               file only.
#   swapped     the fresh models with the second unit's directory holding
#               the first unit's models. identity must report that the
#               second unit's normal model is not the program of its
#               namespaced unit.
#
# The mutation of the shared control is a fixed line of src/context.jinc.
# If that line changes, preparing the control fails, and so does this
# script: the line and the procedure name below must then be updated
# together.
#
#     control.py --work DIR --models DIR [models.py options] --unit ...
#
# --models is a fresh `make extract` of the same units. Every command a
# control runs, with its output and exit status, goes to WORK/log.txt.
# Exit status 0 when every control was rejected as required, 1 otherwise.

import argparse
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MODELS_PY = os.path.join(HERE, "models.py")

MUTATED_FILE = "context.jinc"
MUTATED_LINE = "  room = total < limit ? room : zero;"
MUTANT_LINE = "  room = total <= limit ? room : zero;"
MUTATED_ITEM = "proc __sha2_room"
MAINS = ("NirapodSha2.ec", "NirapodSha2Safety.ec")
MODES = ("normal", "safety")


class ControlError(Exception):
    pass


def unit_name(spec):
    return spec.split(":", 1)[0]


def unit_dir(spec):
    arch, _, variant = unit_name(spec).partition("-")
    return os.path.join(arch, variant)


def remap(spec, src, copy):
    """The spec with every root under src moved under copy."""
    name, jarch, roots = spec.split(":", 2)
    words = roots.split()
    out = []
    for w in words:
        ident, sep, path = w.partition("=")
        if sep and (path == src or path.startswith(src + "/")):
            w = ident + "=" + copy + path[len(src):]
        out.append(w)
    if out == words:
        raise ControlError("unit %s has no root under %s" % (name, src))
    return "%s:%s:%s" % (name, jarch, " ".join(out))


def models(args, command, extra, specs, cwd=None):
    cmd = [sys.executable, "-I", MODELS_PY, command,
           "--jasmin2ec", args.jasmin2ec, "--entry", args.entry,
           "--units", args.units] + extra
    if args.array_entry:
        cmd += ["--array-entry", args.array_entry]
    for s in specs:
        cmd += ["--unit", s]
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=cwd)
    out = p.stdout.decode("utf-8", "replace")
    with open(os.path.join(args.work, "log.txt"), "a") as f:
        f.write("$ %s\n%s(exit %d)\n\n" % (" ".join(cmd), out, p.returncode))
    return p.returncode, out.splitlines()


def need(cond, what, out):
    if not cond:
        raise ControlError(what + "\n" + "\n".join("    " + l for l in out[-30:]))


def rejected(code, out):
    need(code == 1, "the check exited %d, not 1" % code, out)


def altered_tree(args):
    """WORK/tree: the altered src/, with the entry and the unit files.

    Run from WORK/tree, the extraction commands are those of the
    repository root, so models made there are what a checkout of the
    altered source would have committed."""
    tree = os.path.join(args.work, "tree")
    copy = os.path.join(tree, args.src)
    shutil.copytree(args.src, copy)
    for p in (args.entry, args.units) + ((args.array_entry,) if args.array_entry else ()):
        if os.path.isabs(p):
            continue
        dest = os.path.join(tree, p)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        (shutil.copytree if os.path.isdir(p) else shutil.copyfile)(p, dest)
    path = os.path.join(copy, MUTATED_FILE)
    with open(path) as f:
        lines = f.read().split("\n")
    hits = [i for i, l in enumerate(lines) if l == MUTATED_LINE]
    if len(hits) != 1:
        raise ControlError("%s: the control line occurs %d times, not once"
                           % (path, len(hits)))
    lines[hits[0]] = MUTANT_LINE
    with open(path, "w") as f:
        f.write("\n".join(lines))
    return tree


def control_shared(args, specs, tree):
    copy = os.path.join(tree, args.src)
    arches = []
    for s in specs:
        a = unit_name(s).split("-")[0]
        if a not in arches:
            arches.append(a)
    last = {}
    for i, s in enumerate(specs):
        last[unit_name(s).split("-")[0]] = i
    mixed = [remap(s, args.src, copy) if i in last.values() else s
             for i, s in enumerate(specs)]
    out_dir = os.path.join(args.work, "shared-models")
    code, out = models(args, "extract", ["--out", out_dir], mixed)
    need(code == 0, "extract of the mixed units failed", out)
    code, out = models(args, "identity", ["--models", out_dir, "--work",
                                          os.path.join(args.work, "shared-work")], mixed)
    rejected(code, out)
    pat = re.compile(r"^identity: (\S+) (normal|safety): (.+) differs between units: (.*)$")
    got = set()
    for line in out:
        m = pat.match(line)
        if m:
            altered = unit_name(specs[last[m.group(1)]])
            groups = [set(g.split(", ")) for g in m.group(4).split(" | ")]
            need({altered} in groups, "the altered unit %s is not on its own: %s"
                 % (altered, line), out)
            got.add((m.group(1), m.group(2), m.group(3)))
        elif "missing from" in line or "a kernel item in" in line \
                or "namespaced unit" in line:
            need(False, "unexpected failure: " + line, out)
    want = set((a, m, MUTATED_ITEM) for a in arches for m in MODES)
    need(got == want, "reported %s, expected %s" % (sorted(got), sorted(want)), out)
    return "%s differs in %d (architecture, mode) pairs" % (MUTATED_ITEM, len(want))


def check_lines(out):
    files = set()
    items = set()
    for line in out:
        m = re.match(r"^check: (\S+): (\S+) differs from a fresh extraction$", line)
        if m:
            files.add(m.group(2))
            continue
        m = re.match(r"^check:   (.+): text differs$", line)
        if m:
            items.add(m.group(1))
            continue
        if line.startswith("check: ") and not line.startswith("check: FAIL"):
            need(False, "unexpected line: " + line, out)
    return files, items


def control_stale(args, specs, tree):
    stale = os.path.abspath(os.path.join(args.work, "stale-models"))
    code, out = models(args, "extract", ["--out", stale], specs, cwd=tree)
    need(code == 0, "extract from the altered copy failed", out)
    code, out = models(args, "check", ["--models", stale], specs)
    rejected(code, out)
    files, items = check_lines(out)
    want = set(os.path.join(unit_dir(s), m) for s in specs for m in MAINS)
    need(files == want, "files reported %s, expected %s" % (sorted(files), sorted(want)), out)
    need(items == {MUTATED_ITEM}, "items reported %s" % sorted(items), out)
    return "%d stale models reported, %s named" % (len(files), MUTATED_ITEM)


def control_edited(args, specs):
    edited = os.path.join(args.work, "edited-models")
    shutil.copytree(args.models, edited)
    target = os.path.join(unit_dir(specs[0]), MAINS[0])
    path = os.path.join(edited, target)
    with open(path) as f:
        src = f.read()
    if "\\ult" not in src:
        raise ControlError("%s has no \\ult to edit" % path)
    with open(path, "w") as f:
        f.write(src.replace("\\ult", "\\ule", 1))
    code, out = models(args, "check", ["--models", edited], specs)
    rejected(code, out)
    files, items = check_lines(out)
    need(files == {target}, "files reported %s, expected %s" % (sorted(files), target), out)
    need(len(items) == 1, "items reported %s, expected one" % sorted(items), out)
    return "%s reported (%s)" % (target, next(iter(items)))


def control_swapped(args, specs):
    if len(specs) < 2:
        raise ControlError("the swapped control needs two units")
    swapped = os.path.join(args.work, "swapped-models")
    shutil.copytree(args.models, swapped)
    a, b = unit_dir(specs[0]), unit_dir(specs[1])
    shutil.rmtree(os.path.join(swapped, b))
    shutil.copytree(os.path.join(swapped, a), os.path.join(swapped, b))
    code, out = models(args, "identity", ["--models", swapped, "--work",
                                          os.path.join(args.work, "swapped-work")], specs)
    rejected(code, out)
    model = os.path.join(swapped, b, MAINS[0])
    hit = [l for l in out if l.startswith("identity: " + model + ":")
           and "the namespaced unit gives" in l]
    need(hit, "no correspondence failure for %s" % model, out)
    return "%s: %s" % (unit_name(specs[1]), hit[0].split(": ", 2)[-1])


def main(argv):
    p = argparse.ArgumentParser(prog="control.py")
    p.add_argument("--jasmin2ec", default="jasmin2ec")
    p.add_argument("--entry", required=True)
    p.add_argument("--array-entry")
    p.add_argument("--units", required=True)
    p.add_argument("--models", required=True)
    p.add_argument("--work", required=True)
    p.add_argument("--src", default="src")
    p.add_argument("--unit", action="append", default=[])
    args = p.parse_args(argv)
    specs = args.unit
    if not specs:
        print("control.py: no unit given", file=sys.stderr)
        return 2
    if os.path.exists(args.work):
        shutil.rmtree(args.work)
    os.makedirs(args.work)

    failed = 0
    try:
        tree = altered_tree(args)
    except (ControlError, OSError) as e:
        print("control: FAIL: cannot prepare the altered copy: %s" % e)
        return 1
    for name, run in (("shared", lambda: control_shared(args, specs, tree)),
                      ("stale", lambda: control_stale(args, specs, tree)),
                      ("edited", lambda: control_edited(args, specs)),
                      ("swapped", lambda: control_swapped(args, specs))):
        try:
            print("control %s: rejected, as required: %s" % (name, run()))
        except (ControlError, OSError) as e:
            print("control %s: FAIL: %s" % (name, e))
            failed += 1
    if failed:
        print("control: FAIL: %d of 4 controls were not rejected as required" % failed)
        return 1
    print("control: all 4 controls rejected, as required")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
