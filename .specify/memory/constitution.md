<!--
  SYNC IMPACT REPORT
  ==================
  Version change: 1.0.0 → 2.0.0

  Modified principles:
  - [NEW] VI. Modern UI - Web interface with timer

  Modified sections:
  - Technical Constraints: Added web/ directory structure
  - Exam Environment: Removed exclusions (timer and web UI now implemented)

  Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ Compatible (no changes needed)
  - .specify/templates/spec-template.md: ✅ Compatible (no changes needed)
  - .specify/templates/tasks-template.md: ✅ Compatible (no changes needed)

  Follow-up TODOs: None
-->

# ckad-dojo Constitution

## Core Principles

### I. Script-First Automation

All exam environment operations MUST be fully automated via scripts:
- `ckad_dojo.py`: Unified Python CLI providing interactive menu and direct commands
- `ckad-setup.sh`: Configures the cluster with all pre-requisites
- `ckad-exam.sh`: Launches the exam interface
- `ckad-score.sh`: Evaluates answers and calculates scores
- `ckad-cleanup.sh`: Removes all exam-related resources

The Python CLI (`uv run ckad-dojo`) wraps existing bash scripts without modifying their functionality.

Scripts MUST be idempotent and safe to re-run. Manual intervention MUST NOT be required for standard operations.

### II. Kubernetes-Native Tooling

All Kubernetes operations MUST use native tooling:
- `kubectl` for all cluster operations
- `helm` for Helm-based questions
- `docker` and `podman` for container image operations

Scripts MUST NOT introduce external dependencies beyond standard CKAD exam tools. This ensures users practice with the same tools available during the real exam.

### III. Automated Scoring

The scoring system MUST automatically verify each criterion defined in `scorring.md`:
- Each question has explicit pass/fail criteria
- Partial scores are calculated per question
- Total score displayed with percentage
- Detailed feedback per criterion (PASS/FAIL)

Scoring MUST be deterministic: same cluster state = same score.

### IV. Exam Fidelity

The simulator MUST faithfully reproduce CKAD exam conditions:
- Questions match content from `simulation1.md`
- Namespaces and resource names match exam specifications
- Pre-existing resources (Deployments, Pods, Services) are created exactly as expected
- File paths use local equivalent (`./exam/course/`) of exam paths (`/opt/course/`)

Deviations from exam conditions MUST be documented in setup output.

### V. Idempotent Operations

All scripts MUST be safely re-runnable:
- Setup: Skip already-existing resources, recreate missing ones
- Score: Read-only operations, no state modification
- Cleanup: No errors on already-deleted resources

Failed partial runs MUST be recoverable by re-running the same script.

### VI. Modern UI

The web interface MUST provide a realistic exam experience:
- Integrated 120-minute countdown timer with visual warnings
- Question navigation via keyboard, buttons, and dropdown
- Flag questions for later review
- Dark and light theme support
- Markdown rendering with syntax highlighting
- Time's up notification that blocks the interface

The web interface is served locally via Python HTTP server using `uv run` and requires no external dependencies beyond the Python standard library.

## Technical Constraints

**Cluster Type**: kubeadm (user's existing cluster)
**Required Tools**: kubectl, helm, docker, podman, ttyd, bash 4.0+, uv
**File Structure**:
```
ckad-dojo/
├── ckad_dojo.py           # Unified Python CLI
├── pyproject.toml         # Python project config (uv)
├── scripts/
│   ├── ckad-exam.sh       # Main exam launcher (web + terminal)
│   ├── ckad-setup.sh
│   ├── ckad-score.sh
│   ├── ckad-cleanup.sh
│   └── lib/               # Shared functions
├── web/
│   ├── server.py          # Python web server with API
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
├── exams/
│   ├── ckad-simulation1/  # 22 questions, 113 points (planetary theme)
│   ├── ckad-simulation2/  # 21 questions, 112 points (constellation theme)
│   ├── ckad-simulation3/  # 20 questions, 105 points (Greek mythology theme)
│   └── ckad-simulation4/  # 22 questions, 115 points (Norse mythology theme)
│       ├── exam.conf
│       ├── questions.md
│       ├── solutions.md
│       ├── scoring-functions.sh
│       ├── manifests/setup/
│       └── templates/
├── exam/
│   └── course/
│       ├── 1/ through N/
│       └── p1/, p2/  (preview questions)
└── tests/                 # Unit tests
```

**Namespaces Required**: default, neptune, saturn, earth, mars, pluto, jupiter, mercury, venus, moon, sun, shell-intern

**External Dependencies**: Local Docker registry (deployed in-cluster for Q11)

## Exam Environment

**Exam Sets**: 4 simulation exams (85 questions total, 445 points)
- ckad-simulation1: 22 questions, 113 points (planetary theme namespaces)
- ckad-simulation2: 21 questions, 112 points (constellation theme namespaces)
- ckad-simulation3: 20 questions, 105 points (Greek mythology theme namespaces)
- ckad-simulation4: 22 questions, 115 points (Norse mythology theme namespaces)

**Duration**: 120 minutes (configurable per exam in exam.conf)

**Implemented Features**:
- Unified Python CLI (`uv run ckad-dojo`) with interactive menu and direct commands
- Web interface with integrated timer at http://localhost:9090
- Question navigation with keyboard shortcuts (← → F)
- Flag questions for review
- Dark/light theme toggle
- Visual timer warnings (yellow 15 min, orange 5 min, red 1 min)
- Timer pause/resume button with visual feedback
- Multi-exam support via exams/ directory
- Stop Exam button with custom styled modal (replaces browser confirm)
- Score modal with pass/fail status (66% threshold), elapsed time, and per-question breakdown
- Detailed criteria display in score modal: expand/collapse per question to view PASS/FAIL criteria
- Visual score indicators: green ✓ (full), orange ⚠ (partial), red ✗ (zero)
- Interactive exam selection menu at launch
- Starting question selection (-q option or interactive prompt)
- Automatic detection of existing exam resources with cleanup offer
- Embedded web terminal via ttyd (split layout with resizable divider)
- Graceful cleanup on Close: runs ckad-cleanup.sh and stops server
- Auto-open K8s and Helm documentation tabs (--no-docs to disable)

**Not Implemented**:
- No SSH simulation (single cluster context)

**Adaptations**:
- Local registry at `localhost:5000`
- File paths `/opt/course/` mapped to `./exam/course/`

## Governance

This constitution governs all development on the ckad-dojo project:
- All scripts MUST adhere to these principles
- Deviations require explicit justification in code comments
- Version updates follow semantic versioning
- Constitution amendments require updating this file and dependent templates

**Version**: 2.7.0 | **Ratified**: 2025-12-04 | **Last Amended**: 2025-12-09
