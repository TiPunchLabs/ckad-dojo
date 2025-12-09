# Feature Specification: Score Details Display

**Feature Branch**: `011-score-details`
**Created**: 2025-12-09
**Status**: Draft
**Input**: User description: "Améliorer l'affichage des résultats d'examen pour montrer le détail des critères PASS/FAIL par question"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Detailed Criteria Results (Priority: P1)

After completing an exam, the user wants to see exactly which criteria passed or failed for each question, so they can understand their mistakes and improve.

**Why this priority**: This is the core functionality requested. Without detailed criteria display, users cannot identify what specifically went wrong in their answers.

**Independent Test**: Can be fully tested by stopping an exam and verifying that each question shows its individual criteria with PASS/FAIL status.

**Acceptance Scenarios**:

1. **Given** an exam has been stopped or time has expired, **When** the score modal displays, **Then** each question should show a list of its evaluation criteria with clear PASS (green) or FAIL (red) indicators.
2. **Given** the score modal is displayed, **When** a user looks at a partially scored question (e.g., 3/5 points), **Then** they should see exactly which 3 criteria passed and which 2 failed.
3. **Given** the score results are displayed, **When** a criterion is marked as FAIL, **Then** the criterion description should clearly indicate what was expected (e.g., "Pod is Running", "Deployment has 5 replicas").

---

### User Story 2 - Expandable Question Details (Priority: P2)

The score modal should remain readable by showing criteria details on demand, not overwhelming users with all information at once.

**Why this priority**: Improves UX by keeping the summary clean while allowing drill-down into details.

**Independent Test**: Can be tested by clicking on a question row in the score modal and verifying details expand/collapse.

**Acceptance Scenarios**:

1. **Given** the score modal is displayed, **When** the user views the questions list, **Then** questions should show a collapsed view with score and topic only.
2. **Given** a question row is displayed in collapsed state, **When** the user clicks on the question, **Then** the criteria details should expand below the question row.
3. **Given** criteria details are expanded for a question, **When** the user clicks on the question again, **Then** the details should collapse.

---

### User Story 3 - Visual Score Indicators (Priority: P3)

Users should quickly identify which questions need attention through visual cues.

**Why this priority**: Enhances usability but not essential for core functionality.

**Independent Test**: Can be tested by visually inspecting score modal for color-coded indicators.

**Acceptance Scenarios**:

1. **Given** the score modal is displayed, **When** a question has full points (e.g., 5/5), **Then** it should display a success indicator (green checkmark or similar).
2. **Given** a question has partial points (e.g., 3/5), **When** displayed in the list, **Then** it should show a warning indicator (yellow/orange).
3. **Given** a question has zero points (0/N), **When** displayed in the list, **Then** it should show a failure indicator (red).

---

### Edge Cases

- What happens when the scoring script fails or times out? Display an error message with available partial results.
- How does the system handle criteria output that doesn't follow the expected format? Skip malformed lines and display only valid criteria.
- What if a question has no criteria output (only score)? Display the question with score only, without criteria section.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse individual criterion results (PASS/FAIL) from scoring script output for each question.
- **FR-002**: System MUST include criteria details in the scoring API response (`/api/score`).
- **FR-003**: Web interface MUST display criteria details for each question in the score modal.
- **FR-004**: Each criterion MUST show its description and PASS/FAIL status with visual differentiation (colors/icons).
- **FR-005**: Question rows MUST be expandable/collapsible to show/hide criteria details.
- **FR-006**: System MUST preserve existing score modal functionality (total score, percentage, pass/fail status, elapsed time).
- **FR-007**: Criteria display MUST work consistently across all exam simulations (1, 2, 3, 4).

### Key Entities

- **ScoreResult**: Overall exam result containing total score, percentage, pass status, elapsed time, and list of questions.
- **QuestionScore**: Individual question result containing ID, score, max_score, topic, pass status, and list of criteria.
- **Criterion**: Individual evaluation criterion containing description and pass status (boolean).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view detailed criteria breakdown for 100% of scored questions.
- **SC-002**: Users can identify failed criteria within 2 seconds of viewing a question's details.
- **SC-003**: Score modal loads and displays all criteria details within 3 seconds of exam stop.
- **SC-004**: Criteria display is consistent and accurate across all 4 exam simulations.

## Assumptions

- The scoring script output format (`print_success`/`print_fail` for criteria) remains stable.
- Criteria are always printed before the final `score/total` line for each question.
- The existing scoring script does not need modification to add structured output (we parse existing text output).
- Dark and light themes must both support criteria color coding.
