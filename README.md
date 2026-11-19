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
copier copy --trust https://github.com/dan-s-github/ha-custom-integration-template /path/to/new-repo
```

Example with a concrete target directory:

```bash
copier copy --trust https://github.com/dan-s-github/ha-custom-integration-template ~/Github/ha_projects/ha-my-integration
```

Example pinned to a tag:

```bash
copier copy --trust https://github.com/dan-s-github/ha-custom-integration-template --vcs-ref v0.1.0 ~/Github/ha_projects/ha-my-integration
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
uv run --group dev pytest
./scripts/develop
```

## Notes

- The template is intentionally generic and avoids protocol-specific assumptions.
- Use `requirements_csv` and `ha_dependencies_csv` to declare external/runtime dependencies.
- Use `hacs_country_csv` (e.g. `NZ` or `NZ,AU`) to limit the HACS listing to some countries; leave it blank for all.
- Set `brand_icon_path` to an absolute path to a square PNG (512 px or more) to use it as the brand icon; the copier task writes `brand/icon.png` (256 px) and `brand/icon@2x.png` (512 px). Leave it blank for a placeholder icon, and replace that before publishing. Home Assistant falls back to `icon.png` for the logo and dark variants; add `logo.png`, `dark_icon.png` and so on to `brand/` by hand if you want them.
- The template runs a copier task for the icon, so `copier copy` and `copier update` need `--trust`.
- Generated projects record their answers in `.copier-answers.yml`, so `copier update` can apply later template changes. Commit that file.
