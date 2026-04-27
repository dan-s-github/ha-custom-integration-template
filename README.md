# Home Assistant Custom Integration Copier Template

This Copier template bootstraps a generic Home Assistant custom integration.

It includes:

- Home Assistant config flow scaffold
- Integration setup/unload scaffold
- Optional minimal sensor platform scaffold
- Tests, linting, and development scripts
- HACS metadata and manifest wiring

## Requirements

- [Copier](https://copier.readthedocs.io/)
- Python 3.14+

## Use It

```bash
copier copy https://github.com/dan-s-github/ha-custom-integration-template /path/to/new-repo
```

Example with a concrete target directory:

```bash
copier copy https://github.com/dan-s-github/ha-custom-integration-template ~/Github/ha_projects/ha-my-integration
```

Example pinned to a tag:

```bash
copier copy https://github.com/dan-s-github/ha-custom-integration-template --vcs-ref v0.1.0 ~/Github/ha_projects/ha-my-integration
```

Template repository layout:

- Root: template metadata and docs
- project/: files rendered into generated projects

## Template Validation

Run these checks in the template repository:

```bash
pre-commit run --all-files
./scripts/validate-precommit.sh
./scripts/test-generator.sh
```

Install local git hooks (including commit-msg) to enforce conventional commits:

```bash
./scripts/setup-hooks.sh
```

Or install them manually:

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

Examples of valid commit messages:

- feat: add generator smoke tests
- fix: handle empty dependency inputs in manifest template
- chore: update pre-commit hook versions

These checks are also run in CI on pull requests and pushes to main.

Then in the generated project:

```bash
./scripts/setup
./scripts/lint
pytest
./scripts/develop
```

## Notes

- The template is intentionally generic and avoids protocol-specific assumptions.
- Use `requirements_csv` and `ha_dependencies_csv` to declare external/runtime dependencies.
