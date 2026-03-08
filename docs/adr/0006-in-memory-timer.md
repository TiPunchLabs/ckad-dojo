# ADR-0006: In-Memory Timer

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

The exam timer tracks elapsed time and enforces the 120-minute exam duration. It needs to support start, pause/resume (when allowed by exam config), and time's-up detection. The timer state must be accessible from both the web frontend (via API polling) and the scoring script (to record elapsed time).

Persistence options range from file-based (write state to `/tmp`) to in-memory (keep state in the Python server process) to database-backed.

## Decision

Store the timer state entirely in-memory within the Python web server process. The timer is a simple data structure (start time, pause offsets, state flag) managed by the server and exposed via `GET /api/timer`.

## Alternatives Considered

- **File-based timer**: Used by the Bash scripts for terminal mode. Works but introduces file I/O, race conditions between readers/writers, and stale state on crash.
- **SQLite**: Persistent, queryable. But adds complexity for a single data point (remaining seconds) that only lives for 2 hours.
- **Redis/external store**: Networked state. Completely overkill for a single-user local application.

## Consequences

- **Positive**: Simplest possible implementation. No file I/O, no persistence layer, no cleanup needed.
- **Positive**: Timer state is always consistent — single process, single thread for mutations (GIL).
- **Positive**: API response is instant — no file read, just return the in-memory value.
- **Negative**: Timer state is lost if the server process crashes or is killed. User must restart the exam.
- **Negative**: Terminal mode (without web server) still uses the file-based timer in `scripts/lib/timer.sh`. Two timer implementations coexist.
- **Accepted trade-off**: An exam is ephemeral (2 hours max). Losing timer state on crash is acceptable — the user can simply restart.
