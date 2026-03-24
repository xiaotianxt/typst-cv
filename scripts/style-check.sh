#!/bin/sh
set -eu

MODE="${1:-assert}"
MAX_LEN="${MAX_LINE_LEN:-140}"

if [ "$MODE" != "assert" ] && [ "$MODE" != "warn" ]; then
  echo "usage: $0 [assert|warn]" >&2
  exit 2
fi

FILES="$(find modules -type f -name '*.yml' | sort) base.yml profiles.yml"

awk -v max_len="$MAX_LEN" -v mode="$MODE" '
  length($0) > max_len {
    printf "%s:%d:%d\n", FILENAME, NR, length($0)
    violations += 1
  }
  END {
    if (violations > 0) {
      if (mode == "warn") {
        printf "style warning: %d line(s) exceed %d chars\n", violations, max_len > "/dev/stderr"
        exit 0
      }
      printf "style error: %d line(s) exceed %d chars\n", violations, max_len > "/dev/stderr"
      exit 1
    }
    printf "style check ok: all lines <= %d chars\n", max_len
  }
' $FILES
