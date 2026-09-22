/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * json.c
 * =====
 *
 * A recursive-descent JSON reader. It accepts the subset that RFC 8259
 * defines, with numbers kept as signed integers: the Wycheproof schema
 * uses integers only. Errors carry a byte offset.
 */

#include "json.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct parser {
    const char *p;
    const char *end;
    const char *start;
    char *err;
    size_t err_len;
    int depth;
} parser;

static void fail(parser *ps, const char *fmt, ...)
{
    va_list ap;
    int used;

    if (ps->err[0] != '\0') {
        return;
    }
    used = snprintf(ps->err, ps->err_len, "byte %ld: ", (long)(ps->p - ps->start));
    if (used < 0 || (size_t)used >= ps->err_len) {
        return;
    }
    va_start(ap, fmt);
    vsnprintf(ps->err + used, ps->err_len - (size_t)used, fmt, ap);
    va_end(ap);
}

static void skip_space(parser *ps)
{
    while (ps->p < ps->end &&
           (*ps->p == ' ' || *ps->p == '\t' || *ps->p == '\n' || *ps->p == '\r')) {
        ps->p++;
    }
}

static json_value *new_value(parser *ps, json_type type)
{
    json_value *v = calloc(1, sizeof *v);

    if (v == NULL) {
        fail(ps, "out of memory");
        return NULL;
    }
    v->type = type;
    return v;
}

static int hex4(parser *ps, unsigned *out)
{
    unsigned v = 0;
    int i;

    for (i = 0; i < 4; i++) {
        int c;
        unsigned d;

        if (ps->p >= ps->end) {
            fail(ps, "truncated \\u escape");
            return 0;
        }
        c = (unsigned char)*ps->p++;
        if (c >= '0' && c <= '9') {
            d = (unsigned)(c - '0');
        } else if (c >= 'a' && c <= 'f') {
            d = (unsigned)(c - 'a' + 10);
        } else if (c >= 'A' && c <= 'F') {
            d = (unsigned)(c - 'A' + 10);
        } else {
            fail(ps, "bad \\u hex digit");
            return 0;
        }
        v = (v << 4) | d;
    }
    *out = v;
    return 1;
}

static int append_utf8(char **buf, size_t *len, size_t *cap, unsigned cp)
{
    unsigned char out[4];
    size_t n, i;

    if (cp < 0x80) {
        out[0] = (unsigned char)cp;
        n = 1;
    } else if (cp < 0x800) {
        out[0] = (unsigned char)(0xc0 | (cp >> 6));
        out[1] = (unsigned char)(0x80 | (cp & 0x3f));
        n = 2;
    } else {
        out[0] = (unsigned char)(0xe0 | (cp >> 12));
        out[1] = (unsigned char)(0x80 | ((cp >> 6) & 0x3f));
        out[2] = (unsigned char)(0x80 | (cp & 0x3f));
        n = 3;
    }
    if (*len + n + 1 > *cap) {
        size_t new_cap = *cap ? *cap * 2 : 32;
        char *q;

        while (new_cap < *len + n + 1) {
            new_cap *= 2;
        }
        q = realloc(*buf, new_cap);
        if (q == NULL) {
            return 0;
        }
        *buf = q;
        *cap = new_cap;
    }
    for (i = 0; i < n; i++) {
        (*buf)[(*len)++] = (char)out[i];
    }
    return 1;
}

static char *parse_string_raw(parser *ps)
{
    char *buf = NULL;
    size_t len = 0, cap = 0;

    if (ps->p >= ps->end || *ps->p != '"') {
        fail(ps, "expected a string");
        return NULL;
    }
    ps->p++;
    while (ps->p < ps->end) {
        unsigned char c = (unsigned char)*ps->p++;

        if (c == '"') {
            if (buf == NULL) {
                buf = malloc(1);
                if (buf == NULL) {
                    fail(ps, "out of memory");
                    return NULL;
                }
            }
            buf[len] = '\0';
            return buf;
        }
        if (c == '\\') {
            unsigned cp;

            if (ps->p >= ps->end) {
                fail(ps, "truncated escape");
                break;
            }
            c = (unsigned char)*ps->p++;
            switch (c) {
            case '"': cp = '"'; break;
            case '\\': cp = '\\'; break;
            case '/': cp = '/'; break;
            case 'b': cp = '\b'; break;
            case 'f': cp = '\f'; break;
            case 'n': cp = '\n'; break;
            case 'r': cp = '\r'; break;
            case 't': cp = '\t'; break;
            case 'u':
                if (!hex4(ps, &cp)) {
                    free(buf);
                    return NULL;
                }
                break;
            default:
                fail(ps, "bad escape");
                free(buf);
                return NULL;
            }
            if (!append_utf8(&buf, &len, &cap, cp)) {
                fail(ps, "out of memory");
                free(buf);
                return NULL;
            }
        } else if (c < 0x20) {
            fail(ps, "control character in a string");
            free(buf);
            return NULL;
        } else {
            if (len + 2 > cap) {
                size_t new_cap = cap ? cap * 2 : 32;
                char *q = realloc(buf, new_cap);

                if (q == NULL) {
                    fail(ps, "out of memory");
                    free(buf);
                    return NULL;
                }
                buf = q;
                cap = new_cap;
            }
            buf[len++] = (char)c;
        }
    }
    fail(ps, "unterminated string");
    free(buf);
    return NULL;
}

static json_value *parse_value(parser *ps);

static json_value *parse_array(parser *ps)
{
    json_value *v = new_value(ps, JSON_ARRAY);

    if (v == NULL) {
        return NULL;
    }
    ps->p++; /* '[' */
    skip_space(ps);
    if (ps->p < ps->end && *ps->p == ']') {
        ps->p++;
        return v;
    }
    for (;;) {
        json_value *item;
        json_value **items;

        item = parse_value(ps);
        if (item == NULL) {
            json_free(v);
            return NULL;
        }
        items = realloc(v->items, (v->count + 1) * sizeof *items);
        if (items == NULL) {
            fail(ps, "out of memory");
            json_free(item);
            json_free(v);
            return NULL;
        }
        v->items = items;
        v->items[v->count++] = item;
        skip_space(ps);
        if (ps->p >= ps->end) {
            fail(ps, "unterminated array");
            json_free(v);
            return NULL;
        }
        if (*ps->p == ']') {
            ps->p++;
            return v;
        }
        if (*ps->p != ',') {
            fail(ps, "expected ',' or ']'");
            json_free(v);
            return NULL;
        }
        ps->p++;
        skip_space(ps);
    }
}

static json_value *parse_object(parser *ps)
{
    json_value *v = new_value(ps, JSON_OBJECT);

    if (v == NULL) {
        return NULL;
    }
    ps->p++; /* '{' */
    skip_space(ps);
    if (ps->p < ps->end && *ps->p == '}') {
        ps->p++;
        return v;
    }
    for (;;) {
        char *key;
        json_value *item;
        char **keys;
        json_value **values;

        skip_space(ps);
        key = parse_string_raw(ps);
        if (key == NULL) {
            json_free(v);
            return NULL;
        }
        skip_space(ps);
        if (ps->p >= ps->end || *ps->p != ':') {
            fail(ps, "expected ':'");
            free(key);
            json_free(v);
            return NULL;
        }
        ps->p++;
        item = parse_value(ps);
        if (item == NULL) {
            free(key);
            json_free(v);
            return NULL;
        }
        keys = realloc(v->keys, (v->members + 1) * sizeof *keys);
        if (keys == NULL) {
            fail(ps, "out of memory");
            free(key);
            json_free(item);
            json_free(v);
            return NULL;
        }
        v->keys = keys;
        values = realloc(v->values, (v->members + 1) * sizeof *values);
        if (values == NULL) {
            fail(ps, "out of memory");
            free(key);
            json_free(item);
            json_free(v);
            return NULL;
        }
        v->values = values;
        v->keys[v->members] = key;
        v->values[v->members] = item;
        v->members++;
        skip_space(ps);
        if (ps->p >= ps->end) {
            fail(ps, "unterminated object");
            json_free(v);
            return NULL;
        }
        if (*ps->p == '}') {
            ps->p++;
            return v;
        }
        if (*ps->p != ',') {
            fail(ps, "expected ',' or '}'");
            json_free(v);
            return NULL;
        }
        ps->p++;
    }
}

static json_value *parse_number(parser *ps)
{
    const char *begin = ps->p;
    char *end;
    long long value;
    json_value *v;

    if (ps->p < ps->end && *ps->p == '-') {
        ps->p++;
    }
    if (ps->p >= ps->end || *ps->p < '0' || *ps->p > '9') {
        fail(ps, "expected a digit");
        return NULL;
    }
    while (ps->p < ps->end && *ps->p >= '0' && *ps->p <= '9') {
        ps->p++;
    }
    if (ps->p < ps->end && (*ps->p == '.' || *ps->p == 'e' || *ps->p == 'E')) {
        fail(ps, "only integer numbers are supported");
        return NULL;
    }
    value = strtoll(begin, &end, 10);
    if (end != ps->p) {
        fail(ps, "bad number");
        return NULL;
    }
    v = new_value(ps, JSON_NUMBER);
    if (v != NULL) {
        v->number = value;
    }
    return v;
}

static json_value *parse_value(parser *ps)
{
    json_value *v;

    if (ps->depth++ > 64) {
        fail(ps, "nesting too deep");
        ps->depth--;
        return NULL;
    }
    skip_space(ps);
    if (ps->p >= ps->end) {
        fail(ps, "unexpected end of input");
        ps->depth--;
        return NULL;
    }
    if (*ps->p == '{') {
        v = parse_object(ps);
    } else if (*ps->p == '[') {
        v = parse_array(ps);
    } else if (*ps->p == '"') {
        char *s = parse_string_raw(ps);

        v = NULL;
        if (s != NULL) {
            v = new_value(ps, JSON_STRING);
            if (v != NULL) {
                v->string = s;
            } else {
                free(s);
            }
        }
    } else if (strncmp(ps->p, "true", 4) == 0 && ps->p + 4 <= ps->end) {
        ps->p += 4;
        v = new_value(ps, JSON_BOOL);
        if (v != NULL) {
            v->boolean = 1;
        }
    } else if (strncmp(ps->p, "false", 5) == 0 && ps->p + 5 <= ps->end) {
        ps->p += 5;
        v = new_value(ps, JSON_BOOL);
        if (v != NULL) {
            v->boolean = 0;
        }
    } else if (strncmp(ps->p, "null", 4) == 0 && ps->p + 4 <= ps->end) {
        ps->p += 4;
        v = new_value(ps, JSON_NULL);
    } else if (*ps->p == '-' || (*ps->p >= '0' && *ps->p <= '9')) {
        v = parse_number(ps);
    } else {
        fail(ps, "unexpected character '%c'", *ps->p);
        v = NULL;
    }
    ps->depth--;
    return v;
}

json_value *json_parse(const char *text, size_t len, char *err, size_t err_len)
{
    parser ps;
    json_value *v;

    ps.p = text;
    ps.start = text;
    ps.end = text + len;
    ps.err = err;
    ps.err_len = err_len;
    ps.depth = 0;
    if (err_len != 0) {
        err[0] = '\0';
    }
    v = parse_value(&ps);
    if (v == NULL) {
        return NULL;
    }
    skip_space(&ps);
    if (ps.p != ps.end) {
        fail(&ps, "trailing bytes");
        json_free(v);
        return NULL;
    }
    return v;
}

void json_free(json_value *v)
{
    size_t i;

    if (v == NULL) {
        return;
    }
    switch (v->type) {
    case JSON_STRING:
        free(v->string);
        break;
    case JSON_ARRAY:
        for (i = 0; i < v->count; i++) {
            json_free(v->items[i]);
        }
        free(v->items);
        break;
    case JSON_OBJECT:
        for (i = 0; i < v->members; i++) {
            free(v->keys[i]);
            json_free(v->values[i]);
        }
        free(v->keys);
        free(v->values);
        break;
    default:
        break;
    }
    free(v);
}

const json_value *json_get(const json_value *object, const char *key)
{
    size_t i;

    if (object == NULL || object->type != JSON_OBJECT) {
        return NULL;
    }
    for (i = 0; i < object->members; i++) {
        if (strcmp(object->keys[i], key) == 0) {
            return object->values[i];
        }
    }
    return NULL;
}
