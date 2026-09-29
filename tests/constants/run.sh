#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The constants suite: every constant table under src/ against its
# derivation from FIPS 180-4, with one negative control per table
# (tests/constants/check.py). Needs python3 only.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
command -v python3 >/dev/null 2>&1 || { echo "constants: python3 not found" >&2; exit 1; }
exec python3 -I "$here/check.py" "$here/../../src"
