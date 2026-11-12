# Architecture Decision Records

**Langue :** [English (par défaut)](README.md) | Français

> Ce répertoire contient les Architecture Decision Records (ADR) du projet ckad-dojo.
> Les ADR documentent les choix d'architecture importants avec leur contexte, leur justification et leurs conséquences.

## Index

| ADR | Titre | Statut | Date |
|-----|-------|--------|------|
| [ADR-0001](0001-stdlib-only-web-server.fr.md) | Bibliothèque standard uniquement pour le serveur web | Accepté | 2025-12-04 |
| [ADR-0002](0002-bash-for-business-logic.fr.md) | Bash pour la logique métier | Accepté | 2025-12-04 |
| [ADR-0003](0003-vanilla-js-frontend.fr.md) | Frontend en JS vanilla | Accepté | 2025-12-04 |
| [ADR-0004](0004-self-contained-exams.fr.md) | Répertoires d'examen autonomes | Accepté | 2025-12-04 |
| [ADR-0005](0005-python-cli-orchestrator.fr.md) | CLI Python comme orchestrateur | Accepté | 2025-12-04 |
| [ADR-0006](0006-in-memory-timer.fr.md) | Timer en mémoire | Accepté | 2025-12-04 |

## Statuts

- **Proposé** (Proposed) — En discussion, pas encore décidé
- **Accepté** (Accepted) — Décision adoptée et en vigueur
- **Remplacé** (Superseded) — Remplacé par un ADR plus récent (lié)
- **Obsolète** (Deprecated) — N'est plus pertinent mais conservé pour l'historique

## Modèle

Les nouveaux ADR doivent suivre ce format :

Le modèle ci-dessous reste en anglais : les nouveaux ADR sont d'abord rédigés en anglais, puis traduits.

```markdown
# ADR-NNNN: Title

**Status**: Proposed | Accepted | Superseded by [ADR-XXXX](XXXX-title.md) | Deprecated
**Date**: YYYY-MM-DD
**Authors**: @username

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Alternatives Considered

What other options were evaluated and why were they rejected?

## Consequences

What becomes easier or more difficult to do because of this change?
```

## Conventions

- Les ADR sont numérotés séquentiellement : `NNNN-short-title.md`
- Une fois accepté, un ADR est **immuable** — en créer un nouveau pour le remplacer
- Faire référence aux ADR dans les PR, les specs et les échanges avec `ADR-NNNN`
