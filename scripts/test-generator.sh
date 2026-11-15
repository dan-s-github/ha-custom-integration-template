#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DEFAULT="/tmp/ha-template-default"
TMP_NO_SENSOR="/tmp/ha-template-no-sensor"
TMP_ICON="/tmp/ha-template-icon.png"

rm -rf "${TMP_DEFAULT}" "${TMP_NO_SENSOR}" "${TMP_ICON}"

# A non-square source icon, to check it is padded rather than stretched.
uv run --no-project --with pillow python -c \
  "from PIL import Image; Image.new('RGBA', (700, 500), '#d33').save('${TMP_ICON}')"

# --vcs-ref HEAD renders the checked-out commit, not the latest tag.
copier copy \
  --vcs-ref HEAD \
  --defaults \
  --force \
  --trust \
  --data author_name="Template Tester" \
  --data author_email="template@example.com" \
  --data github_username="template-user" \
  --data open_source_license="MIT" \
  "${ROOT_DIR}" \
  "${TMP_DEFAULT}"

# A long domain catches generated lines that only fit ruff's limit for short ones.
copier copy \
  --vcs-ref HEAD \
  --defaults \
  --force \
  --trust \
  --data include_sensor_platform=false \
  --data integration_name="Test Integration" \
  --data domain="test_integration_with_a_long_domain" \
  --data project_slug="ha-test-integration-with-a-long-domain" \
  --data hacs_country_csv="nz, AU" \
  --data brand_icon_path="${TMP_ICON}" \
  --data author_name="Template Tester" \
  --data author_email="template@example.com" \
  --data github_username="template-user" \
  --data open_source_license="MIT" \
  "${ROOT_DIR}" \
  "${TMP_NO_SENSOR}"

# Basic generated project assertions.
test -f "${TMP_DEFAULT}/.pre-commit-config.yaml"
test -f "${TMP_DEFAULT}/custom_components/my_integration/manifest.json"
test -f "${TMP_DEFAULT}/.github/workflows/ci.yml"
test -f "${TMP_DEFAULT}/.github/workflows/lint.yml"
test -f "${TMP_DEFAULT}/.github/workflows/release.yml"
test -f "${TMP_DEFAULT}/.github/workflows/validate.yml"
test -f "${TMP_DEFAULT}/tests/test_config_flow.py"
grep -q "^\[tool.ruff\]" "${TMP_DEFAULT}/pyproject.toml"

test -f "${TMP_NO_SENSOR}/.pre-commit-config.yaml"
test -f "${TMP_NO_SENSOR}/custom_components/test_integration_with_a_long_domain/manifest.json"
test -f "${TMP_NO_SENSOR}/.github/workflows/ci.yml"
test -f "${TMP_NO_SENSOR}/.github/workflows/lint.yml"
test -f "${TMP_NO_SENSOR}/.github/workflows/release.yml"
test -f "${TMP_NO_SENSOR}/.github/workflows/validate.yml"
test -f "${TMP_NO_SENSOR}/tests/test_config_flow.py"
grep -q "^\[tool.ruff\]" "${TMP_NO_SENSOR}/pyproject.toml"

# Answers file, .gitignore and hacs.json country list.
for project_dir in "${TMP_DEFAULT}" "${TMP_NO_SENSOR}"; do
  test -f "${project_dir}/.gitignore"
  grep -q "^_src_path:" "${project_dir}/.copier-answers.yml"
  python3 -m json.tool "${project_dir}/hacs.json" > /dev/null
done
grep -q "^domain: my_integration$" "${TMP_DEFAULT}/.copier-answers.yml"
if grep -q '"country"' "${TMP_DEFAULT}/hacs.json"; then
  echo "hacs.json should have no country list when hacs_country_csv is blank" >&2
  exit 1
fi
grep -q '"country": \["NZ", "AU"\],' "${TMP_NO_SENSOR}/hacs.json"

# Brand icons: the placeholder by default, resized from brand_icon_path otherwise.
for brand_dir in \
  "${TMP_DEFAULT}/custom_components/my_integration/brand" \
  "${TMP_NO_SENSOR}/custom_components/test_integration_with_a_long_domain/brand"; do
  file "${brand_dir}/icon.png" | grep -q "256 x 256"
  file "${brand_dir}/icon@2x.png" | grep -q "512 x 512"
done
if cmp -s "${TMP_DEFAULT}/custom_components/my_integration/brand/icon.png" \
  "${TMP_NO_SENSOR}/custom_components/test_integration_with_a_long_domain/brand/icon.png"; then
  echo "brand_icon_path was ignored: the placeholder icon was used" >&2
  exit 1
fi

# Run the same checks as the generated project's own CI.
for project_dir in "${TMP_DEFAULT}" "${TMP_NO_SENSOR}"; do
  (
    cd "${project_dir}"
    uv sync --group dev
    uv run --frozen ruff check .
    uv run --frozen ruff format --check .
    uv run --frozen pytest -q
    uv run --frozen mypy custom_components
  )
done

echo "Generator tests passed."
