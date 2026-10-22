#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# run.sh [suite...]
# =================
#
# Builds and runs the validation suite. With no arguments every suite
# runs. The oracle install prefixes come from the environment:
#
#     ORACLE_OPENSSL, ORACLE_AWSLC, ORACLE_BORINGSSL, ORACLE_HACL
#
# the first three pointing at a prefix with include/openssl and
# lib/libcrypto.a, the last at one with include/hacl and
# lib/libhacl_static.a. Without one the differential and long suites
# report SKIP.

set -eu

here=$(cd "$(dirname "$0")" && pwd)

if [ "$#" -gt 0 ]; then
    set -- "SUITES=$*"
fi

exec make -C "$here" check "$@"
