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
- `.gitleaks.toml` config for path-based allowlist of exercise templates
- Pre-commit: `check-added-large-files` hook (max 500KB)
- Pre-commit: `mirrors-mypy` hook for Python type checking
- Python unit tests: 57 tests covering `ckad_dojo.py`, `web/server.py`, `scripts/bump-version.py`
- pytest + pytest-cov configuration in `pyproject.toml` (coverage threshold 30%)
- mypy configuration with `explicit_package_bases` and gradual type checking
- Dependabot: grouping, labels, and weekly Monday schedule
- Architecture documentation (`docs/architecture.md`)

### Changed

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
