# Feature Specification: Fix CLI Setup-Exam Flow

**Feature Branch**: `fix/cli-setup-exam-flow`
**Created**: 2025-12-09
**Status**: Draft
**Input**: User description: "Corriger le flux CLI setup-exam: quand ckad-dojo lance setup puis exam, le script ckad-exam.sh ne doit pas redemander si on veut cleanup les ressources qu'on vient de créer. Ajouter un flag --skip-detection pour bypasser la détection d'examen existant quand le setup vient d'être fait."

## Problem Statement

When users run `uv run ckad-dojo exam start`, the following happens:

1. CLI runs `ckad-setup.sh -e <exam>` to setup the environment
2. CLI then runs `ckad-exam.sh web -e <exam>` to launch the interface
3. `ckad-exam.sh` detects existing resources (that were just created in step 1)
4. User is prompted to choose: cleanup, continue, or cancel

This is **redundant and confusing** because:
- The resources were JUST created intentionally
- The user already made the decision to start the exam
- Asking again breaks the user flow

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Seamless Exam Start via CLI (Priority: P1)

As a user starting an exam via the unified CLI (`uv run ckad-dojo exam start`), I want the setup and exam launch to flow seamlessly without redundant prompts.

**Why this priority**: This is the primary use case that caused the bug. The CLI is the recommended way to use the tool.

**Independent Test**: Run `uv run ckad-dojo exam start -e ckad-simulation1` and verify the exam interface opens directly after setup without any additional prompts.

**Acceptance Scenarios**:

1. **Given** I run `uv run ckad-dojo exam start -e ckad-simulation1`, **When** the setup completes successfully, **Then** the exam interface opens immediately without asking about existing resources.
2. **Given** I run `uv run ckad-dojo` and select "Start Exam", **When** setup completes, **Then** the exam interface opens without redundant prompts.

---

### User Story 2 - Direct Script Usage Unchanged (Priority: P2)

As a user running `ckad-exam.sh` directly (not via CLI), I still want to see the existing exam detection warning if resources exist.

**Why this priority**: Preserves backward compatibility for users who don't use the unified CLI.

**Independent Test**: Run `./scripts/ckad-exam.sh web -e ckad-simulation1` when resources already exist and verify the detection prompt appears.

**Acceptance Scenarios**:

1. **Given** exam resources already exist, **When** I run `./scripts/ckad-exam.sh web -e ckad-simulation1` directly, **Then** I see the existing exam detection prompt.
2. **Given** no exam resources exist, **When** I run `./scripts/ckad-exam.sh web -e ckad-simulation1` directly, **Then** setup runs and exam starts normally.

---

### Edge Cases

- What happens if setup fails? → Exam should NOT launch (current behavior preserved)
- What happens if user cancels during setup? → Process should exit cleanly
- What happens if --skip-detection is used but resources don't match the exam ID? → Should still skip detection (trust the flag)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `ckad-exam.sh` MUST accept a `--skip-detection` flag to bypass existing exam resource detection
- **FR-002**: When `--skip-detection` is passed, the script MUST skip the "EXISTING EXAM DETECTED" check entirely
- **FR-003**: The Python CLI (`ckad_dojo.py`) MUST pass `--skip-detection` when calling `ckad-exam.sh` after a successful setup
- **FR-004**: Direct usage of `ckad-exam.sh` without the flag MUST preserve current behavior (show detection prompt)
- **FR-005**: The `--skip-detection` flag MUST be documented in the script's help output

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can start an exam via CLI without any redundant prompts (0 extra confirmation dialogs)
- **SC-002**: Direct script usage continues to show detection prompt when appropriate (100% backward compatible)
- **SC-003**: The end-to-end flow `uv run ckad-dojo exam start` completes in one continuous flow

## Technical Notes

### Files to Modify

1. `scripts/ckad-exam.sh` - Add `--skip-detection` flag handling
2. `ckad_dojo.py` - Pass `--skip-detection` when calling `ckad-exam.sh` after setup

### Implementation Approach

The `--skip-detection` flag should:
- Be parsed in the argument handling section of `ckad-exam.sh`
- Set a variable like `SKIP_DETECTION=true`
- Check this variable before the "EXISTING EXAM DETECTED" block
- If `SKIP_DETECTION=true`, skip the entire detection logic

## Assumptions

- The setup script (`ckad-setup.sh`) always creates the resources correctly
- If setup succeeds, we can trust that resources are valid for the exam
- Users using direct scripts are advanced users who want full control
