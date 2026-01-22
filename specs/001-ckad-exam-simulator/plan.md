# Implementation Plan: CKAD Exam Simulator

**Branch**: `001-ckad-exam-simulator` | **Date**: 2025-12-04 | **Updated**: 2025-12-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-ckad-exam-simulator/spec.md`
**Status**: Implemented

## Summary

Create a local CKAD exam simulator with:

- Three bash scripts for setup, scoring, and cleanup
- A modern web interface with integrated 120-minute timer
- Multi-exam support for future expansion
- Full automation of 113+ scoring criteria

The simulator configures a kubeadm cluster with all pre-requisites for 24 exam questions, provides a realistic exam experience with time pressure, and automatically scores user answers.

## Technical Context

**Language/Version**: Bash 4.0+, Python 3.x, JavaScript (ES6+)
**Primary Dependencies**: kubectl, helm 3.x, docker, uv
**Storage**: Kubernetes cluster (in-memory), local filesystem (`./exam/course/`)
**Testing**: Manual verification, scoring script self-validates
**Target Platform**: Linux (kubeadm cluster)
**Project Type**: CLI scripts + Web interface
**Performance Goals**: Setup < 5 minutes, Scoring < 2 minutes, Web UI < 2s load
**Constraints**: Must use only CKAD exam-available tools, idempotent operations
**Scale/Scope**: 24 questions, 113+ scoring criteria, 11 namespaces, multi-exam support

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Script-First Automation | PASS | All operations via bash scripts |
| II. Kubernetes-Native Tooling | PASS | Only kubectl, helm, docker |
| III. Automated Scoring | PASS | All 113+ criteria automatically evaluated |
| IV. Exam Fidelity | PASS | Questions from simulation1.md, paths mapped |
| V. Idempotent Operations | PASS | All scripts designed for safe re-run |
| VI. Modern UI | PASS | Web interface with timer, dark/light mode |

**Gate Status**: PASSED - No violations

## Project Structure

### Documentation (this feature)

```text
specs/001-ckad-exam-simulator/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (Kubernetes resources)
├── quickstart.md        # Phase 1 output (usage guide)
├── tasks.md             # Phase 2 output
└── checklists/
    └── requirements.md  # Requirements checklist
```

### Source Code (repository root)

```text
ckad-dojo/
├── scripts/
│   ├── ckad-exam.sh            # Main exam launcher (web + terminal)
│   ├── ckad-setup.sh           # Environment setup script
│   ├── ckad-score.sh           # Scoring script
│   ├── ckad-cleanup.sh         # Cleanup script
│   └── lib/
│       ├── common.sh           # Shared functions & multi-exam support
│       ├── scoring-functions.sh # Per-question scoring
│       ├── setup-functions.sh   # Per-question setup & cleanup
│       └── timer.sh            # Terminal timer functions
├── web/
│   ├── server.py               # Python web server with API
│   ├── index.html              # Main HTML interface
│   ├── css/
│   │   └── style.css           # Modern styles (dark/light themes)
│   └── js/
│       └── app.js              # JavaScript application logic
├── exams/
│   └── ckad-simulation1/       # First exam
│       ├── exam.conf           # Exam configuration
│       ├── questions.md        # Questions (no answers)
│       ├── scoring-functions.sh # Exam-specific scoring
│       ├── manifests/setup/    # K8s manifests for pre-existing resources
│       └── templates/          # Template files for questions
├── manifests/setup/            # Legacy location (backward compat)
├── templates/                  # Legacy location (backward compat)
├── exam/course/                # Created by setup (user answers)
├── simulation1.md              # Original questions with answers
└── scorring.md                 # Scoring criteria reference
```

**Structure Decision**: Multi-exam architecture with exam-specific files in `exams/` directory, web interface in `web/`, shared scripts in `scripts/`.

## Key Components

### 1. Exam Launcher (ckad-exam.sh)

Entry point for all exam operations:

- `web` (default): Launch web interface with timer
- `start`: Terminal-only mode with background timer
- `list`: Show available exams
- `status`: Check current exam state
- `stop`: End exam session

### 2. Web Interface (web/)

Modern single-page application:

- Python server for static files and API
- Real-time 120-minute countdown timer
- Question navigation (arrows, dropdown, keyboard)
- Flag questions for review
- Dark/light theme toggle
- Markdown rendering with syntax highlighting

### 3. Multi-Exam Support (exams/)

Extensible exam architecture:

- Each exam in its own directory
- `exam.conf` defines duration, questions, scoring
- Exam-specific manifests and templates
- Exam-specific scoring functions

### 4. Scoring System

Automated evaluation of 113+ criteria:

- Per-question scoring functions
- File content verification
- Kubernetes resource state checks
- Docker image verification (Q11)

## Implementation Phases

### Phase 1: Core Infrastructure (Completed)

- Directory structure and manifests
- Setup, score, cleanup scripts
- Library functions

### Phase 2: Multi-Exam Architecture (Completed)

- Exam configuration system
- Exam selection in all scripts
- Timer library

### Phase 3: Web Interface (Completed)

- Python server with API
- HTML/CSS/JS interface
- Timer integration
- Question navigation and flagging

### Phase 4: Stop Exam & Scoring Integration (Completed)

- "Stop Exam" button in web interface
- API endpoint `/api/score` for scoring
- Score results modal with detailed breakdown
- Pass/fail status display (66% threshold)
- Elapsed time tracking
- Per-question score display

## Complexity Tracking

No violations to justify - all requirements align with constitution principles.

## Testing Strategy

1. **Setup Testing**: Verify all resources created correctly
2. **Scoring Testing**: Test with known answers for expected scores
3. **Cleanup Testing**: Verify clean removal of all resources
4. **Web Interface Testing**: Manual testing of UI features
5. **Multi-Exam Testing**: Create second exam, verify isolation
