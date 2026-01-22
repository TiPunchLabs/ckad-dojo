# Analyse de Couverture CKAD-Dojo

Commande d'analyse de couverture pour le projet CKAD-Dojo. Vérifie que tous les éléments du projet sont correctement couverts : tests, scoring, solutions, manifests.

## Arguments

| Argument | Description |
|----------|-------------|
| (aucun) | Analyse complète de couverture |
| `<exam-id>` | Analyse ciblée sur un examen (ex: `ckad-simulation2`) |
| `--tests` | Focus sur la couverture des tests unitaires |
| `--scoring` | Focus sur la couverture des fonctions de scoring |
| `--report` | Génère un rapport Markdown dans `./reports/` |

---

## PHASE 1 : INVENTAIRE DU PROJET

### 1.1 Scripts à tester

Lister tous les scripts et leurs fonctions :

```bash
# Scripts principaux
scripts/ckad-setup.sh
scripts/ckad-exam.sh
scripts/ckad-score.sh
scripts/ckad-cleanup.sh

# Bibliothèques
scripts/lib/common.sh      → Fonctions utilitaires
scripts/lib/setup-functions.sh → Fonctions setup/cleanup
scripts/lib/timer.sh       → Gestion du timer
```

### 1.2 Tests existants

Scanner `tests/` :

```bash
tests/run-tests.sh         → Runner principal
tests/test-framework.sh    → Framework d'assertions
tests/test-common.sh       → Tests pour common.sh
tests/test-setup-functions.sh → Tests pour setup-functions.sh
```

### 1.3 Examens et leurs composants

Pour chaque `exams/*/` :

- Nombre de questions
- Nombre de scoring functions
- Nombre de solutions
- Manifests de setup
- Templates fournis

---

## PHASE 2 : ANALYSE DE COUVERTURE

### 2.1 Couverture des Tests Unitaires

Pour chaque fichier dans `scripts/lib/*.sh` :

```bash
# Extraire les fonctions définies
grep -E "^[a-z_]+\(\)" scripts/lib/common.sh

# Comparer avec les fonctions testées dans tests/test-common.sh
grep -E "test_[a-z_]+" tests/test-common.sh
```

**Métriques** :

| Fichier | Fonctions | Testées | Couverture |
|---------|-----------|---------|------------|
| common.sh | X | Y | Z% |
| setup-functions.sh | X | Y | Z% |
| timer.sh | X | Y | Z% |

### 2.2 Couverture du Scoring

Pour chaque examen :

```bash
# Fonctions de scoring attendues (basé sur TOTAL_QUESTIONS)
score_q1() à score_qN()

# Vérifier que chaque fonction existe et est complète
```

**Critères de couverture scoring** :

- [ ] Fonction existe
- [ ] `total` ou `max_points` défini
- [ ] Au moins un critère vérifié
- [ ] Retourne `$score/$total`

### 2.3 Couverture Questions ↔ Solutions

Pour chaque question dans `questions.md` :

```bash
# Vérifier présence dans solutions.md
## Question N → doit avoir ## Question N dans solutions.md
```

### 2.4 Couverture Manifests

Pour chaque question nécessitant des ressources pré-existantes :

```bash
# Vérifier présence dans manifests/setup/
qN-*.yaml
```

### 2.5 Couverture Templates

Pour chaque question mentionnant un template :

```bash
# Vérifier présence dans templates/
```

---

## PHASE 3 : RAPPORT DE COUVERTURE

### Format de sortie console

```
📊 Rapport de Couverture CKAD-Dojo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Projet : ckad-dojo
📅 Analyse : {date}
🎯 Couverture globale : {X}%

┌─────────────────────────────────────────────────────────────────┐
│ 🧪 TESTS UNITAIRES                                              │
├─────────────────────────────────────────────────────────────────┤
│ scripts/lib/common.sh                                           │
│   Fonctions : 15 | Testées : 12 | Couverture : 80%              │
│   ❌ Non testées : print_header, print_separator, get_exam_dir  │
│                                                                 │
│ scripts/lib/setup-functions.sh                                  │
│   Fonctions : 8 | Testées : 6 | Couverture : 75%                │
│   ❌ Non testées : cleanup_helm_releases, wait_for_pods         │
│                                                                 │
│ scripts/lib/timer.sh                                            │
│   Fonctions : 4 | Testées : 0 | Couverture : 0%                 │
│   ❌ Non testées : start_timer, stop_timer, get_elapsed, format │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🎓 SCORING FUNCTIONS                                            │
├─────────────────────────────────────────────────────────────────┤
│ ckad-simulation1 (22 questions)                                 │
│   ✅ 22/22 fonctions définies                                   │
│   ✅ 22/22 avec total/max_points                                │
│   ✅ 22/22 avec critères alignés                                │
│                                                                 │
│ ckad-simulation2 (21 questions)                                 │
│   ✅ 21/21 fonctions définies                                   │
│   ✅ 21/21 avec total/max_points                                │
│   ✅ 21/21 avec critères alignés                                │
│                                                                 │
│ ckad-simulation3 (20 questions)                                 │
│   ✅ 20/20 fonctions définies                                   │
│   ✅ 20/20 avec total/max_points                                │
│   ✅ 20/20 avec critères alignés                                │
│                                                                 │
│ ckad-simulation4 (20 questions)                                 │
│   ✅ 20/20 fonctions définies                                   │
│   ✅ 20/20 avec total/max_points                                │
│   ✅ 20/20 avec critères alignés                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📝 SOLUTIONS                                                    │
├─────────────────────────────────────────────────────────────────┤
│ ckad-simulation1 : ✅ 22/22 solutions                           │
│ ckad-simulation2 : ✅ 21/21 solutions                           │
│ ckad-simulation3 : ✅ 20/20 solutions                           │
│ ckad-simulation4 : ✅ 20/20 solutions                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📦 MANIFESTS & TEMPLATES                                        │
├─────────────────────────────────────────────────────────────────┤
│ ckad-simulation1                                                │
│   Manifests : 15 fichiers                                       │
│   Templates : 3 fichiers                                        │
│   ⚠️  Q7 référence template non trouvé                          │
│                                                                 │
│ ckad-simulation2                                                │
│   Manifests : 12 fichiers                                       │
│   Templates : 2 fichiers                                        │
│   ✅ Tous les templates présents                                │
└─────────────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 ACTIONS À EFFECTUER
━━━━━━━━━━━━━━━━━━━━━━

🔴 PRIORITÉ HAUTE (Bloquant)
─────────────────────────────
1. Créer tests pour timer.sh (0% couverture)
   → Fichier à créer : tests/test-timer.sh
   → Fonctions à tester : start_timer, stop_timer, get_elapsed, format_time

2. Ajouter template manquant pour Q7 (sim1)
   → Fichier attendu : exams/ckad-simulation1/templates/q7-template.yaml

🟡 PRIORITÉ MOYENNE (Amélioration)
──────────────────────────────────
3. Compléter tests common.sh (+3 fonctions)
   → tests/test-common.sh
   → Ajouter : test_print_header, test_print_separator, test_get_exam_dir

4. Compléter tests setup-functions.sh (+2 fonctions)
   → tests/test-setup-functions.sh
   → Ajouter : test_cleanup_helm_releases, test_wait_for_pods

🟢 PRIORITÉ BASSE (Nice to have)
────────────────────────────────
5. Ajouter tests d'intégration pour scoring functions
   → Nouveau fichier : tests/test-scoring-integration.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 RÉSUMÉ
─────────
| Catégorie        | Couvert | Total | Pourcentage |
|------------------|---------|-------|-------------|
| Tests unitaires  | 18      | 27    | 67%         |
| Scoring funcs    | 83      | 83    | 100%        |
| Solutions        | 83      | 83    | 100%        |
| Manifests/Templ  | 31      | 32    | 97%         |
|------------------|---------|-------|-------------|
| **GLOBAL**       |         |       | **91%**     |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## PHASE 4 : GÉNÉRATION DES ACTIONS

### Format des actions

Chaque action générée contient :

```markdown
## Action #{N} - {Titre}

**Priorité** : 🔴 Haute | 🟡 Moyenne | 🟢 Basse
**Type** : Test manquant | Fichier manquant | Incohérence
**Fichier concerné** : {chemin}

### Description
{Description détaillée du problème}

### Solution proposée
{Code ou instructions à appliquer}

### Commande de vérification
```bash
{Commande pour vérifier que l'action est faite}
```

```

### Priorités

| Priorité | Critère |
|----------|---------|
| 🔴 Haute | Fichier manquant, 0% couverture, bloque le fonctionnement |
| 🟡 Moyenne | Couverture < 80%, amélioration de qualité |
| 🟢 Basse | Nice to have, refactoring, documentation |

---

## COMMANDES UTILES

### Lister les fonctions d'un script

```bash
grep -E "^[a-z_]+\(\)\s*\{" scripts/lib/common.sh | sed 's/().*//'
```

### Lister les tests existants

```bash
grep -E "^test_[a-z_]+" tests/test-common.sh | sed 's/().*//'
```

### Compter les questions par examen

```bash
for exam in exams/ckad-simulation*; do
  name=$(basename $exam)
  count=$(grep -c "^## Question" $exam/questions.md)
  echo "$name: $count questions"
done
```

### Compter les scoring functions

```bash
for exam in exams/ckad-simulation*; do
  name=$(basename $exam)
  count=$(grep -c "^score_q[0-9]" $exam/scoring-functions.sh)
  echo "$name: $count scoring functions"
done
```

### Vérifier les solutions

```bash
for exam in exams/ckad-simulation*; do
  name=$(basename $exam)
  q_count=$(grep -c "^## Question" $exam/questions.md)
  s_count=$(grep -c "^## Question" $exam/solutions.md)
  echo "$name: $q_count questions, $s_count solutions"
done
```

---

## INTÉGRATION WORKFLOW

### Utilisation recommandée

| Moment | Commande |
|--------|----------|
| Après ajout de questions | `/coverage <exam-id>` |
| Après ajout de tests | `/coverage --tests` |
| Avant release | `/coverage --report` |
| CI/CD | `/coverage --report` |

### Chaînage avec autres commandes

```
/coverage           → Analyse la couverture
/coverage --report  → Génère le rapport
/quality            → Vérifie la qualité globale
/commit             → Commit les changements
```

---

## EXEMPLES D'EXÉCUTION

### Analyse complète

```
> /coverage

Analyse de couverture en cours...

✅ Tests unitaires : 67% (18/27 fonctions)
✅ Scoring functions : 100% (83/83)
✅ Solutions : 100% (83/83)
⚠️  Manifests/Templates : 97% (31/32)

3 actions à effectuer (1 haute, 2 moyennes)
```

### Analyse ciblée sur un examen

```
> /coverage ckad-simulation2

Analyse de ckad-simulation2...

✅ 21 questions
✅ 21 scoring functions (critères alignés)
✅ 21 solutions
✅ 12 manifests
✅ 2 templates

Aucune action requise pour cet examen.
```

### Focus sur les tests

```
> /coverage --tests

Couverture des tests unitaires :

common.sh          : ████████░░ 80% (12/15)
setup-functions.sh : ███████░░░ 75% (6/8)
timer.sh           : ░░░░░░░░░░  0% (0/4)

Actions :
1. [HAUTE] Créer tests/test-timer.sh
2. [MOYENNE] Ajouter 3 tests dans test-common.sh
3. [MOYENNE] Ajouter 2 tests dans test-setup-functions.sh
```
