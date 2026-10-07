/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * tests/insn/run.c
 * ================
 *
 *     run SEED RANDOM > vectors.txt
 *
 * Runs every export of the instruction test program (tests/insn/insn.py
 * jazz) on this processor and prints one line per call:
 *
 *     <name> <index> <input, 128 bytes> <output, 16 bytes per result>
 *
 * in hexadecimal, byte 0 first. The inputs of each export are, for its
 * operand slots (16 bytes each, a to h):
 *
 *   1. every slot set to the same edge pattern, for each pattern below;
 *   2. one slot set to an edge pattern and the others random, for each
 *      slot the export reads and each pattern;
 *   3. RANDOM vectors with every slot random.
 *
 * Slots an export does not read are random. The random bytes come from
 * splitmix64 seeded with SEED, so a run is reproducible from its
 * arguments. The output buffer is filled with a guard byte before each
 * call, and the bytes past the export's results must keep it.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct insn {
  const char *name;
  void (*fn)(uint8_t *out, const uint8_t *src);
  unsigned operands; /* bit i set: slot i is an operand */
  unsigned results;  /* number of 16-byte results */
};

#include "insns.h"

#define SLOTS 8
#define SLOT 16
#define IN_BYTES (SLOTS * SLOT)
#define OUT_BYTES (4 * SLOT)
#define GUARD 0xa5

static uint64_t state;

static uint64_t splitmix64(void)
{
  uint64_t z = (state += 0x9e3779b97f4a7c15ULL);
  z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
  z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
  return z ^ (z >> 31);
}

static void random_bytes(uint8_t *p, size_t n)
{
  while (n > 0) {
    uint64_t r = splitmix64();
    size_t k = n < 8 ? n : 8;
    memcpy(p, &r, k);
    p += k;
    n -= k;
  }
}

static void fill32(uint8_t *p, uint32_t w)
{
  for (int i = 0; i < SLOT; i += 4) {
    p[i] = (uint8_t)w;
    p[i + 1] = (uint8_t)(w >> 8);
    p[i + 2] = (uint8_t)(w >> 16);
    p[i + 3] = (uint8_t)(w >> 24);
  }
}

static void fill64(uint8_t *p, uint64_t w)
{
  for (int i = 0; i < SLOT; i++)
    p[i] = (uint8_t)(w >> (8 * (i % 8)));
}

/*
 * Edge patterns of one 16-byte slot: the carry and sign boundaries of
 * 32-bit and 64-bit lanes, alternating bits, single bits at both ends
 * of every lane, and lanes that differ from each other.
 */
#define PATTERNS 12

static void pattern(uint8_t *p, int k)
{
  switch (k) {
  case 0: memset(p, 0x00, SLOT); break;
  case 1: memset(p, 0xff, SLOT); break;
  case 2: memset(p, 0x55, SLOT); break;
  case 3: memset(p, 0xaa, SLOT); break;
  case 4: fill32(p, 0x80000000u); break;
  case 5: fill32(p, 0x7fffffffu); break;
  case 6: fill32(p, 0x00000001u); break;
  case 7: fill64(p, 0x8000000000000000ULL); break;
  case 8: fill64(p, 0x7fffffffffffffffULL); break;
  case 9: fill64(p, 0x0000000000000001ULL); break;
  case 10: fill64(p, 0xffffffff00000000ULL); break;
  default:
    for (int i = 0; i < SLOT; i++) p[i] = (uint8_t)i;
    break;
  }
}

static int run(const struct insn *t, int index, const uint8_t *in)
{
  uint8_t out[OUT_BYTES];
  memset(out, GUARD, sizeof out);
  t->fn(out, in);
  for (unsigned i = t->results * SLOT; i < OUT_BYTES; i++) {
    if (out[i] != GUARD) {
      fprintf(stderr, "run: %s wrote past its results\n", t->name);
      return 1;
    }
  }
  printf("%s %d ", t->name, index);
  for (int i = 0; i < IN_BYTES; i++) printf("%02x", in[i]);
  printf(" ");
  for (unsigned i = 0; i < t->results * SLOT; i++) printf("%02x", out[i]);
  printf("\n");
  return 0;
}

int main(int argc, char **argv)
{
  if (argc != 3) {
    fprintf(stderr, "usage: run SEED RANDOM\n");
    return 2;
  }
  uint64_t seed = strtoull(argv[1], NULL, 0);
  long nrandom = strtol(argv[2], NULL, 0);
  if (nrandom < 0) {
    fprintf(stderr, "run: RANDOM must not be negative\n");
    return 2;
  }

  int bad = 0;
  for (size_t n = 0; n < sizeof insns / sizeof insns[0]; n++) {
    const struct insn *t = &insns[n];
    uint8_t in[IN_BYTES];
    int index = 0;
    /* One seed per export, so adding an entry leaves the others' vectors
       unchanged. */
    state = seed;
    for (const char *c = t->name; *c; c++) state = state * 131 + (uint8_t)*c;

    for (int k = 0; k < PATTERNS; k++) {
      random_bytes(in, IN_BYTES);
      for (int s = 0; s < SLOTS; s++)
        if (t->operands & (1u << s)) pattern(in + s * SLOT, k);
      bad |= run(t, index++, in);
    }
    for (int s = 0; s < SLOTS; s++) {
      if (!(t->operands & (1u << s))) continue;
      for (int k = 0; k < PATTERNS; k++) {
        random_bytes(in, IN_BYTES);
        pattern(in + s * SLOT, k);
        bad |= run(t, index++, in);
      }
    }
    for (long r = 0; r < nrandom; r++) {
      random_bytes(in, IN_BYTES);
      bad |= run(t, index++, in);
    }
  }
  return bad;
}
