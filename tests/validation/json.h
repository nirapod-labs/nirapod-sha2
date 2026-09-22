/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * json.h
 * =====
 *
 * A small JSON reader for the Wycheproof test files. It builds a tree of
 * the whole document; the files are under 100 KiB, so simplicity matters
 * more than streaming.
 */

#ifndef NIRAPOD_SHA2_VALIDATION_JSON_H
#define NIRAPOD_SHA2_VALIDATION_JSON_H

#include <stddef.h>

typedef enum json_type {
    JSON_NULL,
    JSON_BOOL,
    JSON_NUMBER,
    JSON_STRING,
    JSON_ARRAY,
    JSON_OBJECT
} json_type;

typedef struct json_value {
    json_type type;
    int boolean;
    long long number;
    char *string;
    struct json_value **items;
    size_t count;
    char **keys;
    struct json_value **values;
    size_t members;
} json_value;

/* Parses text[0..len). On failure returns NULL and writes a message to
 * err. The result is freed with json_free. */
json_value *json_parse(const char *text, size_t len, char *err, size_t err_len);

void json_free(json_value *v);

/* The value of key in an object, or NULL. */
const json_value *json_get(const json_value *object, const char *key);

#endif /* NIRAPOD_SHA2_VALIDATION_JSON_H */
