# Contributing to ckad-dojo

Thank you for your interest in contributing to ckad-dojo!

## How to Contribute

### Report a Bug

Found a bug? Please [open an issue](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=bug_report.md) with:

- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, kubectl version, etc.)

### Suggest an Improvement

Have an idea? [Create a feature request](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=feature_request.md) with:

- Description of the proposed feature
- Use case and benefits
- Any implementation ideas (optional)

### Submit a Pull Request

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test your changes (`./tests/run-tests.sh`)
5. Run pre-commit checks (`pre-commit run --all-files`)
6. Commit with a [conventional message](https://www.conventionalcommits.org/)
7. Open a Pull Request

## Development Setup

This project uses [direnv](https://direnv.net/) and [pre-commit](https://pre-commit.com/) for a consistent development environment.

```bash
# 1. Install direnv (if not already installed)
# Ubuntu/Debian: sudo apt install direnv
# macOS: brew install direnv

# 2. Allow direnv for this project
direnv allow

# 3. Install pre-commit hooks
uv sync --group dev
pre-commit install
pre-commit install --hook-type commit-msg
```

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Description |
|--------|-------------|
| `feat:` | New features |
| `fix:` | Bug fixes |
| `docs:` | Documentation changes |
| `refactor:` | Code refactoring |
| `test:` | Adding tests |
| `chore:` | Maintenance tasks |
| `style:` | Code formatting |

## Pre-commit Hooks

The following hooks run automatically on commit:

| Hook | Purpose |
|------|---------|
| `shellcheck` | Shell script linting |
| `shfmt` | Shell script formatting |
| `flake8` | Python linting |
| `yamllint` | YAML validation |
| `markdownlint` | Markdown formatting |
| `gitleaks` | Secret detection |
| `commitizen` | Conventional commit messages |

## Code Style

- **Shell scripts**: Follow shellcheck recommendations, use shfmt formatting
- **Python**: Follow PEP 8, use flake8 for linting
- **YAML**: Use 2-space indentation
- **Markdown**: Follow markdownlint rules

## Testing

Run tests before submitting:

```bash
./tests/run-tests.sh
```

## License

All contributions must respect the [CC BY-NC-SA 4.0](LICENSE) license.

## Questions?

Open an issue for any questions or concerns.
