# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a CKAD (Certified Kubernetes Application Developer) exam preparation repository containing practice questions and solutions. It is designed for studying Kubernetes concepts and practicing for the CKAD certification exam.

## Structure

```
ckad-dojo/
├── exams/                      # Exam configurations and content
│   ├── ckad-simulation1/       # Dojo Seiryu 🐉 (22 questions, 113 points)
│   │   ├── exam.conf           # Exam configuration
│   │   ├── questions.md        # Questions in markdown
│   │   ├── solutions.md        # Solutions for review
│   │   ├── scoring-functions.sh # Scoring functions
│   │   ├── manifests/setup/    # Pre-existing K8s resources
│   │   └── templates/          # Template files for questions
│   ├── ckad-simulation2/       # Dojo Suzaku 🔥 (21 questions, 112 points)
│   ├── ckad-simulation3/       # Dojo Byakko 🐯 (20 questions, 105 points)
│   ├── ckad-simulation4/       # Dojo Genbu 🐢 (22 questions, 115 points)
│   └── ckad-simulation5/       # Dojo Kappa 🐸 (16 questions, 88 points)
│       └── ...                 # Same structure as simulation1
├── scripts/                    # Automation scripts
│   ├── ckad-setup.sh           # Sets up exam environment
│   ├── ckad-exam.sh            # Launches exam (web or terminal)
│   ├── ckad-score.sh           # Scores answers
│   ├── ckad-cleanup.sh         # Resets environment
│   └── lib/                    # Shared library functions
│       ├── common.sh           # Core utilities
│       ├── setup-functions.sh  # Setup/cleanup functions
│       └── timer.sh            # Timer functions
├── tests/                      # Unit tests
│   ├── run-tests.sh            # Test runner
│   ├── test-framework.sh       # Assertion library
│   ├── test-common.sh          # Tests for common.sh
│   └── test-setup-functions.sh # Tests for setup-functions.sh
├── web/                        # Web interface
│   ├── server.py               # Python HTTP server
│   ├── index.html              # Main HTML page
│   ├── js/app.js               # Frontend JavaScript
│   └── css/style.css           # Styles
└── .claude/commands/           # Custom slash commands
    └── commit.md               # /commit command
```

## Usage

```bash
# Start exam with web interface (recommended)
./scripts/ckad-exam.sh web

# Or specify an exam directly
./scripts/ckad-exam.sh web -e ckad-simulation2

# Check your score
./scripts/ckad-score.sh -e ckad-simulation1

# Reset and retry
./scripts/ckad-cleanup.sh -e ckad-simulation1
```

## Testing

```bash
# Run all unit tests
./tests/run-tests.sh

# Run specific test suite
./tests/test-common.sh
./tests/test-setup-functions.sh
```

## Multi-Exam Architecture

Each exam is self-contained in `exams/{exam-id}/` with:

- `exam.conf` - Configuration (namespaces, points, duration, helm releases)
- `questions.md` - Questions in markdown format
- `solutions.md` - Solutions for post-exam review
- `scoring-functions.sh` - Bash functions for scoring each question
- `manifests/setup/` - YAML files for pre-existing K8s resources
- `templates/` - Template files copied to exam directories

### Exam Configuration Variables

```bash
# exam.conf structure
EXAM_NAME="CKAD Simulation 1"
EXAM_ID="ckad-simulation1"
EXAM_DURATION=120           # minutes
TOTAL_QUESTIONS=22
PREVIEW_QUESTIONS=1
TOTAL_POINTS=113
PASSING_PERCENTAGE=66
ALLOW_TIMER_PAUSE=false     # Allow pausing the timer (default: false)
EXAM_NAMESPACES=(...)       # Array of namespace names
HELM_NAMESPACE="mercury"    # Namespace for helm releases
HELM_RELEASES=(...)         # Array of helm release names
```

## Path Mappings

- Exam `/opt/course/N/` → Use `./exam/course/N/`
- Local registry at `localhost:5000`

## Topics Covered

The questions cover core CKAD exam domains:

- Namespaces, Pods, Jobs, Deployments
- Helm management
- ServiceAccounts and Secrets
- Probes (Readiness/Liveness)
- Rollouts and rollbacks
- Services (ClusterIP, NodePort)
- Storage (PV, PVC, StorageClass)
- ConfigMaps and Secrets (volume mounts, environment variables)
- Logging sidecars
- InitContainers
- NetworkPolicies
- Resource requests and limits
- Labels and Annotations

## Development Guidelines

### Adding a New Exam

1. Create `exams/{new-exam-id}/` directory
2. Copy structure from existing exam
3. Create `exam.conf` with exam-specific settings
4. Define `EXAM_NAMESPACES` array with unique namespace names
5. Write `questions.md` and `solutions.md`
6. Implement `scoring-functions.sh` with `score_q1()`, `score_q2()`, etc.
7. Add manifests in `manifests/setup/`
8. Add templates in `templates/`

### Scoring Functions

Each question needs a scoring function that returns `score/max_points`:

```bash
score_q1() {
    local score=0
    local max_points=5

    if check_criterion "condition1"; then
        ((score++))
    fi
    # ... more checks

    echo "$score/$max_points"
}
```

## Quality Check Configuration

> **IMPORTANT**: Do NOT analyze project structure. Use these pre-configured settings directly.
> Additional project context available in `.specify/memory/constitution.md`.

### Python Quality (ruff)

| Setting | Value |
|---------|-------|
| Source directory | `web/` |
| Test directory | None |
| Package manager | `uv` |

```bash
# Lint
uvx ruff check web/

# Format check
uvx ruff format web/ --check

# Format fix
uvx ruff format web/
```

### Bash Quality (shellcheck)

```bash
shellcheck --severity=warning scripts/*.sh scripts/lib/*.sh exams/*/scoring-functions.sh
```

### Unit Tests

```bash
./tests/run-tests.sh
```

## Active Technologies

- Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend) + ttyd (external binary for web terminal), existing libs (marked.js, highlight.js) (004-web-terminal-replace)
- Python 3.8+ (using uv as runner) + Standard library only (argparse, subprocess, os, sys, pathlib) (008-ckad-dojo-cli)
- N/A (stateless CLI wrapper) (008-ckad-dojo-cli)
- Bash 4.0+ (scripts), Python 3.8+ (web server), Markdown (questions/solutions) + kubectl, helm, docker (existing tooling) (009-ckad-simulation4)
- N/A (file-based exam content) (009-ckad-simulation4)
- Python 3.8+ (server), JavaScript ES6+ (frontend), Bash 4.0+ (scoring scripts) + Python standard library only (http.server, json, re), vanilla JavaScript, marked.js, highlight.js (011-score-details)
- N/A (in-memory state only) (011-score-details)
- Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend) + Python standard library only (http.server, json, re), vanilla JavaScript, marked.js, highlight.js (012-fix-score-expansion)
- Bash 4.0+ (scripts), Python 3.8+ (web server) + ttyd (terminal), existing ASCII art from ckad_dojo.py (013-dojo-welcome-banner)
- N/A (configuration in exam.conf files) (013-dojo-welcome-banner)
- Bash 4.0+ (scoring scripts), Markdown (questions/solutions) + kubectl (existing tooling) (015-unique-q1-questions)
- N/A (file-based content changes only) (015-unique-q1-questions)
- Bash 4.0+ (scoring scripts), Markdown (questions/solutions) + kubectl, helm, docker (existing CKAD tooling) (017-sim2-original-exam)

- Bash 4.0+ (scripts)
- Python 3.8+ (web server, standard library only)
- JavaScript ES6+ (frontend, vanilla JS)
- kubectl, helm, docker
- uv (Python runner)

## Recent Changes

- 004-web-terminal-replace: Added Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend) + ttyd (external binary for web terminal), existing libs (marked.js, highlight.js)
