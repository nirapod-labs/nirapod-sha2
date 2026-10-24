#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# toolchain/baselines/build.sh
# ============================
#
# Builds the pinned implementations of toolchain/baselines/PIN.
#
#   toolchain/baselines/build.sh WORK [openssl] [awslc] [boringssl] [hacl] [sphincs]
#
# With no name, all five. Each archive is downloaded to WORK/archives
# (kept if already there), checked against its SHA-256, unpacked afresh
# under WORK/src, built with the host's C compiler in the build type its
# project calls Release, and installed under WORK/install/<name>:
#
#     WORK/install/openssl-4.0.3      static libcrypto, no shared libraries
#     WORK/install/aws-lc-5.11.0
#     WORK/install/boringssl-99b9d64
#     WORK/install/hacl-star-0.7.2
#     WORK/install/sphincsplus-7ec789a   x86-64 only, see build_sphincs
#
# WORK/install is what the differential tests take as SHA2_BASELINES
# (ci/jobs/tests.sh) and the benchmarks as BASELINE_ROOT/install
# (bench/Makefile). Needs curl, perl, make, CMake and ar; JOBS sets the
# build parallelism (default 4) and CC the compiler of the SPHINCS+ files
# (default cc). One log per library in WORK/logs.

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$here/PIN"

[ $# -ge 1 ] || { echo "usage: $0 WORK [openssl] [awslc] [boringssl] [hacl] [sphincs]" >&2; exit 2; }
mkdir -p "$1"
work=$(cd "$1" && pwd)
shift
[ $# -gt 0 ] || set -- openssl awslc boringssl hacl sphincs
jobs=${JOBS:-4}

need() { command -v "$1" >/dev/null 2>&1 || { echo "build.sh: $1 not found" >&2; exit 1; }; }
need curl; need perl; need make; need cmake; need tar; need ar

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

# fetch NAME URL SHA256: the archive, checked; prints its path.
fetch() {
  local name=$1 url=$2 want=$3 file
  file=$work/archives/$name.tar.gz
  mkdir -p "$work/archives"
  if [ ! -f "$file" ]; then
    curl -fsSL -o "$file.part" "$url"
    mv "$file.part" "$file"
  fi
  local got
  got=$(sha256 "$file")
  if [ "$got" != "$want" ]; then
    echo "build.sh: $file has SHA-256 $got, pinned $want" >&2
    exit 1
  fi
  printf '%s\n' "$file"
}

# unpack NAME ARCHIVE: a fresh source tree; prints its path.
unpack() {
  local name=$1 archive=$2 dir
  dir=$work/src/$name
  rm -rf "$dir"
  mkdir -p "$dir"
  tar -xzf "$archive" -C "$dir" --strip-components=1
  printf '%s\n' "$dir"
}

cmake_build() {
  local src=$1 bld=$2 prefix=$3; shift 3
  rm -rf "$bld" "$prefix"
  cmake -S "$src" -B "$bld" -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$prefix" "$@"
  cmake --build "$bld" -- -j"$jobs"
  cmake --install "$bld"
}

build_openssl() {
  local src
  src=$(unpack "$OPENSSL_NAME" "$(fetch "$OPENSSL_NAME" "$OPENSSL_URL" "$OPENSSL_SHA256")")
  rm -rf "$work/install/$OPENSSL_NAME"
  (cd "$src" && perl ./Configure --prefix="$work/install/$OPENSSL_NAME" no-shared no-docs \
     && make -j"$jobs" && make install_sw)
}

build_awslc() {
  local src
  src=$(unpack "$AWSLC_NAME" "$(fetch "$AWSLC_NAME" "$AWSLC_URL" "$AWSLC_SHA256")")
  cmake_build "$src" "$work/build/$AWSLC_NAME" "$work/install/$AWSLC_NAME" \
    -DBUILD_TESTING=OFF -DDISABLE_GO=ON
}

build_boringssl() {
  local src
  src=$(unpack "$BORINGSSL_NAME" "$(fetch "$BORINGSSL_NAME" "$BORINGSSL_URL" "$BORINGSSL_SHA256")")
  cmake_build "$src" "$work/build/$BORINGSSL_NAME" "$work/install/$BORINGSSL_NAME" \
    -DBUILD_TESTING=OFF
}

# HACL*'s install rule copies build/config.h from the source directory, so
# its build directory must be src/build.
build_hacl() {
  local src
  src=$(unpack "$HACL_NAME" "$(fetch "$HACL_NAME" "$HACL_URL" "$HACL_SHA256")")
  cmake_build "$src" "$src/build" "$work/install/$HACL_NAME" \
    -DENABLE_TESTS=OFF -DENABLE_BENCHMARKS=OFF
}

# SPHINCS+ has no build of a library, only of its signing programs, so the
# files its 8-way SHA-256 (sha256x8) and 4-way SHA-512 (sha512x4_seeded)
# need are compiled here into one static archive:
#
#     sha256avx.c sha256x8.c   the 8-way SHA-256
#     sha512x4.c               the 4-way SHA-512
#     utils.c                  u32_to_bytes, which the MGF1 functions in
#                              both files call
#     thash_sha2_simple.c address.c sha2.c
#                              what utils.c calls, so that the archive
#                              links; the benchmark calls none of it
#
# The project's own Makefile builds with -O3 -march=native -flto. Here it
# is -O3 -mavx2: -march=native would let the compiler use AVX-512 on a CPU
# that has it, which is not the code being compared, and the archive is
# linked into a driver built without LTO. The code is AVX2 only, so the
# build is skipped on any other machine.
sphincs_files="sha256avx sha256x8 sha512x4 utils thash_sha2_simple address sha2"

sphincs_host() {
  case $(uname -m) in
    x86_64|amd64) return 0 ;;
    *) return 1 ;;
  esac
}

build_sphincs() {
  local src dir obj prefix f
  src=$(unpack "$SPHINCS_NAME" "$(fetch "$SPHINCS_NAME" "$SPHINCS_URL" "$SPHINCS_SHA256")")
  dir=$src/sha2-avx2
  obj=$work/build/$SPHINCS_NAME
  prefix=$work/install/$SPHINCS_NAME
  rm -rf "$obj" "$prefix"
  mkdir -p "$obj" "$prefix/lib" "$prefix/include/params"
  for f in $sphincs_files; do
    "${CC:-cc}" -O3 -std=c99 -mavx2 -fomit-frame-pointer -DPARAMS="$SPHINCS_PARAMS" \
      -I"$dir" -c -o "$obj/$f.o" "$dir/$f.c"
  done
  ar rcs "$prefix/lib/libsphincs_sha2_avx2.a" "$obj"/*.o
  cp "$dir/params.h" "$dir/sha2_offsets.h" "$dir/sha256x8.h" "$dir/sha512x4.h" \
    "$prefix/include/"
  cp "$dir/params/params-$SPHINCS_PARAMS.h" "$prefix/include/params/"
  cp "$src/LICENSE" "$prefix/"
  cp -R "$src/LICENSES" "$prefix/"
}

mkdir -p "$work/logs"
for lib in "$@"; do
  case $lib in
    openssl|awslc|boringssl|hacl|sphincs) ;;
    *) echo "build.sh: unknown library: $lib" >&2; exit 2 ;;
  esac
  if [ "$lib" = sphincs ] && ! sphincs_host; then
    echo "build.sh: sphincs skipped: its multi-way SHA-2 is AVX2 code and this machine is $(uname -m)"
    continue
  fi
  log=$work/logs/$lib.log
  echo "build.sh: $lib (log $log)"
  if ! "build_$lib" > "$log" 2>&1; then
    tail -n 20 "$log" >&2
    echo "build.sh: $lib failed" >&2
    exit 1
  fi
done
echo "build.sh: done, installs in $work/install"
