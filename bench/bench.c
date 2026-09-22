/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * bench.c
 * =======
 *
 * The benchmark driver. It builds the workload list, checks every output
 * against bench_kat.c before timing anything, then times each workload of
 * each variant a backend offers. It writes one CSV row per workload and
 * can instead measure stack use (--stack) or only verify the outputs
 * (--selftest).
 *
 * Timing
 *
 *     A call is timed in batches. The batch size is chosen once per
 *     workload so that a sample lasts about --target-ms; --warmup samples
 *     are run and discarded, then --reps samples are kept. The reported
 *     latency is the median over the samples, the variability the
 *     interquartile range (quartiles by linear interpolation) as a
 *     percentage of the median. The clock is CLOCK_MONOTONIC_RAW.
 *
 * Cycles
 *
 *     x86-64: RDTSCP around each batch. The TSC is invariant and counts
 *     at a fixed frequency, so the number is a stable time unit rather
 *     than the core clock under boost. The frequency is measured at
 *     startup and printed, for the record only; cycles per byte use the
 *     ticks as they are.
 *
 *     AArch64 macOS: user code has no cycle counter. Without --ghz the
 *     cycle columns are empty and the nanoseconds stand on their own.
 *     With --ghz N the driver multiplies the measured time by N and
 *     labels the result derived, never measured.
 *
 * Stack
 *
 *     --stack paints 256 KiB of stack below the call site with 0xA5,
 *     calls the workload, and scans upward for the first changed byte.
 *     The depth is reported below the caller's stack pointer, so it
 *     includes the return address (8 bytes on x86-64) and any ABI
 *     padding. The painted region is much deeper than any of these
 *     operations needs; an operation that went deeper than 256 KiB would
 *     be reported too low.
 */

#if defined(__linux__)
#define _POSIX_C_SOURCE 200809L
#endif

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(__APPLE__)
#include <sys/sysctl.h>
#include <sys/types.h>
#endif

#if defined(__linux__)
#include <sys/utsname.h>
#endif

#if defined(__x86_64__)
#include <x86intrin.h>
#endif

#include "bench.h"

#define BENCH_MAX_WORKLOADS 320
#define BENCH_MAX_REPS 64

static uint8_t msg[BENCH_MAX_WORK_BYTES];
static uint8_t key[BENCH_HMAC_KEY_LEN];
static uint8_t out[BENCH_MAX_OUT];

const bench_variant *bench_variants;
size_t bench_variant_count;

static char cpu_model[128] = "unknown";
static char os_name[256] = "unknown";
static const char *const arch_name =
#if defined(__aarch64__)
    "aarch64";
#elif defined(__x86_64__)
    "x86_64";
#else
#error "unsupported architecture"
#endif

static int cycles_enabled;
static int cycles_measured;
static double cycles_per_ns;
static char cycles_source_buf[64] = "none";
static const char *cycles_source = cycles_source_buf;

/* ------------------------------------------------------------------ */
/* Workloads and outputs                                              */
/* ------------------------------------------------------------------ */

void bench_fill_msg(uint8_t *p, size_t n)
{
    size_t i;

    for (i = 0; i < n; i++) {
        p[i] = (uint8_t)((i * 131 + 7) & 0xff);
    }
}

void bench_fill_key(uint8_t *p)
{
    size_t i;

    for (i = 0; i < BENCH_HMAC_KEY_LEN; i++) {
        p[i] = (uint8_t)((i * 197 + 11) & 0xff);
    }
}

const uint8_t *bench_msg(void)
{
    return msg;
}

const uint8_t *bench_key(void)
{
    return key;
}

size_t bench_fn_out_len(bench_fn fn)
{
    switch (fn) {
    case BENCH_SHA224:
    case BENCH_SHA512_224:
        return 28;
    case BENCH_SHA256:
    case BENCH_SHA512_256:
    case BENCH_HMAC_SHA256:
        return 32;
    case BENCH_SHA384:
        return 48;
    case BENCH_SHA512:
    case BENCH_HMAC_SHA512:
        return 64;
    case BENCH_SHA256_X8:
    case BENCH_SHA512_X4:
    case BENCH_SHA256_X8_REF:
    case BENCH_SHA512_X4_REF:
        return 256;
    default:
        return 0;
    }
}

size_t bench_work_bytes(const bench_workload *w)
{
    switch (w->fn) {
    case BENCH_SHA256_X8:
    case BENCH_SHA256_X8_REF:
        return 8 * w->len;
    case BENCH_SHA512_X4:
    case BENCH_SHA512_X4_REF:
        return 4 * w->len;
    default:
        return w->len;
    }
}

const char *bench_fn_name(bench_fn fn)
{
    switch (fn) {
    case BENCH_SHA224: return "sha224";
    case BENCH_SHA256: return "sha256";
    case BENCH_SHA384: return "sha384";
    case BENCH_SHA512: return "sha512";
    case BENCH_SHA512_224: return "sha512_224";
    case BENCH_SHA512_256: return "sha512_256";
    case BENCH_HMAC_SHA256: return "hmac_sha256";
    case BENCH_HMAC_SHA512: return "hmac_sha512";
    case BENCH_SHA256_X8: return "sha256_x8";
    case BENCH_SHA512_X4: return "sha512_x4";
    case BENCH_SHA256_X8_REF: return "sha256_x8_ref";
    case BENCH_SHA512_X4_REF: return "sha512_x4_ref";
    default: return "?";
    }
}

static size_t build_workloads(bench_workload *list)
{
    static const size_t lengths[] = {
        0, 1, 16, 32, 55, 56, 64, 100, 128, 200, 256,
        1024, 2048, 4096, 8192, 16384, 1048576
    };
    static const size_t hmac_lengths[] = { 32, 1024 };
    static const bench_fn hashes[] = {
        BENCH_SHA224, BENCH_SHA256, BENCH_SHA384, BENCH_SHA512,
        BENCH_SHA512_224, BENCH_SHA512_256
    };
    static const bench_fn hmacs[] = { BENCH_HMAC_SHA256, BENCH_HMAC_SHA512 };
    static const bench_fn multi[] = {
        BENCH_SHA256_X8, BENCH_SHA512_X4,
        BENCH_SHA256_X8_REF, BENCH_SHA512_X4_REF
    };
    size_t n = 0;
    size_t i, j;
    int mode;

    for (i = 0; i < sizeof(hashes) / sizeof(hashes[0]); i++) {
        for (j = 0; j < sizeof(lengths) / sizeof(lengths[0]); j++) {
            for (mode = 0; mode <= 1; mode++) {
                list[n].fn = hashes[i];
                list[n].len = lengths[j];
                list[n].incremental = mode;
                n++;
            }
        }
    }
    for (i = 0; i < sizeof(hmacs) / sizeof(hmacs[0]); i++) {
        for (j = 0; j < sizeof(hmac_lengths) / sizeof(hmac_lengths[0]); j++) {
            for (mode = 0; mode <= 1; mode++) {
                list[n].fn = hmacs[i];
                list[n].len = hmac_lengths[j];
                list[n].incremental = mode;
                n++;
            }
        }
    }
    for (i = 0; i < sizeof(multi) / sizeof(multi[0]); i++) {
        for (j = 0; j < sizeof(lengths) / sizeof(lengths[0]); j++) {
            list[n].fn = multi[i];
            list[n].len = lengths[j];
            list[n].incremental = 0;
            n++;
        }
    }
    return n;
}

static int verify_workload(const bench_variant *v, const bench_workload *w)
{
    size_t want_len = 0;
    const unsigned char *want = bench_kat(w->fn, w->len, &want_len);

    if (want == NULL) {
        fprintf(stderr, "bench: no known answer for %s len %zu\n",
                bench_fn_name(w->fn), w->len);
        return -1;
    }
    if (v->run(v, w, out) != 0) {
        fprintf(stderr, "bench: %s/%s: %s len %zu mode %s failed\n",
                v->library, v->variant, bench_fn_name(w->fn), w->len,
                w->incremental ? "incremental" : "one-shot");
        return -1;
    }
    if (memcmp(out, want, want_len) != 0) {
        fprintf(stderr, "bench: %s/%s: %s len %zu mode %s: wrong output\n",
                v->library, v->variant, bench_fn_name(w->fn), w->len,
                w->incremental ? "incremental" : "one-shot");
        return -1;
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* Clock and cycles                                                   */
/* ------------------------------------------------------------------ */

static double now_ns(void)
{
    struct timespec ts;

    if (clock_gettime(CLOCK_MONOTONIC_RAW, &ts) != 0) {
        fprintf(stderr, "bench: clock_gettime: %s\n", strerror(errno));
        exit(2);
    }
    return (double)ts.tv_sec * 1e9 + (double)ts.tv_nsec;
}

static uint64_t cycles_now(void)
{
#if defined(__x86_64__)
    unsigned int aux;

    return __rdtscp(&aux);
#else
    return 0;
#endif
}

static void cycles_init(double ghz)
{
#if defined(__x86_64__)
    double t0, t1;
    uint64_t c0, c1;

    (void)ghz;
    cycles_enabled = 1;
    cycles_measured = 1;
    snprintf(cycles_source_buf, sizeof(cycles_source_buf), "rdtscp-tsc");
    t0 = now_ns();
    c0 = cycles_now();
    do {
        t1 = now_ns();
    } while (t1 - t0 < 20e6);
    c1 = cycles_now();
    cycles_per_ns = (double)(c1 - c0) / (t1 - t0);
    fprintf(stderr, "bench: tsc %.3f GHz (invariant ticks, not core cycles under boost)\n",
            cycles_per_ns);
#else
    if (ghz > 0.0) {
        cycles_per_ns = ghz;
        cycles_enabled = 1;
        cycles_measured = 0;
        snprintf(cycles_source_buf, sizeof(cycles_source_buf), "derived-%.2fGHz", ghz);
    } else {
        cycles_enabled = 0;
        cycles_measured = 0;
        snprintf(cycles_source_buf, sizeof(cycles_source_buf), "none");
    }
#endif
}

/* ------------------------------------------------------------------ */
/* Statistics                                                         */
/* ------------------------------------------------------------------ */

typedef struct stats {
    double median;
    double q1;
    double q3;
    double iqr;
    double iqr_pct;
    double min;
    double max;
} stats;

static int cmp_double(const void *a, const void *b)
{
    double x = *(const double *)a;
    double y = *(const double *)b;

    return (x > y) - (x < y);
}

static double percentile(const double *a, size_t n, double p)
{
    double h = (double)(n - 1) * p;
    size_t lo = (size_t)h;
    double f = h - (double)lo;

    if (lo + 1 >= n) {
        return a[n - 1];
    }
    return a[lo] * (1.0 - f) + a[lo + 1] * f;
}

static void summarize(double *a, size_t n, stats *s)
{
    qsort(a, n, sizeof(a[0]), cmp_double);
    s->min = a[0];
    s->max = a[n - 1];
    s->median = percentile(a, n, 0.5);
    s->q1 = percentile(a, n, 0.25);
    s->q3 = percentile(a, n, 0.75);
    s->iqr = s->q3 - s->q1;
    s->iqr_pct = s->median > 0.0 ? 100.0 * s->iqr / s->median : 0.0;
}

/* ------------------------------------------------------------------ */
/* Timing                                                             */
/* ------------------------------------------------------------------ */

static int time_batch(const bench_variant *v, const bench_workload *w,
                      size_t iters, double *ns_per_call, double *cyc_per_call)
{
    double t0, t1;
    uint64_t c0 = 0, c1 = 0;
    size_t i;

    t0 = now_ns();
    if (cycles_measured) {
        c0 = cycles_now();
    }
    for (i = 0; i < iters; i++) {
        if (v->run(v, w, out) != 0) {
            return -1;
        }
    }
    if (cycles_measured) {
        c1 = cycles_now();
    }
    t1 = now_ns();
    *ns_per_call = (t1 - t0) / (double)iters;
    if (cycles_measured) {
        *cyc_per_call = (double)(c1 - c0) / (double)iters;
    } else if (cycles_enabled) {
        *cyc_per_call = *ns_per_call * cycles_per_ns;
    } else {
        *cyc_per_call = 0.0;
    }
    return 0;
}

static size_t calibrate(const bench_variant *v, const bench_workload *w,
                        double target_ns, int *rc)
{
    double ns, cyc;
    size_t iters = 1;

    /*
     * One cold call costs far more than a warm one (cache misses, the
     * clock's own overhead), so the batch is doubled until it lasts an
     * eighth of the target, and the cost per call is taken from there.
     */
    for (;;) {
        *rc = time_batch(v, w, iters, &ns, &cyc);
        if (*rc != 0) {
            return 0;
        }
        if (ns * (double)iters >= target_ns / 8.0 || iters >= 1000000) {
            break;
        }
        iters *= 2;
    }
    if (ns <= 0.0) {
        return 1000000;
    }
    iters = (size_t)(target_ns / ns);
    if (iters < 1) {
        iters = 1;
    }
    if (iters > 1000000) {
        iters = 1000000;
    }
    return iters;
}

static int time_workload(const bench_variant *v, const bench_workload *w,
                         size_t reps, size_t warmup, double target_ns,
                         stats *ns_stats, stats *cyc_stats, size_t *iters_out,
                         int *has_cycles)
{
    double ns_samples[BENCH_MAX_REPS];
    double cyc_samples[BENCH_MAX_REPS];
    double ns, cyc;
    size_t iters;
    size_t i;
    int rc;

    iters = calibrate(v, w, target_ns, &rc);
    if (rc != 0) {
        return -1;
    }
    for (i = 0; i < warmup; i++) {
        if (time_batch(v, w, iters, &ns, &cyc) != 0) {
            return -1;
        }
    }
    for (i = 0; i < reps; i++) {
        if (time_batch(v, w, iters, &ns, &cyc) != 0) {
            return -1;
        }
        ns_samples[i] = ns;
        cyc_samples[i] = cyc;
    }
    summarize(ns_samples, reps, ns_stats);
    *iters_out = iters;
    *has_cycles = cycles_enabled;
    if (cycles_enabled) {
        summarize(cyc_samples, reps, cyc_stats);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* Stack                                                              */
/* ------------------------------------------------------------------ */

#if defined(__x86_64__)
__attribute__((naked)) static uintptr_t paint_stack(void)
{
    __asm__ volatile(
        "subq $262144, %rsp\n\t"
        "movq %rsp, %rax\n\t"
        "movq %rsp, %rdi\n\t"
        "movl $32768, %ecx\n\t"
        "movabsq $0xA5A5A5A5A5A5A5A5, %rdx\n\t"
        "1:\n\t"
        "movq %rdx, (%rdi)\n\t"
        "addq $8, %rdi\n\t"
        "decl %ecx\n\t"
        "jnz 1b\n\t"
        "addq $262144, %rsp\n\t"
        "ret\n\t");
}
#elif defined(__aarch64__)
__attribute__((naked)) static uintptr_t paint_stack(void)
{
    __asm__ volatile(
        "sub sp, sp, #0x40000\n\t"
        "mov x0, sp\n\t"
        "mov x1, sp\n\t"
        "mov w2, #32768\n\t"
        "movz x3, #0xa5a5\n\t"
        "movk x3, #0xa5a5, lsl #16\n\t"
        "movk x3, #0xa5a5, lsl #32\n\t"
        "movk x3, #0xa5a5, lsl #48\n\t"
        "1:\n\t"
        "str x3, [x1], #8\n\t"
        "subs w2, w2, #1\n\t"
        "b.ne 1b\n\t"
        "add sp, sp, #0x40000\n\t"
        "ret\n\t");
}
#endif

static uintptr_t stack_pointer(void)
{
    uintptr_t sp;

#if defined(__x86_64__)
    __asm__ volatile("movq %%rsp, %0" : "=r"(sp));
#elif defined(__aarch64__)
    __asm__ volatile("mov %0, sp" : "=r"(sp));
#endif
    return sp;
}

static size_t stack_depth(uintptr_t low, uintptr_t sp)
{
    const unsigned char *p = (const unsigned char *)low;
    size_t n;
    size_t i;

    if (sp <= low) {
        return 0;
    }
    n = (size_t)(sp - low);
    for (i = 0; i < n; i++) {
        if (p[i] != 0xA5u) {
            return n - i;
        }
    }
    return 0;
}

static int measure_stack(const bench_variant *v, const bench_workload *w,
                         size_t *depth)
{
    uintptr_t low, sp;
    int rc;

    low = paint_stack();
    __asm__ volatile("" ::: "memory");
    sp = stack_pointer();
    rc = v->run(v, w, out);
    __asm__ volatile("" ::: "memory");
    if (rc != 0) {
        return -1;
    }
    *depth = stack_depth(low, sp);
    return 0;
}

/* ------------------------------------------------------------------ */
/* Host identification                                                */
/* ------------------------------------------------------------------ */

static void identify_host(void)
{
#if defined(__APPLE__)
    size_t n;
    char version[64];

    n = sizeof(cpu_model);
    if (sysctlbyname("machdep.cpu.brand_string", cpu_model, &n, NULL, 0) != 0) {
        snprintf(cpu_model, sizeof(cpu_model), "unknown");
    }
    n = sizeof(version);
    if (sysctlbyname("kern.osproductversion", version, &n, NULL, 0) == 0) {
        snprintf(os_name, sizeof(os_name), "macOS %s", version);
    } else {
        snprintf(os_name, sizeof(os_name), "macOS");
    }
#elif defined(__linux__)
    struct utsname u;
    FILE *f;
    char line[256];

    f = fopen("/proc/cpuinfo", "r");
    if (f != NULL) {
        while (fgets(line, sizeof(line), f) != NULL) {
            if (strncmp(line, "model name", 10) == 0) {
                char *colon = strchr(line, ':');
                if (colon != NULL) {
                    char *p = colon + 1;
                    size_t len;
                    while (*p == ' ' || *p == '\t') {
                        p++;
                    }
                    len = strlen(p);
                    while (len > 0 && (p[len - 1] == '\n' || p[len - 1] == ' ')) {
                        len--;
                    }
                    if (len >= sizeof(cpu_model)) {
                        len = sizeof(cpu_model) - 1;
                    }
                    memcpy(cpu_model, p, len);
                    cpu_model[len] = '\0';
                }
                break;
            }
        }
        fclose(f);
    }
    if (uname(&u) == 0) {
        snprintf(os_name, sizeof(os_name), "%s %s", u.sysname, u.release);
    }
#endif
}

/* ------------------------------------------------------------------ */
/* Driver                                                             */
/* ------------------------------------------------------------------ */

static void usage(FILE *f)
{
    fprintf(f,
            "usage: bench [options]\n"
            "  --smoke            short run: 5 samples of 0.5 ms (labelled smoke)\n"
            "  --full             full run: 25 samples of 5 ms (default)\n"
            "  --reps N           samples kept per workload\n"
            "  --warmup N         samples discarded before the kept ones\n"
            "  --target-ms X      length of one sample, in milliseconds\n"
            "  --ghz X            derive cycles from nanoseconds at X GHz\n"
            "                     (AArch64 only, where no counter is readable)\n"
            "  --csv FILE         CSV output (default stdout)\n"
            "  --variant NAME     only this variant\n"
            "  --selftest         verify every output, time nothing\n"
            "  --stack            write stack use instead of timing\n"
            "  --list             list the variants and exit\n");
}

static const bench_variant *find_variant(const char *name)
{
    size_t i;

    for (i = 0; i < bench_variant_count; i++) {
        if (strcmp(bench_variants[i].variant, name) == 0) {
            return &bench_variants[i];
        }
    }
    return NULL;
}

int main(int argc, char **argv)
{
    bench_workload workloads[BENCH_MAX_WORKLOADS];
    size_t workload_count;
    size_t reps = 0, warmup = 0;
    double target_ms = 0.0;
    double ghz = 0.0;
    int smoke = 0;
    int selftest = 0;
    int stack = 0;
    int list = 0;
    const char *csv_path = NULL;
    const char *only_variant = NULL;
    const char *run_label;
    FILE *csv = stdout;
    size_t i, w;
    unsigned verified = 0;
    unsigned failed = 0;
    int a;

    for (a = 1; a < argc; a++) {
        if (strcmp(argv[a], "--smoke") == 0) {
            smoke = 1;
        } else if (strcmp(argv[a], "--full") == 0) {
            smoke = 0;
        } else if (strcmp(argv[a], "--reps") == 0 && a + 1 < argc) {
            reps = (size_t)strtoul(argv[++a], NULL, 10);
        } else if (strcmp(argv[a], "--warmup") == 0 && a + 1 < argc) {
            warmup = (size_t)strtoul(argv[++a], NULL, 10);
        } else if (strcmp(argv[a], "--target-ms") == 0 && a + 1 < argc) {
            target_ms = strtod(argv[++a], NULL);
        } else if (strcmp(argv[a], "--ghz") == 0 && a + 1 < argc) {
            ghz = strtod(argv[++a], NULL);
        } else if (strcmp(argv[a], "--csv") == 0 && a + 1 < argc) {
            csv_path = argv[++a];
        } else if (strcmp(argv[a], "--variant") == 0 && a + 1 < argc) {
            only_variant = argv[++a];
        } else if (strcmp(argv[a], "--selftest") == 0) {
            selftest = 1;
        } else if (strcmp(argv[a], "--stack") == 0) {
            stack = 1;
        } else if (strcmp(argv[a], "--list") == 0) {
            list = 1;
        } else if (strcmp(argv[a], "--help") == 0 || strcmp(argv[a], "-h") == 0) {
            usage(stdout);
            return 0;
        } else {
            usage(stderr);
            return 2;
        }
    }
    if (selftest) {
        reps = 1;
        warmup = 0;
    }
    if (reps == 0) {
        reps = smoke ? 5 : 25;
    }
    if (warmup == 0) {
        warmup = smoke ? 2 : 3;
    }
    if (target_ms == 0.0) {
        target_ms = smoke ? 0.5 : 5.0;
    }
    if (reps > BENCH_MAX_REPS) {
        fprintf(stderr, "bench: --reps at most %d\n", BENCH_MAX_REPS);
        return 2;
    }
    run_label = selftest ? "selftest" : stack ? "stack" : smoke ? "smoke" : "full";

    identify_host();
    cycles_init(ghz);
    bench_backend_init();
    bench_fill_msg(msg, sizeof(msg));
    bench_fill_key(key);
    workload_count = build_workloads(workloads);

    if (only_variant != NULL && find_variant(only_variant) == NULL) {
        fprintf(stderr, "bench: no variant %s\n", only_variant);
        return 2;
    }

    if (list) {
        for (i = 0; i < bench_variant_count; i++) {
            printf("%s %s %s %s\n", bench_variants[i].library,
                   bench_variants[i].version, bench_variants[i].revision,
                   bench_variants[i].variant);
        }
        return 0;
    }

    if (csv_path != NULL) {
        csv = fopen(csv_path, "w");
        if (csv == NULL) {
            fprintf(stderr, "bench: %s: %s\n", csv_path, strerror(errno));
            return 2;
        }
    }

    if (selftest) {
        fprintf(csv, "library,version,variant,workloads,verified,failed\n");
    } else if (stack) {
        fprintf(csv, "run,library,version,revision,variant,function,mode,len,"
                     "stack_bytes,note,cpu,arch,os\n");
    } else {
        fprintf(csv, "run,library,version,revision,variant,function,mode,len,work_bytes,"
                     "reps,iters,median_ns,iqr_ns,min_ns,max_ns,iqr_pct,median_cycles,"
                     "cycles_per_byte,cycles_source,cpu,arch,os,verified\n");
    }

    for (i = 0; i < bench_variant_count; i++) {
        const bench_variant *v = &bench_variants[i];
        size_t supported = 0;

        if (only_variant != NULL && strcmp(v->variant, only_variant) != 0) {
            continue;
        }
        for (w = 0; w < workload_count; w++) {
            if (v->supports(v, &workloads[w])) {
                supported++;
            }
        }
        if (supported == 0) {
            continue;
        }
        fprintf(stderr, "bench: %s %s %s: %zu workloads, %s\n",
                v->library, v->version, v->variant, supported,
                selftest ? "selftest" : stack ? "stack" : "timing");

        {
            unsigned v_ok = 0;
            unsigned v_fail = 0;

            for (w = 0; w < workload_count; w++) {
                const bench_workload *work = &workloads[w];

                if (!v->supports(v, work)) {
                    continue;
                }
                if (verify_workload(v, work) != 0) {
                    v_fail++;
                    failed++;
                    continue;
                }
                v_ok++;
                verified++;
                if (selftest) {
                    continue;
                }
                if (stack) {
                    size_t depth = 0;

                    if (measure_stack(v, work, &depth) != 0) {
                        v_fail++;
                        failed++;
                        continue;
                    }
                    fprintf(csv, "%s,%s,%s,%s,%s,%s,%s,%zu,%zu,below-call-site,"
                                 "%s,%s,%s\n",
                            run_label, v->library, v->version, v->revision,
                            v->variant, bench_fn_name(work->fn),
                            work->incremental ? "incremental" : "oneshot",
                            work->len, depth, cpu_model, arch_name, os_name);
                } else {
                    stats ns_stats, cyc_stats;
                    size_t iters = 0;
                    int has_cycles = 0;

                    if (time_workload(v, work, reps, warmup, target_ms * 1e6,
                                      &ns_stats, &cyc_stats, &iters,
                                      &has_cycles) != 0) {
                        v_fail++;
                        failed++;
                        continue;
                    }
                    fprintf(csv, "%s,%s,%s,%s,%s,%s,%s,%zu,%zu,%zu,%zu,"
                                 "%.2f,%.2f,%.2f,%.2f,%.2f",
                            run_label, v->library, v->version, v->revision,
                            v->variant, bench_fn_name(work->fn),
                            work->incremental ? "incremental" : "oneshot",
                            work->len, bench_work_bytes(work), reps, iters,
                            ns_stats.median, ns_stats.iqr, ns_stats.min,
                            ns_stats.max, ns_stats.iqr_pct);
                    if (has_cycles) {
                        size_t work_bytes = bench_work_bytes(work);
                        double cpb = work_bytes > 0
                                         ? cyc_stats.median / (double)work_bytes
                                         : 0.0;

                        fprintf(csv, ",%.1f,", cyc_stats.median);
                        if (work_bytes > 0) {
                            fprintf(csv, "%.3f", cpb);
                        }
                        fprintf(csv, ",%s", cycles_source);
                    } else {
                        fprintf(csv, ",,none");
                    }
                    fprintf(csv, ",%s,%s,%s,PASS\n", cpu_model, arch_name, os_name);
                }
                fflush(csv);
            }
            if (selftest) {
                fprintf(csv, "%s,%s,%s,%u,%u,%u\n", v->library, v->version,
                        v->variant, v_ok + v_fail, v_ok, v_fail);
            }
        }
    }

    if (csv != stdout) {
        fclose(csv);
    }
    fprintf(stderr, "bench: %u outputs verified, %u failed\n", verified, failed);
    return failed == 0 ? 0 : 1;
}
