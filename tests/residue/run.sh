#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The residue suite: no secret left on the stack or in a register after
# any public operation, with every kernel built here, and the stack below
# the C frames cleared, with the negative controls (tests/residue).

set -eu

here=$(cd "$(dirname "$0")" && pwd)
exec make -C "$here/../.." residue-check
