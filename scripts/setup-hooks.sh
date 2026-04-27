#!/usr/bin/env bash

set -euo pipefail

if ! command -v pre-commit >/dev/null 2>&1; then
    echo "Installing pre-commit and commitizen..."
    python3 -m pip install --user pre-commit commitizen
fi

pre-commit install
pre-commit install --hook-type commit-msg

echo "Pre-commit hooks installed."
