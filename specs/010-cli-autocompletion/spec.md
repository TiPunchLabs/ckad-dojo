# Feature Specification: CLI Shell Autocompletion

**Feature Branch**: `010-cli-autocompletion`
**Created**: 2025-12-09
**Status**: Draft
**Input**: User description: "Ajouter l'autocomplétion shell (bash, zsh, fish) au CLI ckad-dojo. L'utilisateur doit pouvoir générer et installer les scripts de complétion pour son shell. Les commandes (exam, score, setup, cleanup), sous-commandes (start, list) et options (-e, --exam) doivent être complétées automatiquement. Ajouter une commande 'ckad-dojo completion' pour générer les scripts."

## Problem Statement

Currently, users must remember and type all CLI commands, subcommands, and options manually. This is error-prone and slows down the workflow, especially for new users discovering the available commands.

Adding shell autocompletion improves:
- **Discoverability**: Users can explore commands by pressing Tab
- **Efficiency**: Faster command entry without looking up documentation
- **Accuracy**: Reduces typos and invalid command combinations

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Bash Completion Script (Priority: P1)

As a user with bash shell, I want to generate and install a completion script so that I can autocomplete ckad-dojo commands with Tab.

**Why this priority**: Bash is the most widely used shell on Linux systems, which is the primary platform for Kubernetes/CKAD practice.

**Independent Test**: Run `uv run ckad-dojo completion bash` and verify a valid bash completion script is output.

**Acceptance Scenarios**:

1. **Given** I run `uv run ckad-dojo completion bash`, **When** the command completes, **Then** a valid bash completion script is printed to stdout.
2. **Given** I have installed the bash completion script, **When** I type `uv run ckad-dojo ` and press Tab, **Then** I see available commands (exam, setup, score, cleanup, list, info, status, completion).
3. **Given** I have installed the bash completion script, **When** I type `uv run ckad-dojo exam ` and press Tab, **Then** I see available subcommands (start, stop).
4. **Given** I have installed the bash completion script, **When** I type `uv run ckad-dojo score -` and press Tab, **Then** I see available options (-e, --exam, --help).

---

### User Story 2 - Generate Zsh Completion Script (Priority: P2)

As a user with zsh shell, I want to generate a completion script so that I can autocomplete ckad-dojo commands with Tab.

**Why this priority**: Zsh is the default shell on macOS and popular among developers.

**Independent Test**: Run `uv run ckad-dojo completion zsh` and verify a valid zsh completion script is output.

**Acceptance Scenarios**:

1. **Given** I run `uv run ckad-dojo completion zsh`, **When** the command completes, **Then** a valid zsh completion script is printed to stdout.
2. **Given** I have installed the zsh completion script, **When** I type `ckad-dojo ` and press Tab, **Then** I see available commands with descriptions.

---

### User Story 3 - Generate Fish Completion Script (Priority: P3)

As a user with fish shell, I want to generate a completion script so that I can autocomplete ckad-dojo commands.

**Why this priority**: Fish is growing in popularity and has a different completion syntax.

**Independent Test**: Run `uv run ckad-dojo completion fish` and verify a valid fish completion script is output.

**Acceptance Scenarios**:

1. **Given** I run `uv run ckad-dojo completion fish`, **When** the command completes, **Then** a valid fish completion script is printed to stdout.

---

### User Story 4 - Show Installation Instructions (Priority: P1)

As a user, I want to see clear installation instructions for my shell so that I can easily set up autocompletion.

**Why this priority**: Without instructions, users won't know how to install the generated script.

**Independent Test**: Run `uv run ckad-dojo completion --help` and verify installation instructions are displayed.

**Acceptance Scenarios**:

1. **Given** I run `uv run ckad-dojo completion --help`, **When** the output is displayed, **Then** I see installation instructions for each supported shell.
2. **Given** I run `uv run ckad-dojo completion bash --install-instructions`, **When** the output is displayed, **Then** I see specific installation steps for bash.

---

### User Story 5 - Dynamic Exam ID Completion (Priority: P2)

As a user, I want the `-e/--exam` option to autocomplete with available exam IDs so that I don't have to remember or type them manually.

**Why this priority**: This is the most commonly used option, and exam IDs can be long (e.g., ckad-simulation1).

**Independent Test**: Type `uv run ckad-dojo score -e ` and press Tab to see available exam IDs.

**Acceptance Scenarios**:

1. **Given** I have completion installed and exam directories exist, **When** I type `uv run ckad-dojo score -e ` and press Tab, **Then** I see available exam IDs (ckad-simulation1, ckad-simulation2, etc.).
2. **Given** I type `uv run ckad-dojo exam start -e ckad-s` and press Tab, **Then** the partial text completes to matching exam IDs.

---

### Edge Cases

- What happens if the exams directory is empty? → Exam ID completion returns no suggestions (graceful handling)
- What happens if the user doesn't have the target shell installed? → Script generation still works (shell not required to generate)
- What happens if uv is not in PATH? → Completion assumes standard invocation pattern, works with any Python entry point

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: CLI MUST provide a `completion` subcommand to generate shell completion scripts
- **FR-002**: The `completion` subcommand MUST support `bash`, `zsh`, and `fish` as arguments
- **FR-003**: Generated completion scripts MUST be output to stdout for flexible installation
- **FR-004**: Completion scripts MUST complete all top-level commands: exam, setup, score, cleanup, list, info, status, completion
- **FR-005**: Completion scripts MUST complete subcommands: exam start, exam stop
- **FR-006**: Completion scripts MUST complete options: --version, -V, --no-color, --help, -h, -e, --exam
- **FR-007**: The `-e/--exam` option MUST dynamically complete with available exam IDs from the exams/ directory
- **FR-008**: The `completion` command MUST display installation instructions when `--help` is used
- **FR-009**: Running `completion` without a shell argument MUST show an error with supported shells

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can generate a working completion script in under 1 second
- **SC-002**: All 8 top-level commands are completable after installation
- **SC-003**: All subcommands and options are completable for each command
- **SC-004**: Dynamic exam ID completion works with any number of exams (0 to N)
- **SC-005**: Installation instructions are clear enough for first-time users to set up completion without external documentation

## Technical Notes

### Current CLI Structure (from ckad_dojo.py)

Commands and their options:
- `exam start [-e/--exam]`
- `exam stop`
- `setup [-e/--exam]`
- `score [-e/--exam]`
- `cleanup [-e/--exam]`
- `list`
- `info [-e/--exam]`
- `status [-e/--exam]`
- `completion <shell>` (new)

Global options:
- `--version`, `-V`
- `--no-color`

### Installation Paths (Reference)

- Bash: `~/.bashrc` or `~/.bash_completion.d/`
- Zsh: `~/.zshrc` or `$fpath` directory
- Fish: `~/.config/fish/completions/`

## Assumptions

- Users know their current shell type (bash, zsh, or fish)
- Users have write access to their shell configuration files
- The completion scripts are installed once and persist across sessions
- Dynamic exam ID completion reads from the filesystem at completion time
