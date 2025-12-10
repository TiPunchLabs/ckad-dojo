# Implementation Plan: Score Details Display

**Branch**: `011-score-details` | **Date**: 2025-12-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/011-score-details/spec.md`

## Summary

Enhance the score modal to display detailed PASS/FAIL criteria for each question after exam completion. The current system shows only aggregate scores (e.g., "3/5") but users need to see exactly which criteria passed or failed to understand their mistakes.

**Technical approach**: Parse the existing scoring script output which already contains criterion-level results (via `print_success`/`print_fail`), extract this data in the Python server, and display it in expandable question rows in the web interface.

## Technical Context

**Language/Version**: Python 3.8+ (server), JavaScript ES6+ (frontend), Bash 4.0+ (scoring scripts)
**Primary Dependencies**: Python standard library only (http.server, json, re), vanilla JavaScript, marked.js, highlight.js
**Storage**: N/A (in-memory state only)
**Testing**: Manual testing via exam completion flow
**Target Platform**: Linux (localhost web server)
**Project Type**: Web application (backend + frontend in same project)
**Performance Goals**: Score modal loads within 3 seconds
**Constraints**: No external dependencies, must work offline after initial page load
**Scale/Scope**: 4 exams, ~20-22 questions per exam, ~5-10 criteria per question

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Script-First Automation | ✅ PASS | No modification to scoring scripts needed - we parse existing output |
| II. Kubernetes-Native Tooling | ✅ PASS | No new K8s tooling required |
| III. Automated Scoring | ✅ PASS | Enhances scoring display, maintains deterministic scoring |
| IV. Exam Fidelity | ✅ PASS | No impact on exam behavior |
| V. Idempotent Operations | ✅ PASS | Display-only change, no state modification |
| VI. Modern UI | ✅ PASS | Improves user experience with detailed feedback |

**Gate Result**: PASS - No violations. Feature aligns with all constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/011-score-details/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
web/
├── server.py            # MODIFY: Parse criteria from scoring output
├── index.html           # MODIFY: Add expandable criteria UI elements
├── css/style.css        # MODIFY: Add criteria styling
└── js/app.js            # MODIFY: Handle criteria display logic
```

**Structure Decision**: Existing web application structure. All changes confined to `web/` directory. No new files needed - only modifications to existing files.

## Complexity Tracking

> No constitution violations requiring justification.
