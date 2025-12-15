# Tasks: Unique Q1 Questions

**Input**: Design documents from `/specs/015-unique-q1-questions/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup (Verification)

**Purpose**: Verify current state before modifications

- [x] T001 Verify sim1 Q1 is baseline (list namespaces) in exams/ckad-simulation1/questions.md
- [x] T002 Verify sim3 Q1 is unique (list ns with "a") in exams/ckad-simulation3/questions.md

**Checkpoint**: Confirmed sim1 and sim3 Q1 are already unique - only sim2 needs changes

---

## Phase 2: User Story 1 - Unique Warm-up Questions (Priority: P1)

**Goal**: Replace sim2 Q1 with node listing question

**Independent Test**: Read sim2 questions.md and verify Q1 asks for node listing

### Implementation for User Story 1

- [x] T003 [US1] Update Q1 section in exams/ckad-simulation2/questions.md:
  - Change title from "Namespaces" to "Nodes"
  - Change task to list nodes instead of namespaces
  - Change output file from `./exam/course/1/namespaces` to `./exam/course/1/nodes`
  - Keep 1 point value

**Checkpoint**: sim2 Q1 now asks for node listing

---

## Phase 3: User Story 2 - Correct Scoring (Priority: P1)

**Goal**: Update scoring function to validate node output

**Independent Test**: Run `./scripts/ckad-score.sh -e ckad-simulation2` after completing Q1 correctly

### Implementation for User Story 2

- [x] T004 [US2] Update score_q1() function in exams/ckad-simulation2/scoring-functions.sh:
  - Change file path from `./exam/course/1/namespaces` to `./exam/course/1/nodes`
  - Change validation to check for node status (Ready/NotReady pattern)
  - Keep max_points at 1

**Checkpoint**: Scoring correctly returns 1/1 for valid node output

---

## Phase 4: User Story 3 - Solutions Available (Priority: P2)

**Goal**: Update solution to show correct kubectl command

**Independent Test**: Read sim2 solutions.md and verify Q1 shows `kubectl get nodes`

### Implementation for User Story 3

- [x] T005 [US3] Update Q1 section in exams/ckad-simulation2/solutions.md:
  - Change solution command to `kubectl get nodes`
  - Update explanation to match node listing task
  - Update output file reference to `./exam/course/1/nodes`

**Checkpoint**: Solution matches the new question

---

## Phase 5: Polish & Validation

**Purpose**: End-to-end verification

- [x] T006 Run quickstart.md validation steps
- [x] T007 Verify all 3 simulations have unique Q1 by comparing grep output

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
T003: Update exams/ckad-simulation2/questions.md
T004: Update exams/ckad-simulation2/scoring-functions.sh
T005: Update exams/ckad-simulation2/solutions.md
```

---

## Implementation Strategy

### MVP First (Minimum Viable)

1. Complete T003 (questions.md) - Question is visible to user
2. Complete T004 (scoring-functions.sh) - Scoring works
3. **STOP and VALIDATE**: Test Q1 scoring
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
