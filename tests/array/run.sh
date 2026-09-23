#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The array instance suite: build the array test unit for the host,
# type it with jasmin-ct and jasmin-ct --sct, and run array.c against
# the production library.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
exec make -C "$here/../.." array-check
