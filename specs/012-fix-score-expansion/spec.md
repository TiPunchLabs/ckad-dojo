# Feature Specification: Fix Score Expansion Details

**Feature Branch**: `012-fix-score-expansion`
**Created**: 2025-12-11
**Status**: Draft
**Input**: Correction du BUG-001 - L'expansion des détails de score dans le modal ne fonctionne pas

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Detailed Scoring Criteria (Priority: P1)

After completing an exam, when the user clicks on a question row in the score modal, they should see the detailed criteria that were checked during scoring, with visual indicators showing which criteria passed and which failed.

**Why this priority**: This is the core functionality of the feature 011-score-details. Without it, users cannot understand why they lost points on specific questions.

**Independent Test**: Can be fully tested by completing a question, clicking "Stop Exam", and clicking on any question row in the score modal to verify criteria expand/collapse.

**Acceptance Scenarios**:

1. **Given** user has completed an exam and the score modal is displayed, **When** user clicks on a question row (e.g., Q2), **Then** the row expands to show all scoring criteria with visual indicators for passed and failed criteria.

2. **Given** user has expanded a question's criteria, **When** user clicks on the same question row again, **Then** the criteria collapse and the expand icon changes back to collapsed state.

3. **Given** user has completed an exam, **When** viewing the score modal, **Then** each question shows the total score (e.g., "3/5") AND can be expanded to show individual criteria.

---

### User Story 2 - Visual Feedback on Expansion State (Priority: P2)

The expand/collapse state should be visually clear to the user through icon changes and smooth animations.

**Why this priority**: Improves user experience but not critical to core functionality.

**Independent Test**: Can be tested by clicking on question rows and observing icon changes and animation.

**Acceptance Scenarios**:

1. **Given** a question row in collapsed state, **When** user views the row, **Then** the expand icon shows collapsed indicator.

2. **Given** a question row in expanded state, **When** user views the row, **Then** the expand icon shows expanded indicator.

---

### Edge Cases

- What happens when a scoring function has no criteria output? Show empty criteria list or message "No detailed criteria available"
- What happens when the scoring script times out? Display error message, criteria remain unavailable
- What happens when a question scores 0/N? All criteria should show as failed
- What happens when a question scores N/N (full marks)? All criteria should show as passed

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The scoring script MUST output criteria lines for each question before the score line
- **FR-002**: The web API MUST parse and return criteria data for each question in the score response
- **FR-003**: The frontend MUST display criteria as an expandable list under each question row
- **FR-004**: The frontend MUST toggle the expand/collapse state when clicking on a question header
- **FR-005**: Each criterion MUST display its pass/fail status with a visual indicator
- **FR-006**: The expand icon MUST visually indicate the current state (collapsed vs expanded)

### Key Entities

- **Criterion**: A single scoring check with description and passed/failed status
- **QuestionScore**: Contains question ID, topic, score, max_score, and array of Criteria
- **ScoreResult**: Contains total score, percentage, pass status, and array of QuestionScores with criteria

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can expand any question in the score modal to view detailed criteria within 1 click
- **SC-002**: 100% of scoring criteria from each question are visible when expanded
- **SC-003**: Users can identify which specific criteria passed or failed for any question
- **SC-004**: Expand/collapse toggle works reliably for all questions in the score list
