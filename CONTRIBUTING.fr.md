# Contribuer à ckad-dojo

**Langue :** [English (par défaut)](CONTRIBUTING.md) | Français

Merci de l'intérêt que vous portez à ckad-dojo !

## Comment contribuer

### Signaler un bug

Vous avez trouvé un bug ? [Ouvrez une issue](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=bug_report.md) en indiquant :

- Une description claire du problème
- Les étapes pour le reproduire
- Le comportement attendu et le comportement observé
- Votre environnement (OS, version de kubectl, etc.)

### Proposer une amélioration

Vous avez une idée ? [Créez une demande de fonctionnalité](https://github.com/TiPunchLabs/ckad-dojo/issues/new?template=feature_request.md) en indiquant :

- La description de la fonctionnalité proposée
- Le cas d'usage et ses bénéfices
- Des pistes d'implémentation (facultatif)

### Soumettre une pull request

1. Forkez le dépôt
2. Créez une branche de fonctionnalité (`git checkout -b feature/my-feature`)
3. Apportez vos modifications
4. Testez vos modifications (`./tests/run-tests.sh`)
5. Lancez les vérifications pre-commit (`pre-commit run --all-files`)
6. Committez avec un [message conventionnel](https://www.conventionalcommits.org/)
7. Ouvrez une pull request

### Contributions assistées par agent

Les mainteneurs peuvent confier une modification à Claude Code, avec une revue indépendante par Codex.
Ce workflow, ses fichiers de mission et ses garde-fous sont décrits dans
[docs/agent-workflow.fr.md](docs/agent-workflow.fr.md). Il ne change pas les étapes
ci-dessus pour les autres contributeurs.

## Langues de la documentation

La documentation est maintenue en anglais et en français. L'anglais est la langue
par défaut et la référence canonique.

- Les fichiers sans suffixe (`README.md`, `docs/architecture.md`, …) sont en anglais.
  La traduction française se trouve dans le même répertoire, avec le suffixe `.fr.md`
  (`README.fr.md`, `docs/architecture.fr.md`).
- Ajouter un document, ou le modifier de façon substantielle, met à jour les deux
  versions linguistiques dans la même pull request.
- Chaque paire conserve son sélecteur de langue en haut du document, l'anglais en
  premier, avec un lien vers l'équivalent exact.
- Les liens relatifs et les ancres de section doivent fonctionner dans les deux
  langues. Les titres français produisent des ancres françaises : tenez les tables
  des matières et les liens vers des sections des documents français à jour en conséquence.
- Les points d'entrée par défaut (la page d'accueil du dépôt, les liens depuis les
  documents anglais) restent en anglais. Dans un document français, les liens
  pointent vers l'équivalent français s'il existe, sinon vers le fichier anglais.
- Quand les deux versions divergent, la version anglaise fait foi : corrigez la version française.
- Les traductions des instructions destinées aux agents (`CLAUDE.fr.md`, `AGENTS.fr.md`,
  `docs/agent-workflow.fr.md`) sont des documents de référence pour les lecteurs. Les
  agents suivent uniquement les fichiers anglais `CLAUDE.md`, `AGENTS.md` et `docs/agent-workflow.md`.
- Non traduits : `LICENSE`, `CHANGELOG.md`, les modèles d'issue et de pull request
  GitHub, le contenu des examens (`exams/`) et les archives `specs/`.

## Environnement de développement

Ce projet utilise [direnv](https://direnv.net/) et [pre-commit](https://pre-commit.com/) pour garantir un environnement de développement homogène. Il requiert Python 3.12+, que `uv` installe à la demande.

```bash
# 1. Installer direnv (s'il n'est pas déjà installé)
# Ubuntu/Debian: sudo apt install direnv
# macOS: brew install direnv

# 2. Autoriser direnv pour ce projet
direnv allow

# 3. Installer les hooks pre-commit
uv sync --group dev
uv run pre-commit install
uv run pre-commit install --hook-type commit-msg
```

> 💡 **Note** : si votre `.venv` a été créé avec Python 3.10 ou 3.11, `uv sync` le recrée avec un interpréteur compatible. Si `uv` n'en trouve aucun, lancez d'abord `uv python install 3.12` (ou installez Python 3.12+ avec le gestionnaire de paquets de votre système si les téléchargements sont en mode `never`).

## Convention de commit

Nous utilisons les [Conventional Commits](https://www.conventionalcommits.org/) :

| Préfixe | Description |
|---------|-------------|
| `feat:` | Nouvelles fonctionnalités |
| `fix:` | Corrections de bugs |
| `docs:` | Modifications de la documentation |
| `refactor:` | Refactorisation du code |
| `test:` | Ajout de tests |
| `chore:` | Tâches de maintenance |
| `style:` | Mise en forme du code |

## Hooks pre-commit

Les hooks suivants s'exécutent automatiquement à chaque commit :

| Hook | Rôle |
|------|------|
| `shellcheck` | Analyse statique des scripts shell |
| `shfmt` | Mise en forme des scripts shell |
| `flake8` | Analyse statique du code Python |
| `yamllint` | Validation YAML |
| `markdownlint` | Mise en forme Markdown |
| `gitleaks` | Détection de secrets |
| `commitizen` | Messages de commit conventionnels |

## Style de code

- **Scripts shell** : suivez les recommandations de shellcheck, formatez avec shfmt
- **Python** : suivez la PEP 8, utilisez flake8 pour l'analyse statique
- **YAML** : indentation de 2 espaces
- **Markdown** : respectez les règles de markdownlint

## Tests

Lancez les tests avant de soumettre :

```bash
./tests/run-tests.sh
```

## Licence

Toute contribution doit respecter la licence [CC BY-NC-SA 4.0](LICENSE) (texte en anglais).

## Des questions ?

Ouvrez une issue pour toute question ou remarque.
