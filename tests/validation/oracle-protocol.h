/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-protocol.h
 * =================
 *
 * The wire format between the validation runner and an oracle program,
 * the small executable that computes the same hash or HMAC through an
 * independent implementation. It is the same on both sides and knows
 * nothing of the library under test.
 *
 * A request is a 12-byte header followed by key_len bytes of key and
 * msg_len bytes of message:
 *
 *     offset 0  op        1 hash, 2 hmac
 *     offset 1  alg       hash: 0 SHA-224, 1 SHA-256, 2 SHA-384,
 *                         3 SHA-512, 4 SHA-512/224, 5 SHA-512/256
 *                         hmac: 0 HMAC-SHA-256, 1 HMAC-SHA-512
 *     offset 2  reserved  0
 *     offset 4  key_len   little-endian 32-bit, 0 for a hash
 *     offset 8  msg_len   little-endian 32-bit
 *
 * A response is 2 bytes followed by len bytes of digest:
 *
 *     offset 0  status    0 ok, 1 this oracle does not implement alg,
 *                         2 error
 *     offset 1  len       digest length in bytes
 */

#ifndef NIRAPOD_SHA2_ORACLE_PROTOCOL_H
#define NIRAPOD_SHA2_ORACLE_PROTOCOL_H

#define ORACLE_BANNER "NIRAPOD-SHA2-ORACLE"
#define ORACLE_MAX_DIGEST 64
#define ORACLE_HEADER_BYTES 12

#define ORACLE_OP_HASH 1
#define ORACLE_OP_HMAC 2

#define ORACLE_STATUS_OK 0
#define ORACLE_STATUS_UNSUPPORTED 1
#define ORACLE_STATUS_ERROR 2

#define ORACLE_SUPPORTS(mask, id) (((mask) >> (id)) & 1u)
#define ORACLE_SUPPORTS_HMAC(mask, id) (((mask) >> (8 + (id))) & 1u)

#endif /* NIRAPOD_SHA2_ORACLE_PROTOCOL_H */
