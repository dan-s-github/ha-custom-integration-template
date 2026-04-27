#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DEFAULT="/tmp/ha-template-default"
TMP_NO_SENSOR="/tmp/ha-template-no-sensor"

rm -rf "${TMP_DEFAULT}" "${TMP_NO_SENSOR}"

copier copy \
  --defaults \
  --force \
  --data author_name="Template Tester" \
  --data author_email="template@example.com" \
  --data github_username="template-user" \
  --data open_source_license="MIT" \
  "${ROOT_DIR}" \
  "${TMP_DEFAULT}"

copier copy \
  --force \
  --data include_sensor_platform=false \
  --data integration_name="Test Integration" \
  --data domain="test_integration" \
  --data project_slug="ha-test-integration" \
  --data author_name="Template Tester" \
  --data author_email="template@example.com" \
  --data github_username="template-user" \
  --data open_source_license="MIT" \
  "${ROOT_DIR}" \
  "${TMP_NO_SENSOR}"

# Basic generated project assertions.
test -f "${TMP_DEFAULT}/.pre-commit-config.yaml"
test -f "${TMP_DEFAULT}/custom_components/my_integration/manifest.json"
test -f "${TMP_DEFAULT}/tests/test_config_flow.py"
grep -q "^\[tool.ruff\]" "${TMP_DEFAULT}/pyproject.toml"

test -f "${TMP_NO_SENSOR}/.pre-commit-config.yaml"
test -f "${TMP_NO_SENSOR}/custom_components/test_integration/manifest.json"
test -f "${TMP_NO_SENSOR}/tests/test_config_flow.py"
grep -q "^\[tool.ruff\]" "${TMP_NO_SENSOR}/pyproject.toml"

python3 -m compileall "${TMP_DEFAULT}/custom_components" "${TMP_DEFAULT}/tests"
python3 -m compileall "${TMP_NO_SENSOR}/custom_components" "${TMP_NO_SENSOR}/tests"

echo "Generator tests passed."
