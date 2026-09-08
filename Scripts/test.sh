#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
TASK_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TASK_TEST_DIR"' EXIT
swiftc Shared/Countdown.swift Shared/Attendance.swift Tests/CountdownTests.swift -o "$TASK_TEST_DIR/countdown-tests"
"$TASK_TEST_DIR/countdown-tests"
