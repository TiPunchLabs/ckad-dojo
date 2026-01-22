# Feature Specification: Sim2 Original Exam

**Feature Branch**: `017-sim2-original-exam`
**Created**: 2025-12-19
**Status**: Draft
**Input**: Refonte complète de ckad-simulation2 pour créer un examen original

## Context

L'examen ckad-simulation2 (Dojo Suzaku) est actuellement une copie de simulation1 avec des noms différents. Cette feature remplace **toutes les questions** par des questions originales couvrant les mêmes domaines CKAD mais avec des scénarios complètement différents.

### Analyse de Similarité Actuelle

| Sim2 Actuelle | Copie de Sim1 | Similarité |
|---------------|---------------|------------|
| Q2 Multi-container | Preview Q3 | ~90% |
| Q6 ConfigMap Volume | Q15 | ~85% |
| Q9 Pod→Deployment | Q9 | ~95% |
| Q13 Helm Operations | Q4 | ~90% |
| Q15 Sidecar Logging | Q16 | ~90% |
| ... | ... | >80% |

### Objectif

Créer 21 questions **totalement originales** qui:

- Couvrent tous les domaines CKAD
- Ont le même niveau de difficulté (~112 points)
- Utilisent des scénarios différents de sim1, sim3, sim4
- Respectent le thème Suzaku (Phénix Vermillon)

## User Scenarios & Testing

### User Story 1 - Questions Originales (Priority: P1)

En tant que candidat CKAD, je veux pratiquer sur un deuxième examen avec des questions différentes pour élargir ma préparation.

**Why this priority**: Raison d'être de cette feature - éliminer les doublons.

**Independent Test**: Comparer chaque question de sim2 avec sim1/sim3/sim4 - aucune ne doit être similaire.

**Acceptance Scenarios**:

1. **Given** sim2 questions, **When** je compare avec sim1, **Then** aucune question n'est similaire à >20%
2. **Given** les 21 questions, **When** je les catégorise par domaine CKAD, **Then** tous les domaines sont couverts

---

### User Story 2 - Scoring Fonctionnel (Priority: P1)

En tant qu'utilisateur, je veux que chaque question soit correctement évaluée.

**Why this priority**: Sans scoring, l'examen est inutilisable.

**Independent Test**: Exécuter chaque scoring function avec une réponse correcte et vérifier 100% des points.

---

### User Story 3 - Setup Complet (Priority: P1)

En tant qu'utilisateur, je veux que l'environnement d'examen soit correctement initialisé.

**Why this priority**: Prérequis pour l'examen.

**Independent Test**: Exécuter `ckad-setup.sh -e ckad-simulation2` et vérifier tous les namespaces/resources créés.

---

### User Story 4 - Solutions Documentées (Priority: P2)

En tant qu'utilisateur, je veux consulter les solutions pour apprendre.

**Why this priority**: Important pour l'apprentissage post-examen.

---

## NEW EXAM DESIGN

### Thème: Suzaku (Phénix Vermillon du Sud)

Namespaces: `phoenix`, `ember`, `blaze`, `inferno`, `flame`, `spark`, `solar`, `corona`, `flare`, `magma`

### Structure des 21 Questions (112 points)

| Q# | Titre | Points | Domaine CKAD | Différenciation vs Sim1 |
|----|-------|--------|--------------|------------------------|
| 1 | API Resources | 1 | Core | Sim1=namespaces, Sim2=api-resources |
| 2 | Deployment Recreate Strategy | 5 | Deployment | Sim1=rollback, Sim2=recreate strategy |
| 3 | Job Failure Handling | 5 | Design | Sim1=parallelism, Sim2=backoffLimit+activeDeadline |
| 4 | Helm Template Debug | 5 | Design | Sim1=CRUD releases, Sim2=template inspection |
| 5 | CrashLoopBackOff Fix | 6 | Observability | Sim1=rollback, Sim2=debug+fix command |
| 6 | ConfigMap Partial Mount | 5 | Config | Sim1=full mount, Sim2=items/subPath mount |
| 7 | Secret from File | 5 | Security | Sim1=from literal, Sim2=from file |
| 8 | Headless Service | 5 | Networking | Sim1=ClusterIP/NodePort, Sim2=headless |
| 9 | Canary Deployment | 7 | Deployment | Sim1=convert pod, Sim2=canary pattern |
| 10 | EmptyDir Sidecar | 6 | Design | Sim1=log sidecar, Sim2=data processing sidecar |
| 11 | NetworkPolicy Namespace | 6 | Networking | Sim1=egress DNS, Sim2=cross-namespace ingress |
| 12 | Docker ARG Build | 6 | Design | Sim1=ENV only, Sim2=ARG+build-time |
| 13 | Helm Values Override | 5 | Design | Sim1=--set, Sim2=values.yaml file |
| 14 | PostStart Hook | 5 | Design | Sim1=initContainer, Sim2=lifecycle hooks |
| 15 | QoS Classes | 5 | Config | Sim1=requests/limits, Sim2=achieve specific QoS |
| 16 | SA Token Volume Projection | 4 | Security | Sim1=default token, Sim2=projected volume |
| 17 | TCP Socket Probe | 5 | Observability | Sim1=http/exec, Sim2=tcpSocket probe |
| 18 | Service Named Ports | 5 | Networking | Sim1=port numbers, Sim2=named targetPort |
| 19 | TopologySpread | 6 | Deployment | NEW - topologySpreadConstraints |
| 20 | Field Selectors | 3 | Core | Sim1=label selectors, Sim2=field selectors |
| 21 | Pod Eviction | 3 | Maintenance | NEW - voluntary eviction |

**Total: 112 points** (identique à l'actuel)

---

## Requirements

### Functional Requirements

- **FR-001**: Les 21 questions DOIVENT être différentes de sim1/sim3/sim4
- **FR-002**: Chaque question DOIT avoir une fonction de scoring fonctionnelle
- **FR-003**: Le setup DOIT créer tous les namespaces et ressources pré-existantes
- **FR-004**: Les solutions DOIVENT être documentées avec explications
- **FR-005**: Le total DOIT être de 112 points
- **FR-006**: Les templates et manifests DOIVENT être fournis quand nécessaire
- **FR-007**: Le thème Suzaku DOIT être respecté (noms liés au feu/phénix)

### CKAD Domain Coverage

| Domaine | % Cible | Questions |
|---------|---------|-----------|
| Application Design and Build | 20% | Q3, Q4, Q10, Q12, Q13, Q14 |
| Application Deployment | 20% | Q2, Q9, Q19 |
| Application Observability | 15% | Q5, Q17, Q21 |
| Application Environment/Config/Security | 25% | Q6, Q7, Q15, Q16 |
| Services and Networking | 20% | Q1, Q8, Q11, Q18, Q20 |

### Files to Create/Modify

```
exams/ckad-simulation2/
├── exam.conf                    # Update namespaces
├── questions.md                 # 21 new questions
├── solutions.md                 # 21 new solutions
├── scoring-functions.sh         # 21 scoring functions
├── manifests/setup/             # Pre-existing resources
│   ├── namespaces.yaml
│   ├── phoenix/                 # Resources per namespace
│   ├── ember/
│   └── ...
└── templates/                   # Template files for questions
    ├── 3/job.yaml
    ├── 9/canary-base.yaml
    └── ...
```

## Success Criteria

### Measurable Outcomes

- **SC-001**: 0 questions similaires à >20% avec sim1/sim3/sim4
- **SC-002**: Scoring retourne 112/112 pour réponses parfaites
- **SC-003**: Setup crée tous les namespaces/resources sans erreur
- **SC-004**: Tous les domaines CKAD couverts avec ±5% de la cible
- **SC-005**: Temps estimé de complétion ~120 minutes (comme sim1)
