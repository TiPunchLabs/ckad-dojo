# Architecture

> **Prerequisites**: Read the README.md for the project's functional context.

## Mental Model

```
                          User
                       /        \
                      /          \
              [Python CLI]    [Browser]
              ckad_dojo.py        |
                   |         web/server.py ── index.html + app.js
                   |              |
              subprocess      subprocess
                   |              |
              scripts/ckad-*.sh ◄─┘
                   |
            ┌──────┼──────┐
            │      │      │
         kubectl  helm  docker
            │
      Kubernetes Cluster
```

The project follows a **layered architecture**:

1. **Presentation layer**: Interactive Python CLI or web interface
2. **Orchestration layer**: Bash scripts that execute the exam lifecycle
3. **Infrastructure layer**: kubectl, helm, docker for K8s operations

------

## Main Components

### Python CLI (`ckad_dojo.py`)

Main entry point. Provides an interactive menu and subcommands
(`exam start`, `score`, `cleanup`, `list`, `info`, `status`, `completion`).

It acts as a **lightweight orchestrator**: it contains no business logic but
delegates all operations to Bash scripts via `subprocess.run()`.

```
ckad_dojo.py
  ├── Interactive menu (no-argument mode)
  ├── argparse subcommands + argcomplete
  └── run_script() ──> scripts/ckad-*.sh
```

### Web Server (`web/server.py`)

Python standard library HTTP server (`http.server`) with no external framework.
Launched by `ckad-exam.sh` in web mode. Listens on `localhost:9090`.

**Responsibilities**:

- Serves static files (`index.html`, `app.js`, `style.css`)
- Exposes a JSON REST API for the frontend
- Manages the exam timer in memory
- Runs scoring and cleanup via subprocess

**Main endpoints**:

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/exams` | List available exams |
| GET | `/api/exam/{id}/questions` | Questions parsed from `questions.md` |
| GET | `/api/exam/{id}/config` | Exam configuration |
| GET | `/api/exam/{id}/solutions` | Solutions (post-exam) |
| GET | `/api/timer` | Timer state |
| POST | `/api/score` | Stop timer + run scoring |
| POST | `/api/cleanup` | Run cleanup |
| POST | `/api/shutdown` | Graceful server shutdown |

### Frontend (`web/`)

Vanilla JavaScript application (ES6+) with no framework.

- **Markdown rendering**: `marked.js` + `highlight.js` for questions and solutions
- **Icons**: Lucide
- **Interface**: question panel (left) + embedded ttyd terminal (right, iframe)
- **Features**: question navigation, timer, flags, dark/light theme, keyboard shortcuts, score modal with per-criteria details

### Bash Scripts (`scripts/`)

Operational core of the project. Four main scripts + shared libraries.

```
scripts/
  ├── ckad-setup.sh          # K8s environment preparation
  ├── ckad-exam.sh           # Exam launcher (web or terminal)
  ├── ckad-score.sh          # Answer evaluation
  ├── ckad-cleanup.sh        # Environment cleanup
  └── lib/
      ├── common.sh          # Utilities (colors, kubectl helpers, ttyd, state)
      ├── setup-functions.sh # Setup and cleanup functions
      ├── timer.sh           # File-based timer (PID, state, countdown)
      └── banner.sh          # ASCII banner for the terminal
```

------

## Exam Lifecycle

```
 1. SETUP                2. EXAM                 3. SCORE               4. CLEANUP
 ckad-setup.sh           ckad-exam.sh            ckad-score.sh          ckad-cleanup.sh
 ┌──────────────┐        ┌──────────────┐        ┌──────────────┐       ┌──────────────┐
 │ Create NS    │        │ Start ttyd   │        │ Load         │       │ Stop timer   │
 │ Deploy       │───────>│ Start        │───────>│  scoring-    │──────>│ Uninstall    │
 │  manifests   │        │  server.py   │        │  functions   │       │  Helm        │
 │ Copy         │        │ Open         │        │ Evaluate     │       │ Delete NS    │
 │  templates   │        │  browser     │        │  score_q1()  │       │ Delete PV    │
 │ Registry     │        │              │        │  ...         │       │ Remove       │
 │ Helm charts  │        │              │        │  score_qN()  │       │  registry    │
 │ Post-setup   │        │              │        │ Display      │       │ Clean up     │
 │              │        │              │        │  results     │       │  Docker      │
 └──────────────┘        └──────────────┘        └──────────────┘       └──────────────┘
        │                                                                       │
        └── State saved in /tmp/ckad-dojo/active-exam.state ────────────────────┘
```

------

## Exam Structure

Each exam is a self-contained directory under `exams/{exam-id}/`:

```
exams/ckad-simulation1/
  ├── exam.conf              # Configuration (duration, points, namespaces, options)
  ├── questions.md           # Questions in Markdown with metadata table
  ├── solutions.md           # Solutions for post-exam review
  ├── scoring-functions.sh   # Bash functions: score_q1(), score_q2(), ...
  ├── manifests/
  │   └── setup/
  │       ├── namespaces.yaml    # Namespace definitions
  │       └── *.yaml             # Pre-existing K8s resources
  └── templates/
      ├── q01-file.yaml          # Files copied to exam/course/N/
      └── q11-image/             # Directories (Dockerfile, etc.)
```

**Key `exam.conf` variables**:

| Variable | Description |
|----------|-------------|
| `EXAM_NAME` | Display name |
| `EXAM_DURATION` | Duration in minutes |
| `TOTAL_QUESTIONS` / `TOTAL_POINTS` | Exam dimensions |
| `PASSING_PERCENTAGE` | Pass threshold (default 66%) |
| `EXAM_NAMESPACES=()` | Array of namespaces to create |
| `HELM_RELEASES=()` | Helm releases to install |
| `ALLOW_TIMER_PAUSE` | Allow timer pause |
| `ALLOW_HINTS` | Allow hints |
| `DOJO_NAME` / `DOJO_EMOJI` | Dojo thematic identity |

------

## Scoring Mechanism

```
scoring-functions.sh                    web/server.py
┌─────────────────────┐                ┌──────────────────────┐
│ score_q1() {        │   stdout       │ run_scoring_script() │
│   # kubectl checks  │ ──────────────>│   parse output:      │
│   echo "2/3"        │                │   - regex Q(\d+)     │
│   echo "DETAILS:..."│                │   - regex TOTAL      │
│ }                   │                │   - parse DETAILS:   │
└─────────────────────┘                │   return JSON        │
                                       └──────────────────────┘
```

Each `score_qN()` function:

1. Checks K8s resources via helpers (`resource_exists`, `get_resource_field`)
2. Prints pass/fail markers (checkmark/cross) per criterion
3. Returns `score/max_points` on stdout
4. Returns `DETAILS:item1. item2.` for criteria details

The web server parses this output with regex and builds a structured JSON
response for the interface.

------

## External Integrations

| Tool | Role | Usage |
|------|------|-------|
| **kubectl** | K8s operations | Setup (create/apply), scoring (get/describe), cleanup (delete) |
| **helm** | Helm charts | Install releases for Helm-related questions |
| **docker** | Local registry | `registry:2` on `localhost:5000` for build questions |
| **ttyd** | Web terminal | Embedded in the interface via iframe on port 7682 |
| **uv** | Python manager | Runs the server, tests, and linting |

------

## Test Infrastructure

### Bash Tests (`tests/`)

Custom test framework (`test-framework.sh`) with assertions:

```
tests/
  ├── run-tests.sh            # Runner: executes all test-*.sh files
  ├── test-framework.sh       # Assertions (assert_true, assert_equals, ...)
  ├── test-common.sh          # Tests for scripts/lib/common.sh
  ├── test-setup-functions.sh # Tests for scripts/lib/setup-functions.sh
  ├── test-timer.sh           # Tests for scripts/lib/timer.sh
  ├── test-banner.sh          # Tests for scripts/lib/banner.sh
  └── test-scoring.sh         # Tests for scoring functions
```

### Python Tests (`tests/python/`)

57 unit tests via pytest + pytest-cov:

| Module | Coverage |
|--------|----------|
| `ckad_dojo.py` | CLI, config parsing, exam discovery |
| `web/server.py` | Parsing, config, questions, solutions |
| `scripts/bump-version.py` | Validation, version reading, file update |

### CI Pipeline (`.github/workflows/ci.yml`)

```
  Stage 1          Stage 2              Stage 3
 ┌──────┐     ┌──────┐  ┌──────┐     ┌──────┐
 │ Lint │────>│ Test │  │Secu. │────>│Build │
 │      │     │      │  │      │     │      │
 └──────┘     └──────┘  └──────┘     └──────┘
                 │           │
              parallel    parallel
```

- **Lint**: `pre-commit run --all-files` (ruff, shellcheck, mypy, markdownlint, etc.)
- **Test**: Bash tests + pytest with coverage
- **Security**: `pip-audit` + `gitleaks`
- **Build**: `uv build` + artifact upload

------

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Python standard library only (server) | Zero external dependencies, simple deployment |
| Bash for business logic | Direct interaction with kubectl/helm/docker without abstraction layer |
| Python CLI as orchestrator | Ergonomics (argparse, completion, interactive menu) without duplicating logic |
| In-memory timer (server) | Simplicity, no persistence needed for an ephemeral exam |
| Self-contained exams | Each dojo is an independent directory, making it easy to add new exams |
| Vanilla JS frontend | No build step, direct loading, minimal CDN dependencies |

------

> **Document created**: 2026-02-17
> **Version**: 1.0
