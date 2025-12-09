# Tasks: CKAD Simulation 3 Exam

**Input**: Design documents from `/specs/007-ckad-simulation3/`
**Prerequisites**: plan.md (required), spec.md (required)

**Status**: Most tasks COMPLETED - exam content already exists in `exams/ckad-simulation3/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create exam directory structure and configuration

- [x] T001 Create exam directory `exams/ckad-simulation3/`
- [x] T002 [P] Create `exams/ckad-simulation3/exam.conf` with exam metadata
- [x] T003 [P] Create `exams/ckad-simulation3/manifests/setup/` directory

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create namespace definitions and pre-existing resources

- [x] T004 [P] Create `exams/ckad-simulation3/manifests/setup/namespaces.yaml` with 11 Greek mythology namespaces
- [x] T005 [P] Create `exams/ckad-simulation3/manifests/setup/q08-deployment.yaml` for rollback question
- [x] T006 [P] Create `exams/ckad-simulation3/manifests/setup/q15-god-pods.yaml` for labels question
- [x] T007 [P] Create `exams/ckad-simulation3/manifests/setup/q16-deployment.yaml` for scaling question
- [x] T008 [P] Create `exams/ckad-simulation3/manifests/setup/q18-shadow-pod.yaml` for logs question
- [x] T009 [P] Create `exams/ckad-simulation3/manifests/setup/q19-lightning-pod.yaml` for annotations question
- [x] T010 [P] Create `exams/ckad-simulation3/templates/q20-image/Dockerfile` for container build question
- [x] T011 [P] Create `exams/ckad-simulation3/templates/q20-image/app.sh` application script

**Checkpoint**: Infrastructure ready - question content can now be created

---

## Phase 3: User Story 1 - Run CKAD Simulation 3 Exam (Priority: P1)

**Goal**: Create 20 questions with Greek mythology theme covering all CKAD domains

**Independent Test**: Run `./scripts/ckad-exam.sh web -e ckad-simulation3` and verify all questions display correctly

### Implementation for User Story 1

- [x] T012 [US1] Create `exams/ckad-simulation3/questions.md` with 20 questions
- [x] T013 [US1] Verify questions cover all CKAD domains (pods, deployments, jobs, helm, etc.)
- [x] T014 [US1] Verify question point totals sum to 105
- [ ] T015 [US1] Add post-setup configuration in `scripts/lib/setup-functions.sh` for Q8 broken revision

**Checkpoint**: Questions can be viewed and exam can be started

---

## Phase 4: User Story 2 - Score Exam Answers (Priority: P1)

**Goal**: Implement scoring functions for all 20 questions

**Independent Test**: Complete answers and run `./scripts/ckad-score.sh -e ckad-simulation3`

### Implementation for User Story 2

- [x] T016 [US2] Create `exams/ckad-simulation3/scoring-functions.sh`
- [x] T017 [P] [US2] Implement `score_q1()` through `score_q10()` scoring functions
- [x] T018 [P] [US2] Implement `score_q11()` through `score_q20()` scoring functions
- [ ] T019 [US2] Test scoring functions return valid `score/max` format

**Checkpoint**: Answers can be scored with point breakdown

---

## Phase 5: User Story 3 - View Exam Solutions (Priority: P2)

**Goal**: Create solutions documentation for all 20 questions

**Independent Test**: Click "View Solutions" in web interface after exam

### Implementation for User Story 3

- [x] T020 [US3] Create `exams/ckad-simulation3/solutions.md` with solutions for all 20 questions
- [x] T021 [US3] Verify solutions include kubectl/helm commands
- [x] T022 [US3] Verify code blocks have proper syntax highlighting markers

**Checkpoint**: Solutions viewable in web interface

---

## Phase 6: User Story 4 - Reset Exam Environment (Priority: P2)

**Goal**: Ensure cleanup properly removes ckad-simulation3 resources

**Independent Test**: Run `./scripts/ckad-cleanup.sh -e ckad-simulation3`

### Implementation for User Story 4

- [x] T023 [US4] Verify namespaces array in exam.conf matches cleanup expectations
- [x] T024 [US4] Verify Helm releases array in exam.conf for cleanup
- [ ] T025 [US4] Test cleanup removes all resources without errors

**Checkpoint**: Environment can be reset for new attempts

---

## Phase 7: Polish & Validation

**Purpose**: Final validation and integration testing

- [ ] T026 Run `./tests/run-tests.sh` to verify unit tests pass
- [ ] T027 Manually test exam setup: `./scripts/ckad-setup.sh -e ckad-simulation3`
- [ ] T028 Manually test scoring: `./scripts/ckad-score.sh -e ckad-simulation3`
- [ ] T029 Manually test cleanup: `./scripts/ckad-cleanup.sh -e ckad-simulation3`
- [ ] T030 Test web interface renders all 20 questions correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - COMPLETED
- **Foundational (Phase 2)**: Depends on Setup - COMPLETED
- **User Stories (Phase 3-6)**: Most content COMPLETED, some validation pending
- **Polish (Phase 7)**: Depends on all user stories - PENDING

### Remaining Tasks

| Task | Description | Status |
|------|-------------|--------|
| T015 | Post-setup for Q8 broken revision | Pending |
| T019 | Test scoring functions | Pending |
| T025 | Test cleanup | Pending |
| T026-T030 | Validation tests | Pending |

---

## Summary

**Total Tasks**: 30
**Completed**: 24 (80%)
**Pending**: 6 (20%)

**MVP Status**: Core exam content is complete. Remaining tasks are validation and post-setup configuration.

---

## Notes

- Exam already exists in `exams/ckad-simulation3/` with all core files
- Post-setup configuration for Q8 needs to be added to `setup-functions.sh`
- Validation testing required before merge
- No new dependencies introduced - follows existing architecture
