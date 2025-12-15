# Tasks: Sim3 Q8 Update Strategy

**Input**: Design documents from `/specs/016-sim3-q8-update-strategy/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup (Verification)

**Purpose**: Verify current state before modifications

- [x] T001 Verify sim1 Q8 is rollback-focused in exams/ckad-simulation1/questions.md
- [x] T002 Verify sim3 Q8 currently matches sim1 (rollback) in exams/ckad-simulation3/questions.md

**Checkpoint**: Confirmed sim1 and sim3 Q8 are both rollback-focused - differentiation needed

---

## Phase 2: User Story 1 - Question Différenciée (Priority: P1)

**Goal**: Replace sim3 Q8 with Update Strategy question

**Independent Test**: Read sim3 questions.md and verify Q8 asks for RollingUpdate config with maxSurge/maxUnavailable

### Implementation for User Story 1

- [x] T003 [US1] Update Q8 section in exams/ckad-simulation3/questions.md:
  - Change title from "Deployment Rollback" to "Deployment Update Strategy"
  - Change task to configure RollingUpdate strategy instead of rollback
  - Specify maxSurge: 2 and maxUnavailable: 1
  - Remove output file requirement (rollback-info.txt)
  - Keep 6 points value

**Checkpoint**: sim3 Q8 now asks for RollingUpdate configuration

---

## Phase 3: User Story 2 - Scoring Correct (Priority: P1)

**Goal**: Update scoring function to validate RollingUpdate config

**Independent Test**: Run `./scripts/ckad-score.sh -e ckad-simulation3` after configuring correctly

### Implementation for User Story 2

- [x] T004 [US2] Update score_q8() function in exams/ckad-simulation3/scoring-functions.sh:
  - Change title to "Deployment Update Strategy"
  - Check Deployment exists (1 pt)
  - Check strategy type is RollingUpdate (1 pt)
  - Check maxSurge is 2 (2 pts)
  - Check maxUnavailable is 1 (2 pts)
  - Remove rollback-info.txt checks
  - Keep total at 6 points

**Checkpoint**: Scoring correctly returns 6/6 for valid RollingUpdate config

---

## Phase 4: User Story 3 - Solution Disponible (Priority: P2)

**Goal**: Update solution to show correct kubectl command

**Independent Test**: Read sim3 solutions.md and verify Q8 shows `kubectl patch` for strategy

### Implementation for User Story 3

- [x] T005 [US3] Update Q8 section in exams/ckad-simulation3/solutions.md:
  - Change title to "Deployment Update Strategy"
  - Replace solution command with `kubectl patch deployment` for strategy
  - Update explanation to cover maxSurge and maxUnavailable
  - Remove rollback-related content

**Checkpoint**: Solution matches the new question

---

## Phase 5: Polish & Validation

**Purpose**: End-to-end verification

- [x] T006 Run quickstart.md validation steps
- [x] T007 Verify sim1 and sim3 Q8 are now different by comparing grep output

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - verification only
- **User Story 1 (Phase 2)**: No dependencies - can start after setup
- **User Story 2 (Phase 3)**: Can run in parallel with US1 (different file)
- **User Story 3 (Phase 4)**: Can run in parallel with US1/US2 (different file)
- **Polish (Phase 5)**: Depends on all user stories complete

### Parallel Opportunities

```bash
# All three file modifications can run in parallel:
T003: Update exams/ckad-simulation3/questions.md
T004: Update exams/ckad-simulation3/scoring-functions.sh
T005: Update exams/ckad-simulation3/solutions.md
```

---

## Implementation Strategy

### MVP First (Minimum Viable)

1. Complete T003 (questions.md) - Question is visible to user
2. Complete T004 (scoring-functions.sh) - Scoring works
3. **STOP and VALIDATE**: Test Q8 scoring
4. Complete T005 (solutions.md) - Solution available

### Quick Execution

All 3 core tasks (T003-T005) modify different files and can be done in parallel for fastest completion.

---

## Summary

| Phase | Tasks | Description | Status |
|-------|-------|-------------|--------|
| Phase 1 | T001-T002 | Verification | COMPLETE |
| Phase 2 (US1) | T003 | questions.md update | COMPLETE |
| Phase 3 (US2) | T004 | scoring-functions.sh update | COMPLETE |
| Phase 4 (US3) | T005 | solutions.md update | COMPLETE |
| Phase 5 | T006-T007 | Validation | COMPLETE |

**Total Tasks**: 7
**Completed Tasks**: 7
**Status**: ALL TASKS COMPLETE
