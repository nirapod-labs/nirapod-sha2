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
 * Operation 3 hashes a long generated message without sending it: alg is
 * a hash as for operation 1, bytes 4 to 11 hold the message length as a
 * little-endian 64-bit integer, and nothing follows the header. The
 * message is the block of oracle_stream_block repeated, its last copy cut
 * at the length. Both sides generate the block, so a message of any
 * length costs the pipe nothing and the oracle memory for one block.
 *
 * A response is 2 bytes followed by len bytes of digest:
 *
 *     offset 0  status    0 ok, 1 this oracle does not implement alg,
 *                         2 error
 *     offset 1  len       digest length in bytes
 *
 * The banner's mask has bit alg set for each hash the oracle implements,
 * bit 8 + alg for each HMAC, and bit 16 + alg for each hash it answers in
 * operation 3.
 */

#ifndef NIRAPOD_SHA2_ORACLE_PROTOCOL_H
#define NIRAPOD_SHA2_ORACLE_PROTOCOL_H

#include <stdint.h>

#define ORACLE_BANNER "NIRAPOD-SHA2-ORACLE"
#define ORACLE_MAX_DIGEST 64
#define ORACLE_HEADER_BYTES 12

#define ORACLE_OP_HASH 1
#define ORACLE_OP_HMAC 2
#define ORACLE_OP_STREAM 3

#define ORACLE_STATUS_OK 0
#define ORACLE_STATUS_UNSUPPORTED 1
#define ORACLE_STATUS_ERROR 2

#define ORACLE_SUPPORTS(mask, id) (((mask) >> (id)) & 1u)
#define ORACLE_SUPPORTS_HMAC(mask, id) (((mask) >> (8 + (id))) & 1u)
#define ORACLE_SUPPORTS_STREAM(mask, id) (((mask) >> (16 + (id))) & 1u)

/*
 * The period of the operation 3 message: a prime, so that the block
 * boundaries of the message fall at every offset of a 64-byte and a
 * 128-byte block in turn.
 */
#define ORACLE_STREAM_PERIOD 65521u

/* The repeated block: the bytes of a splitmix64 stream from a fixed seed,
 * least significant byte of each output first. */
static inline void oracle_stream_block(uint8_t *p)
{
    uint64_t x = UINT64_C(0x2545f4914f6cdd1d);
    uint64_t z = 0;
    unsigned i;

    for (i = 0; i < ORACLE_STREAM_PERIOD; i++) {
        if (i % 8 == 0) {
            x += UINT64_C(0x9e3779b97f4a7c15);
            z = x;
            z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
            z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb);
            z ^= z >> 31;
        }
        p[i] = (uint8_t)(z >> (8 * (i % 8)));
    }
}

#endif /* NIRAPOD_SHA2_ORACLE_PROTOCOL_H */
