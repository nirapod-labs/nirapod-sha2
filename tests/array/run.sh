#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The array instance suite: the array test unit for the host against
# the production library (array.c). Its typing is part of make ct.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
exec make -C "$here/../.." array-test
