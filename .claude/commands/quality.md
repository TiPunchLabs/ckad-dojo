# Analyse Qualité CKAD-Dojo

Commande d'analyse de qualité pour le projet CKAD-Dojo. Vérifie la cohérence des examens, la qualité du code et l'intégrité du système de scoring.

## Arguments

| Argument | Description |
|----------|-------------|
| (aucun) | Analyse complète du projet |
| `<exam-id>` | Analyse ciblée sur un examen (ex: `ckad-simulation2`) |
| `--scoring` | Focus sur la vérification des fonctions de scoring |
| `--fix` | Analyse + corrections automatiques si possible |
| `--report` | Génère un rapport Markdown dans `./reports/` |

---

## PHASE 1 : LECTURE DU CONTEXTE PROJET

### 1.1 Documentation projet

Lire `CLAUDE.md` et extraire :
- Structure du projet
- Conventions de développement
- Technologies utilisées (Bash, Python, JavaScript)
- Architecture multi-examens

### 1.2 Configuration des examens

Scanner `exams/*/` pour chaque simulation :
- `exam.conf` : Configuration (namespaces, points, durée)
- `questions.md` : Questions et leurs points
- `solutions.md` : Solutions de référence
- `scoring-functions.sh` : Fonctions de validation

### 1.3 Outils disponibles

Détecter les outils de qualité :
- `shellcheck` (linting Bash)
- `python3 -m py_compile` (syntaxe Python)
- `./tests/run-tests.sh` (tests unitaires)

---

## PHASE 2 : COHÉRENCE DES EXAMENS

### 2.1 Intégrité de chaque examen

Pour chaque examen dans `exams/*/` :

```bash
# Vérifications automatiques
1. Nombre de questions dans questions.md == TOTAL_QUESTIONS dans exam.conf
2. Somme des points == TOTAL_POINTS dans exam.conf
3. Nombre de score_qN() == TOTAL_QUESTIONS
4. Chaque score_qN() a (total|max_points) == points déclarés dans questions.md
```

### 2.2 Cohérence Scoring ↔ Questions

Pour chaque fonction `score_qN()` :
- `total` ou `max_points` correspond aux points de la question
- Nombre de critères (score++) correspond au total déclaré
- Critères cohérents avec les exigences de la question

### 2.3 Cohérence Solutions ↔ Questions

Vérifier que :
- Chaque question a une solution correspondante
- Les solutions correspondent aux critères de scoring

### 2.4 Manifests et Templates

Vérifier la présence des ressources :
- `manifests/setup/*.yaml` : Ressources pré-existantes
- `templates/*` : Templates fournis aux candidats

---

## PHASE 3 : QUALITÉ TECHNIQUE

### 3.1 Analyse Bash (Scripts)

```bash
# Fichiers à analyser
scripts/*.sh
scripts/lib/*.sh
exams/*/scoring-functions.sh

# Vérifications
shellcheck --severity=warning <fichiers>
```

| Catégorie | Éléments vérifiés |
|-----------|-------------------|
| **Syntaxe** | Erreurs shellcheck |
| **Portabilité** | Bashisms, compatibilité POSIX |
| **Sécurité** | Injection de commandes, eval dangereux |
| **Style** | Variables non quotées, globbing |

### 3.2 Analyse Python (Serveur Web)

```bash
# Fichiers à analyser
web/server.py
ckad_dojo.py (si existe)

# Vérifications
python3 -m py_compile <fichier>
```

### 3.3 Analyse JavaScript (Frontend)

```bash
# Fichiers à analyser
web/js/*.js

# Vérifications manuelles
- Pas de console.log en production
- Gestion des erreurs fetch
- Variables globales minimales
```

### 3.4 Tests

```bash
# Exécuter les tests
./tests/run-tests.sh

# Métriques attendues
- Tests passants : 100%
- Aucun test skipped sans raison
```

---

## PHASE 4 : SCORING ET RAPPORT

### Système de scoring

| Catégorie | Poids | Critères |
|-----------|-------|----------|
| Cohérence Examens | 40% | Points, questions, scoring alignés |
| Qualité Bash | 25% | Shellcheck clean, bonnes pratiques |
| Qualité Python/JS | 15% | Syntaxe valide, pas d'erreurs |
| Tests | 20% | Tests passants, couverture |

### Format de sortie console

```
📊 Rapport Qualité CKAD-Dojo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Projet : ckad-dojo
📅 Analyse : {date}
🎯 Score global : {X}/100

┌─────────────────────────────────────────────────────────────────┐
│ 🎓 COHÉRENCE EXAMENS (40%)                           Score: X/40│
├─────────────────────────────────────────────────────────────────┤
│ Simulations : 4 détectées                                       │
│                                                                 │
│ ckad-simulation1 (Seiryu):                                      │
│   ✅ Questions: 22/22 | Points: 113/113 | Scoring: 22/22        │
│                                                                 │
│ ckad-simulation2 (Suzaku):                                      │
│   ✅ Questions: 21/21 | Points: 112/112 | Scoring: 21/21        │
│                                                                 │
│ ckad-simulation3 (Byakko):                                      │
│   ✅ Questions: 20/20 | Points: 105/105 | Scoring: 20/20        │
│                                                                 │
│ ckad-simulation4 (Genbu):                                       │
│   ✅ Questions: 20/20 | Points: 105/105 | Scoring: 20/20        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🔍 QUALITÉ BASH (25%)                                Score: X/25│
├─────────────────────────────────────────────────────────────────┤
│ Fichiers analysés : X                                           │
│ Shellcheck : X erreurs, Y warnings                              │
│ Scripts principaux :                                            │
│   ✅ ckad-setup.sh                                              │
│   ✅ ckad-exam.sh                                               │
│   ⚠️  ckad-score.sh (2 warnings)                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🐍 QUALITÉ PYTHON/JS (15%)                           Score: X/15│
├─────────────────────────────────────────────────────────────────┤
│ Python :                                                        │
│   ✅ web/server.py - syntaxe valide                             │
│                                                                 │
│ JavaScript :                                                    │
│   ✅ web/js/app.js - pas d'erreurs évidentes                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🧪 TESTS (20%)                                       Score: X/20│
├─────────────────────────────────────────────────────────────────┤
│ Tests passants : X/Y                                            │
│ Suites :                                                        │
│   ✅ test-common.sh (X/X)                                       │
│   ✅ test-setup-functions.sh (X/X)                              │
└─────────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 ACTIONS PRIORITAIRES
───────────────────────
1. [CRITIQUE] Corriger les erreurs shellcheck dans ckad-score.sh
2. [IMPORTANT] Ajouter tests pour scoring-functions
3. [MINEUR] Documenter les nouvelles fonctions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 5 : MODE --fix

Si `--fix` est passé, appliquer les corrections automatiques :

### Corrections automatiques

1. **Scoring mismatch** : Ajuster `total`/`max_points` si critères corrects
2. **Shellcheck fixes** : Appliquer les corrections sûres
3. **Syntaxe Python** : Corriger indentation évidente

### Corrections interactives (demander confirmation)

1. Ajouter critères manquants dans scoring
2. Mettre à jour exam.conf si incohérence
3. Créer solutions manquantes

### Jamais corrigé automatiquement

- Contenu des questions
- Logique de scoring métier
- Suppression de code fonctionnel

---

## PHASE 6 : MODE --report

Générer un rapport persistant :

**Fichier** : `./reports/quality-report-{YYYY-MM-DD}.md`

**Contenu** :
- Résumé exécutif
- Détail par examen
- Historique des scores (si rapports précédents)
- Actions recommandées avec liens vers les fichiers

---

## COMMANDES UTILES

### Vérification rapide scoring

```bash
# Compter critères vs total pour chaque fonction
for exam in exams/ckad-simulation*; do
  echo "=== $(basename $exam) ==="
  grep -E "total=|max_points=|\(\(score\+\+\)\)" $exam/scoring-functions.sh | \
  awk '/score_q.*\(\)/{fn=$0}/total=|max_points=/{t=$0}/score\+\+/{c++}END{print fn, t, "criteria="c}'
done
```

### Vérification shellcheck

```bash
shellcheck --severity=warning scripts/*.sh scripts/lib/*.sh
```

### Vérification Python

```bash
python3 -m py_compile web/server.py
```

### Exécuter tests

```bash
./tests/run-tests.sh
```

---

## FICHIERS CLÉS À ANALYSER

| Catégorie | Fichiers | Priorité |
|-----------|----------|----------|
| **Scoring** | `exams/*/scoring-functions.sh` | Haute |
| **Scripts** | `scripts/ckad-*.sh` | Haute |
| **Lib** | `scripts/lib/*.sh` | Haute |
| **Web** | `web/server.py`, `web/js/app.js` | Moyenne |
| **Config** | `exams/*/exam.conf` | Moyenne |
| **Tests** | `tests/*.sh` | Moyenne |

---

## RÈGLES SPÉCIFIQUES CKAD-DOJO

Depuis `CLAUDE.md` :

- Chaque examen est auto-contenu dans `exams/{exam-id}/`
- Les scoring functions retournent `$score/$max_points`
- Les namespaces sont définis dans `EXAM_NAMESPACES` de exam.conf
- Les manifests setup créent les ressources pré-existantes
- Les templates sont copiés dans `./exam/course/N/`

### Conventions de nommage

- Fonctions de scoring : `score_q1()`, `score_q2()`, etc.
- Variables locales : `local var_name=...`
- Pas d'espaces dans les noms de fichiers

### Bonnes pratiques Bash

- Toujours quoter les variables : `"$var"`
- Utiliser `local` pour les variables de fonction
- Retourner 0 en fin de fonction scoring
- Utiliser `2>/dev/null` pour les commandes kubectl qui peuvent échouer

---

## INTÉGRATION WORKFLOW

### Utilisation recommandée

| Moment | Commande |
|--------|----------|
| Avant commit | `/quality` (check rapide) |
| Après ajout d'examen | `/quality <exam-id>` |
| Après modif scoring | `/quality --scoring` |
| Release | `/quality --report` |

### Chaînage avec autres commandes

```
/quality            → Vérifie la qualité globale
/quality --fix      → Corrige les problèmes détectés
/commit             → Commit avec message standardisé
```
