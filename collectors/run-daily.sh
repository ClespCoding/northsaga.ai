#!/bin/sh
# Daily planning-application collection. Invoked by cron; see crontab.example.
#
# Deliberately boring: one lock so a slow run never overlaps the next, one log
# file per day, and a non-zero exit if the collector failed so cron's MAILTO
# (or your monitoring) actually tells you.
#
#   ./run-daily.sh              collect the last 7 days
#   DAYS=1 ./run-daily.sh       collect yesterday only
#
# Environment:
#   GOOGLE_APPLICATION_CREDENTIALS  path to the service-account JSON key
#   DAYS                            lookback window (default 7)
#   COUNCILS                        space-separated slugs (default: all three)
#   LOG_DIR                         where to write logs (default ./logs)

set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DAYS=${DAYS:-7}
COUNCILS=${COUNCILS:-}
LOG_DIR=${LOG_DIR:-"$HERE/logs"}
CREDS=${GOOGLE_APPLICATION_CREDENTIALS:-/etc/northsaga/service-account.json}

# One lock per council set, so three staggered single-council jobs can run
# without blocking each other while a single all-councils job still self-locks.
LOCK_TAG=$(echo "${COUNCILS:-all}" | tr ' ' '-')
LOCK=${LOCK:-/tmp/northsaga-planning-$LOCK_TAG.lock}

mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/collect-$LOCK_TAG-$(date +%Y-%m-%d).log"

# A lookback of several days rather than one means a missed morning heals
# itself on the next run — the sheet de-duplicates on application code, so
# re-collecting an overlapping window costs nothing.

if [ ! -f "$CREDS" ]; then
    echo "$(date -Is) FATAL: no credentials at $CREDS" | tee -a "$LOG" >&2
    exit 2
fi

# mkdir is atomic on every POSIX filesystem, so it works as a lock without
# depending on flock(1), which is absent from Alpine and macOS.
if ! mkdir "$LOCK" 2>/dev/null; then
    echo "$(date -Is) SKIPPED: another run holds $LOCK" | tee -a "$LOG" >&2
    exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT INT TERM

echo "=== $(date -Is) starting (days=$DAYS councils=${COUNCILS:-all}) ===" >>"$LOG"

# Not piped into tee: a pipeline would report tee's exit status, not the
# collector's, and cron would think every failed run succeeded.
set +e
if [ -n "$COUNCILS" ]; then
    # Unquoted on purpose — COUNCILS is a space-separated list of slugs.
    # shellcheck disable=SC2086
    python3 "$HERE/collect.py" --days "$DAYS" --credentials "$CREDS" \
        --councils $COUNCILS >>"$LOG" 2>&1
else
    python3 "$HERE/collect.py" --days "$DAYS" --credentials "$CREDS" >>"$LOG" 2>&1
fi
status=$?
set -e

echo "=== $(date -Is) finished, exit $status ===" >>"$LOG"

# Cron mails whatever a job writes to stdout/stderr. Stay silent on success so
# a working collector does not mail every morning; on failure send the log.
if [ "$status" -ne 0 ]; then
    echo "Planning collector exited $status. Log: $LOG"
    tail -n 40 "$LOG"
fi >&2

exit "$status"
