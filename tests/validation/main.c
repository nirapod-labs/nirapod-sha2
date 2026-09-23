/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * main.c
 * ======
 *
 * The runner. It parses the options, prints what it is about to test and
 * with which oracles, runs the selected suites, and exits nonzero when any
 * check failed.
 *
 *     --vectors DIR       tests/vectors (default: tests/vectors)
 *     --oracle PATH       an oracle program (at most four, repeatable)
 *     --iterations N      random cases per suite (default 200)
 *     --large N           size of the large-message case (default 1 MiB + 3)
 *     --suite NAME        run only this suite (repeatable)
 *     --list              list the suite names and exit
 *     --require-oracle    fail when no oracle is named
 *     --write-xarch FILE  write the xarch values of this build to FILE
 *                         instead of checking them (suite xarch)
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

validation_env validation;

typedef int (*suite_fn)(void);

static const struct suite_entry {
    const char *name;
    suite_fn fn;
} suites[] = {
    { "cavp", suite_cavp },
    { "wycheproof", suite_wycheproof },
    { "bounds", suite_bounds },
    { "splits", suite_splits },
    { "cross", suite_cross },
    { "negative", suite_negative },
    { "multiway", suite_multiway },
    { "differential", suite_oracle },
    { "xarch", suite_xarch },
};

#define SUITE_COUNT (sizeof suites / sizeof suites[0])

static void usage(FILE *f)
{
    fprintf(f,
            "usage: validation [--vectors DIR] [--oracle PATH]... [--iterations N]\n"
            "                  [--large N] [--suite NAME]... [--list] [--require-oracle]\n"
            "                  [--write-xarch FILE]\n");
}

static unsigned long parse_ulong(const char *what, const char *s)
{
    char *end;
    unsigned long v;

    if (*s == '\0' || *s == '-') {
        die("bad %s: %s", what, s);
    }
    v = strtoul(s, &end, 10);
    if (*end != '\0') {
        die("bad %s: %s", what, s);
    }
    return v;
}

static void print_header(void)
{
    int k;

    printf("nirapod-sha2 validation\n");
#if defined(__aarch64__)
    printf("architecture: aarch64\n");
#elif defined(__x86_64__)
    printf("architecture: x86_64\n");
#else
    printf("architecture: unknown\n");
#endif
    printf("cpu features: 0x%x\n", nirapod_sha2_testing_cpu_features());
    printf("kernels built:");
    for (k = 0; k < VALIDATION_KERNELS; k++) {
        if (kernel_built(k)) {
            printf(" %s", kernel_label(k));
        }
    }
    printf("\n");
    for (k = 0; k < VALIDATION_KERNELS; k++) {
        int f;
        int any = 0;

        if (!kernel_built(k)) {
            continue;
        }
        printf("kernel %s:", kernel_label(k));
        for (f = 0; f < 4; f++) {
            static const char *const family[4] = { "sha256", "sha512", "x8", "x4" };

            if (nirapod_sha2_testing_available((nirapod_sha2_testing_kernel)k,
                                               (nirapod_sha2_testing_family)f)) {
                printf(" %s", family[f]);
                any = 1;
            }
        }
        if (!any) {
            printf(" (no family this CPU can run)");
        }
        printf("\n");
    }
    printf("vectors: %s\n", validation.vectors);
    printf("iterations: %zu, large: %zu\n", validation.iterations, validation.large_bytes);
    printf("oracles named: %d\n", validation.oracle_count);
    fflush(stdout);
}

int main(int argc, char **argv)
{
    int selected[SUITE_COUNT];
    int failures = 0;
    int i, n_selected = 0;

    validation.vectors = "tests/vectors";
    validation.iterations = 200;
    validation.large_bytes = (1u << 20) + 3;
    validation.require_oracle = 0;
    validation.write_xarch = NULL;
    validation.oracle_count = 0;
    memset(selected, 0, sizeof selected);

    for (i = 1; i < argc; i++) {
        const char *arg = argv[i];

        if (strcmp(arg, "--vectors") == 0 && i + 1 < argc) {
            validation.vectors = argv[++i];
        } else if (strcmp(arg, "--oracle") == 0 && i + 1 < argc) {
            if (validation.oracle_count >= VALIDATION_MAX_ORACLES) {
                die("at most %d oracles", VALIDATION_MAX_ORACLES);
            }
            validation.oracle[validation.oracle_count++] = argv[++i];
        } else if (strcmp(arg, "--iterations") == 0 && i + 1 < argc) {
            validation.iterations = (size_t)parse_ulong("iterations", argv[++i]);
        } else if (strcmp(arg, "--large") == 0 && i + 1 < argc) {
            validation.large_bytes = (size_t)parse_ulong("large", argv[++i]);
        } else if (strcmp(arg, "--suite") == 0 && i + 1 < argc) {
            size_t s;
            const char *name = argv[++i];
            int found = 0;

            for (s = 0; s < SUITE_COUNT; s++) {
                if (strcmp(suites[s].name, name) == 0) {
                    selected[s] = 1;
                    n_selected++;
                    found = 1;
                }
            }
            if (!found) {
                die("unknown suite %s", name);
            }
        } else if (strcmp(arg, "--list") == 0) {
            size_t s;

            for (s = 0; s < SUITE_COUNT; s++) {
                printf("%s\n", suites[s].name);
            }
            return 0;
        } else if (strcmp(arg, "--write-xarch") == 0 && i + 1 < argc) {
            validation.write_xarch = argv[++i];
        } else if (strcmp(arg, "--require-oracle") == 0) {
            validation.require_oracle = 1;
        } else if (strcmp(arg, "--help") == 0 || strcmp(arg, "-h") == 0) {
            usage(stdout);
            return 0;
        } else {
            usage(stderr);
            die("unknown argument %s", arg);
        }
    }

    if (validation.require_oracle && validation.oracle_count == 0) {
        fprintf(stderr, "validation: --require-oracle but no oracle was named\n");
        return 2;
    }

    print_header();
    for (i = 0; i < (int)SUITE_COUNT; i++) {
        if (n_selected != 0 && !selected[i]) {
            continue;
        }
        if (suites[i].fn() != 0) {
            failures++;
        }
    }
    printf("validation: %s (%d suite%s failed)\n", failures ? "FAIL" : "PASS", failures,
           failures == 1 ? "" : "s");
    return failures ? 1 : 0;
}
