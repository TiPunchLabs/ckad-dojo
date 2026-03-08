# Architecture Decision Records

> This directory contains Architecture Decision Records (ADR) for the ckad-dojo project.
> ADRs document significant architectural choices with their context, rationale, and consequences.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-0001](0001-stdlib-only-web-server.md) | Standard library only for web server | Accepted | 2025-12-04 |
| [ADR-0002](0002-bash-for-business-logic.md) | Bash for business logic | Accepted | 2025-12-04 |
| [ADR-0003](0003-vanilla-js-frontend.md) | Vanilla JS frontend | Accepted | 2025-12-04 |
| [ADR-0004](0004-self-contained-exams.md) | Self-contained exam directories | Accepted | 2025-12-04 |
| [ADR-0005](0005-python-cli-orchestrator.md) | Python CLI as orchestrator | Accepted | 2025-12-04 |
| [ADR-0006](0006-in-memory-timer.md) | In-memory timer | Accepted | 2025-12-04 |

## Statuses

- **Proposed** — Under discussion, not yet decided
- **Accepted** — Decision adopted and in effect
- **Superseded** — Replaced by a newer ADR (linked)
- **Deprecated** — No longer relevant but kept for history

## Template

New ADRs should follow this format:

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

- ADRs are numbered sequentially: `NNNN-short-title.md`
- Once accepted, an ADR is **immutable** — create a new one to supersede it
- Reference ADRs in PRs, specs, and conversations using `ADR-NNNN`
