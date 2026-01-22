# Tasks: Score Details Display

**Input**: Design documents from `/specs/011-score-details/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested - no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This feature modifies existing files in the `web/` directory:

- `web/server.py` - Python backend
- `web/index.html` - HTML structure
- `web/css/style.css` - Styles
- `web/js/app.js` - JavaScript logic

---

## Phase 1: Setup

**Purpose**: No new files needed - this feature modifies existing code only.

- [x] T001 Review existing scoring output format by running `./scripts/ckad-score.sh -e ckad-simulation2` and analyzing criteria markers (✓/✗)

---

## Phase 2: Foundational (Backend API Enhancement)

**Purpose**: Extend the `/api/score` response to include criteria data - MUST complete before any UI work.

**⚠️ CRITICAL**: Frontend cannot display criteria until backend provides the data.

- [x] T002 Add regex pattern for parsing PASS (✓) and FAIL (✗) criteria lines in `web/server.py` function `run_scoring_script()`
- [x] T003 Create helper function `parse_criteria_from_output(output, question_id)` in `web/server.py` to extract criteria list for a question
- [x] T004 Update `run_scoring_script()` in `web/server.py` to include `criteria` array in each question object

**Checkpoint**: API at `/api/score` returns questions with `criteria` array containing `{description, passed}` objects

---

## Phase 3: User Story 1 - View Detailed Criteria Results (Priority: P1) 🎯 MVP

**Goal**: Display PASS/FAIL criteria for each question when score modal is shown

**Independent Test**: Stop exam → Score modal shows questions → Click question → See criteria with green (✓) and red (✗) indicators

### Implementation for User Story 1

- [x] T005 [P] [US1] Add CSS classes `.criterion`, `.criterion-pass`, `.criterion-fail` in `web/css/style.css` with appropriate colors (green/red)
- [x] T006 [P] [US1] Add CSS class `.criteria-list` for criteria container in `web/css/style.css`
- [x] T007 [US1] Update `displayScoreResults(data)` function in `web/js/app.js` to render criteria list within each question row
- [x] T008 [US1] Add criterion rendering logic: loop through `question.criteria` and create HTML elements with pass/fail styling in `web/js/app.js`

**Checkpoint**: Score modal displays all criteria for each question with PASS (green ✓) and FAIL (red ✗) indicators

---

## Phase 4: User Story 2 - Expandable Question Details (Priority: P2)

**Goal**: Questions collapsed by default, click to expand/collapse criteria

**Independent Test**: Score modal → Questions show only score/topic → Click question → Criteria expand → Click again → Criteria collapse

### Implementation for User Story 2

- [x] T009 [P] [US2] Add CSS class `.question-row` with cursor pointer and hover state in `web/css/style.css`
- [x] T010 [P] [US2] Add CSS class `.criteria-list.collapsed` with `display: none` in `web/css/style.css`
- [x] T011 [P] [US2] Add CSS transition/animation for expand/collapse effect in `web/css/style.css`
- [x] T012 [P] [US2] Add expand/collapse chevron icon (▶/▼) styling in `web/css/style.css`
- [x] T013 [US2] Add click event handler on question rows to toggle `collapsed` class in `web/js/app.js`
- [x] T014 [US2] Update question row HTML to include expand/collapse icon in `web/js/app.js`
- [x] T015 [US2] Initialize criteria as collapsed by default in `displayScoreResults()` in `web/js/app.js`

**Checkpoint**: Questions collapse/expand on click, showing/hiding criteria details

---

## Phase 5: User Story 3 - Visual Score Indicators (Priority: P3)

**Goal**: Quick visual identification of question status via colored icons

**Independent Test**: Score modal → Full score questions have green ✓ → Partial scores have orange ⚠ → Zero scores have red ✗

### Implementation for User Story 3

- [x] T016 [P] [US3] Add CSS classes `.score-indicator`, `.score-full`, `.score-partial`, `.score-zero` in `web/css/style.css`
- [x] T017 [US3] Add function `getScoreIndicator(score, maxScore)` in `web/js/app.js` returning appropriate icon (✓/⚠/✗)
- [x] T018 [US3] Update question row rendering to include score indicator icon in `web/js/app.js`
- [x] T019 [US3] Ensure indicator colors work in both dark and light themes by testing with theme toggle in `web/css/style.css`

**Checkpoint**: Questions display colored indicators matching their score status

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and validation

- [ ] T020 Test criteria display with all 4 exam simulations (ckad-simulation1, 2, 3, 4)
- [x] T021 Verify dark theme colors have sufficient contrast for criteria
- [x] T022 Verify light theme colors have sufficient contrast for criteria
- [ ] T023 Run quickstart.md validation checklist
- [x] T024 Update constitution.md "Implemented Features" to include "Detailed criteria display in score modal"

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Depends on US1 completion (needs criteria HTML to exist)
- **User Story 3 (Phase 5)**: Can start after Foundational, independent of US2
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational (T002-T004) - Displays criteria
- **User Story 2 (P2)**: Depends on US1 - Adds expand/collapse to existing criteria
- **User Story 3 (P3)**: Depends on Foundational only - Adds icons independently of US1/US2

### Within Each Phase

- CSS tasks ([P]) can run in parallel within a phase
- JavaScript tasks typically sequential (same file, logical dependencies)

### Parallel Opportunities

**Phase 2 (Foundational)**: Sequential - same file
**Phase 3 (US1)**: T005 || T006, then T007 → T008
**Phase 4 (US2)**: T009 || T010 || T011 || T012, then T013 → T014 → T015
**Phase 5 (US3)**: T016, then T017 → T018 → T019

---

## Parallel Example: User Story 2

```bash
# Launch all CSS tasks for US2 together:
Task: "Add CSS class .question-row in web/css/style.css"
Task: "Add CSS class .criteria-list.collapsed in web/css/style.css"
Task: "Add CSS transition for expand/collapse in web/css/style.css"
Task: "Add expand/collapse chevron icon styling in web/css/style.css"

# Then sequential JS tasks:
Task: "Add click event handler in web/js/app.js"
Task: "Update question row HTML in web/js/app.js"
Task: "Initialize criteria as collapsed in web/js/app.js"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002-T004)
3. Complete Phase 3: User Story 1 (T005-T008)
4. **STOP and VALIDATE**: Criteria are visible in score modal
5. Can deploy MVP at this point

### Incremental Delivery

1. Setup + Foundational → API returns criteria ✓
2. Add User Story 1 → Criteria displayed → Deploy (MVP!)
3. Add User Story 2 → Expand/collapse works → Deploy
4. Add User Story 3 → Visual indicators → Deploy
5. Polish → Final validation → Release

---

## Notes

- All changes are in `web/` directory
- No new files created - modifying existing server.py, app.js, style.css
- Dark/light theme support required for all color additions
- Test with multiple exams to ensure consistent parsing
- Commit after each task or logical group
