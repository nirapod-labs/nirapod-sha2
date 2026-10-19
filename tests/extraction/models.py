#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/extraction/models.py
# ==========================
#
# The EasyCrypt models of the units, as jasmin2ec extracts them, and the
# checks that make one proof per shared layer sound.
#
#     models.py extract  --out DIR   UNIT...
#     models.py check    --models DIR UNIT...
#     models.py identity --models DIR --work DIR UNIT...
#
# UNIT is `--unit NAME:JARCH:ROOTS`, the unit's name, its Jasmin target
# and its include roots as `make print-roots-NAME` prints them. Every
# command also takes --jasmin2ec, --entry (the extraction entry: the root
# file required with no namespace) and --units (the directory of the
# namespaced unit files the library is compiled from), and optionally
# --array-entry (the array test unit, extracted for the portable units).
#
# Models
# ------
#
# Each unit has two models, one per extraction mode, in DIR/<arch>/<variant>:
#
#     NirapodSha2.ec        jasmin2ec, the normal model
#     NirapodSha2Safety.ec  jasmin2ec -m safety, the safety model
#     BArray*.ec, SBArray*.ec
#                           the array theories both models require
#     ArraySha2.ec          portable units only: jasmin2ec of the array
#                           test unit (--array-entry, tests/array/array.jazz),
#                           the instances of src/*_ASIZE.jinc it compiles,
#                           for the proofs of the array forms
#     COMMANDS              the commands, as run from the repository root
#
# The entry is the root file with no namespace, so a procedure has the same
# name in every unit; the identity command shows that it is the namespaced
# unit's program (see "Correspondence"). A model file is jasmin2ec's output
# byte for byte. The two modes write array theories of the same names; a
# name written twice must have the same bytes, or extraction fails.
#
# extract writes the models of every unit given. check extracts again into
# a scratch directory and requires DIR to hold the same files with the same
# bytes in every unit directory, and no unit directory that is not given:
# a stale, hand-edited, missing or left-over model fails, with the file and,
# for a model, the items whose text differs.
#
# Shared and kernel items
# -----------------------
#
# A model is split into items: the prelude statements, the abbreviations
# (global data), the module variables, the procedures of module M, and in
# the safety model the specification operators and the comment before
# them. The splitter knows only these shapes and fails on any other line,
# so a change in jasmin2ec's printing stops the check rather than passing
# it. The items reassembled must give back the file, and no item may occur
# twice.
#
# The kernel items of a unit are what the kernel files contribute. The
# kernel include roots are every root of the unit other than Hash and
# HashWord. The kernel entries are the `from <kernel root> require` lines
# of the shared files (the .jinc files directly under the Hash root); the
# kernel files are those entries resolved under the unit's roots and every
# file they require through a kernel root or by a relative path. The
# shared files a kernel file requires (through Hash or HashWord: the round
# constants and the word helpers) form the base. A kernel file that
# requires a file directly under the Hash root by a relative path is an
# error, since that file could be shared. Two more extractions of the unit,
# with the same roots and mode, give the kernel items:
#
#     items(kernel entries) - items(base)
#
# restricted to procedures, abbreviations and operators. Every other item
# of the model is shared: the shared layers, the round constants and the
# architecture's word helpers. word.jinc is compared too: within one
# architecture every unit reads the same file, and the proofs bring in one
# word theory per architecture, so its procedures must extract the same
# everywhere on it.
#
# For each architecture and mode, each shared item must be present in
# every unit and have the same text in all of them. An item that is shared
# in one unit and a kernel item in another is a failure, as is an item
# missing from a unit. A difference names the item and groups the units by
# text, with a diff of the first two texts.
#
# Excluded from the comparison, and why:
#
#   - the prelude statement `require import BArray... SBArray...`: it lists
#     the array theories of the whole unit, so kernel-only sizes make it
#     differ. Each theory's text is checked instead: a file name maps to one
#     content across every unit, mode and architecture;
#   - the order of the items in the file: an item is compared by kind and
#     name, and a procedure refers to the others by name, so its meaning
#     does not depend on its position (kernel procedures sit between the
#     shared ones, at places that differ from unit to unit);
#   - kernel items, as defined above.
#
# Nothing else is excluded. The text of an item is compared byte for byte,
# with the blank lines that follow it removed.
#
# Correspondence
# --------------
#
# The library is compiled from the namespaced units (build/units/<unit>.jazz,
# `namespace N { from Hash require "nirapod_sha2.jinc" }`). jasmin2ec
# extracts them too, with every global name prefixed by `N__`, and the
# longer names change the printer's line breaks. For each unit and mode the
# identity command extracts the namespaced unit and requires its token
# sequence, after the renaming below, to equal the model's. A token is a run
# of letters, digits, `_` and `'`, or one other non-space character; all
# white space is dropped. The renaming removes `N__` wherever it occurs in a
# token (procedure names, and the trace variables of the safety model that
# carry them), and when the token began with it, lowers the first letter of
# what is left: an EasyCrypt abbreviation starts with a lower-case letter,
# so jasmin2ec writes the global SHA256_K as sHA256_K, while N__SHA256_K
# needs no change. The array theories of the two extractions must be the
# same files with the same bytes. This is how the models are tied to the
# exports that ship.
#
# Exit status: 0 when every check passed, 1 when a check failed, 2 on a
# usage or tool error. Every jasmin2ec run must exit 0, write nothing on
# standard error and write its output file; otherwise the command fails.

import argparse
import difflib
import hashlib
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

MODES = (
    ("normal", "NirapodSha2.ec", []),
    ("safety", "NirapodSha2Safety.ec", ["-m", "safety"]),
)

# The array test unit is built with the portable kernels only, so its
# model is extracted into the portable units' directories.
ARRAY_MAIN = "ArraySha2.ec"
ARRAY_VARIANT = "portable"

SHARED_ROOTS = ("Hash", "HashWord")
KERNEL_KINDS = ("proc", "abbrev", "op")
ARRAY_FILE = re.compile(r"^S?BArray[0-9]+(_[0-9]+)?\.ec$")


class ToolError(Exception):
    """A tool or input problem: the check cannot give a verdict."""


# --------------------------------------------------------------------
# Units


class Unit:
    def __init__(self, spec):
        try:
            name, jarch, roots = spec.split(":", 2)
        except ValueError:
            raise ToolError("bad unit spec %r (NAME:JARCH:ROOTS)" % spec)
        words = shlex.split(roots)
        if len(words) % 2 or not words:
            raise ToolError("bad include roots for %s: %r" % (name, roots))
        self.roots = {}
        for flag, binding in zip(words[0::2], words[1::2]):
            ident, sep, path = binding.partition("=")
            if flag != "-I" or not sep or not ident or not path:
                raise ToolError("bad include root for %s: %r" % (name, binding))
            if ident in self.roots:
                raise ToolError("root %s given twice for %s" % (ident, name))
            self.roots[ident] = path
        for ident in SHARED_ROOTS:
            if ident not in self.roots:
                raise ToolError("unit %s has no %s root" % (name, ident))
        arch, sep, variant = name.partition("-")
        if not sep or not variant:
            raise ToolError("unit name %r is not <arch>-<variant>" % name)
        self.name = name
        self.arch = arch
        self.variant = variant
        self.jarch = jarch
        self.root_args = words

    @property
    def dir(self):
        return os.path.join(self.arch, self.variant)

    def kernel_roots(self):
        return sorted(r for r in self.roots if r not in SHARED_ROOTS)


def ensure_unique(units):
    seen = set()
    for u in units:
        if u.name in seen:
            raise ToolError("unit %s given twice" % u.name)
        seen.add(u.name)
    if not units:
        raise ToolError("no unit given")


# --------------------------------------------------------------------
# jasmin2ec


def run_jasmin2ec(jasmin2ec, unit, flags, entry, out_file):
    """Extract entry under the unit's roots into out_file.

    The array theories go to the directory of out_file. Returns the command
    as a list. Fails on a non-zero exit, on output on standard error, and
    when out_file is missing or empty.
    """
    cmd = [jasmin2ec, "--arch=" + unit.jarch] + flags + unit.root_args \
        + ["-o", out_file, entry]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    err = proc.stderr.decode("utf-8", "replace")
    if proc.returncode != 0 or err.strip():
        raise ToolError("jasmin2ec failed (exit %d) for %s: %s\n%s"
                        % (proc.returncode, unit.name, " ".join(cmd), err))
    if not os.path.isfile(out_file) or os.path.getsize(out_file) == 0:
        raise ToolError("jasmin2ec wrote no output for %s: %s"
                        % (unit.name, " ".join(cmd)))
    return cmd


def read(path):
    with open(path, "rb") as f:
        return f.read()


def text(path):
    return read(path).decode("utf-8")


def extract_unit(jasmin2ec, unit, entry, dest, array_entry=None):
    """Both models of one unit into dest, which must not exist; for a
    portable unit, also the model of the array test unit."""
    os.makedirs(dest)
    commands = []
    runs = [(main, flags, entry) for _, main, flags in MODES]
    if array_entry and unit.variant == ARRAY_VARIANT:
        runs.append((ARRAY_MAIN, [], array_entry))
    for main, flags, src in runs:
        tmp = tempfile.mkdtemp(prefix="extract-")
        try:
            cmd = run_jasmin2ec(jasmin2ec, unit, flags, src,
                                os.path.join(tmp, main))
            shown = cmd[:]
            shown[0] = "jasmin2ec"
            shown[-2] = os.path.join(unit.dir, main)
            commands.append(" ".join(shlex.quote(w) for w in shown))
            for name in sorted(os.listdir(tmp)):
                src = os.path.join(tmp, name)
                if name != main and not ARRAY_FILE.match(name):
                    raise ToolError("jasmin2ec wrote an unexpected file %s for %s"
                                    % (name, unit.name))
                target = os.path.join(dest, name)
                if os.path.exists(target):
                    if read(target) != read(src):
                        raise ToolError("%s differs between the models of %s"
                                        % (name, unit.name))
                    continue
                shutil.copyfile(src, target)
        finally:
            shutil.rmtree(tmp)
    with open(os.path.join(dest, "COMMANDS"), "w") as f:
        f.write("# The models of unit %s, extracted from the repository root by\n"
                "# `make extract`. The entry requires src/nirapod_sha2.jinc\n"
                "# through the Hash root, with no namespace.\n" % unit.name)
        if len(runs) > len(MODES):
            f.write("# %s is the model of the array test unit.\n" % ARRAY_MAIN)
        for c in commands:
            f.write(c + "\n")


def extract_all(jasmin2ec, units, entry, out, array_entry=None):
    """Every unit's models into out, replacing it as a whole."""
    parent = os.path.dirname(os.path.abspath(out))
    os.makedirs(parent, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix=".models-", dir=parent)
    try:
        for u in units:
            extract_unit(jasmin2ec, u, entry, os.path.join(tmp, u.dir), array_entry)
        if os.path.exists(out):
            shutil.rmtree(out)
        os.rename(tmp, out)
    except BaseException:
        shutil.rmtree(tmp, ignore_errors=True)
        raise


# --------------------------------------------------------------------
# Splitting a model into items

TOP_START = re.compile(r"^(require|from|import|abbrev|op|module|\(\*)(\s|$)")
MODULE_START = re.compile(r"^module M = \{$")
MODULE_END = "}."
IN_MODULE_START = re.compile(r"^  (proc|var) ([A-Za-z_][A-Za-z0-9_']*)[ :(]")
NAMED = re.compile(r"^(abbrev|op) ([A-Za-z_][A-Za-z0-9_']*)( |$)")


def is_array_require(stmt):
    words = stmt.replace(".", " ").split()
    return len(words) > 2 and words[:2] == ["require", "import"] \
        and all(ARRAY_FILE.match(w + ".ec") for w in words[2:])


def split_model(source, where):
    """Return [(key, text)] for the model text, in file order.

    key is (kind, name). Raises ToolError on any line the splitter does
    not recognise, or if the items do not reassemble to the source.
    """
    lines = source.split("\n")
    items = []
    cur = None

    def flush():
        if cur is not None:
            items.append(cur)

    i = 0
    n = len(lines)
    module_seen = False
    while i < n:
        line = lines[i]
        if MODULE_START.match(line):
            if module_seen:
                raise ToolError("%s:%d: a second module" % (where, i + 1))
            module_seen = True
            flush()
            cur = None
            items.append((("module-open", "M"), [line]))
            i += 1
            while i < n and lines[i] != MODULE_END:
                m = IN_MODULE_START.match(lines[i])
                if m:
                    flush()
                    cur = ((m.group(1), m.group(2)), [lines[i]])
                elif cur is None and lines[i].strip() == "":
                    items[-1][1].append(lines[i])
                elif cur is None:
                    raise ToolError("%s:%d: unexpected line in module M: %r"
                                    % (where, i + 1, lines[i]))
                else:
                    cur[1].append(lines[i])
                i += 1
            if i == n:
                raise ToolError("%s: module M is not closed" % where)
            flush()
            cur = None
            items.append((("module-close", "M"), [lines[i]]))
            i += 1
            continue
        if TOP_START.match(line):
            flush()
            m = NAMED.match(line)
            if m:
                key = (m.group(1), m.group(2))
            elif line.startswith("(*"):
                key = ("comment", line)
            elif line.startswith("module"):
                raise ToolError("%s:%d: unexpected module: %r" % (where, i + 1, line))
            else:
                key = ("prelude", None)
            cur = (key, [line])
        elif line.strip() == "":
            if cur is not None:
                cur[1].append(line)
            elif items:
                items[-1][1].append(line)
            else:
                raise ToolError("%s:%d: the file starts with a blank line"
                                % (where, i + 1))
        elif cur is None:
            raise ToolError("%s:%d: a line outside any item: %r"
                            % (where, i + 1, line))
        else:
            cur[1].append(line)
        i += 1
    flush()

    if "\n".join(l for _, ls in items for l in ls) != source:
        raise ToolError("%s: the items do not reassemble to the file" % where)
    if not module_seen:
        raise ToolError("%s: no module M" % where)

    result = []
    for (kind, name), ls in items:
        while ls and ls[-1].strip() == "":
            ls = ls[:-1]
        body = "\n".join(ls)
        if kind == "prelude":
            name = "array theories" if is_array_require(body) else body
            if name == "array theories":
                kind = "arrays"
        result.append(((kind, name), body))
    keys = [k for k, _ in result]
    dup = sorted(set(k for k in keys if keys.count(k) > 1))
    if dup:
        raise ToolError("%s: items given twice: %s" % (where, dup))
    return result


def items_of(path):
    return dict(split_model(text(path), path))


def show(key):
    kind, name = key
    if kind in ("prelude", "comment"):
        return "%s %r" % (kind, name)
    return "%s %s" % (kind, name)


# --------------------------------------------------------------------
# check: a models tree against a fresh extraction


def unit_files(d):
    if not os.path.isdir(d):
        return None
    return sorted(f for f in os.listdir(d) if os.path.isfile(os.path.join(d, f)))


def model_dirs(root):
    """<arch>/<variant> directories of root that hold an .ec file."""
    found = set()
    for arch in sorted(os.listdir(root)):
        a = os.path.join(root, arch)
        if not os.path.isdir(a):
            continue
        for variant in sorted(os.listdir(a)):
            v = os.path.join(a, variant)
            if os.path.isdir(v) and any(f.endswith(".ec") for f in os.listdir(v)):
                found.add(os.path.join(arch, variant))
    return found


def compare_trees(fresh, models, units):
    problems = []
    for u in units:
        want = unit_files(os.path.join(fresh, u.dir))
        have = unit_files(os.path.join(models, u.dir))
        if have is None:
            problems.append("%s: no model directory %s" % (u.name, u.dir))
            continue
        for f in sorted(set(want) - set(have)):
            problems.append("%s: %s is missing" % (u.name, os.path.join(u.dir, f)))
        for f in sorted(set(have) - set(want)):
            problems.append("%s: %s is not made by the extraction"
                            % (u.name, os.path.join(u.dir, f)))
        for f in sorted(set(want) & set(have)):
            a = os.path.join(fresh, u.dir, f)
            b = os.path.join(models, u.dir, f)
            if read(a) == read(b):
                continue
            problems.append("%s: %s differs from a fresh extraction"
                            % (u.name, os.path.join(u.dir, f)))
            if f.endswith(".ec") and not ARRAY_FILE.match(f):
                try:
                    ia, ib = items_of(a), items_of(b)
                except ToolError as e:
                    problems.append("  (%s)" % e)
                    continue
                for k in sorted(set(ia) | set(ib), key=str):
                    if k not in ib:
                        problems.append("  %s: missing from the committed model" % show(k))
                    elif k not in ia:
                        problems.append("  %s: not in a fresh extraction" % show(k))
                    elif ia[k] != ib[k]:
                        problems.append("  %s: text differs" % show(k))
    given = set(u.dir for u in units)
    for d in sorted(model_dirs(models) - given):
        problems.append("%s: models of a unit that is not built" % d)
    return problems


# --------------------------------------------------------------------
# identity: kernel classification, shared items, correspondence

COMMENT = re.compile(r"/\*.*?\*/|//[^\n]*", re.S)
REQUIRE = re.compile(r'(?:\bfrom\s+([A-Za-z_][A-Za-z0-9_]*)\s+)?\brequire\s+((?:"[^"]*"\s*)+)')


def requires(path):
    """[(root or None, file)] of the require lines of a Jasmin file."""
    src = COMMENT.sub(" ", text(path))
    out = []
    for m in REQUIRE.finditer(src):
        for f in re.findall(r'"([^"]*)"', m.group(2)):
            out.append((m.group(1), f))
    return out


def kernel_layout(unit):
    """(kernel entries, kernel files, base entries) of a unit."""
    hash_dir = unit.roots["Hash"]
    kroots = unit.kernel_roots()
    entries = set()
    for f in sorted(os.listdir(hash_dir)):
        p = os.path.join(hash_dir, f)
        if f.endswith(".jinc") and os.path.isfile(p):
            for root, req in requires(p):
                if root in kroots:
                    entries.add((root, req))
    if not entries:
        raise ToolError("%s: no shared file requires a kernel root" % unit.name)
    files = set()
    base = set()
    todo = [os.path.join(unit.roots[r], f) for r, f in sorted(entries)]
    while todo:
        p = os.path.normpath(todo.pop())
        if p in files:
            continue
        if not os.path.isfile(p):
            raise ToolError("%s: kernel file %s is missing" % (unit.name, p))
        files.add(p)
        for root, req in requires(p):
            if root is None:
                q = os.path.normpath(os.path.join(os.path.dirname(p), req))
                if os.path.dirname(q) == os.path.normpath(hash_dir):
                    raise ToolError("%s: %s requires %s by a relative path, which "
                                    "cannot be told from a shared file"
                                    % (unit.name, p, q))
                todo.append(q)
            elif root in kroots:
                todo.append(os.path.join(unit.roots[root], req))
            elif root in SHARED_ROOTS:
                base.add((root, req))
            else:
                raise ToolError("%s: %s requires through unknown root %s"
                                % (unit.name, p, root))
    return sorted(entries), sorted(files), sorted(base)


def wrapper(path, reqs):
    with open(path, "w") as f:
        for root, req in reqs:
            f.write('from %s require "%s"\n' % (root, req))


def kernel_items(jasmin2ec, unit, work):
    """{mode: set of kernel item keys} of a unit, and its kernel files."""
    entries, files, base = kernel_layout(unit)
    d = os.path.join(work, unit.name)
    os.makedirs(d, exist_ok=True)
    wrapper(os.path.join(d, "kernel.jazz"), entries)
    if base:
        wrapper(os.path.join(d, "base.jazz"), base)
    result = {}
    for mode, _main, flags in MODES:
        out = os.path.join(d, "kernel-" + mode, "Kernel.ec")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        run_jasmin2ec(jasmin2ec, unit, flags, os.path.join(d, "kernel.jazz"), out)
        kset = set(items_of(out))
        if base:
            out = os.path.join(d, "base-" + mode, "Base.ec")
            os.makedirs(os.path.dirname(out), exist_ok=True)
            run_jasmin2ec(jasmin2ec, unit, flags, os.path.join(d, "base.jazz"), out)
            kset -= set(items_of(out))
        result[mode] = set(k for k in kset if k[0] in KERNEL_KINDS)
    return result, files


TOKEN = re.compile(r"[A-Za-z0-9_']+|\S")


def unit_namespace(path):
    m = re.search(r"\bnamespace\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{", COMMENT.sub(" ", text(path)))
    if not m:
        raise ToolError("%s: no namespace" % path)
    return m.group(1)


def rename_token(tok, prefix):
    if prefix not in tok:
        return tok
    lead = tok.startswith(prefix)
    tok = tok.replace(prefix, "")
    if lead and tok[:1].isupper():
        tok = tok[0].lower() + tok[1:]
    return tok


def correspondence(model, namespaced, ns):
    """Problems found comparing a model with its namespaced extraction."""
    prefix = ns + "__"
    a_src = text(model)
    b_src = text(namespaced)
    a = [(m.group(0), m.start()) for m in TOKEN.finditer(a_src)]
    b = [rename_token(m.group(0), prefix) for m in TOKEN.finditer(b_src)]
    if prefix in a_src:
        return ["%s: the model contains the namespace %s" % (model, ns)]
    for i, (tok, pos) in enumerate(a):
        if i >= len(b) or b[i] != tok:
            line = a_src.count("\n", 0, pos) + 1
            got = b[i] if i < len(b) else "<end>"
            return ["%s:%d: token %d is %r; the namespaced unit gives %r"
                    % (model, line, i, tok, got)]
    if len(b) != len(a):
        return ["%s: the namespaced unit has %d more tokens" % (model, len(b) - len(a))]
    return []


def identity(args, units):
    jasmin2ec, models, work = args.jasmin2ec, args.models, args.work
    if os.path.exists(work):
        shutil.rmtree(work)
    os.makedirs(work)
    problems = []
    report = []

    # Array theories: one content per file name.
    theories = {}
    for u in units:
        files = unit_files(os.path.join(models, u.dir))
        if files is None:
            raise ToolError("%s: no models in %s" % (u.name, os.path.join(models, u.dir)))
        for f in files:
            if ARRAY_FILE.match(f):
                h = hashlib.sha256(read(os.path.join(models, u.dir, f))).hexdigest()
                theories.setdefault(f, {}).setdefault(h, []).append(u.name)
    for f in sorted(theories):
        if len(theories[f]) > 1:
            problems.append("array theory %s differs between units: %s"
                            % (f, "; ".join(", ".join(v) for v in theories[f].values())))
    report.append("array theories: %d names, one content each" % len(theories))

    # Correspondence with the namespaced units.
    for u in units:
        unit_file = os.path.join(args.units, u.name + ".jazz")
        if not os.path.isfile(unit_file):
            raise ToolError("%s: unit file %s is missing" % (u.name, unit_file))
        ns = unit_namespace(unit_file)
        for mode, main, flags in MODES:
            d = os.path.join(work, u.name, "unit-" + mode)
            os.makedirs(d)
            out = os.path.join(d, main)
            run_jasmin2ec(jasmin2ec, u, flags, unit_file, out)
            found = correspondence(os.path.join(models, u.dir, main), out, ns)
            for f in sorted(os.listdir(d)):
                if f == main:
                    continue
                m = os.path.join(models, u.dir, f)
                if not os.path.isfile(m) or read(m) != read(os.path.join(d, f)):
                    found.append("%s: array theory %s of the namespaced unit "
                                 "is not the model's" % (u.name, f))
            problems.extend(found)
            if not found:
                report.append("correspondence %s %s: equal to %s modulo %s__"
                              % (u.name, mode, unit_file, ns))

    # Shared items, per architecture and mode.
    kernels = {}
    for u in units:
        kernels[u.name], files = kernel_items(jasmin2ec, u, work)
        report.append("kernel files %s: %s" % (u.name, " ".join(files)))
    arches = []
    for u in units:
        if u.arch not in arches:
            arches.append(u.arch)
    for arch in arches:
        group = [u for u in units if u.arch == arch]
        for mode, main, _flags in MODES:
            items = {u.name: items_of(os.path.join(models, u.dir, main)) for u in group}
            shared = {}
            for u in group:
                for k, body in items[u.name].items():
                    if k[0] == "arrays" or k in kernels[u.name][mode]:
                        continue
                    shared.setdefault(k, {})[u.name] = body
            for k in sorted(shared, key=str):
                where = shared[k]
                for u in group:
                    if u.name in where:
                        continue
                    if k in kernels[u.name][mode]:
                        problems.append("%s %s: %s is shared in %s but a kernel item in %s"
                                        % (arch, mode, show(k), ", ".join(sorted(where)), u.name))
                    else:
                        problems.append("%s %s: %s is in %s but missing from %s"
                                        % (arch, mode, show(k), ", ".join(sorted(where)), u.name))
                texts = {}
                for name in [u.name for u in group if u.name in where]:
                    texts.setdefault(where[name], []).append(name)
                if len(texts) > 1:
                    variants = list(texts.items())
                    problems.append("%s %s: %s differs between units: %s"
                                    % (arch, mode, show(k),
                                       " | ".join(", ".join(v) for _, v in variants)))
                    diff = difflib.unified_diff(
                        variants[0][0].split("\n"), variants[1][0].split("\n"),
                        variants[0][1][0], variants[1][1][0], lineterm="", n=1)
                    problems.extend("    " + l for l in list(diff)[:40])
            for u in group:
                kinds = {}
                for k in kernels[u.name][mode]:
                    kinds[k[0]] = kinds.get(k[0], 0) + 1
                report.append("kernel items %s %s: %s" % (
                    u.name, mode,
                    ", ".join("%d %s" % (kinds[x], x) for x in sorted(kinds)) or "none"))
                for k in sorted(kernels[u.name][mode]):
                    report.append("  %s" % show(k))
            report.append("shared %s %s: %d items over %s" % (
                arch, mode, len(shared), " ".join(u.name for u in group)))
            for k in sorted(shared, key=str):
                h = hashlib.sha256("\n".join(sorted(set(shared[k].values()))).encode()).hexdigest()
                report.append("  %s %s" % (h[:16], show(k)))

    with open(os.path.join(work, "report.txt"), "w") as f:
        f.write("\n".join(report) + "\n")
    return problems, report


# --------------------------------------------------------------------


def main(argv):
    p = argparse.ArgumentParser(prog="models.py")
    p.add_argument("command", choices=("extract", "check", "identity"))
    p.add_argument("--jasmin2ec", default="jasmin2ec")
    p.add_argument("--entry", required=True)
    p.add_argument("--array-entry")
    p.add_argument("--units", required=True)
    p.add_argument("--out")
    p.add_argument("--models")
    p.add_argument("--work")
    p.add_argument("--unit", action="append", default=[])
    args = p.parse_args(argv)

    units = [Unit(s) for s in args.unit]
    ensure_unique(units)
    if not os.path.isfile(args.entry):
        raise ToolError("entry %s is missing" % args.entry)
    if args.array_entry and not os.path.isfile(args.array_entry):
        raise ToolError("array entry %s is missing" % args.array_entry)

    if args.command == "extract":
        if not args.out:
            raise ToolError("extract needs --out")
        extract_all(args.jasmin2ec, units, args.entry, args.out, args.array_entry)
        print("extract: %d units, %d models each, in %s"
              % (len(units), len(MODES), args.out))
        return 0

    if not args.models:
        raise ToolError("%s needs --models" % args.command)
    if not os.path.isdir(args.models):
        raise ToolError("no models at %s" % args.models)

    if args.command == "check":
        tmp = tempfile.mkdtemp(prefix="check-")
        try:
            fresh = os.path.join(tmp, "models")
            extract_all(args.jasmin2ec, units, args.entry, fresh, args.array_entry)
            problems = compare_trees(fresh, args.models, units)
        finally:
            shutil.rmtree(tmp)
        for line in problems:
            print("check: " + line)
        if problems:
            print("check: FAIL: %s is not what the units extract to" % args.models)
            return 1
        print("check: %s equals a fresh extraction of %d units" % (args.models, len(units)))
        return 0

    if not args.work:
        raise ToolError("identity needs --work")
    problems, report = identity(args, units)
    for line in problems:
        print("identity: " + line)
    for line in report:
        if not line.startswith("  "):
            print("identity: " + line)
    if problems:
        print("identity: FAIL")
        return 1
    print("identity: shared items identical in every unit of each architecture, "
          "both modes; every model corresponds to its namespaced unit")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except (ToolError, OSError, UnicodeError) as e:
        print("models.py: error: %s" % e, file=sys.stderr)
        sys.exit(2)
    except Exception:
        import traceback
        traceback.print_exc()
        sys.exit(2)
