# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Browser UX: inline markdown values rendered in exam questions can now be copied with a visible hover/click affordance
- Browser compatibility: clipboard fallback handling for non-Clipboard API environments
- CI: `security` job with dependency audit (`pip-audit`) and secret scanning (`gitleaks`)
- CI: `build` job with package build (`uv build`) and artifact upload
- CI: Python test step with pytest and coverage reporting
- CI: Python tests run on a version matrix pinned to Python 3.12, and the dependency audit also runs under Python 3.12 (minimum supported version)
- `.gitleaks.toml` config for path-based allowlist of exercise templates
- Pre-commit: `check-added-large-files` hook (max 500KB)
- Pre-commit: `mirrors-mypy` hook for Python type checking
- Python unit tests: 57 tests covering `ckad_dojo.py`, `web/server.py`, `scripts/bump-version.py`
- pytest + pytest-cov configuration in `pyproject.toml` (coverage threshold 30%)
- mypy configuration with `explicit_package_bases` and gradual type checking
- Dependabot: grouping, labels, and weekly Monday schedule
- Architecture documentation (`docs/architecture.md`)

### Changed

- **BREAKING — Python 3.12+ is now required** (`requires-python = ">=3.12"`, was `>=3.10`): Python 3.10 and 3.11 are no longer supported. Dropping 3.10 also removes a vulnerable lock entry, since the patched releases of `filelock` (CVE fixes from 4.2.1 onward) no longer support Python 3.10. Ruff (`target-version`) and mypy (`python_version`) now target 3.12 as well.
  - Most users have nothing to do: `uv` downloads a compatible Python automatically on the next `uv run ckad-dojo`.
  - If automatic Python downloads are set to `manual`, run `uv python install 3.12` first. If they are set to `never` (`python-downloads` or `UV_PYTHON_DOWNLOADS`), install Python 3.12+ with your system package manager or switch the setting to `manual`.
  - Existing clone with a `.venv` built on 3.10 or 3.11: run `uv sync` to recreate it.
  - Global install (`uv tool install`) built on 3.10 or 3.11: run `uv tool install --reinstall --python 3.12 <source>` with the source you installed from (`ckad-dojo`, `./ckad-dojo` or the `git+https://` URL). Without `--python`, `uv` can keep the tool's old interpreter and resolution fails.
- CI: restructured pipeline into 3 ordered stages (lint -> test+security -> build)
- Pre-commit: replaced flake8 with ruff (lint + format)
- Ruff configuration in `pyproject.toml` with comprehensive rule selection
- Narrowed all `except Exception` to specific exception types (`OSError`, `subprocess.SubprocessError`, `ValueError`)
- Added type annotations to `web/server.py` and `ckad_dojo.py`
- Codespell ignore list extended for French documentation support

### Fixed

- `web/server.py`: `send_header` Content-Length passed as `str` instead of `int` (type bug)

### Removed

- `.flake8` configuration file (replaced by ruff in `pyproject.toml`)

### Security

- Dependencies: `filelock` 3.31.2 -> 4.2.7 and `virtualenv` 21.14.4 -> 21.15.2 (dev dependencies) to fix 20 known CVEs reported by `pip-audit` (12 in filelock, 8 in virtualenv)

## [1.7.0] - 2026-01-26

### Added

- Timer pause control (`ALLOW_TIMER_PAUSE` in exam.conf, disabled by default)

### Changed

### Fixed

### Removed

## [1.6.0] - 2025-01-26

### Added

- Browser selection option (`--browser` / `-b`) for CLI and bash scripts
- Support for `CKAD_BROWSER` environment variable to set default browser
- Global installation documentation with `uv tool install`
- "Cleanup & Exit" button in score modal (separate from "Close")
- Accessibility: focus-visible states on all interactive elements
- Accessibility: `prefers-reduced-motion` support for animations
- Keyboard navigation for exam cards and question dots (Enter/Space)

### Changed

- Updated color palette to modern developer/tech theme (slate/blue)
- Enhanced button interactions with active states (`scale(0.97)`)
- Improved exam cards with gradient accent on hover
- Score modal now has 3 buttons: Back to Exam, Close, Cleanup & Exit
- "Close" button now exits without cleanup (was doing cleanup before)

### Fixed

- Stop Exam button behavior: now shows score without automatic cleanup

## [1.3.1] - 2025-01-22

### Changed

- Adapted opensource-ready command for ckad-dojo
- Applied shfmt formatting to shell scripts

### Added

- Pre-commit hooks and linting configuration
- Shell auto-completion with argcomplete

## [1.3.0] - 2025-01-15

### Added

- Dojo Genbu (ckad-simulation4) - 22 questions, 115 points
- Norse mythology theme (Odin, Thor, Asgard...)

## [1.2.1] - 2025-01-10

### Fixed

- Score expansion display in web interface
- Various scoring function improvements

## [1.2.0] - 2025-01-05

### Added

- Dojo welcome banner in embedded terminal
- Score details view with expandable criteria

## [1.1.0] - 2024-12-20

### Added

- Dojo Byakko (ckad-simulation3) - 20 questions, 105 points
- Greek mythology theme (Olympus, Zeus, Athena...)

## [1.0.0] - 2024-12-01

### Added

- Initial release with 2 dojos
- Dojo Seiryu (ckad-simulation1) - 22 questions, 113 points
- Dojo Suzaku (ckad-simulation2) - 21 questions, 112 points
- Web interface with timer
- Automated scoring system
- Unified CLI with `uv run ckad-dojo`
