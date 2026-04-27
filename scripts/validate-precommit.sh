#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

python3 -m pre_commit validate-config "${ROOT_DIR}/project/.pre-commit-config.yaml"

echo "Pre-commit config is valid."
