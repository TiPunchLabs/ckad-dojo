# ADR-0004: Self-Contained Exam Directories

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

The project supports multiple exam simulations (dojos), each with its own questions, solutions, scoring logic, Kubernetes manifests, and configuration. These components need to be organized in a way that makes it easy to add, modify, or remove an exam without affecting others.

Two approaches were considered: a centralized structure (all questions in one file, all scoring in one file) or a decentralized structure (each exam is a self-contained directory).

## Decision

Each exam is a fully self-contained directory under `exams/{exam-id}/` containing all its resources: `exam.conf`, `questions.md`, `solutions.md`, `scoring-functions.sh`, `manifests/setup/`, `templates/`, and optionally `post-setup.sh`.

## Alternatives Considered

- **Centralized structure**: A single `questions/` directory with all questions, a single `scoring.sh` with all functions. Simpler at small scale, but becomes unwieldy with 9+ exams and 178+ questions.
- **Database-driven**: Store questions and scoring criteria in SQLite or JSON. Powerful for querying but overkill for static content and would complicate the contribution workflow.

## Consequences

- **Positive**: Adding a new exam is a pure directory addition — no modification to existing files.
- **Positive**: Each exam can be developed, tested, and contributed independently (see simulations 4-9 from external contributors).
- **Positive**: Easy to gitignore private or local-only exams via standard patterns.
- **Negative**: Some duplication across exams (e.g., similar scoring patterns, namespace YAML structure).
- **Mitigated**: Shared scoring helpers in `scripts/lib/common.sh` reduce boilerplate in individual `scoring-functions.sh` files.
