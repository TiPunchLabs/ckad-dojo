# Architecture

**Langue :** [English (par défaut)](architecture.md) | Français

> **Prérequis** : lire le README.md pour le contexte fonctionnel du projet.

## Modèle mental

```
                        Utilisateur
                       /           \
                      /             \
              [CLI Python]      [Navigateur]
              ckad_dojo.py          |
                   |           web/server.py ── index.html + app.js
                   |                |
              subprocess        subprocess
                   |                |
              scripts/ckad-*.sh ◄───┘
                   |
            ┌──────┼──────┐
            │      │      │
         kubectl  helm  docker
            │
      Cluster Kubernetes
```

Le projet suit une **architecture en couches** :

1. **Couche présentation** : CLI Python interactive ou interface web
2. **Couche orchestration** : scripts Bash qui exécutent le cycle de vie de l'examen
3. **Couche infrastructure** : kubectl, helm, docker pour les opérations K8s

------

## Composants principaux

### CLI Python (`ckad_dojo.py`)

Point d'entrée principal. Fournit un menu interactif et des sous-commandes
(`exam start`, `score`, `cleanup`, `list`, `info`, `status`, `completion`).

C'est un **orchestrateur léger** : il ne contient aucune logique métier mais
délègue toutes les opérations aux scripts Bash via `subprocess.run()`.

```
ckad_dojo.py
  ├── Menu interactif (mode sans argument)
  ├── Sous-commandes argparse + argcomplete
  └── run_script() ──> scripts/ckad-*.sh
```

### Serveur web (`web/server.py`)

Serveur HTTP de la bibliothèque standard Python (`http.server`) sans framework externe.
Lancé par `ckad-exam.sh` en mode web. Écoute sur `localhost:9090`.

**Responsabilités** :

- Sert les fichiers statiques (`index.html`, `app.js`, `style.css`)
- Expose une API REST JSON pour le frontend
- Gère le timer de l'examen en mémoire
- Exécute le scoring et le nettoyage via subprocess

**Endpoints principaux** :

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/exams` | Liste des examens disponibles |
| GET | `/api/exam/{id}/questions` | Questions parsées depuis `questions.md` |
| GET | `/api/exam/{id}/config` | Configuration de l'examen |
| GET | `/api/exam/{id}/solutions` | Solutions (après l'examen) |
| GET | `/api/timer` | État du timer |
| POST | `/api/score` | Arrête le timer + lance le scoring |
| POST | `/api/cleanup` | Lance le nettoyage |
| POST | `/api/shutdown` | Arrêt propre du serveur |

### Frontend (`web/`)

Application JavaScript vanilla (ES6+) sans framework.

- **Rendu Markdown** : `marked.js` + `highlight.js` pour les questions et les solutions
- **Icônes** : Lucide
- **Interface** : panneau des questions (à gauche) + terminal ttyd intégré (à droite, iframe)
- **Fonctionnalités** : navigation entre les questions, timer, marque-pages (flags), thème sombre/clair, raccourcis clavier, fenêtre modale de score avec le détail par critère

### Scripts Bash (`scripts/`)

Cœur opérationnel du projet. Quatre scripts principaux + des bibliothèques partagées.

```
scripts/
  ├── ckad-setup.sh          # Préparation de l'environnement K8s
  ├── ckad-exam.sh           # Lancement de l'examen (web ou terminal)
  ├── ckad-score.sh          # Évaluation des réponses
  ├── ckad-cleanup.sh        # Nettoyage de l'environnement
  └── lib/
      ├── common.sh          # Utilitaires (couleurs, helpers kubectl, ttyd, état)
      ├── setup-functions.sh # Fonctions de setup et de nettoyage
      ├── timer.sh           # Timer à base de fichiers (PID, état, compte à rebours)
      └── banner.sh          # Bannière ASCII pour le terminal
```

------

## Cycle de vie d'un examen

```
 1. SETUP                2. EXAM                 3. SCORE               4. CLEANUP
 ckad-setup.sh           ckad-exam.sh            ckad-score.sh          ckad-cleanup.sh
 ┌──────────────┐        ┌──────────────┐        ┌──────────────┐       ┌──────────────┐
 │ Créer NS     │        │ Lancer ttyd  │        │ Charger      │       │ Arrêter timer│
 │ Déployer     │───────>│ Lancer       │───────>│  scoring-    │──────>│ Désinstaller │
 │  manifests   │        │  server.py   │        │  functions   │       │  Helm        │
 │ Copier       │        │ Ouvrir le    │        │ Évaluer      │       │ Suppr. NS    │
 │  templates   │        │  navigateur  │        │  score_q1()  │       │ Suppr. PV    │
 │ Registry     │        │              │        │  ...         │       │ Suppr.       │
 │ Helm charts  │        │              │        │  score_qN()  │       │  registry    │
 │ Post-setup * │        │              │        │ Afficher     │       │ Nettoyer     │
 │              │        │              │        │  résultats   │       │  Docker      │
 └──────────────┘        └──────────────┘        └──────────────┘       └──────────────┘
        │                                                                       │
        └── État sauvegardé dans /tmp/ckad-dojo/active-exam.state ──────────────┘
```

\* **Post-setup** : après l'application de la logique partagée (release Helm cassée), `setup_post_resources()` source
`exams/{exam-id}/post-setup.sh` s'il existe et appelle la fonction `exam_post_setup()`. Cela permet
à chaque examen de définir sa propre initialisation en plusieurs étapes (par exemple créer des révisions de Deployment cassées pour
des exercices de rollback) sans modifier le fichier partagé `setup-functions.sh`.

------

## Structure d'un examen

Chaque examen est un répertoire autonome sous `exams/{exam-id}/` :

```
exams/ckad-simulation1/
  ├── exam.conf              # Configuration (durée, points, namespaces, options)
  ├── questions.md           # Questions en Markdown avec table de métadonnées
  ├── solutions.md           # Solutions pour la revue après l'examen
  ├── scoring-functions.sh   # Fonctions Bash : score_q1(), score_q2(), ...
  ├── post-setup.sh          # Post-setup optionnel propre à l'examen (sourcé par setup-functions.sh)
  ├── manifests/
  │   └── setup/
  │       ├── namespaces.yaml    # Définitions des namespaces
  │       └── *.yaml             # Ressources K8s préexistantes
  └── templates/
      ├── q01-file.yaml          # Fichiers copiés dans exam/course/N/
      └── q11-image/             # Répertoires (Dockerfile, etc.)
```

**Variables clés de `exam.conf`** :

| Variable | Description |
|----------|-------------|
| `EXAM_NAME` | Nom affiché |
| `EXAM_DURATION` | Durée en minutes |
| `TOTAL_QUESTIONS` / `TOTAL_POINTS` | Dimensions de l'examen |
| `PASSING_PERCENTAGE` | Seuil de réussite (66% par défaut) |
| `EXAM_NAMESPACES=()` | Tableau des namespaces à créer |
| `HELM_RELEASES=()` | Releases Helm à installer |
| `ALLOW_TIMER_PAUSE` | Autoriser la pause du timer |
| `ALLOW_HINTS` | Autoriser les indices |
| `DOJO_NAME` / `DOJO_EMOJI` | Identité thématique du dojo |

------

## Mécanisme de scoring

```
scoring-functions.sh                    web/server.py
┌─────────────────────┐                ┌──────────────────────┐
│ score_q1() {        │   stdout       │ run_scoring_script() │
│   # kubectl checks  │ ──────────────>│   parse output:      │
│   echo "2/3"        │                │   - regex Q(\d+)     │
│   echo "DETAILS:..."│                │   - regex TOTAL      │
│ }                   │                │   - parse DETAILS:   │
└─────────────────────┘                │   return JSON        │
                                       └──────────────────────┘
```

Chaque fonction `score_qN()` :

1. Vérifie les ressources K8s via des helpers (`resource_exists`, `get_resource_field`)
2. Affiche des marqueurs de réussite/échec (coche/croix) pour chaque critère
3. Renvoie `score/max_points` sur stdout
4. Renvoie `DETAILS:item1. item2.` pour le détail des critères

Le serveur web parse cette sortie avec des expressions régulières et construit une réponse JSON
structurée pour l'interface.

------

## Intégrations externes

| Outil | Rôle | Utilisation |
|-------|------|-------------|
| **kubectl** | Opérations K8s | Setup (create/apply), scoring (get/describe), nettoyage (delete) |
| **helm** | Helm charts | Installation des releases pour les questions liées à Helm |
| **docker** | Registry local | `registry:2` sur `localhost:5000` pour les questions de build |
| **ttyd** | Terminal web | Intégré à l'interface via une iframe sur le port 7682 |
| **uv** | Gestionnaire Python (Python 3.12+) | Exécute le serveur, les tests et le linting |

------

## Infrastructure de tests

### Tests Bash (`tests/`)

Framework de test maison (`test-framework.sh`) avec des assertions :

```
tests/
  ├── run-tests.sh            # Runner : exécute tous les fichiers test-*.sh
  ├── test-framework.sh       # Assertions (assert_true, assert_equals, ...)
  ├── test-common.sh          # Tests de scripts/lib/common.sh
  ├── test-setup-functions.sh # Tests de scripts/lib/setup-functions.sh
  ├── test-timer.sh           # Tests de scripts/lib/timer.sh
  ├── test-banner.sh          # Tests de scripts/lib/banner.sh
  └── test-scoring.sh         # Tests des fonctions de scoring
```

### Tests Python (`tests/python/`)

57 tests unitaires via pytest + pytest-cov :

| Module | Couverture |
|--------|------------|
| `ckad_dojo.py` | CLI, parsing de la configuration, découverte des examens |
| `web/server.py` | Parsing, configuration, questions, solutions |
| `scripts/bump-version.py` | Validation, lecture de la version, mise à jour des fichiers |

### Pipeline CI (`.github/workflows/ci.yml`)

```
  Étape 1          Étape 2              Étape 3
 ┌──────┐     ┌──────┐  ┌──────┐     ┌──────┐
 │ Lint │────>│ Test │  │Secu. │────>│Build │
 │      │     │      │  │      │     │      │
 └──────┘     └──────┘  └──────┘     └──────┘
                 │           │
             parallèle   parallèle
```

- **Lint** : `pre-commit run --all-files` (ruff, shellcheck, mypy, markdownlint, etc.)
- **Test** : tests Bash + pytest avec couverture
- **Security** : `pip-audit` + `gitleaks`
- **Build** : `uv build` + envoi des artefacts

------

## Décisions techniques

| Décision | Justification |
|----------|---------------|
| Bibliothèque standard Python uniquement (serveur) | Zéro dépendance externe, déploiement simple |
| Bash pour la logique métier | Interaction directe avec kubectl/helm/docker sans couche d'abstraction |
| CLI Python comme orchestrateur | Ergonomie (argparse, complétion, menu interactif) sans dupliquer la logique |
| Timer en mémoire (serveur) | Simplicité, aucune persistance nécessaire pour un examen éphémère |
| Examens autonomes | Chaque dojo est un répertoire indépendant, ce qui facilite l'ajout de nouveaux examens |
| Frontend en JS vanilla | Pas d'étape de build, chargement direct, dépendances CDN minimales |

------

> **Document créé le** : 2026-02-17
> **Version** : 1.0
