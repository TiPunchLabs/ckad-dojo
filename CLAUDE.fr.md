# ckad-dojo — instructions pour Claude Code

**Langue :** [English (par défaut)](CLAUDE.md) | Français

> ⚠️ **Traduction de référence** : ce document traduit [`CLAUDE.md`](CLAUDE.md) pour les lecteurs francophones. Il ne fait pas autorité : Claude Code suit uniquement la version anglaise, qui prévaut en cas de divergence.

Point d'entrée d'une session Claude Code dans ce dépôt. Documentation destinée
aux humains : [`README.fr.md`](README.fr.md), [`CONTRIBUTING.fr.md`](CONTRIBUTING.fr.md),
[`docs/architecture.fr.md`](docs/architecture.fr.md), ADR dans [`docs/adr/`](docs/adr/).
Quand ce fichier et le code divergent, le code l'emporte : corrigez les deux.

## Votre rôle

Pour un objectif donné par le propriétaire, Claude Code est le **seul orchestrateur
et le seul implémenteur** : il inspecte, cadre, travaille dans un worktree, lance
les vérifications, obtient une review indépendante de Codex via Herdr, corrige les
constats et remet un rapport. Le propriétaire décide du merge, du déploiement et
de chaque prompt de confiance ou de permission.

Lisez [`docs/agent-workflow.fr.md`](docs/agent-workflow.fr.md) au début de chaque
mission : il décrit les fichiers de mission, les commandes Herdr et Codex
vérifiées, les cycles de correction et la manière de reprendre. Les instructions
de Codex se trouvent dans [`AGENTS.fr.md`](AGENTS.fr.md).

## Organisation du dépôt

```text
ckad_dojo.py              CLI (uv run ckad-dojo) : list, info, exam start|stop, setup, score, cleanup, status, completion
web/                      interface web d'examen : server.py (bibliothèque standard Python uniquement) + JS/CSS vanilla
scripts/                  logique métier en Bash : ckad-setup.sh, ckad-exam.sh, ckad-score.sh, ckad-cleanup.sh
scripts/lib/              Bash partagé : common, setup-functions, scoring-functions, timer, banner
exams/<exam-id>/          examens autonomes : exam.conf, questions.md, solutions.md, scoring-functions.sh, manifests/, templates/
manifests/setup/, templates/   manifests et templates de setup partagés
tests/                    suites Bash (run-tests.sh, test-*.sh) et tests/python/ (pytest)
docs/                     architecture, ADR, programme CKAD, workflow agent
specs/                    spécifications historiques des fonctionnalités (référence en lecture seule)
.github/                  CI, templates d'issue et de PR, Dependabot, Scorecard
```

Les décisions de conception sont consignées dans des ADR (serveur web limité à la
bibliothèque standard, Bash pour la logique métier, JS vanilla, examens autonomes,
CLI Python comme orchestrateur, minuteur en mémoire). Lisez l'ADR correspondant
avant de modifier l'un de ces domaines.

Les examens ignorés par `.gitignore` sont strictement locaux : ne jamais les
nommer ni copier leur contenu dans un fichier suivi, un message de commit, une PR
ou une issue.

## Vérifications

| Changement | Vérifications |
|---|---|
| Tout changement | `git add` des fichiers, puis `uv run pre-commit run --files <files>` ; `git diff --check`, puis `git diff --check <base>...HEAD` après le commit |
| Documentation | ce qui précède, plus la vérification de chaque lien relatif, de chaque ancre et de chaque commande citée ; les versions anglaise et française (`*.fr.md`) mises à jour ensemble ([langues de la documentation](CONTRIBUTING.fr.md#langues-de-la-documentation)) |
| Bash | `./tests/run-tests.sh` |
| Python | `uv run pytest --cov --cov-report=term-missing` |
| Parité avec la CI | `uv sync --group dev && uv run pre-commit run --all-files` |

Hooks : ruff, mypy, shellcheck, shfmt, yamllint, actionlint, markdownlint,
codespell, gitleaks et commitizen (message de commit). Ils sont installés dans le
checkout principal et s'exécutent dans chaque worktree. Ne jamais les contourner
ni les affaiblir (`--no-verify`, `SKIP=`, modification de configuration) pour
passer.

Rapportez séparément les vérifications de documentation, les tests Bash, les
tests Python et l'intégration Kubernetes, chacun en `VERIFIED`, `NOT_VERIFIED` ou
`NOT_APPLICABLE` avec sa preuve ou sa justification. Les suites Bash et Python de
la CI tournent sans cluster ; elles ne prouvent pas le comportement sur un
cluster.

## Règles Git

- GitHub Flow : une branche par changement à partir de `origin/main`, dans un
  worktree sous `../ckad-dojo-worktrees/<slug>`. Ne jamais commiter sur `main`,
  ne jamais pousser vers `main`.
- Conventional Commits (imposé par commitizen). Utilisez `git switch`, pas
  `git checkout`.
- Commit, push et PR uniquement quand l'objectif les autorise. Les PR sont des
  drafts ciblant `main`. Le merge est toujours la décision du propriétaire ;
  aucune automatisation ne merge ni ne publie.
- Le checkout principal peut contenir le travail du propriétaire : fichiers non
  commités ou non suivis, fichiers locaux ignorés et stashes. Ne jamais le
  modifier, le stager, le stasher, le réinitialiser, le nettoyer ni changer sa
  branche. Pas de `git reset --hard`, `git clean`, `git checkout -- <path>`,
  `rm -rf`.
- Les artefacts de mission restent hors de Git, dans
  `$XDG_DATA_HOME/ckad-dojo-agent/<mission-id>/` (par défaut
  `~/.local/share/...`). Ce dépôt est public.
- Aucun secret, token, contenu de kubeconfig ni donnée de `Secret` Kubernetes
  dans un fichier, un commit, une PR, une issue ou un artefact local.
- Ne modifiez pas la configuration globale de la machine (`~/.codex`,
  `~/.claude`, profils de shell) dans le cadre d'une mission.

## Règles Kubernetes

Toute commande qui atteint un cluster est interdite, sauf si l'objectif
l'autorise explicitement :

- `kubectl`, `helm`, et toute sous-commande `ckad-dojo` autre que `list`, `info`
  et `completion` (menu interactif compris) ;
- `scripts/ckad-setup.sh`, `ckad-exam.sh`, `ckad-score.sh`, `ckad-cleanup.sh` et
  tout setup, réinitialisation ou nettoyage d'examen. Certains chemins de
  nettoyage suppriment des ressources dans `default` ou au niveau du cluster.

Quand une mission est autorisée à modifier un cluster :

1. Le propriétaire nomme le kube context et confirme qu'il s'agit d'un cluster
   **dédié et jetable**. Consignez les deux dans `prompt.md`.
2. Vérifiez le contexte avant toute commande (`kubectl config get-contexts`, les
   nœuds du cluster) et arrêtez-vous s'il ne correspond pas.
3. Passez le contexte explicitement à chaque commande (`kubectl --context <ctx>`,
   `helm --kube-context <ctx>`) ; ne vous fiez jamais au contexte courant.
4. Un namespace dédié ne suffit pas : les objets au niveau du cluster
   (namespaces, ClusterRoles, CRD, PersistentVolumes) et le namespace `default`
   sont partagés.
5. Si la cible devient incertaine à un moment quelconque, arrêtez toute opération
   sur le cluster et consignez le blocage dans `mission.md`.

Un accès en lecture seule (`status`, `score`, `kubectl get`) reste un accès au
cluster et suit les mêmes règles. Codex n'a jamais accès à un cluster.
