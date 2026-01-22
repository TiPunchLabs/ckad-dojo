# Tasks: Fix Score Expansion Details

**Input**: Design documents from `/specs/012-fix-score-expansion/`
**Prerequisites**: plan.md, spec.md

**Tests**: No automated tests requested. Manual verification via web interface.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Understand current implementation

- [x] T001 Review current scoring output by running `./scripts/ckad-score.sh -q 1` in scripts/ckad-score.sh

---

## Phase 2: Foundational (Core Bug Fix)

**Purpose**: Fix the root cause in scoring script - MUST complete before user stories can work

**CRITICAL**: This fix enables all scoring criteria to be visible in output

- [x] T002 Modify scoring loop in scripts/ckad-score.sh to echo full scoring function output (including criteria lines) before extracting score from line ~164

**Checkpoint**: After T002, running `./scripts/ckad-score.sh` should display criteria lines (with pass/fail markers) for each question

---

## Phase 3: User Story 1 - View Detailed Scoring Criteria (Priority: P1)

**Goal**: Users can click on a question row in the score modal to see detailed scoring criteria

**Independent Test**: Complete an exam, click "Stop Exam", click on any question row to verify criteria expand with pass/fail indicators

### Implementation for User Story 1

- [x] T003 [US1] Verify parse_criteria_from_output() in web/server.py correctly extracts criteria from enhanced scoring output
- [x] T004 [US1] Test API response by checking /api/score endpoint returns criteria array for each question
- [x] T005 [US1] Verify renderQuestionScores() in web/js/app.js displays criteria list correctly
- [x] T006 [US1] Verify toggleQuestionCriteria() in web/js/app.js toggles expand/collapse on click

**Checkpoint**: User Story 1 complete - clicking question rows expands/collapses criteria

---

## Phase 4: User Story 2 - Visual Feedback on Expansion State (Priority: P2)

**Goal**: Clear visual indication of expanded/collapsed state through icon changes

**Independent Test**: Click on question rows and observe icon changes and visual feedback

### Implementation for User Story 2

- [x] T007 [US2] Verify expand icon changes in web/js/app.js (collapsed vs expanded indicator)
- [x] T008 [US2] Verify CSS styling for expanded/collapsed states in web/css/style.css

**Checkpoint**: User Story 2 complete - visual feedback is clear and consistent

---

## Phase 5: Polish & Validation

**Purpose**: End-to-end validation and edge case handling

- [x] T009 Test with question scoring 0/N (all criteria failed)
- [x] T010 Test with question scoring N/N (all criteria passed)
- [x] T011 Test with partial scores (some criteria passed, some failed)
- [x] T012 Verify all 22 questions display criteria correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: CRITICAL - blocks all user stories. Must fix ckad-score.sh first
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion
- **User Story 2 (Phase 4)**: Can run in parallel with Phase 3 (different aspects)
- **Polish (Phase 5)**: Depends on Phases 3 and 4

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational fix only
- **User Story 2 (P2)**: Independent of US1, both verify existing code after bug fix

### Parallel Opportunities

After Phase 2 (Foundational fix):

- T003, T004, T005, T006 can be verified in parallel
- T007, T008 can be verified in parallel
- Phase 3 and Phase 4 can be worked on in parallel

---

## Implementation Strategy

### MVP First (Bug Fix + US1)

1. Complete Phase 1: Setup (understand current state)
2. Complete Phase 2: Foundational (fix ckad-score.sh) - **CRITICAL**
3. Complete Phase 3: User Story 1 (verify criteria display)
4. **STOP and VALIDATE**: Test expansion works in web interface
5. Deploy if ready

### Quick Fix Path

The actual code change is minimal:

```bash
# In scripts/ckad-score.sh, change from:
score_result=$("score_q$qnum" 2>/dev/null || echo "0/0")

# To:
score_result=$("score_q$qnum" 2>/dev/null || echo "0/0")
echo "$score_result"  # Output criteria lines before extracting score
```

This single change enables the entire feature to work.

---

## Notes

- Primary fix is in scripts/ckad-score.sh (1 line change)
- web/server.py already has parse_criteria_from_output() - just needs data
- web/js/app.js already has toggleQuestionCriteria() - just needs criteria to display
- Most tasks are verification, not implementation
- Commit after Phase 2 fix and again after full validation
