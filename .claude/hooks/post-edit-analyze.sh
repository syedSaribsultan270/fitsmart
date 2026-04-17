#!/bin/bash
# Post-edit hook: run flutter analyze after any Dart file edit and surface issues to Claude.
# Receives tool context as JSON on stdin.

input=$(cat)

# Only run for .dart files — check file_path in the tool input JSON
if ! echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    fp = d.get('tool_input', {}).get('file_path', '')
    exit(0 if fp.endswith('.dart') else 1)
except Exception:
    exit(1)
" 2>/dev/null; then
  exit 0
fi

export PATH="$PATH:/Users/vyro/development/flutter/bin"
cd /Users/vyro/Downloads/fitsmart2.0/fitsmart_app || exit 0

output=$(flutter analyze --no-pub 2>&1)

if echo "$output" | grep -qE '\• (error|warning)'; then
  echo "=== flutter analyze: issues found — fix before moving on ==="
  echo "$output" | grep -E '\• (error|warning)' | head -20
fi

exit 0
