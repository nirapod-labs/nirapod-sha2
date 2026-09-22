/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * wycheproof.c
 * ============
 *
 * The Wycheproof HMAC-SHA-256 and HMAC-SHA-512 test files, every case,
 * valid and invalid. A tag may be truncated to tagSize bits; a case
 * passes when the first tagSize / 8 bytes of the computed tag match the
 * recorded tag for a valid case, and differ for an invalid one.
 *
 * Both the one-shot and the incremental forms run the case. The files are
 * parsed with json.c, which is independent of the library.
 */

#include "validation.h"
#include "json.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int prefix_match(const uint8_t *got, size_t got_len, const uint8_t *want, size_t want_len)
{
    return want_len <= got_len && memcmp(got, want, want_len) == 0;
}

static void run_file(validation_suite *s, int kernel, const hmac_alg *alg, const char *path)
{
    size_t text_len;
    char *text = read_file(path, &text_len);
    char err[256];
    json_value *doc = json_parse(text, text_len, err, sizeof err);
    const json_value *groups;
    const json_value *number;
    long long expected_total, seen = 0;
    const char *file;
    size_t g, t;

    if (doc == NULL) {
        die("%s: %s", path, err);
    }
    groups = json_get(doc, "testGroups");
    number = json_get(doc, "numberOfTests");
    if (groups == NULL || groups->type != JSON_ARRAY || number == NULL ||
        number->type != JSON_NUMBER) {
        die("%s: no testGroups or numberOfTests", path);
    }
    expected_total = number->number;
    {
        const char *slash = strrchr(path, '/');

        file = slash != NULL ? slash + 1 : path;
    }

    for (g = 0; g < groups->count; g++) {
        const json_value *group = groups->items[g];
        const json_value *key_size = json_get(group, "keySize");
        const json_value *tag_size = json_get(group, "tagSize");
        const json_value *tests = json_get(group, "tests");
        long long key_bits, tag_bits;

        if (key_size == NULL || tag_size == NULL || tests == NULL ||
            key_size->type != JSON_NUMBER || tag_size->type != JSON_NUMBER ||
            tests->type != JSON_ARRAY) {
            die("%s: malformed group %zu", path, g);
        }
        key_bits = key_size->number;
        tag_bits = tag_size->number;
        if (tag_bits <= 0 || (tag_bits % 8) != 0 ||
            (size_t)(tag_bits / 8) > alg->digest_len) {
            die("%s: group %zu has tagSize %lld", path, g, tag_bits);
        }

        for (t = 0; t < tests->count; t++) {
            const json_value *test = tests->items[t];
            const json_value *key = json_get(test, "key");
            const json_value *msg = json_get(test, "msg");
            const json_value *tag = json_get(test, "tag");
            const json_value *result = json_get(test, "result");
            const json_value *tc_id = json_get(test, "tcId");
            uint8_t *key_bytes, *msg_bytes, *tag_bytes;
            size_t key_len, msg_len, tag_len;
            uint8_t got[64];
            size_t tag_bytes_len = (size_t)(tag_bits / 8);
            int want_valid, ok_oneshot, ok_incremental, rc;
            validation_ctx c;
            char what[4224];

            if (key == NULL || msg == NULL || tag == NULL || result == NULL ||
                key->type != JSON_STRING || msg->type != JSON_STRING ||
                tag->type != JSON_STRING || result->type != JSON_STRING) {
                die("%s: malformed test %zu in group %zu", path, t, g);
            }
            key_bytes = unhex(key->string, &key_len);
            msg_bytes = unhex(msg->string, &msg_len);
            tag_bytes = unhex(tag->string, &tag_len);
            if ((long long)key_len * 8 != key_bits) {
                die("%s: tcId %lld key is %zu bytes, keySize is %lld", path,
                    tc_id && tc_id->type == JSON_NUMBER ? tc_id->number : -1, key_len, key_bits);
            }
            if (tag_len != tag_bytes_len) {
                die("%s: tag is %zu bytes, tagSize is %lld", path, tag_len, tag_bits);
            }
            want_valid = strcmp(result->string, "valid") == 0;
            if (!want_valid && strcmp(result->string, "invalid") != 0) {
                die("%s: unknown result '%s'", path, result->string);
            }

            rc = hmac_oneshot(alg, kernel, got, key_bytes, key_len, msg_bytes, msg_len);
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: %s tcId %lld one-shot returned %d", alg->name, file,
                          tc_id && tc_id->type == JSON_NUMBER ? tc_id->number : -1, rc);
            } else {
                ok_oneshot = prefix_match(got, alg->digest_len, tag_bytes, tag_bytes_len);
                snprintf(what, sizeof what, "%s: %s tcId %lld (%s) one-shot", alg->name, file,
                         tc_id && tc_id->type == JSON_NUMBER ? tc_id->number : -1,
                         result->string);
                if (ok_oneshot == want_valid) {
                    count_pass(s, kernel);
                } else {
                    fail_case(s, kernel, "%s: tag prefix %s the recorded tag", what,
                              ok_oneshot ? "matches" : "differs from");
                }
            }

            rc = hmac_init(alg, kernel, &c, key_bytes, key_len);
            if (rc == NIRAPOD_SHA2_OK) {
                size_t half = msg_len / 2;

                rc = hmac_update(alg, kernel, &c, msg_bytes, half);
                if (rc == NIRAPOD_SHA2_OK) {
                    rc = hmac_update(alg, kernel, &c, msg_bytes + half, msg_len - half);
                }
                if (rc == NIRAPOD_SHA2_OK) {
                    rc = hmac_final(alg, kernel, &c, got);
                }
            }
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: %s tcId %lld incremental returned %d", alg->name, file,
                          tc_id && tc_id->type == JSON_NUMBER ? tc_id->number : -1, rc);
            } else {
                ok_incremental =
                    prefix_match(got, alg->digest_len, tag_bytes, tag_bytes_len);
                snprintf(what, sizeof what, "%s: %s tcId %lld (%s) incremental", alg->name,
                         file, tc_id && tc_id->type == JSON_NUMBER ? tc_id->number : -1,
                         result->string);
                if (ok_incremental == want_valid) {
                    count_pass(s, kernel);
                } else {
                    fail_case(s, kernel, "%s: tag prefix %s the recorded tag", what,
                              ok_incremental ? "matches" : "differs from");
                }
            }

            free(key_bytes);
            free(msg_bytes);
            free(tag_bytes);
            seen++;
        }
    }

    if (seen != expected_total) {
        die("%s: %lld cases, numberOfTests is %lld", path, seen, expected_total);
    }
    json_free(doc);
    free(text);
}

int suite_wycheproof(void)
{
    validation_suite s;
    char dir[2048];
    int k;
    size_t i;

    snprintf(dir, sizeof dir, "%s/wycheproof", validation.vectors);
    suite_begin(&s, "wycheproof");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
            const hmac_alg *a = &HMAC_ALGS[i];
            char path[4096];

            if (!validation_usable(&s, target, a->family)) {
                continue;
            }
            if (strcmp(a->name, "HMAC-SHA-256") == 0) {
                snprintf(path, sizeof path, "%s/hmac_sha256_test.json", dir);
            } else {
                snprintf(path, sizeof path, "%s/hmac_sha512_test.json", dir);
            }
            run_file(&s, target, a, path);
        }
    }
    return suite_end(&s);
}
