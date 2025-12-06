# Feature Specification: Exam Modal & Timer Improvements

**Feature Branch**: `005-exam-modal-improvements`
**Created**: 2025-12-06
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - Custom Stop Exam Modal (Priority: P1)

Replace the browser's native confirm() dialog with a custom-styled modal that matches the exam interface design.

**Why this priority**: The native browser dialog breaks immersion and looks unprofessional.

**Independent Test**: Click "Stop Exam" button, verify custom modal appears with dark theme styling.

**Acceptance Scenarios**:

1. **Given** exam is running, **When** user clicks "Stop Exam", **Then** custom modal appears with backdrop overlay
2. **Given** modal is open, **When** user clicks "Cancel" or presses Escape, **Then** modal closes and exam continues
3. **Given** modal is open, **When** user clicks "Stop Exam" (red button), **Then** exam stops and score is calculated

---

### User Story 2 - Pause Timer (Priority: P1)

Add ability to pause/resume the countdown timer for breaks.

**Why this priority**: Users need breaks without losing exam time.

**Independent Test**: Click pause button, verify timer stops counting down, click resume, verify timer continues.

**Acceptance Scenarios**:

1. **Given** exam is running, **When** user clicks pause button, **Then** timer stops and button shows "Resume"
2. **Given** timer is paused, **When** user clicks "Resume", **Then** timer continues from where it stopped
3. **Given** timer is paused, **When** user refreshes page, **Then** timer remains paused

---

### User Story 3 - Fix Score Calculation (Priority: P1)

Ensure score is properly calculated when exam is stopped.

**Why this priority**: Core functionality - users need to see their actual score.

**Independent Test**: Complete some questions, click Stop Exam, verify score reflects completed work.

**Acceptance Scenarios**:

1. **Given** user has completed questions, **When** exam is stopped, **Then** score shows X/Y points (not 0/0)
2. **Given** exam is stopped, **When** score modal appears, **Then** per-question breakdown is visible
3. **Given** score is below 66%, **When** modal shows, **Then** "NOT PASSED" status displayed

---

### User Story 4 - Graceful Cleanup on Close (Priority: P2)

When user clicks "Close" in score modal, trigger exam cleanup and stop server.

**Why this priority**: Clean shutdown prevents stale state on next run.

**Independent Test**: Click Close, verify namespaces are deleted and server stops.

**Acceptance Scenarios**:

1. **Given** score modal is open, **When** user clicks "Close", **Then** cleanup script runs
2. **Given** cleanup is running, **When** complete, **Then** server stops gracefully
3. **Given** cleanup fails, **When** error occurs, **Then** user sees error message

---

### Edge Cases

- What happens if scoring script fails? Show error in modal
- What happens if timer is paused when exam is stopped? Calculate remaining time correctly
- What happens if cleanup is already in progress? Prevent duplicate cleanup

## Requirements

### Functional Requirements

- **FR-001**: System MUST display custom modal instead of browser confirm() for Stop Exam
- **FR-002**: System MUST allow pausing/resuming the countdown timer
- **FR-003**: System MUST calculate actual score by running ckad-score.sh
- **FR-004**: System MUST trigger ckad-cleanup.sh when user clicks Close
- **FR-005**: System MUST stop server gracefully after cleanup completes
- **FR-006**: Modal MUST match dark theme design of exam interface
- **FR-007**: Pause state MUST persist across page refresh

### Key Entities

- **Timer State**: running, paused, stopped; remaining time, pause timestamp
- **Modal State**: visible, type (confirm, score), actions available
- **Score Result**: total points, max points, per-question breakdown, pass/fail

## Success Criteria

### Measurable Outcomes

- **SC-001**: Custom modal appears within 100ms of clicking Stop Exam
- **SC-002**: Timer pause/resume works correctly with no time drift
- **SC-003**: Score calculation returns accurate results matching ckad-score.sh output
- **SC-004**: Cleanup completes within 30 seconds and server stops
