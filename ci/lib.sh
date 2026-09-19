# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# shellcheck shell=bash
#
# ci/lib.sh
# =========
#
# Helpers shared by ci/run.sh and the job scripts. The file only defines
# functions; sourcing it changes no state. Job scripts run from the
# repository root with the variables ci/run.sh exports:
#
#     CI_REPO_ROOT     absolute path of the checkout
#     CI_RUN_DIR       directory of this run's logs
#     CI_HOST_ARCH     aarch64 or x86_64
#     CI_HOST_SYSTEM   macosx or linux
#     CI_NEED_EASYCRYPT  1 when the selected jobs need the proof tools

# A condition the job cannot meet. The message is the last line of its log.
ci_fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

ci_host_arch() {
  case $(uname -m) in
    arm64|aarch64) printf 'aarch64\n' ;;
    x86_64|amd64) printf 'x86_64\n' ;;
    *) return 1 ;;
  esac
}

ci_host_system() {
  case $(uname -s) in
    Darwin) printf 'macosx\n' ;;
    Linux) printf 'linux\n' ;;
    *) return 1 ;;
  esac
}

ci_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$@" | awk '{print $1}'
  else
    shasum -a 256 "$@" | awk '{print $1}'
  fi
}

ci_need() {
  command -v "$1" >/dev/null 2>&1 || ci_fail "required tool not found: $1"
}

# The build output directory of the host, as the Makefile names it.
ci_out() {
  printf 'build/%s-%s\n' "$CI_HOST_ARCH" "$CI_HOST_SYSTEM"
}

# The units of an architecture, in the order of the Makefile.
ci_units() {
  case $1 in
    aarch64) printf 'aarch64-portable aarch64-scalar aarch64-sha2\n' ;;
    x86_64) printf 'x86_64-portable x86_64-shani x86_64-avx2\n' ;;
    *) return 1 ;;
  esac
}

# The Jasmin target architecture and the toolkit roots of a unit. These
# repeat unit_jarch and unit_roots of the Makefile. Each host builds its
# three units; the two host builds cover all six.
ci_jarch() {
  case ${1%%-*} in
    aarch64) printf 'armv8a\n' ;;
    x86_64) printf 'x86-64\n' ;;
    *) return 1 ;;
  esac
}

ci_unit_roots() {
  local unit=$1 arch variant kernel kernelx
  arch=${unit%%-*}
  variant=${unit#*-}
  kernel=src
  kernelx=src
  case $variant in
    portable) ;;
    scalar) kernel=src/$arch/scalar ;;
    sha2) kernel=src/$arch/sha2 ;;
    shani) kernel=src/$arch/shani ;;
    avx2) kernelx=src/$arch/avx2 ;;
    *) return 1 ;;
  esac
  printf -- '-I Hash=src -I HashWord=src/%s -I Sha2Kernel=%s -I Sha2KernelX=%s\n' \
    "$arch" "$kernel" "$kernelx"
}

# Run a command under a wall-clock limit, killing the whole process group
# on expiry. Exit status is the command's, or 124 when the limit expired.
# Perl is present on macOS and Linux; the shell has no portable timeout.
ci_cap() {
  local limit=$1
  shift
  perl -e '
    my $limit = shift @ARGV;
    my $pid = fork();
    die "fork: $!\n" unless defined $pid;
    if ($pid == 0) {
      setpgrp(0, 0);
      exec @ARGV;
      print STDERR "cannot exec $ARGV[0]: $!\n";
      exit 127;
    }
    my $timed_out = 0;
    local $SIG{ALRM} = sub {
      $timed_out = 1;
      kill "TERM", -$pid;
      sleep 10;
      kill "KILL", -$pid;
    };
    alarm $limit;
    waitpid($pid, 0);
    alarm 0;
    my $status = $?;
    if ($timed_out) {
      print STDERR "timeout after ${limit}s\n";
      exit 124;
    }
    exit(($status & 127) ? 128 + ($status & 127) : $status >> 8);
  ' "$limit" "$@"
}
