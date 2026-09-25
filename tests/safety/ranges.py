#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/safety/ranges.py
# ======================
#
# The verdict of one jasmin-checksafety run on one export, read against
# the export's #[safety] contract.
#
# The checker's "No Safety Violation" holds under the memory ranges it
# prints: mem_p is the extent, in bytes from p, of the region the input
# pointer p must be valid for, and the "* Rel:" line relates those extents
# to the input values inv_x of the arguments. A verdict whose range for
# in is wider than inlen, or not related to inlen at all, says nothing
# about a caller that passes exactly inlen valid bytes. So a run passes
# here only when, besides "No Safety Violation", every argument's range is
# within the bound its contract gives:
#
#   argument                            bound on mem_<arg>
#   u64 named by is_mem_init(p, n)      inv_n, or the constant n
#   array pointer (reg ptr u8[N] ...)   0: accessed as an array, whose
#                                       bounds the checker proves on its own
#   any other argument                  0: it must not be used as an address
#
# The bounds come from the contracts in the source, not from a second
# table, so the comparison cannot drift from the contracts the proofs
# discharge. A contract this script cannot read is an error, not a pass:
# requires must be a conjunction (&&) of atoms, and an is_mem_init atom
# must be is_mem_init((64u) p, (64u) n) with p an argument and n an
# argument or a constant.
#
# A region whose base is a pointer read from an array, such as the lane
# table of the multi-way exports (is_mem_init((64u) in[k], ...)), has no
# range in the checker's memory model, which knows only the regions of
# the input arguments. Such an export cannot pass here.
#
# The implication "the printed constraints imply mem_p <= bound" is
# decided exactly: Fourier-Motzkin elimination over the rationals finds
# the largest value of t = mem_p - bound on the polyhedron, and since t
# is an integer in every concrete state, the check holds when that
# largest value is below 1. The relaxation to the rationals can only make
# the largest value larger, so the check never accepts a range the
# constraints do not imply.
#
#     ranges.py bounds SRC [EXPORT...]
#         print the contract bound of every argument of every export
#     ranges.py verdict SRC EXPORT LOG [--function NAME]
#         read LOG, print one line PASS or FAIL with the reasons, exit 0
#         on PASS and 1 on FAIL
#
# --function is the name the log must say was analysed (default EXPORT;
# the job passes NAMESPACE::EXPORT). Exit status 2 is an error of this
# script or of its input.

import re
import sys
from fractions import Fraction


class InputError(Exception):
    pass


# ---------------------------------------------------------------------------
# Contracts

EXPORT_RE = re.compile(r"\bexport\s+fn\s+([A-Za-z_]\w*)\s*\(([^)]*)\)")
FN_END_RE = re.compile(r"\bfn\s+[A-Za-z_]\w*\s*\(")
TYPE_RE = re.compile(r"^(u8|u16|u32|u64|u128|u256|bool|int)(\[[^\]]*\])?$")
IDENT_RE = re.compile(r"^[A-Za-z_]\w*$")
MEM_RE = re.compile(
    r"^is_mem_init\(\s*\(64u\)\s*([A-Za-z_]\w*)\s*(\[\s*\d+\s*\])?\s*,"
    r"\s*\(64u\)\s*([A-Za-z_]\w*|\d+)\s*\)$")


def strip_comments(text):
    text = re.sub(r"/\*.*?\*/", lambda m: re.sub(r"[^\n]", " ", m.group(0)),
                  text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def parse_params(text, export):
    """[(name, is_array_pointer)] in declaration order."""
    params = []
    for chunk in text.split(","):
        toks = chunk.split()
        if not toks:
            continue
        types = [i for i, t in enumerate(toks) if TYPE_RE.match(t)]
        if len(types) != 1:
            raise InputError(f"{export}: cannot read parameter '{chunk.strip()}'")
        i = types[0]
        names = toks[i + 1:]
        if not names or not all(IDENT_RE.match(n) for n in names):
            raise InputError(f"{export}: cannot read parameter '{chunk.strip()}'")
        array = "ptr" in toks[:i] and "[" in toks[i]
        params.extend((n, array) for n in names)
    return params


def split_top(text, sep):
    """Split text on sep outside parentheses and brackets."""
    parts, depth, cur, i = [], 0, [], 0
    while i < len(text):
        c = text[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        if depth == 0 and text.startswith(sep, i):
            parts.append("".join(cur))
            cur = []
            i += len(sep)
            continue
        cur.append(c)
        i += 1
    parts.append("".join(cur))
    return parts


def contract_text(attrs, export):
    """The requires clause of the #[safety] attribute in attrs, or ''."""
    at = attrs.rfind("#[safety")
    if at < 0:
        raise InputError(f"{export}: no #[safety] contract")
    body = attrs[at:]
    lb = body.index("{")
    depth = 0
    for j in range(lb, len(body)):
        if body[j] == "{":
            depth += 1
        elif body[j] == "}":
            depth -= 1
            if depth == 0:
                break
    else:
        raise InputError(f"{export}: unterminated #[safety] contract")
    fields = split_top(body[lb + 1:j], ",")
    requires = ""
    for f in fields:
        key, _, value = f.strip().partition("=")
        if key.strip() == "requires":
            requires = value.strip()
    return requires


def export_bounds(src_path):
    """{export: {"params": [(name, bound)], "lanes": [atom]}}.

    bound is ("arg", name) or ("const", int)."""
    text = strip_comments(open(src_path, encoding="utf-8").read())
    out = {}
    prev_end = 0
    for m in EXPORT_RE.finditer(text):
        export = m.group(1)
        # The attributes of this export lie after the end of the previous
        # function's header.
        attrs = text[prev_end:m.start()]
        last_fn = None
        for f in FN_END_RE.finditer(attrs):
            last_fn = f
        if last_fn is not None:
            attrs = attrs[last_fn.end():]
        prev_end = m.end()
        params = parse_params(m.group(2), export)
        names = {n for n, _ in params}
        requires = contract_text(attrs, export)
        if "||" in requires or "==>" in requires or "?" in requires:
            raise InputError(f"{export}: requires is not a conjunction")
        mem = {}
        lanes = []
        for atom in split_top(requires, "&&") if requires else []:
            atom = " ".join(atom.split())
            if not atom.startswith("is_mem_init"):
                continue
            a = MEM_RE.match(atom)
            if not a:
                raise InputError(f"{export}: cannot read '{atom}'")
            base, index, length = a.groups()
            if base not in names:
                raise InputError(f"{export}: '{atom}' names no argument")
            if length.isdigit():
                bound = ("const", int(length))
            elif length in names:
                bound = ("arg", length)
            else:
                raise InputError(f"{export}: '{atom}' length is no argument")
            if index:
                lanes.append((base, int(index.strip("[] ")), bound[1]))
                continue
            if base in mem and mem[base] != bound:
                raise InputError(f"{export}: two bounds for {base}")
            mem[base] = bound
        bounds = []
        for name, array in params:
            if name in mem:
                if array:
                    raise InputError(f"{export}: is_mem_init on array {name}")
                bounds.append((name, mem[name]))
            else:
                bounds.append((name, ("const", 0)))
        if export in out:
            raise InputError(f"{export}: exported twice")
        out[export] = {"params": bounds, "lanes": lanes}
    if not out:
        raise InputError(f"{src_path}: no export")
    return out


def show_bound(name, bound):
    kind, v = bound
    return f"mem_{name} <= {v}"


def show_lanes(lanes):
    """The lane regions in short form: in[0..7] <= len."""
    groups = {}
    for base, k, length in lanes:
        groups.setdefault((base, length), []).append(k)
    return [f"{b}[{min(ks)}..{max(ks)}] <= {n}" if len(ks) > 1 else f"{b}[{ks[0]}] <= {n}"
            for (b, n), ks in sorted(groups.items())]


# ---------------------------------------------------------------------------
# Checker output

NUM = r"\d+(?:/\d+)?"
TOKEN_RE = re.compile(
    rf"\s*(?:(?P<num>{NUM})|(?P<var>[A-Za-z_][\w.]*)|(?P<op>≤|≥|<=|>=|=|<|>)"
    r"|(?P<sign>[+-])|(?P<dot>·|\*))")


def parse_linear(text):
    """{var: coef}, const for a sum of terms c·x, x, c."""
    pos, coeffs, const = 0, {}, Fraction(0)
    sign = Fraction(1)
    expect_term = True
    while pos < len(text):
        m = TOKEN_RE.match(text, pos)
        if not m or m.end() == pos:
            if text[pos:].strip() == "":
                break
            raise InputError(f"cannot read '{text}'")
        pos = m.end()
        if m.group("sign"):
            sign = sign * (-1 if m.group("sign") == "-" else 1)
            expect_term = True
            continue
        if not expect_term:
            raise InputError(f"cannot read '{text}'")
        if m.group("num"):
            c = Fraction(m.group("num"))
            m2 = TOKEN_RE.match(text, pos)
            if m2 and m2.group("dot"):
                m3 = TOKEN_RE.match(text, m2.end())
                if not m3 or not m3.group("var"):
                    raise InputError(f"cannot read '{text}'")
                pos = m3.end()
                v = m3.group("var")
                coeffs[v] = coeffs.get(v, 0) + sign * c
            else:
                const += sign * c
        elif m.group("var"):
            v = m.group("var")
            coeffs[v] = coeffs.get(v, 0) + sign
        else:
            raise InputError(f"cannot read '{text}'")
        sign = Fraction(1)
        expect_term = False
    if expect_term:
        raise InputError(f"cannot read '{text}'")
    return coeffs, const


def parse_constraint(text):
    """(coeffs, const, kind): sum coeffs·x <= const, or = const."""
    m = re.search(r"≤|≥|<=|>=|=|<|>", text)
    if not m:
        raise InputError(f"no relation in '{text}'")
    op = m.group(0)
    lc, lk = parse_linear(text[:m.start()])
    rc, rk = parse_linear(text[m.end():])
    coeffs = dict(lc)
    for v, c in rc.items():
        coeffs[v] = coeffs.get(v, 0) - c
    const = rk - lk
    if op in ("≥", ">=", ">"):
        coeffs = {v: -c for v, c in coeffs.items()}
        const = -const
    # A strict inequality is relaxed to the non-strict one; the relaxed
    # polyhedron is larger, so an implication it gives still holds.
    kind = "eq" if op == "=" else "le"
    return ({v: c for v, c in coeffs.items() if c != 0}, const, kind)


class Undecided(Exception):
    pass


MAX_CONSTRAINTS = 20000


def normalise(cons):
    """Drop trivial rows, merge parallel ones; None if infeasible."""
    best = {}
    eqs = []
    for coeffs, const, kind in cons:
        if not coeffs:
            if (kind == "le" and const < 0) or (kind == "eq" and const != 0):
                return None
            continue
        if kind == "eq":
            eqs.append((coeffs, const, kind))
            continue
        lead = coeffs[min(coeffs)]
        scale = abs(lead)
        key = tuple(sorted((v, c / scale) for v, c in coeffs.items()))
        k = const / scale
        if key not in best or k < best[key]:
            best[key] = k
    rows = eqs + [({v: c for v, c in key}, k, "le") for key, k in best.items()]
    if len(rows) > MAX_CONSTRAINTS:
        raise Undecided("too many constraints")
    return rows


def maximise(cons, target):
    """Largest value of the linear form target on the polyhedron cons:
    a Fraction, None when unbounded, or "empty"."""
    t = "__t"
    tc, tk = target
    # t - target = tk, i.e. t equals the form plus its constant.
    row = {t: Fraction(1)}
    for v, c in tc.items():
        row[v] = row.get(v, 0) - c
    cons = list(cons) + [(row, tk, "eq")]
    cons = normalise(cons)
    if cons is None:
        return "empty"
    # Equalities first: solve each for one of its variables other than t.
    while True:
        pick = None
        for i, (coeffs, const, kind) in enumerate(cons):
            if kind == "eq":
                others = [v for v in coeffs if v != t]
                if others:
                    pick = (i, min(others))
                    break
        if pick is None:
            break
        i, v = pick
        coeffs, const, _ = cons.pop(i)
        a = coeffs[v]
        # v = (const - sum_{w != v} coeffs[w]·w) / a
        new = []
        for c2, k2, kind2 in cons:
            if v not in c2:
                new.append((c2, k2, kind2))
                continue
            f = c2[v] / a
            c3 = {w: c2.get(w, 0) - f * coeffs.get(w, 0)
                  for w in set(c2) | set(coeffs) if w != v}
            new.append(({w: c for w, c in c3.items() if c != 0},
                        k2 - f * const, kind2))
        cons = normalise(new)
        if cons is None:
            return "empty"
    # Then Fourier-Motzkin on the inequalities, cheapest variable first.
    while True:
        variables = {v for c, _, _ in cons for v in c if v != t}
        if not variables:
            break

        def cost(v):
            p = sum(1 for c, _, k in cons if k == "le" and c.get(v, 0) > 0)
            n = sum(1 for c, _, k in cons if k == "le" and c.get(v, 0) < 0)
            return (p * n - p - n, v)

        v = min(variables, key=cost)
        pos, neg, rest = [], [], []
        for c, k, kind in cons:
            if kind == "eq":
                if v in c:
                    raise Undecided("equality left after substitution")
                rest.append((c, k, kind))
            elif c.get(v, 0) > 0:
                pos.append((c, k))
            elif c.get(v, 0) < 0:
                neg.append((c, k))
            else:
                rest.append((c, k, kind))
        for cp, kp in pos:
            for cn, kn in neg:
                fp, fn = cp[v], -cn[v]
                c3 = {w: fn * cp.get(w, 0) + fp * cn.get(w, 0)
                      for w in set(cp) | set(cn) if w != v}
                rest.append(({w: c for w, c in c3.items() if c != 0},
                             fn * kp + fp * kn, "le"))
        cons = normalise(rest)
        if cons is None:
            return "empty"
    upper = None
    for c, k, kind in cons:
        a = c.get(t, 0)
        if a > 0 or (kind == "eq" and a != 0):
            u = k / a
            upper = u if upper is None or u < upper else upper
    return upper


def read_log(log_text, function):
    """The parts of a checker log the verdict needs."""
    lines = log_text.splitlines()
    analysed = [l.split("Analyzing function", 1)[1].strip()
                for l in lines if "Analyzing function" in l]
    info = {
        "analysed": analysed,
        "no_violation": sum(1 for l in lines if "*** No Safety Violation" in l),
        "violations": [],
        "assumptions": any("*** Safety Assumptions" in l for l in lines),
        "alignment": any("Possible alignment issue" in l for l in lines),
        "unsafe": any("Program is not safe" in l for l in lines),
        "ranges": {},
        "rel": None,
    }
    i = 0
    while i < len(lines):
        l = lines[i]
        if "*** Possible Safety Violation" in l:
            i += 1
            while i < len(lines) and lines[i].startswith("  ") and lines[i].strip():
                info["violations"].append(lines[i].strip())
                i += 1
            continue
        if l.startswith("Memory ranges:"):
            i += 1
            while i < len(lines) and lines[i].strip():
                m = re.match(r"^\s*mem_(\S+): \[(.*); (.*)\]\s*$", lines[i])
                if not m:
                    raise InputError(f"cannot read range '{lines[i].strip()}'")
                info["ranges"][m.group(1)] = (m.group(2), m.group(3))
                i += 1
            continue
        if l.startswith("* Rel:"):
            if info["rel"] is not None:
                raise InputError("more than one relation in the log")
            if i + 1 >= len(lines):
                raise InputError("no relation after '* Rel:'")
            info["rel"] = lines[i + 1].strip()
            i += 2
            continue
        i += 1
    return info


def verdict(src, export, log_path, function):
    bounds = export_bounds(src)
    if export not in bounds:
        raise InputError(f"{export} is no export of {src}")
    entry = bounds[export]
    info = read_log(open(log_path, encoding="utf-8", errors="replace").read(),
                    function)
    why = []
    if function not in info["analysed"]:
        return False, [f"the checker did not analyse {function}"]
    if len(info["analysed"]) != 1:
        why.append(f"{len(info['analysed'])} functions analysed, expected 1")
    if info["violations"] or info["unsafe"]:
        shown = info["violations"][:3]
        more = len(info["violations"]) - len(shown)
        why.append("checker violation: " + "; ".join(shown)
                   + (f"; and {more} more" if more > 0 else ""))
    if info["assumptions"]:
        why.append("verdict under safety assumptions")
    if info["alignment"]:
        why.append("possible alignment issue")
    if info["no_violation"] != 1 and not why:
        why.append("no verdict")
    for lane in show_lanes(entry["lanes"]):
        why.append(f"{lane}: a region at a pointer read from an array has"
                   " no range in the checker's memory model")
    if why:
        return False, why
    names = [n for n, _ in entry["params"]]
    for n in names:
        if n not in info["ranges"]:
            why.append(f"no range printed for {n}")
    for n, (lo, hi) in info["ranges"].items():
        if n not in names:
            why.append(f"range for mem_{n}, which is no argument")
        if "inf" in lo or "inf" in hi:
            why.append(f"mem_{n} is unbounded: [{lo}; {hi}]")
    if info["rel"] is None:
        why.append("no relation printed")
    if why:
        return False, why
    rel = info["rel"]
    if not (rel.startswith("{") and rel.endswith("}")):
        return False, [f"cannot read the relation '{rel}'"]
    body = rel[1:-1].strip()
    cons = [parse_constraint(c) for c in split_top(body, ",")] if body else []
    shown = []
    for n, (kind, v) in entry["params"]:
        if kind == "arg":
            target = ({f"mem_{n}": Fraction(1), f"inv_{v}": Fraction(-1)}, Fraction(0))
        else:
            target = ({f"mem_{n}": Fraction(1)}, Fraction(-v))
        try:
            top = maximise(cons, target)
        except Undecided as e:
            why.append(f"mem_{n} <= {v}: undecided ({e})")
            continue
        if top == "empty":
            why.append("the relation is empty")
            break
        related = kind != "arg" or any(
            f"mem_{n}" in c and any(w.startswith("inv_") for w in c)
            for c, _, _ in cons)
        if top is None:
            why.append(f"mem_{n} is not bounded by {v}")
        elif top >= 1:
            excess = top if top.denominator == 1 else float(top)
            if related:
                why.append(f"mem_{n} may exceed {v} by {excess}")
            else:
                why.append(f"mem_{n} is not related to {v}: it may exceed"
                           f" {v} by {excess}")
        else:
            shown.append(f"mem_{n} <= {v}")
    if why:
        return False, why
    return True, shown


def main(argv):
    if len(argv) >= 2 and argv[1] == "bounds":
        if len(argv) < 3:
            raise InputError("usage: ranges.py bounds SRC [EXPORT...]")
        bounds = export_bounds(argv[2])
        wanted = argv[3:] or list(bounds)
        for e in wanted:
            if e not in bounds:
                raise InputError(f"{e} is no export of {argv[2]}")
            parts = [show_bound(n, b) for n, b in bounds[e]["params"]]
            parts += [f"{l} (no checker range)" for l in show_lanes(bounds[e]["lanes"])]
            print(f"{e}\t" + ", ".join(parts))
        return 0
    if len(argv) >= 2 and argv[1] == "verdict":
        args = argv[2:]
        function = None
        if "--function" in args:
            i = args.index("--function")
            if i + 1 >= len(args):
                raise InputError("--function needs a name")
            function = args[i + 1]
            del args[i:i + 2]
        if len(args) != 3:
            raise InputError("usage: ranges.py verdict SRC EXPORT LOG [--function NAME]")
        src, export, log = args
        ok, notes = verdict(src, export, log, function or export)
        print(("PASS " if ok else "FAIL ") + "; ".join(notes))
        return 0 if ok else 1
    raise InputError("usage: ranges.py bounds|verdict ...")


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except (InputError, OSError) as e:
        print(f"ranges.py: {e}", file=sys.stderr)
        sys.exit(2)
