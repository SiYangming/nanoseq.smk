#!/usr/bin/env bash
# Generate a tiny spliced DRS-like toy dataset (no network).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
python3 "$ROOT/generate_testdata.py"
echo "Wrote $ROOT/resources"
