# Open Source Ready Check

Verifie si le projet est pret a etre publie en open source et propose de creer les fichiers manquants.

## Arguments

| Argument | Description |
|----------|-------------|
| (aucun) | Analyse complete avec rapport |
| `--fix` | Analyse + creation des fichiers manquants |
| `--security` | Focus sur les verifications de securite |
| `--docs` | Focus sur la documentation |

---

## PHASE 1 : DETECTION DU TYPE DE PROJET

Identifier automatiquement le type de projet :

```bash
# Detecter les fichiers de configuration
ls -la
```

| Fichier detecte | Type de projet |
|-----------------|----------------|
| `ansible.cfg` | Ansible/Infrastructure |
| `package.json` | Node.js |
| `pyproject.toml` ou `requirements.txt` + `*.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `terraform/*.tf` | Terraform |

Adapter les verifications selon le type detecte.

---

## PHASE 2 : DOCUMENTATION (25 points)

### 2.1 Fichiers essentiels

| Fichier | Points | Description | Obligatoire |
|---------|--------|-------------|-------------|
| `README.md` | 5 | Documentation principale | Oui |
| `LICENSE` | 5 | Licence du projet | Oui |
| `CONTRIBUTING.md` | 4 | Guide de contribution | Recommande |
| `CODE_OF_CONDUCT.md` | 3 | Code de conduite | Recommande |
| `CHANGELOG.md` | 3 | Historique des versions | Recommande |
| `SECURITY.md` | 3 | Politique de securite | Recommande |
| `CLAUDE.md` | 2 | Contexte pour Claude Code | Optionnel |

### 2.2 Qualite du README

Verifier la presence des sections :

| Section | Points |
|---------|--------|
| Description/Overview | 1 |
| Installation/Quick Start | 1 |
| Usage/Configuration | 1 |
| Prerequisites | 1 |
| Contributing | 1 |
| License mention | 1 |

### 2.3 Verification

```bash
# Fichiers de documentation
ls README.md LICENSE CONTRIBUTING.md CODE_OF_CONDUCT.md CHANGELOG.md SECURITY.md 2>/dev/null
```

---

## PHASE 3 : SECURITE (25 points)

### 3.1 Scan des secrets dans le code

Patterns a detecter :

```
# API Keys
[A-Za-z0-9_]{20,}
api[_-]?key
secret[_-]?key
access[_-]?token

# Passwords
password\s*=\s*["'][^"']+["']
passwd\s*=
pwd\s*=

# AWS
AKIA[0-9A-Z]{16}
aws[_-]?secret

# Tokens
bearer\s+[A-Za-z0-9\-._~+/]+=*
token\s*=\s*["'][^"']+["']

# Private keys
-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----
```

### 3.2 Scan de l'historique git

```bash
# Rechercher des secrets dans l'historique
git log -p --all | grep -iE "(password|secret|api.?key|token)" | head -20
```

### 3.3 Verification .gitignore

Fichiers sensibles qui doivent etre ignores :

| Pattern | Description |
|---------|-------------|
| `.env` | Variables d'environnement |
| `*.pem` | Cles privees |
| `*.key` | Cles privees |
| `*credentials*` | Fichiers de credentials |
| `*secret*` | Fichiers secrets |
| `.vault_password` | Mot de passe Ansible Vault |
| `*.tfstate` | Etat Terraform |
| `*.tfvars` | Variables Terraform sensibles |

### 3.4 Verification Ansible Vault (si applicable)

```bash
# Verifier que les fichiers vault sont chiffres
for f in $(find . -path "*/vault/*" -name "*.yml"); do
  head -1 "$f" | grep -q "^\$ANSIBLE_VAULT" || echo "NON CHIFFRE: $f"
done
```

### 3.5 Scoring securite

| Verification | Points |
|--------------|--------|
| Pas de secrets dans le code | 8 |
| Pas de secrets dans l'historique git | 5 |
| .gitignore complet | 5 |
| Fichiers vault chiffres | 4 |
| SECURITY.md present | 3 |

---

## PHASE 4 : GITHUB/GIT (20 points)

### 4.1 Templates GitHub

Verifier la presence de `.github/` :

| Fichier | Points | Description |
|---------|--------|-------------|
| `.github/ISSUE_TEMPLATE/bug_report.md` | 3 | Template bug |
| `.github/ISSUE_TEMPLATE/feature_request.md` | 3 | Template feature |
| `.github/PULL_REQUEST_TEMPLATE.md` | 3 | Template PR |
| `.github/CODEOWNERS` | 2 | Proprietaires du code |
| `.github/FUNDING.yml` | 1 | Sponsors |
| `.github/dependabot.yml` | 2 | Mises a jour auto |

### 4.2 GitHub Actions (CI/CD)

| Fichier | Points | Description |
|---------|--------|-------------|
| `.github/workflows/ci.yml` | 3 | Integration continue |
| `.github/workflows/release.yml` | 2 | Release automatique |

### 4.3 Configuration git

```bash
# Verifier .gitignore
test -f .gitignore && echo "OK" || echo "MANQUANT"

# Verifier .gitattributes
test -f .gitattributes && echo "OK" || echo "MANQUANT"
```

---

## PHASE 5 : QUALITE DU CODE (20 points)

### 5.1 Linters et formatters

| Outil | Points | Verification |
|-------|--------|--------------|
| Pre-commit configure | 5 | `.pre-commit-config.yaml` existe |
| Linters passent | 5 | `pre-commit run --all-files` |
| EditorConfig | 2 | `.editorconfig` existe |

### 5.2 Tests (si applicable)

| Element | Points |
|---------|--------|
| Tests presents | 3 |
| Tests passent | 3 |
| Couverture > 50% | 2 |

### 5.3 Verification Ansible (si applicable)

```bash
# Syntaxe des playbooks
ansible-playbook deploy.yml --syntax-check
ansible-playbook uninstall.yml --syntax-check

# Ansible-lint
ansible-lint
```

---

## PHASE 6 : METADONNEES (10 points)

### 6.1 Informations du projet

| Element | Points | Verification |
|---------|--------|--------------|
| Description dans README | 2 | Premiere section claire |
| Version definie | 2 | Tag git ou fichier version |
| Auteur/Maintainer | 2 | Dans README ou package |
| URL du repo | 2 | Dans README |
| Badges | 2 | Status, license, version |

---

## PHASE 7 : RAPPORT ET SCORING

### Format du rapport

```
Open Source Ready Check
=======================

Projet : {nom}
Type   : {type detecte}
Date   : {date}

SCORE GLOBAL : {X}/100 - {STATUT}

Statuts :
  90-100 : READY        - Pret pour publication
  70-89  : ALMOST READY - Quelques ajustements
  50-69  : NEEDS WORK   - Travail necessaire
  0-49   : NOT READY    - Non pret

+---------------------------------------------------------------+
| DOCUMENTATION (25 points)                         Score: XX/25|
+---------------------------------------------------------------+
| [X] README.md                                    +5           |
| [X] LICENSE                                      +5           |
| [ ] CONTRIBUTING.md                              +0 (manquant)|
| [ ] CODE_OF_CONDUCT.md                           +0 (manquant)|
| [ ] CHANGELOG.md                                 +0 (manquant)|
| [ ] SECURITY.md                                  +0 (manquant)|
+---------------------------------------------------------------+

+---------------------------------------------------------------+
| SECURITE (25 points)                              Score: XX/25|
+---------------------------------------------------------------+
| [X] Pas de secrets dans le code                  +8           |
| [X] Pas de secrets dans l'historique             +5           |
| [X] .gitignore complet                           +5           |
| [X] Fichiers vault chiffres                      +4           |
| [ ] SECURITY.md present                          +0 (manquant)|
+---------------------------------------------------------------+

+---------------------------------------------------------------+
| GITHUB/GIT (20 points)                            Score: XX/20|
+---------------------------------------------------------------+
| [ ] .github/ISSUE_TEMPLATE/                      +0 (manquant)|
| [ ] .github/PULL_REQUEST_TEMPLATE.md             +0 (manquant)|
| [ ] .github/workflows/                           +0 (manquant)|
| [X] .gitignore                                   +3           |
+---------------------------------------------------------------+

+---------------------------------------------------------------+
| QUALITE (20 points)                               Score: XX/20|
+---------------------------------------------------------------+
| [X] Pre-commit configure                         +5           |
| [X] Linters passent                              +5           |
| [ ] .editorconfig                                +0 (manquant)|
+---------------------------------------------------------------+

+---------------------------------------------------------------+
| METADONNEES (10 points)                           Score: XX/10|
+---------------------------------------------------------------+
| [X] Description                                  +2           |
| [X] Auteur                                       +2           |
| [X] URL repo                                     +2           |
| [X] Badges                                       +2           |
+---------------------------------------------------------------+

================================================================

FICHIERS MANQUANTS
------------------
1. CONTRIBUTING.md
2. CODE_OF_CONDUCT.md
3. CHANGELOG.md
4. SECURITY.md
5. .github/ISSUE_TEMPLATE/bug_report.md
6. .github/ISSUE_TEMPLATE/feature_request.md
7. .github/PULL_REQUEST_TEMPLATE.md
8. .editorconfig

ACTIONS RECOMMANDEES
--------------------
1. [CRITIQUE] Creer SECURITY.md
2. [IMPORTANT] Creer les templates GitHub
3. [MINEUR] Ajouter .editorconfig

Creer les fichiers manquants ? (oui/non)
```

---

## PHASE 8 : CREATION DES FICHIERS MANQUANTS

Si `--fix` ou confirmation, creer les fichiers avec des templates adaptes.

### 8.1 CONTRIBUTING.md

```markdown
# Contributing to {PROJECT_NAME}

Thank you for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

## Code Style

- Run `pre-commit run --all-files` before committing
- Follow existing code patterns

## Questions?

Open an issue for any questions or concerns.
```

### 8.2 CODE_OF_CONDUCT.md

```markdown
# Code of Conduct

## Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

## Our Standards

Examples of behavior that contributes to a positive environment:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:

- Trolling, insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other conduct which could be considered inappropriate

## Enforcement

Instances of abusive behavior may be reported to the project maintainers.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org/).
```

### 8.3 SECURITY.md

```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please:

1. **Do not** open a public issue
2. Email the maintainers directly
3. Include details about the vulnerability
4. Allow time for a fix before public disclosure

We take security seriously and will respond promptly.
```

### 8.4 CHANGELOG.md

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Initial release

### Changed

### Fixed

### Removed
```

### 8.5 .github/ISSUE_TEMPLATE/bug_report.md

```markdown
---
name: Bug Report
about: Report a bug to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Describe the Bug

A clear and concise description of the bug.

## To Reproduce

Steps to reproduce the behavior:
1. Run '...'
2. See error

## Expected Behavior

What you expected to happen.

## Environment

- OS: [e.g., Ubuntu 22.04]
- Version: [e.g., 1.0.0]

## Additional Context

Any other context about the problem.
```

### 8.6 .github/ISSUE_TEMPLATE/feature_request.md

```markdown
---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Is your feature request related to a problem?

A clear description of the problem.

## Describe the solution you'd like

A clear description of what you want to happen.

## Describe alternatives you've considered

Any alternative solutions or features you've considered.

## Additional context

Any other context or screenshots about the feature request.
```

### 8.7 .github/PULL_REQUEST_TEMPLATE.md

```markdown
## Description

Brief description of the changes.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist

- [ ] I have read the CONTRIBUTING guide
- [ ] My code follows the project's style guidelines
- [ ] I have tested my changes
- [ ] I have updated the documentation if needed

## Related Issues

Fixes #(issue number)
```

### 8.8 .editorconfig

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.yml]
indent_size = 2

[*.py]
indent_size = 4

[*.sh]
indent_style = tab

[Makefile]
indent_style = tab
```

### 8.9 .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install uv
        uses: astral-sh/setup-uv@v5

      - name: Install dependencies
        run: uv sync --group dev

      - name: Run pre-commit
        run: uv run pre-commit run --all-files

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: ./tests/run-tests.sh
```

---

## NOTES

- Toujours demander confirmation avant de creer des fichiers
- Adapter les templates au contexte du projet
- Le scoring est indicatif, certains elements peuvent etre optionnels selon le projet
- Verifier les licences des dependances pour compatibilite
