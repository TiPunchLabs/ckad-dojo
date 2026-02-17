# Architecture

> **Prerequis** : Lecture du README.md pour le contexte fonctionnel du projet.

## Mental Model

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

Le projet suit une architecture en **couches** :

1. **Couche presentation** : CLI Python interactive ou interface web
2. **Couche orchestration** : scripts Bash qui executent le cycle de vie
3. **Couche infrastructure** : kubectl, helm, docker pour les operations K8s

------

## Composants principaux

### CLI Python (`ckad_dojo.py`)

Point d'entree principal. Fournit un menu interactif et des sous-commandes
(`exam start`, `score`, `cleanup`, `list`, `info`, `status`, `completion`).

C'est un **orchestrateur leger** : il ne contient pas de logique metier mais
delegue toutes les operations aux scripts Bash via `subprocess.run()`.

```
ckad_dojo.py
  ├── Menu interactif (mode sans arguments)
  ├── Sous-commandes argparse + argcomplete
  └── run_script() ──> scripts/ckad-*.sh
```

### Serveur web (`web/server.py`)

Serveur HTTP Python standard library (`http.server`) sans framework externe.
Lance par `ckad-exam.sh` en mode web. Ecoute sur `localhost:9090`.

**Roles** :

- Sert les fichiers statiques (`index.html`, `app.js`, `style.css`)
- Expose une API REST JSON pour le frontend
- Gere le timer d'examen en memoire
- Execute le scoring et le cleanup via subprocess

**Endpoints principaux** :

| Methode | Route | Description |
|---------|-------|-------------|
| GET | `/api/exams` | Liste des examens disponibles |
| GET | `/api/exam/{id}/questions` | Questions parsees depuis `questions.md` |
| GET | `/api/exam/{id}/config` | Configuration de l'examen |
| GET | `/api/exam/{id}/solutions` | Solutions (post-examen) |
| GET | `/api/timer` | Etat du timer |
| POST | `/api/score` | Arrete le timer + lance le scoring |
| POST | `/api/cleanup` | Execute le nettoyage |
| POST | `/api/shutdown` | Arret du serveur |

### Frontend (`web/`)

Application JavaScript vanilla (ES6+) sans framework.

- **Rendu Markdown** : `marked.js` + `highlight.js` pour les questions et solutions
- **Icones** : Lucide
- **Interface** : panneau de questions (gauche) + terminal ttyd embarque (droite, iframe)
- **Fonctionnalites** : navigation entre questions, timer, flags, theme sombre/clair, raccourcis clavier, modale de score avec details par critere

### Scripts Bash (`scripts/`)

Coeur operationnel du projet. Quatre scripts principaux + bibliotheques partagees.

```
scripts/
  ├── ckad-setup.sh          # Preparation de l'environnement K8s
  ├── ckad-exam.sh           # Lancement de l'examen (web ou terminal)
  ├── ckad-score.sh          # Evaluation des reponses
  ├── ckad-cleanup.sh        # Nettoyage de l'environnement
  └── lib/
      ├── common.sh          # Utilitaires (couleurs, helpers kubectl, ttyd, etat)
      ├── setup-functions.sh # Fonctions de setup et cleanup
      ├── timer.sh           # Timer base sur fichiers (PID, etat, countdown)
      └── banner.sh          # Banniere ASCII pour le terminal
```

------

## Cycle de vie d'un examen

```
 1. SETUP                2. EXAM                 3. SCORE               4. CLEANUP
 ckad-setup.sh           ckad-exam.sh            ckad-score.sh          ckad-cleanup.sh
 ┌──────────────┐        ┌──────────────┐        ┌──────────────┐       ┌──────────────┐
 │ Creer NS     │        │ Lancer ttyd  │        │ Charger      │       │ Stop timer   │
 │ Deployer     │───────>│ Lancer       │───────>│  scoring-    │──────>│ Uninstall    │
 │  manifests   │        │  server.py   │        │  functions   │       │  Helm        │
 │ Copier       │        │ Ouvrir       │        │ Evaluer      │       │ Supprimer NS │
 │  templates   │        │  navigateur  │        │  score_q1()  │       │ Supprimer PV │
 │ Registry     │        │              │        │  ...         │       │ Supprimer    │
 │ Helm charts  │        │              │        │  score_qN()  │       │  registry    │
 │ Post-setup   │        │              │        │ Afficher     │       │ Nettoyer     │
 │              │        │              │        │  resultats   │       │  Docker      │
 └──────────────┘        └──────────────┘        └──────────────┘       └──────────────┘
        │                                                                       │
        └── Etat sauvegarde dans /tmp/ckad-dojo/active-exam.state ──────────────┘
```

------

## Structure d'un examen

Chaque examen est un repertoire autonome sous `exams/{exam-id}/` :

```
exams/ckad-simulation1/
  ├── exam.conf              # Configuration (duree, points, namespaces, options)
  ├── questions.md           # Questions en Markdown avec table de metadonnees
  ├── solutions.md           # Solutions pour la revue post-examen
  ├── scoring-functions.sh   # Fonctions Bash : score_q1(), score_q2(), ...
  ├── manifests/
  │   └── setup/
  │       ├── namespaces.yaml    # Definitions des namespaces
  │       └── *.yaml             # Ressources K8s pre-existantes
  └── templates/
      ├── q01-file.yaml          # Fichiers copies dans exam/course/N/
      └── q11-image/             # Repertoires (Dockerfile, etc.)
```

**Variables cles de `exam.conf`** :

| Variable | Description |
|----------|-------------|
| `EXAM_NAME` | Nom affiche |
| `EXAM_DURATION` | Duree en minutes |
| `TOTAL_QUESTIONS` / `TOTAL_POINTS` | Dimensions de l'examen |
| `PASSING_PERCENTAGE` | Seuil de reussite (defaut 66%) |
| `EXAM_NAMESPACES=()` | Tableau des namespaces a creer |
| `HELM_RELEASES=()` | Releases Helm a installer |
| `ALLOW_TIMER_PAUSE` | Autoriser la pause du timer |
| `ALLOW_HINTS` | Autoriser les indices |
| `DOJO_NAME` / `DOJO_EMOJI` | Identite thematique du dojo |

------

## Mecanisme de scoring

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

1. Verifie les ressources K8s via des helpers (`resource_exists`, `get_resource_field`)
2. Affiche des marqueurs pass/fail (checkmark/cross) par critere
3. Retourne `score/max_points` sur stdout
4. Retourne `DETAILS:item1. item2.` pour le detail des criteres

Le serveur web parse cette sortie avec des regex et construit une reponse JSON
structuree pour l'interface.

------

## Integrations externes

| Outil | Role | Utilisation |
|-------|------|-------------|
| **kubectl** | Operations K8s | Setup (create/apply), scoring (get/describe), cleanup (delete) |
| **helm** | Charts Helm | Installation de releases pour les questions Helm |
| **docker** | Registry local | `registry:2` sur `localhost:5000` pour les questions de build |
| **ttyd** | Terminal web | Embarque dans l'interface via iframe sur le port 7682 |
| **uv** | Gestionnaire Python | Execute le serveur, les tests, le linting |

------

## Infrastructure de tests

### Tests Bash (`tests/`)

Framework de test custom (`test-framework.sh`) avec assertions :

```
tests/
  ├── run-tests.sh            # Runner : execute tous les test-*.sh
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
| `ckad_dojo.py` | CLI, parsing config, decouverte d'examens |
| `web/server.py` | Parsing, config, questions, solutions |
| `scripts/bump-version.py` | Validation, lecture version, mise a jour |

### Pipeline CI (`.github/workflows/ci.yml`)

```
  Stage 1          Stage 2              Stage 3
 ┌──────┐     ┌──────┐  ┌──────┐     ┌──────┐
 │ Lint │────>│ Test │  │Secu. │────>│Build │
 │      │     │      │  │      │     │      │
 └──────┘     └──────┘  └──────┘     └──────┘
                 │           │
              parallel    parallel
```

- **Lint** : `pre-commit run --all-files` (ruff, shellcheck, mypy, markdownlint, etc.)
- **Test** : tests Bash + pytest avec couverture
- **Security** : `pip-audit` + `gitleaks`
- **Build** : `uv build` + upload des artefacts

------

## Decisions techniques

| Decision | Justification |
|----------|---------------|
| Python standard library uniquement (serveur) | Zero dependance externe, deploiement simple |
| Bash pour la logique metier | Interaction directe avec kubectl/helm/docker sans couche d'abstraction |
| CLI Python comme orchestrateur | Ergonomie (argparse, completion, menu interactif) sans dupliquer la logique |
| Timer en memoire (serveur) | Simplicite, pas de persistence necessaire pour un examen ephemere |
| Examens auto-contenus | Chaque dojo est un repertoire independant, facilitant l'ajout de nouveaux examens |
| Frontend vanilla JS | Pas de build step, chargement direct, dependances CDN minimales |

------

> **Document cree le** : 2026-02-17
> **Version** : 1.0
