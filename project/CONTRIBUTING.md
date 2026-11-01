# Contributing

## Setup

```bash
./scripts/setup
```

This installs pre-commit hooks for linting and commit message checks.

## Development

```bash
./scripts/develop
```

## Quality Checks

```bash
./scripts/lint
uv run --group dev pre-commit run --all-files
pytest
```

Commit `uv.lock`: the GitHub workflows install with `uv sync --frozen`.

## Continuous Integration

- `ci.yml` runs pytest and mypy on every push and pull request.
- `lint.yml` runs `ruff check` and `ruff format --check`.
- `validate.yml` runs hassfest and HACS validation, also nightly.

## Releases

Releases are managed with Commitizen and the `Release` workflow.

- Version source of truth: `project.version` in `pyproject.toml`
- Synced file: `custom_components/<domain>/manifest.json` `version` field
- Tag format: `vX.Y.Z`

To cut a release, run the `Release` workflow from Actions and choose the
increment. The `*_RC` choices create a release candidate, published as a
GitHub prerelease so HACS only offers it to beta users.

The workflow pushes the bump commit and tag with a GitHub App token, so it can
push to a protected `main`. One-time setup:

1. Create a GitHub App with **Contents: Read and write** permission and
   install it on this repository. If `main` is protected, allow the app to
   bypass the rule.
2. Create an environment named `release` (Settings -> Environments).
3. Add the environment secrets `APP_CLIENT_ID` (the app's client ID) and
   `APP_PRIVATE_KEY` (a private key generated for the app).
