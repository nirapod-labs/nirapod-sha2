#!/usr/bin/env python3
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# tests/isa/check.py
# ==================
#
# Checks that the CPU features capi/units.c declares for each unit and
# operation family cover every instruction the family's exports can
# execute, as the pinned compiler's assembly has them. dispatch.c and the
# testing interface run a family only on a CPU that has its declared
# features, so an instruction outside them is a fault (SIGILL) on a CPU
# that has the declared features and not the one used.
#
# Derivation. Each export of a unit is followed through every label its
# code names (calls, jumps and address loads) to the functions it can
# reach, and every instruction of those functions is classified:
#
#     x86-64    base         the x86-64 baseline: integer instructions,
#                            CMOV, LFENCE, SSE and SSE2
#               AVX          any VEX-encoded instruction
#               AVX2         VEX integer instructions on ymm registers, and
#                            the AVX2-only forms at any width (VINSERTI128,
#                            VBROADCASTI128, VPERM2I128, VPERMQ, ...)
#               BMI1, BMI2   ANDN, BLSR, ...; RORX, SHLX, ...
#               SHA          SHA256RNDS2, SHA256MSG1, SHA256MSG2
#               SSSE3, SSE4.1, SSE4.2, AVX-512 and the rest: never declared
#     AArch64   base         the A64 integer instructions
#               ASIMD        any instruction on the SIMD and floating-point
#                            registers (v, q, d, s, h, b)
#               SHA256       SHA256H, SHA256H2, SHA256SU0, SHA256SU1
#               SHA512       SHA512H, SHA512H2, SHA512SU0, SHA512SU1
#               SHA3, AES and the rest: never declared
#
# A mnemonic this script does not know fails the check, so a new
# instruction cannot pass unclassified.
#
# Declaration. units.c gives each unit a needs[] entry per family as an
# expression of the NIRAPOD_SHA2_CPU_* bits of capi/internal.h. A bit
# stands for these extensions:
#
#     AVX2    AVX2 and AVX       SHANI   SHA and AVX
#     BMI2    BMI1 and BMI2      ASIMD   ASIMD
#     SHA256  SHA256             SHA512  SHA512
#
# AVX comes with SHANI and AVX2 because dispatch.c reports no x86-64
# feature unless the CPU reports AVX and OSXSAVE and the operating system
# has enabled the SSE and AVX register state.
#
# A family passes when the extensions of every one of its exports lie
# within its declared ones. Declared extensions no export uses are listed
# as a note: declaring more than needed is safe, only slower to admit.
#
# Negative controls, run every time; each must make the check fail:
#
#   needs        every declared bit that some export of the family needs,
#                removed in turn from the declaration
#   shani        the shani unit's SHA-256 and 8-way families declared as
#                SHANI alone, a declaration that omits the AVX2 its stack
#                clearing (VPXOR on ymm) executes
#   reach        an ANDN placed in a function reachable from the portable
#                x86-64 unit's sha256 export only through a call
#   avx2         a VPXOR on ymm registers placed in that export itself
#   sha512       a SHA512H placed in the aarch64 sha2 unit's sha256
#                export, whose family declares SHA256 and not SHA512
#   unknown      a mnemonic no table knows, placed in an export
#
#     check.py UNITS_C INTERNAL_H ASM...
#
# ASM names the assembly files of the units, <unit>.s; a unit of units.c
# must have at least one, and every file must belong to a unit.
# Exit status 0 when every family passes and every control fails as
# required, 1 otherwise, 2 on a usage or parse error.

import copy
import os
import re
import sys

FAMILIES = ("SHA256", "SHA512", "X8", "X4")


def parse_error(message):
    sys.stderr.write("check.py: %s\n" % message)
    sys.exit(2)


# ---------------------------------------------------------------------
# Declaration: capi/units.c and capi/internal.h
# ---------------------------------------------------------------------

DEFINE_RE = re.compile(r"^[ \t]*#[ \t]*define[ \t]+(\w+)[ \t]+(.+?)[ \t]*(?:/\*.*)?$", re.M)
UNIT_RE = re.compile(r'\{\s*"([\w-]+)"\s*,\s*\{([^{}]*)\}\s*,\s*UNIT_OPS\((\w+)\)\s*\}')

BIT_EXTENSIONS = {
    "x86_64": {
        "NIRAPOD_SHA2_CPU_AVX2": {"AVX2", "AVX"},
        "NIRAPOD_SHA2_CPU_SHANI": {"SHA", "AVX"},
        "NIRAPOD_SHA2_CPU_BMI2": {"BMI1", "BMI2"},
    },
    "aarch64": {
        "NIRAPOD_SHA2_CPU_ASIMD": {"ASIMD"},
        "NIRAPOD_SHA2_CPU_SHA256": {"SHA256"},
        "NIRAPOD_SHA2_CPU_SHA512": {"SHA512"},
    },
}


def defines(text):
    return {m.group(1): m.group(2).strip() for m in DEFINE_RE.finditer(text)}


def evaluate(expr, table, depth=0):
    """An expression of integer literals, names of table, | and parentheses."""
    if depth > 16:
        parse_error("macro nesting too deep in %r" % expr)
    tokens = re.findall(r"0[xX][0-9a-fA-F]+[uUlL]*|\d+[uUlL]*|\w+|[|()]|\S", expr)
    value = 0
    pos = 0

    def atom(i):
        tok = tokens[i]
        if tok == "(":
            v, j = alternatives(i + 1)
            if j >= len(tokens) or tokens[j] != ")":
                parse_error("unbalanced parentheses in %r" % expr)
            return v, j + 1
        m = re.fullmatch(r"(0[xX][0-9a-fA-F]+|\d+)[uUlL]*", tok)
        if m:
            return int(m.group(1), 0), i + 1
        if re.fullmatch(r"\w+", tok) and tok in table:
            return evaluate(table[tok], table, depth + 1), i + 1
        parse_error("cannot evaluate %r in %r" % (tok, expr))

    def alternatives(i):
        v, i = atom(i)
        while i < len(tokens) and tokens[i] == "|":
            w, i = atom(i + 1)
            v |= w
        return v, i

    if not tokens:
        parse_error("empty expression")
    value, pos = alternatives(0)
    if pos != len(tokens):
        parse_error("unexpected %r in %r" % (tokens[pos], expr))
    return value


def arch_sections(text):
    a = text.find("#if defined(__aarch64__)")
    x = text.find("#elif defined(__x86_64__)")
    e = text.find("#else", x)
    if a < 0 or x < a or e < x:
        parse_error("units.c: the per-architecture sections were not found")
    return {"aarch64": text[a:x], "x86_64": text[x:e]}


def read_units(units_c, internal_h):
    with open(units_c, encoding="utf-8") as f:
        text = f.read()
    with open(internal_h, encoding="utf-8") as f:
        internal = f.read()
    common = defines(internal)
    bits = {}
    for arch, names in BIT_EXTENSIONS.items():
        for name in names:
            if name not in common:
                parse_error("internal.h does not define %s" % name)
            bits[(arch, evaluate(common[name], common))] = name
    units = {}
    for arch, section in arch_sections(text).items():
        table = dict(common)
        table.update(defines(section))
        rows = UNIT_RE.findall(section)
        if not rows:
            parse_error("units.c: no unit for %s" % arch)
        for name, needs, ops in rows:
            if ops != name.replace("-", "_"):
                parse_error("units.c: unit %s uses the exports of %s" % (name, ops))
            if not name.startswith(arch + "-"):
                parse_error("units.c: unit %s in the %s section" % (name, arch))
            exprs = [x.strip() for x in needs.split(",")]
            if len(exprs) != len(FAMILIES):
                parse_error("units.c: unit %s has %d needs" % (name, len(exprs)))
            declared = {}
            for family, expr in zip(FAMILIES, exprs):
                value = evaluate(expr, table)
                names = set()
                for (a, bit), bit_name in bits.items():
                    if a == arch and value & bit:
                        names.add(bit_name)
                        value &= ~bit
                if value:
                    parse_error("units.c: unit %s, family %s: bits %#x have no meaning here"
                                % (name, family, value))
                declared[family] = names
            units[name] = {"arch": arch, "declared": declared}
    return units


def extensions_of(arch, bit_names):
    out = set()
    for name in bit_names:
        out |= BIT_EXTENSIONS[arch][name]
    return out


# ---------------------------------------------------------------------
# Instruction classes
# ---------------------------------------------------------------------

X86_BASE = re.compile(
    r"(mov|add|sub|xor|and|or|ror|rol|shr|shl|sar|lea|cmp|test|inc|dec|neg|not|bswap|push|pop"
    r"|adc|sbb|imul|mul|xchg)[bwlq]?"
    r"|cmov[a-z]+|j[a-z]+|set[a-z]+|movz[bw][wlq]?|movs[bw][wlq]?|movslq|cltq|cqto"
    r"|call|ret|lfence|mfence|sfence|nop|leave")
X86_SSE2 = re.compile(
    r"movdq[au]|movap[sd]|movup[sd]|movd|movq|pxor|por|pand|pandn|xorp[sd]|andp[sd]|orp[sd]"
    r"|padd[bwdq]|psub[bwdq]|psll[wdq]|psrl[wdq]|psra[wd]|pslldq|psrldq|pshufd|pshuf[lh]w"
    r"|punpck[lh](bw|wd|dq|qdq)|pcmpeq[bwd]|pcmpgt[bwd]|pmuludq|shufp[sd]")
X86_SSSE3 = re.compile(r"pshufb|palignr|phadd[wd]|phsub[wd]|pabs[bwd]|psign[bwd]|pmulhrsw|pmaddubsw")
X86_SSE41 = re.compile(
    r"pblend(w|vb)|blendv?p[sd]|pextr[bwdq]|pinsr[bdq]|ptest|pmin[su][bwd]|pmax[su][bwd]"
    r"|pmov[sz]x[bwd][wdq]|pmulld|pmuldq|pcmpeqq|packusdw|round[ps][sd]|insertps|extractps|dpp[sd]")
X86_SSE42 = re.compile(r"pcmpgtq|crc32[bwlq]?|pcmp[ei]str[im]")
X86_BMI1 = re.compile(r"(andn|blsr|blsi|blsmsk|bextr|tzcnt)[lq]?")
X86_BMI2 = re.compile(r"(rorx|shlx|shrx|sarx|bzhi|pdep|pext|mulx)[lq]?")
X86_SHA = re.compile(r"sha256(rnds2|msg1|msg2)|sha1(rnds4|nexte|msg1|msg2)")
X86_AVX2_ANY = re.compile(
    r"vbroadcasti128|vinserti128|vextracti128|vperm2i128|vpermq|vpermd|vpblendd"
    r"|vpbroadcast[bwdq]|vps[lr]lv[dq]|vpsravd|vpmaskmov[dq]|v?p?gather[dq]p?[sdq]")
X86_AVX1_VP = re.compile(r"vperm2f128|vpermilp[sd]|vptest")
X86_AVX1_OTHER = re.compile(
    r"vmovdq[au]|vmovap[sd]|vmovup[sd]|vmov[dq]|vxorp[sd]|vandp[sd]|vandnp[sd]|vorp[sd]"
    r"|vinsertf128|vextractf128|vbroadcasts[sd]|vbroadcastf128|vzeroupper|vzeroall"
    r"|vshufp[sd]|vblendp[sd]|vblendvp[sd]|vunpck[lh]p[sd]")


def classify_x86(mnemonic, operands):
    if re.search(r"%zmm|%k[0-7]\b|\{", operands) or re.search(r"%[xy]mm(1[6-9]|2\d|3[01])\b", operands):
        return {"AVX512"}
    if mnemonic.startswith("v"):
        if X86_AVX2_ANY.fullmatch(mnemonic):
            return {"AVX", "AVX2"}
        if mnemonic.startswith("vp") and not X86_AVX1_VP.fullmatch(mnemonic):
            return {"AVX", "AVX2"} if "%ymm" in operands else {"AVX"}
        if X86_AVX1_VP.fullmatch(mnemonic) or X86_AVX1_OTHER.fullmatch(mnemonic):
            return {"AVX"}
        return None
    for pattern, ext in ((X86_SHA, "SHA"), (X86_BMI1, "BMI1"), (X86_BMI2, "BMI2"),
                         (X86_SSSE3, "SSSE3"), (X86_SSE41, "SSE4.1"), (X86_SSE42, "SSE4.2")):
        if pattern.fullmatch(mnemonic):
            return {ext}
    if X86_BASE.fullmatch(mnemonic) or X86_SSE2.fullmatch(mnemonic):
        return set()
    return None


A64_BASE = {
    "mov", "movz", "movn", "movk", "add", "adds", "sub", "subs", "adc", "sbc", "eor", "eon",
    "orr", "orn", "and", "ands", "bic", "bics", "ror", "lsl", "lsr", "asr", "csel", "csinc",
    "csinv", "csneg", "cset", "csetm", "cinc", "ccmp", "ccmn", "cmp", "cmn", "tst", "neg",
    "negs", "mvn", "mul", "madd", "msub", "umulh", "smulh", "umull", "udiv", "sdiv", "ldr",
    "ldrb", "ldrh", "ldrsb", "ldrsh", "ldrsw", "ldur", "ldurb", "ldp", "str", "strb", "strh",
    "stur", "sturb", "stp", "adr", "adrp", "b", "bl", "br", "blr", "ret", "cbz", "cbnz",
    "tbz", "tbnz", "rev", "rev16", "rev32", "rbit", "clz", "extr", "ubfx", "sbfx", "ubfiz",
    "sbfiz", "bfi", "bfxil", "uxtb", "uxth", "sxtb", "sxth", "sxtw", "csdb", "dsb", "dmb",
    "isb", "nop",
}
A64_SIMD = {
    "mov", "movi", "mvni", "add", "sub", "eor", "orr", "orn", "and", "bic", "not", "mvn",
    "bsl", "bit", "bif", "shl", "ushr", "sshr", "sri", "sli", "usra", "ssra", "shrn",
    "ext", "dup", "ins", "umov", "smov", "fmov", "trn1", "trn2", "zip1", "zip2", "uzp1",
    "uzp2", "rev16", "rev32", "rev64", "tbl", "tbx", "ld1", "ld1r", "ld2", "ld3", "ld4",
    "st1", "st2", "st3", "st4", "ldr", "str", "ldp", "stp", "ldur", "stur", "cmeq", "cmhi",
    "addp", "addv", "xtn", "uxtl", "sxtl", "umlal", "umull", "ushl", "sshl",
}
A64_SHA256 = {"sha256h", "sha256h2", "sha256su0", "sha256su1"}
A64_SHA512 = {"sha512h", "sha512h2", "sha512su0", "sha512su1"}
A64_SHA3 = {"eor3", "rax1", "xar", "bcax"}
A64_OTHER = {"aese": "AES", "aesd": "AES", "aesmc": "AES", "aesimc": "AES", "pmull": "AES",
             "pmull2": "AES", "sha1c": "SHA1", "sha1h": "SHA1", "sha1m": "SHA1",
             "sha1p": "SHA1", "sha1su0": "SHA1", "sha1su1": "SHA1"}
A64_FPSIMD_REG = re.compile(r"(?<![\w.$])(v\d+(\.\w+)?|[qdshb]\d+)(?![\w$])")


def classify_a64(mnemonic, operands):
    base = mnemonic.split(".")[0] if mnemonic.startswith("b.") else mnemonic
    if mnemonic.startswith("b."):
        return set()
    if base in A64_SHA256:
        return {"ASIMD", "SHA256"}
    if base in A64_SHA512:
        return {"ASIMD", "SHA512"}
    if base in A64_SHA3:
        return {"ASIMD", "SHA3"}
    if base in A64_OTHER:
        return {"ASIMD", A64_OTHER[base]}
    regs = A64_FPSIMD_REG.search(re.sub(r"[.\w]*nirapod\w*(\$\d+)?|\bglob_data\w*", "", operands))
    if regs:
        return {"ASIMD"} if base in A64_SIMD else None
    if base in A64_BASE:
        return set()
    return None


# ---------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------

LABEL_RE = re.compile(r"^([.\w$]+):\s*(?:[#;@].*)?$")


def canonical(label):
    """The label without the object-format decoration (_, .L, L)."""
    name = label
    if name.startswith(".L"):
        name = name[2:]
    elif name.startswith("L") and "nirapod" in name:
        name = name[1:]
    if name.startswith("_nirapod"):
        name = name[1:]
    return name


def read_asm(path):
    """Functions of the file: name -> {"ins": [(line, mnemonic, operands)], "refs": set()}."""
    functions = {}
    owner = {}
    order = []
    current = None
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()
    for number, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")
        stripped = line.strip()
        if not stripped or stripped.startswith(("#", "//", ";")):
            continue
        m = LABEL_RE.match(line)
        if m:
            label = canonical(m.group(1))
            base = re.sub(r"\$\d+$", "", label)
            if base == label:
                current = label
                functions[current] = {"ins": [], "refs": set()}
                order.append(current)
            elif base not in functions:
                parse_error("%s:%d: label %s outside its function" % (path, number, label))
            else:
                current = base
            owner[label] = current
            continue
        if stripped.startswith("."):
            continue
        if not line[0].isspace():
            parse_error("%s:%d: unexpected line: %s" % (path, number, line))
        if current is None:
            parse_error("%s:%d: instruction before any label" % (path, number))
        parts = stripped.split(None, 1)
        mnemonic = parts[0].lower()
        operands = parts[1] if len(parts) > 1 else ""
        functions[current]["ins"].append((number, mnemonic, operands))
        for ref in re.findall(r"[.\w$]*nirapod\w*(?:\$\d+)?", operands):
            functions[current]["refs"].add(canonical(ref))
    for name, fn in functions.items():
        fn["calls"] = set()
        for ref in fn["refs"]:
            target = owner.get(ref)
            if target is None:
                parse_error("%s: %s names %s, which is not a label of the file" % (path, name, ref))
            if target != name:
                fn["calls"].add(target)
    return functions, order


def reachable(functions, start):
    seen = set()
    stack = [start]
    while stack:
        name = stack.pop()
        if name in seen:
            continue
        seen.add(name)
        stack.extend(functions[name]["calls"])
    return seen


def family_of(export):
    if export.startswith("sha256_x8"):
        return "X8"
    if export.startswith("sha512_x4"):
        return "X4"
    if re.match(r"(sha224|sha256|hmac_sha256)(_|$)", export):
        return "SHA256"
    if re.match(r"(sha384|sha512|sha512_224|sha512_256|hmac_sha512)(_|$)", export):
        return "SHA512"
    return None


# ---------------------------------------------------------------------
# The check
# ---------------------------------------------------------------------


def derive(unit, arch, functions, order, path):
    """Per export: (family, extensions, unknown, examples)."""
    classify = classify_x86 if arch == "x86_64" else classify_a64
    prefix = "nirapod_sha2_jz_%s__" % unit.replace("-", "_")
    exports = {}
    for name in order:
        if not name.startswith(prefix) or name.startswith(prefix + "_"):
            continue
        export = name[len(prefix):]
        family = family_of(export)
        if family is None:
            parse_error("%s: export %s belongs to no family" % (path, export))
        used = set()
        unknown = []
        example = {}
        for fn in sorted(reachable(functions, name)):
            for number, mnemonic, operands in functions[fn]["ins"]:
                classes = classify(mnemonic, operands)
                if classes is None:
                    unknown.append("%s:%d: %s %s" % (os.path.basename(path), number, mnemonic,
                                                     operands))
                    continue
                for c in classes:
                    used.add(c)
                    example.setdefault(c, "%s:%d: %s %s" % (os.path.basename(path), number,
                                                             mnemonic, operands))
        exports[export] = {"family": family, "used": used, "unknown": unknown,
                           "example": example}
    return exports


def judge(units, derived, quiet=False):
    """Failures of the comparison: a list of strings."""
    failures = []
    for (unit, path), exports in sorted(derived.items()):
        arch = units[unit]["arch"]
        for family in FAMILIES:
            allowed = extensions_of(arch, units[unit]["declared"][family])
            members = {e: d for e, d in exports.items() if d["family"] == family}
            used = set()
            bad = []
            for export, d in sorted(members.items()):
                used |= d["used"]
                for line in d["unknown"][:1]:
                    bad.append("%s: unclassified instruction %s" % (export, line))
                excess = d["used"] - allowed
                for ext in sorted(excess):
                    bad.append("%s: %s beyond the declared needs (%s)"
                               % (export, ext, d["example"][ext]))
            status = "FAIL" if bad else "PASS"
            if not quiet:
                note = ""
                spare = allowed - used
                if spare and not bad:
                    note = "  note: declared, not used: %s" % " ".join(sorted(spare))
                print("%s %-17s %-6s %-8s %2d exports  declared %-18s used %s%s"
                      % (status, unit, family, os.path.basename(os.path.dirname(path)),
                         len(members), " ".join(sorted(allowed)) or "-",
                         " ".join(sorted(used)) or "-", note))
                for b in bad[:8]:
                    print("     %s" % b)
            failures.extend("%s %s %s" % (unit, family, b) for b in bad)
    return failures


def controls(units, derived, asm):
    """Each control must make judge() fail. Returns the controls that did not."""
    missed = []
    ran = 0

    def expect_failure(name, u, d, match=None):
        nonlocal ran
        ran += 1
        failures = judge(u, d, quiet=True)
        if not failures or (match is not None and not any(match in f for f in failures)):
            missed.append(name)

    for (unit, path), exports in sorted(derived.items()):
        arch = units[unit]["arch"]
        for family in FAMILIES:
            used = set()
            for d in exports.values():
                if d["family"] == family:
                    used |= d["used"]
            for bit in sorted(units[unit]["declared"][family]):
                rest = units[unit]["declared"][family] - {bit}
                if used <= extensions_of(arch, rest):
                    continue
                u = copy.deepcopy(units)
                u[unit]["declared"][family] = rest
                expect_failure("needs %s %s without %s" % (unit, family, bit), u, derived,
                               "%s %s" % (unit, family))

    if "x86_64-shani" in units:
        u = copy.deepcopy(units)
        for family in ("SHA256", "X8"):
            u["x86_64-shani"]["declared"][family] = {"NIRAPOD_SHA2_CPU_SHANI"}
        for family in ("SHA256", "X8"):
            expect_failure("shani %s declared SHANI alone" % family, u, derived,
                           "x86_64-shani %s" % family)
    else:
        missed.append("shani: no x86_64-shani unit")

    def injected(unit, target_fn, mnemonic, operands):
        for (name, path), (functions, order) in asm.items():
            if name != unit:
                continue
            f = copy.deepcopy(functions)
            if target_fn not in f:
                return None
            f[target_fn]["ins"].append((0, mnemonic, operands))
            d = dict(derived)
            d[(name, path)] = derive(name, units[name]["arch"], f, order, path)
            return d
        return None

    def first_callee(unit, export):
        for (name, _), (functions, _) in asm.items():
            if name == unit and export in functions:
                callees = sorted(functions[export]["calls"])
                return callees[0] if callees else None
        return None

    cases = []
    portable = "nirapod_sha2_jz_x86_64_portable__sha256"
    callee = first_callee("x86_64-portable", portable)
    cases.append(("reach", "x86_64-portable", portable, callee, "andnq", "%rax, %rbx, %rcx",
                  "x86_64-portable SHA256"))
    cases.append(("avx2", "x86_64-portable", portable, portable, "vpxor",
                  "%ymm0, %ymm0, %ymm0", "x86_64-portable SHA256"))
    sha2 = "nirapod_sha2_jz_aarch64_sha2__sha256"
    cases.append(("sha512", "aarch64-sha2", sha2, sha2, "sha512h", "q0, q1, v2.2d",
                  "aarch64-sha2 SHA256"))
    cases.append(("unknown", "aarch64-sha2", sha2, sha2, "frobnicate", "x0", "unclassified"))
    for name, unit, export, target, mnemonic, operands, match in cases:
        if target is None:
            missed.append("%s: %s has no callee" % (name, export))
            continue
        d = injected(unit, target, mnemonic, operands)
        if d is None:
            missed.append("%s: unit %s or function %s not found" % (name, unit, target))
            continue
        expect_failure(name, units, d, match)
    return ran, missed


def main(argv):
    if len(argv) < 4:
        sys.stderr.write("usage: check.py UNITS_C INTERNAL_H ASM...\n")
        return 2
    units = read_units(argv[1], argv[2])
    asm = {}
    derived = {}
    seen_units = set()
    for path in argv[3:]:
        unit = os.path.basename(path)[:-2] if path.endswith(".s") else None
        if unit not in units:
            parse_error("%s belongs to no unit of units.c" % path)
        seen_units.add(unit)
        functions, order = read_asm(path)
        asm[(unit, path)] = (functions, order)
        derived[(unit, path)] = derive(unit, units[unit]["arch"], functions, order, path)
        if not derived[(unit, path)]:
            parse_error("%s: no export of unit %s" % (path, unit))
    for unit in sorted(set(units) - seen_units):
        parse_error("no assembly given for unit %s" % unit)

    counts = {len(d) for d in derived.values()}
    if len(counts) != 1:
        parse_error("the units do not have the same number of exports: %s" % sorted(counts))

    failures = judge(units, derived)
    ran, missed = controls(units, derived, asm)
    for m in missed:
        print("FAIL control %s: the check did not fail" % m)
    ok = not failures and not missed
    print("isa: %d files, %d exports each, %d failures, %d negative controls, %d not "
          "rejected, %s" % (len(derived), counts.pop(), len(failures), ran, len(missed),
                            "PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
