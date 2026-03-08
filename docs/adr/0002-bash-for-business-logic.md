# ADR-0002: Bash for Business Logic

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

The core operations of ckad-dojo — setting up Kubernetes resources, scoring answers, cleaning up namespaces — are essentially sequences of `kubectl`, `helm`, and `docker` commands. These operations need to interact directly with cluster state, parse command output, and handle resource lifecycle.

A higher-level language (Python, Go) could wrap these commands, but this adds an abstraction layer between the user and the tools they'll use in the actual CKAD exam.

## Decision

Implement all business logic (setup, scoring, cleanup) in Bash scripts. The scripts call `kubectl`, `helm`, and `docker` directly without any wrapper or abstraction layer.

## Alternatives Considered

- **Python with kubernetes client**: Type-safe, structured. But adds a heavy dependency (`kubernetes` package) and distances users from the CLI tools they need to master.
- **Go with client-go**: Compiled binary, fast. But introduces a build step and a language most users won't modify.
- **Python subprocess wrappers**: Keeps CLI tools but adds unnecessary indirection. The Python layer would just be forwarding commands.

## Consequences

- **Positive**: Scripts use the exact same tools (`kubectl`, `helm`) that users practice with. No translation layer.
- **Positive**: Easy to debug — users can read and understand scoring functions directly.
- **Positive**: No compilation, no dependency installation for core operations.
- **Negative**: Bash has limited data structures, error handling, and testing support compared to Python.
- **Negative**: Complex string parsing and JSON handling require `jq` or careful `grep`/`awk` usage.
- **Mitigated**: A shared library (`scripts/lib/common.sh`) provides reusable helpers to reduce boilerplate.
