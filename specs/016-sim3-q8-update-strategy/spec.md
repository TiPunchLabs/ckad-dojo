# Feature Specification: Sim3 Q8 Update Strategy

**Feature Branch**: `016-sim3-q8-update-strategy`
**Created**: 2025-12-14
**Status**: Draft
**Input**: Différencier la question Q8 de simulation3 en remplaçant Deployment Rollback par Deployment Update Strategy

## Context

La question 8 de la simulation 3 (Deployment Rollback) est trop similaire à la question 8 de la simulation 1 (Deployment, Rollouts). Les deux questions demandent de faire un rollback d'un Deployment.

Cette feature remplace Q8 de sim3 par une question sur la **stratégie de mise à jour des Deployments** (RollingUpdate avec maxSurge/maxUnavailable), un sujet différent mais de complexité équivalente.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Question Différenciée (Priority: P1)

En tant que candidat CKAD pratiquant sur plusieurs simulations, je veux que chaque simulation teste des compétences différentes pour maximiser mon apprentissage.

**Why this priority**: La raison d'être de cette feature - éliminer la redondance entre simulations.

**Independent Test**: Lire Q8 de sim3 et vérifier qu'elle demande de configurer une stratégie RollingUpdate avec maxSurge/maxUnavailable au lieu d'un rollback.

**Acceptance Scenarios**:

1. **Given** simulation 3 Q8 existe, **When** je lis la question, **Then** elle demande de modifier la stratégie de mise à jour d'un Deployment (RollingUpdate)
2. **Given** sim1 Q8 et sim3 Q8, **When** je compare les deux, **Then** elles testent des compétences différentes (rollback vs update strategy)

---

### User Story 2 - Scoring Correct (Priority: P1)

En tant qu'utilisateur, je veux que ma réponse soit correctement évaluée quand je configure la stratégie de mise à jour.

**Why this priority**: Sans scoring fonctionnel, la question n'a pas de valeur.

**Independent Test**: Configurer correctement le Deployment avec RollingUpdate et vérifier que le score retourne 6/6.

**Acceptance Scenarios**:

1. **Given** j'ai configuré le Deployment avec `maxSurge: 2` et `maxUnavailable: 1`, **When** je lance le scoring, **Then** j'obtiens les points correspondants
2. **Given** je n'ai pas modifié le Deployment, **When** je lance le scoring, **Then** j'obtiens 0/6

---

### User Story 3 - Solution Disponible (Priority: P2)

En tant qu'utilisateur, je veux consulter la solution après l'examen pour comprendre la bonne réponse.

**Why this priority**: Important pour l'apprentissage mais pas bloquant pour l'examen.

**Independent Test**: Lire solutions.md Q8 et vérifier qu'elle montre les commandes kubectl pour configurer RollingUpdate.

**Acceptance Scenarios**:

1. **Given** j'ai terminé l'examen, **When** je consulte la solution Q8, **Then** je vois les commandes pour configurer maxSurge et maxUnavailable

---

### Edge Cases

- Que se passe-t-il si l'utilisateur utilise `kubectl edit` vs `kubectl patch` ? → Les deux sont acceptés
- Que se passe-t-il si les valeurs sont en pourcentage vs absolu ? → Les deux sont valides selon la spec

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Q8 de sim3 DOIT demander de configurer la stratégie RollingUpdate d'un Deployment
- **FR-002**: La question DOIT spécifier les valeurs attendues : `maxSurge: 2` et `maxUnavailable: 1`
- **FR-003**: Le scoring DOIT valider que le Deployment utilise la stratégie RollingUpdate
- **FR-004**: Le scoring DOIT valider les valeurs maxSurge et maxUnavailable
- **FR-005**: La solution DOIT montrer au moins une méthode pour configurer la stratégie
- **FR-006**: Le nombre de points DOIT rester 6 (même difficulté que l'ancienne question)

### Key Entities

- **Deployment `battle-app`**: Deployment existant dans le namespace `ares` à modifier
- **Update Strategy**: Configuration de la stratégie de mise à jour (type: RollingUpdate, maxSurge, maxUnavailable)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Q8 de sim3 ne mentionne plus "rollback" dans son titre ou sa tâche
- **SC-002**: grep "Deployment Rollback" dans sim3 questions.md ne retourne aucun résultat
- **SC-003**: Le scoring valide correctement une configuration RollingUpdate avec maxSurge=2, maxUnavailable=1
- **SC-004**: Les 3 simulations ont des Q8 testant des compétences différentes
