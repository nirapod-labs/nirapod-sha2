/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * vectors.h
 * =========
 *
 * Known answers for the smoke tests, from published sources:
 *
 *     FIPS 180-4 examples   NIST's "Examples with intermediate values"
 *                           for FIPS 180-4: the one-block message "abc"
 *                           for every function, the two-block 448-bit
 *                           message for SHA-224 and SHA-256, and the
 *                           two-block 896-bit message for the SHA-512
 *                           family
 *     empty message         the Len = 0 entry of each CAVP
 *                           SHA*ShortMsg.rsp file (byte-oriented SHA test
 *                           vectors, FIPS 180-4)
 *     one million 'a'       FIPS 180-2 appendix B.3 (SHA-256)
 *     HMAC                  RFC 4231 test cases 1, 2, 3, 4, 6 and 7;
 *                           case 5 is a truncated tag and is left out.
 *                           Cases 6 and 7 use a 131-byte key, longer than
 *                           one block of either hash
 *
 * Each value was copied from its source and checked against an
 * independent implementation (Python's hashlib and hmac over OpenSSL) when
 * this file was written; the library is not the oracle for any of them.
 */

#ifndef SMOKE_VECTORS_H
#define SMOKE_VECTORS_H

static const char msg_abc[] = "abc";
static const char msg_448[] = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
static const char msg_896[] =
    "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmn"
    "hijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu";

/* Digest of "", "abc", and the two-block example of the function. */
typedef struct hash_kat {
    const char *name;
    const char *empty;
    const char *abc;
    const char *two_block_msg;
    const char *two_block;
} hash_kat;

static const hash_kat hash_kats[6] = {
    { "SHA-224",
      "d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f",
      "23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7",
      msg_448,
      "75388b16512776cc5dba5da1fd890150b0c6455cb4f58b1952522525" },
    { "SHA-256",
      "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
      msg_448,
      "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1" },
    { "SHA-384",
      "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da"
      "274edebfe76f65fbd51ad2f14898b95b",
      "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed"
      "8086072ba1e7cc2358baeca134c825a7",
      msg_896,
      "09330c33f71147e83d192fc782cd1b4753111b173b3b05d22fa08086e3b0f712"
      "fcc7c71a557e2db966c3e9fa91746039" },
    { "SHA-512",
      "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce"
      "47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e",
      "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a"
      "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f",
      msg_896,
      "8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6889018"
      "501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e96e55b874be909" },
    { "SHA-512/224",
      "6ed0dd02806fa89e25de060c19d3ac86cabb87d6a0ddd05c333b84f4",
      "4634270f707b6a54daae7530460842e20e37ed265ceee9a43e8924aa",
      msg_896,
      "23fec5bb94d60b23308192640b0c453335d664734fe40e7268674af9" },
    { "SHA-512/256",
      "c672b8d1ef56ed28ab87c3622c5114069bdd3ad7b8f9737498d0c01ecef0967a",
      "53048e2681941ef99b2e29b76b4c7dabe4c2d0c634fc6d46e0e2f13107e7af23",
      msg_896,
      "3928e184fb8690f840da3988121d31be65cb9d3ef83ee6146feac861e19b563a" },
};

static const char sha256_million_a[] =
    "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0";

/*
 * RFC 4231 section 4. key and data are hex; a key of the form "aa" x n
 * is spelled out, as the RFC gives it.
 */
typedef struct hmac_kat {
    int rfc_case;
    const char *key;
    const char *data;
    const char *sha256;
    const char *sha512;
} hmac_kat;

#define KEY_AA_131                                                             \
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"  \
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"  \
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"  \
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

static const hmac_kat hmac_kats[6] = {
    { 1,
      "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b",
      "4869205468657265",
      "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
      "87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cde"
      "daa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854" },
    { 2,
      "4a656665",
      "7768617420646f2079612077616e7420666f72206e6f7468696e673f",
      "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
      "164b7a7bfcf819e2e395fbe73b56e0a387bd64222e831fd610270cd7ea250554"
      "9758bf75c05a994a6d034f65f8f0e6fdcaeab1a34d4a6b4b636e070a38bce737" },
    { 3,
      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
      "dddddddddddddddddddddddddddddddddddd",
      "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe",
      "fa73b0089d56a284efb0f0756c890be9b1b5dbdd8ee81a3655f83e33b2279d39"
      "bf3e848279a722c806b485a47e67c807b946a337bee8942674278859e13292fb" },
    { 4,
      "0102030405060708090a0b0c0d0e0f10111213141516171819",
      "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd"
      "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd",
      "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b",
      "b0ba465637458c6990e5a8c5f61d4af7e576d97ff94b872de76f8050361ee3db"
      "a91ca5c11aa25eb4d679275cc5788063a5f19741120c4f2de2adebeb10a298dd" },
    { 6,
      KEY_AA_131,
      "54657374205573696e67204c6172676572205468616e20426c6f636b2d53697a"
      "65204b6579202d2048617368204b6579204669727374",
      "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54",
      "80b24263c7c1a3ebb71493c1dd7be8b49b46d1f41b4aeec1121b013783f8f352"
      "6b56d037e05f2598bd0fd2215d6a1e5295e64f73f63f0aec8b915a985d786598" },
    { 7,
      KEY_AA_131,
      "5468697320697320612074657374207573696e672061206c6172676572207468"
      "616e20626c6f636b2d73697a65206b657920616e642061206c61726765722074"
      "68616e20626c6f636b2d73697a6520646174612e20546865206b6579206e6565"
      "647320746f20626520686173686564206265666f7265206265696e6720757365"
      "642062792074686520484d414320616c676f726974686d2e",
      "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2",
      "e37b6a775dc87dbaa4dfa9f96e5e3ffddebd71f8867289865df5a32d20cdc944"
      "b6022cac3c4982b10d5eeb55c3e4de15134676fb6de0446065c97440fa8c6a58" },
};

#endif /* SMOKE_VECTORS_H */
