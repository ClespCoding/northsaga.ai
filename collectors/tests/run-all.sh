#!/bin/sh
# Run every offline test. No network, no credentials required.
#
#   cd collectors && ./tests/run-all.sh

set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
failed=0

for test in test_grade test_idox test_sheets; do
    echo "--------------------------------------------------------------"
    echo "$test"
    echo "--------------------------------------------------------------"
    if python3 "$HERE/$test.py"; then
        :
    else
        failed=$((failed + 1))
    fi
    echo
done

if [ "$failed" -gt 0 ]; then
    echo "$failed test file(s) FAILED"
    exit 1
fi
echo "all offline tests passed"
