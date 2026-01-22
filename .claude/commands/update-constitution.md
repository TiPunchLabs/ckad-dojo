# Mise à jour de la Constitution

Met à jour le fichier `.specify/memory/constitution.md` pour refléter l'état actuel du projet ckad-dojo.

## Étapes

1. **Analyser l'état actuel du projet**
   - Structure des dossiers (`scripts/`, `web/`, `exams/`, `tests/`)
   - Liste des scripts dans `scripts/` et `scripts/lib/`
   - Liste des examens dans `exams/`
   - Configuration (`pyproject.toml`, `exam.conf` par exam)
   - Interface web (`web/server.py`, `web/js/`, `web/css/`)

2. **Comparer avec la constitution existante**
   - Lire `.specify/memory/constitution.md`
   - Identifier les sections obsolètes
   - Identifier les éléments manquants

3. **Mettre à jour les sections**
   - Architecture et structure du projet
   - Liste des scripts avec leur rôle
   - Liste des examens (dojos) avec leurs statistiques
   - Conventions de code (Bash, Python)
   - Dépendances et outils requis

## Sections à vérifier

- [ ] Vue d'ensemble du projet
- [ ] Stack technique (Bash, Python, JavaScript)
- [ ] Structure des dossiers
- [ ] Scripts disponibles (`ckad_dojo.py`, `ckad-setup.sh`, etc.)
- [ ] Examens/Dojos (Shishin - quatre gardiens célestes)
- [ ] Interface web (server.py, timer, navigation)
- [ ] Configuration (`pyproject.toml`, `exam.conf`)
- [ ] Tests (`tests/run-tests.sh`)
- [ ] Fonctionnalités implémentées vs non implémentées

## Format de sortie

Proposer les modifications sous forme de diff ou liste de changements avant d'appliquer.

Demander confirmation avant de modifier le fichier.
