# ADR-0005: Python CLI as Orchestrator

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

Users interact with ckad-dojo through multiple scripts (`ckad-setup.sh`, `ckad-exam.sh`, `ckad-score.sh`, `ckad-cleanup.sh`), each with its own flags and arguments. This creates a fragmented UX — users must remember which script to call and with which options.

A unified entry point would improve discoverability and provide features like an interactive menu, shell auto-completion, and consistent argument parsing.

## Decision

Provide a Python CLI (`ckad_dojo.py`, invoked via `uv run ckad-dojo`) as a lightweight orchestrator. The CLI offers an interactive menu and subcommands (`exam start`, `score`, `cleanup`, `list`, `info`, `status`) but delegates all actual work to the existing Bash scripts via `subprocess.run()`.

The CLI does NOT duplicate or reimplement business logic — it is purely a UX layer.

## Alternatives Considered

- **Bash wrapper script**: A single `ckad-dojo.sh` that dispatches to sub-scripts. Possible but limited: Bash has poor argument parsing ergonomics, no built-in auto-completion framework, and interactive menus require manual implementation.
- **Makefile**: Common pattern for CLI entry points. But Makefiles are not designed for interactive workflows and have poor error messages for end users.
- **Go CLI (cobra)**: Excellent CLI framework. But introduces a compiled language, a build step, and a second language in the project.

## Consequences

- **Positive**: Single entry point (`uv run ckad-dojo`) for all operations. Discoverability via `--help` and interactive menu.
- **Positive**: Shell auto-completion for bash, zsh, and fish via `argcomplete`.
- **Positive**: Python's `argparse` provides structured argument validation and help text.
- **Positive**: No business logic duplication — Bash scripts remain the source of truth.
- **Negative**: Adds Python as a runtime dependency (already required for the web server).
- **Negative**: Adds `uv` as a tool dependency for running the CLI.
