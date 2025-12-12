# Feature Specification: Centralized CKAD-Dojo CLI

**Feature Branch**: `008-ckad-dojo-cli`
**Created**: 2025-12-08
**Status**: Draft
**Input**: Script CLI centralisé ckad-dojo en Python (uv) qui unifie toutes les commandes: setup, exam, score, cleanup. Interface interactive avec menu, support des options en ligne de commande, et intégration avec le système d'examen existant.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Launch Exam via Single Command (Priority: P1)

A user wants to start a CKAD exam practice session with a single command that handles everything: selecting an exam, setting up the environment, and launching the interface.

**Why this priority**: Core value proposition - simplifies the workflow from multiple script calls to one unified command.

**Independent Test**: Run `uv run ckad-dojo` and verify interactive menu appears, then select an exam and confirm it launches correctly.

**Acceptance Scenarios**:

1. **Given** the user is in the project directory, **When** they run `uv run ckad-dojo`, **Then** an interactive menu displays available options (start exam, score, cleanup, etc.)
2. **Given** the interactive menu is shown, **When** user selects "Start Exam", **Then** available exams are listed for selection
3. **Given** user selects an exam, **When** they confirm, **Then** the setup runs automatically followed by the web interface launch

---

### User Story 2 - Direct Command Line Operations (Priority: P1)

A user wants to run specific operations directly via command line arguments without navigating through menus, for scripting and automation purposes.

**Why this priority**: Power users and automation require direct command access.

**Independent Test**: Run `uv run ckad-dojo exam start -e ckad-simulation1` and verify the exam starts without interactive prompts.

**Acceptance Scenarios**:

1. **Given** user knows the exam name, **When** they run `uv run ckad-dojo exam start -e ckad-simulation1`, **Then** the exam starts directly without prompts
2. **Given** an exam is completed, **When** user runs `uv run ckad-dojo score -e ckad-simulation1`, **Then** the scoring runs and displays results
3. **Given** resources exist, **When** user runs `uv run ckad-dojo cleanup -e ckad-simulation1`, **Then** all exam resources are removed

---

### User Story 3 - View Exam Status and Information (Priority: P2)

A user wants to check the current state of exams, see available exams, and get information about their configuration.

**Why this priority**: Important for orientation and troubleshooting but not blocking for core functionality.

**Independent Test**: Run `uv run ckad-dojo list` and verify all available exams are displayed with their details.

**Acceptance Scenarios**:

1. **Given** multiple exams exist, **When** user runs `uv run ckad-dojo list`, **Then** all exams are shown with name, questions count, and total points
2. **Given** an exam is running, **When** user runs `uv run ckad-dojo status`, **Then** current exam name, elapsed time, and resource state are displayed
3. **Given** user wants details, **When** they run `uv run ckad-dojo info -e ckad-simulation1`, **Then** full exam configuration is displayed

---

### User Story 4 - Quick Setup Only (Priority: P2)

A user wants to set up the exam environment without starting the exam interface, for manual practice or testing.

**Why this priority**: Supports advanced workflows where users want to practice kubectl commands without the exam interface.

**Independent Test**: Run `uv run ckad-dojo setup -e ckad-simulation1` and verify namespaces are created without web interface launch.

**Acceptance Scenarios**:

1. **Given** no exam resources exist, **When** user runs `uv run ckad-dojo setup -e ckad-simulation1`, **Then** namespaces, resources, and templates are created
2. **Given** setup completes, **When** user checks cluster state, **Then** all expected namespaces and resources exist
3. **Given** setup is run twice, **When** resources already exist, **Then** operation is idempotent and shows appropriate status

---

### User Story 5 - Help and Documentation Access (Priority: P3)

A user wants to understand available commands and options without leaving the terminal.

**Why this priority**: Essential for discoverability but users can function without it.

**Independent Test**: Run `uv run ckad-dojo --help` and verify comprehensive help is displayed.

**Acceptance Scenarios**:

1. **Given** user runs with `--help`, **When** executed, **Then** all available commands and global options are listed
2. **Given** user runs `uv run ckad-dojo exam --help`, **When** executed, **Then** exam-specific options are displayed
3. **Given** no arguments provided and non-interactive mode, **When** executed, **Then** usage hint is displayed

---

### Edge Cases

- What happens when Kubernetes cluster is not accessible? Display clear error message with troubleshooting steps.
- What happens when no exams are found in the exams directory? Display informative message pointing to documentation.
- What happens when exam setup fails midway? Offer cleanup option and display partial state information.
- What happens when user interrupts with Ctrl+C? Clean shutdown with appropriate cleanup prompts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: CLI MUST provide an interactive menu when run without arguments
- **FR-002**: CLI MUST support direct command execution via subcommands (exam, setup, score, cleanup, list, status, info)
- **FR-003**: CLI MUST integrate with existing bash scripts without modifying their functionality
- **FR-004**: CLI MUST display ASCII banner consistent with existing scripts
- **FR-005**: CLI MUST support exam selection via `-e/--exam` option for all relevant commands
- **FR-006**: CLI MUST provide colored output for better readability (with `--no-color` option for automation)
- **FR-007**: CLI MUST validate prerequisites (kubectl, helm, docker) before operations
- **FR-008**: CLI MUST work with `uv run` without requiring package installation
- **FR-009**: CLI MUST discover available exams dynamically from the exams/ directory
- **FR-010**: CLI MUST handle keyboard interrupts gracefully with cleanup prompts

### Key Entities

- **Exam**: Identified by exam-id, contains configuration (exam.conf), questions, solutions, and scoring
- **Command**: Subcommand representing an operation (exam, setup, score, cleanup, list, status, info)
- **ExamState**: Current state of an exam (not-setup, ready, running, completed)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can start a complete exam session with a single command in under 10 seconds (excluding cluster setup time)
- **SC-002**: All existing script functionality remains accessible through the new CLI
- **SC-003**: Interactive menu navigation requires no more than 3 selections to start an exam
- **SC-004**: Command execution with direct arguments works without any interactive prompts
- **SC-005**: Help output covers 100% of available commands and options
- **SC-006**: CLI startup time is under 1 second before displaying menu or executing commands

## Assumptions

- Python 3.8+ is available on the system
- `uv` is installed and available in PATH
- Existing bash scripts in scripts/ directory will be called by the Python CLI (wrapper approach)
- Terminal supports ANSI color codes (with fallback for `--no-color`)
- User has appropriate permissions to run kubectl, helm, and docker commands
