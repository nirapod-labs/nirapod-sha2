#!/bin/sh
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# The timing-mode suite: every public call restores the caller's PSTATE.DIT
# on AArch64 (capi/timing.c); on a CPU without FEAT_DIT, and on x86-64, the
# test reports NOT APPLICABLE.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
exec make -C "$here/../.." dit-check
