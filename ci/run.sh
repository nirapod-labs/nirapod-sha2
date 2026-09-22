#!/usr/bin/env bash
# SPDX-FileCopyrightText: nirapod-sha2 contributors
# SPDX-License-Identifier: Apache-2.0
#
# ci/run.sh
# =========
#
# The local CI entry point of nirapod-sha2. It runs every gate of the
# project as a separate job, in order, each in its own process with its
# own wall-clock limit, and prints one summary table at the end.
#
#     ci/run.sh [--all] [--safety] [--proofs] [--only JOBS] [--no-clean]
#     ci/run.sh --list
#
# Default jobs: toolchain build tests exports ct.
# Opt-in jobs: safety (long, Linux only) and proofs (long, Linux only).
#
# A job passes only when it exits zero and its log holds a line that
# starts with PASS:. A timeout is INCONCLUSIVE, any other non-zero exit
# is FAIL, and a selected job that does not run is a failure of the run.
# The exit status is zero only when every selected job passed.
#
# Logs and the summary are under build/ci/<run>/. The tree is cleaned
# first unless --no-clean is given.

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/ci/lib.sh"
cd "$ROOT" || exit 1

ALL_JOBS="toolchain build tests exports ct"
OPT_JOBS="safety proofs"
ORDER="toolchain build tests exports ct safety proofs"

usage() {
  cat <<'EOF'
usage: ci/run.sh [options]

  --all           select every job, including safety and proofs
  --safety        add the safety-checker job (long; Linux only)
  --proofs        add the proof job (long; Linux only)
  --only JOBS     run exactly these jobs, comma separated
  --no-clean      keep the build directory
  --list          list the jobs and exit
  -h, --help      show this text

Environment:
  CI_TIMEOUT_<JOB>   wall-clock limit per job in seconds
  CI_SAFETY_TIMEOUT  limit of one safety-checker run, seconds
  CI_PROOF_JOBS      proof files checked at a time (default: cores, max 8)
  SHA2_TOOLCHAIN_WORK      toolchain work directory to verify
  SHA2_TOOLCHAIN_PROVENANCE  provenance file to verify
EOF
}

selection=
only=
safety=0
proofs=0
clean=1

while [ $# -gt 0 ]; do
  case $1 in
    --all) safety=1; proofs=1 ;;
    --safety) safety=1 ;;
    --proofs) proofs=1 ;;
    --only) shift; [ $# -gt 0 ] || { usage >&2; exit 2; }; only=$1 ;;
    --only=*) only=${1#*=} ;;
    --no-clean) clean=0 ;;
    --list)
      printf 'default: %s\n' "$ALL_JOBS"
      printf 'opt-in:  %s\n' "$OPT_JOBS"
      exit 0
      ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

if [ -n "$only" ]; then
  selection=$(printf '%s' "$only" | tr ',' ' ')
else
  selection=$ALL_JOBS
  [ "$safety" = 1 ] && selection="$selection safety"
  [ "$proofs" = 1 ] && selection="$selection proofs"
fi

for job in $selection; do
  case " $ALL_JOBS $OPT_JOBS " in
    *" $job "*) ;;
    *) echo "ci/run.sh: unknown job: $job" >&2; exit 2 ;;
  esac
done

want() {
  case " $selection " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

[ -n "$selection" ] || { echo "ci/run.sh: no job selected" >&2; exit 2; }

ci_need git
ci_need perl
command -v shasum >/dev/null 2>&1 || ci_need sha256sum

git rev-parse --git-dir >/dev/null 2>&1 || ci_fail "not a git checkout"

HOST_ARCH=$(ci_host_arch) || ci_fail "unsupported machine: $(uname -m)"
HOST_SYSTEM=$(ci_host_system) || ci_fail "unsupported system: $(uname -s)"
case $HOST_ARCH-$HOST_SYSTEM in
  aarch64-macosx|aarch64-linux|x86_64-linux) ;;
  *) ci_fail "unsupported platform: $HOST_ARCH-$HOST_SYSTEM" ;;
esac
export CI_HOST_ARCH=$HOST_ARCH CI_HOST_SYSTEM=$HOST_SYSTEM

REV=$(git rev-parse HEAD)
DIRTY=$(git status --porcelain | wc -l | tr -d ' ')

case " $selection " in
  *" proofs "*) export CI_NEED_EASYCRYPT=1 ;;
  *) export CI_NEED_EASYCRYPT=0 ;;
esac

if [ "$clean" = 1 ]; then
  case " $selection " in
    *" build "*|*" tests "*|*" exports "*|*" ct "*|*" safety "*)
      make clean >/dev/null 2>&1 || ci_fail "make clean failed"
      ;;
  esac
fi

RUNDIR=build/ci/$(date -u +%Y%m%dT%H%M%SZ)-$$
mkdir -p "$RUNDIR" || ci_fail "cannot create $RUNDIR"
export CI_REPO_ROOT=$ROOT CI_RUN_DIR=$RUNDIR

JOBS=
for job in $ORDER; do
  want "$job" && JOBS="$JOBS $job"
done
JOBS=${JOBS# }

ci_timeout() {
  local name=$1 var default
  var=CI_TIMEOUT_$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]')
  eval "default=\${$var:-}"
  if [ -n "$default" ]; then
    printf '%s\n' "$default"
    return
  fi
  case $name in
    toolchain) printf '300\n' ;;
    build) printf '1800\n' ;;
    tests) printf '900\n' ;;
    exports) printf '300\n' ;;
    ct) printf '3600\n' ;;
    safety) printf '43200\n' ;;
    proofs) printf '28800\n' ;;
    *) printf '900\n' ;;
  esac
}

printf 'nirapod-sha2 local CI\n'
printf 'revision %s%s\n' "$REV" "$([ "$DIRTY" -eq 0 ] && printf '' || printf ' (dirty tree: %s files)' "$DIRTY")"
printf 'host     %s %s (%s-%s)\n' "$(uname -s)" "$(uname -r)" "$HOST_ARCH" "$HOST_SYSTEM"
printf 'jobs     %s\n' "$JOBS"
printf 'logs     %s\n\n' "$RUNDIR"

overall=0
for job in $JOBS; do
  script=ci/jobs/$job.sh
  log=$RUNDIR/$job.log
  limit=$(ci_timeout "$job")
  printf '[%s] start (limit %ss)\n' "$job" "$limit"
  start=$(date +%s)
  if [ ! -f "$script" ]; then
    printf 'FAIL: job script %s is missing\n' "$script" > "$log"
    rc=127
  else
    ci_cap "$limit" bash "$script" > "$log" 2>&1
    rc=$?
  fi
  end=$(date +%s)
  secs=$((end - start))

  if [ "$rc" -eq 124 ]; then
    status=INCONCLUSIVE
    printf 'FAIL: job reported a timeout (exit 124)\n' >> "$log"
  elif [ "$rc" -ne 0 ]; then
    status=FAIL
    printf 'FAIL: job exited %s\n' "$rc" >> "$log"
  elif ! grep -q '^PASS:' "$log"; then
    status=FAIL
    printf 'FAIL: job exited 0 without a PASS line\n' >> "$log"
  else
    status=PASS
  fi

  printf '%s %s\n' "$status" "$secs" > "$RUNDIR/status.$job"
  printf '[%s] %s (%ss)\n' "$job" "$status" "$secs"
  if [ "$status" != PASS ]; then
    overall=1
    printf '  log tail (%s):\n' "$log"
    tail -n 15 "$log" | sed 's/^/  /'
  fi
done

printf '\nsummary\n'
printf '%-11s %-13s %8s  %s\n' job status seconds log
for job in $ORDER; do
  if want "$job"; then
    read -r status secs < "$RUNDIR/status.$job"
    log=$RUNDIR/$job.log
  else
    status="NOT RUN"
    secs="-"
    log="-"
  fi
  printf '%-11s %-13s %8s  %s\n' "$job" "$status" "$secs" "$log"
done

if [ "$overall" -eq 0 ]; then
  printf '\noverall: PASS (%s jobs)\n' "$(printf '%s\n' "$JOBS" | wc -w | tr -d ' ')"
else
  printf '\noverall: FAIL\n'
fi
exit "$overall"
