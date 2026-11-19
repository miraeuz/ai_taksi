#!/usr/bin/env bash
# usage: run.sh <label> <command...>
# Runs the command; on failure, publishes the last lines of output as a GitHub annotation.
label="$1"; shift
log="$(mktemp)"
"$@" 2>&1 | tee "$log"
code=${PIPESTATUS[0]}
if [ "$code" -ne 0 ]; then
  msg=$(tail -n 70 "$log" | cut -c1-400 | sed 's/%/%25/g' | awk '{printf "%s%%0A", $0}')
  echo "::error title=${label} failed::${msg}"
fi
exit "$code"
