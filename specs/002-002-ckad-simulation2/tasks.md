# Tasks: CKAD Simulation 2 & Solutions Feature

**Input**: Design documents from `/specs/002-002-ckad-simulation2/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Directory Structure)

**Purpose**: Create exam directory structure

- [x] T001 Create exam directory structure at exams/ckad-simulation2/
- [x] T002 [P] Create manifests/setup/ subdirectory at exams/ckad-simulation2/manifests/setup/
- [x] T003 [P] Create templates/ subdirectory at exams/ckad-simulation2/templates/

**Checkpoint**: Directory structure ready

---

## Phase 2: Foundational (Exam Configuration)

**Purpose**: Core exam infrastructure that MUST be complete before questions can be created

- [x] T004 [US1] Create exam.conf with configuration for ckad-simulation2 at exams/ckad-simulation2/exam.conf
- [x] T005 [US1] Create namespaces.yaml with 11 galaxy/constellation namespaces at exams/ckad-simulation2/manifests/setup/namespaces.yaml
- [x] T006 [US1] Create scoring-functions.sh skeleton with helper sourcing at exams/ckad-simulation2/scoring-functions.sh

**Checkpoint**: Exam infrastructure ready - questions can now be created

---

## Phase 3: User Story 1 - Complete New CKAD Exam Session (Priority: P1)

**Goal**: Provide a fully functional exam with 21 questions covering all CKAD domains

**Independent Test**: Launch `./scripts/ckad-exam.sh -e ckad-simulation2`, run scoring, verify all 21 questions work

### Questions & Scoring (Part 1: Q1-Q7)

- [ ] T007 [P] [US1] Write Question 1 (Namespaces, 1pt) in exams/ckad-simulation2/questions.md
- [ ] T008 [P] [US1] Write score_q1() function for Q1 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T009 [P] [US1] Write Question 2 (Multi-container Pod, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T010 [P] [US1] Write score_q2() function for Q2 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T011 [P] [US1] Write Question 3 (CronJob, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T012 [P] [US1] Write score_q3() function for Q3 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T013 [P] [US1] Write Question 4 (Deployment Scaling, 4pts) in exams/ckad-simulation2/questions.md
- [ ] T014 [P] [US1] Write score_q4() function for Q4 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T015 [P] [US1] Create q04-deployment.yaml manifest for Q4 at exams/ckad-simulation2/manifests/setup/q04-deployment.yaml
- [ ] T016 [P] [US1] Write Question 5 (Deployment Troubleshooting, 6pts) in exams/ckad-simulation2/questions.md
- [ ] T017 [P] [US1] Write score_q5() function for Q5 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T018 [P] [US1] Create q05-broken-deploy.yaml manifest (intentional typo) at exams/ckad-simulation2/manifests/setup/q05-broken-deploy.yaml
- [ ] T019 [P] [US1] Write Question 6 (ConfigMap Volume Mount, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T020 [P] [US1] Write score_q6() function for Q6 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T021 [P] [US1] Write Question 7 (Secret Env Vars, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T022 [P] [US1] Write score_q7() function for Q7 in exams/ckad-simulation2/scoring-functions.sh

### Questions & Scoring (Part 2: Q8-Q14)

- [ ] T023 [P] [US1] Write Question 8 (Service NodePort, 4pts) in exams/ckad-simulation2/questions.md
- [ ] T024 [P] [US1] Write score_q8() function for Q8 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T025 [P] [US1] Write Question 9 (Pod to Deployment, 8pts) in exams/ckad-simulation2/questions.md
- [ ] T026 [P] [US1] Write score_q9() function for Q9 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T027 [P] [US1] Create q09-pod.yaml manifest for Q9 at exams/ckad-simulation2/manifests/setup/q09-pod.yaml
- [ ] T028 [P] [US1] Create q09-pod.yaml template for Q9 at exams/ckad-simulation2/templates/q09-pod.yaml
- [ ] T029 [P] [US1] Write Question 10 (PV/PVC, 6pts) in exams/ckad-simulation2/questions.md
- [ ] T030 [P] [US1] Write score_q10() function for Q10 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T031 [P] [US1] Write Question 11 (NetworkPolicy, 6pts) in exams/ckad-simulation2/questions.md
- [ ] T032 [P] [US1] Write score_q11() function for Q11 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T033 [P] [US1] Write Question 12 (Container Build, 7pts) in exams/ckad-simulation2/questions.md
- [ ] T034 [P] [US1] Write score_q12() function for Q12 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T035 [P] [US1] Create q12-image/ template directory with Dockerfile at exams/ckad-simulation2/templates/q12-image/Dockerfile
- [ ] T036 [P] [US1] Create app.py for Q12 at exams/ckad-simulation2/templates/q12-image/app.py
- [ ] T037 [P] [US1] Write Question 13 (Helm Operations, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T038 [P] [US1] Write score_q13() function for Q13 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T039 [P] [US1] Write Question 14 (InitContainer, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T040 [P] [US1] Write score_q14() function for Q14 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T041 [P] [US1] Create q14-initcontainer.yaml template at exams/ckad-simulation2/templates/q14-initcontainer.yaml

### Questions & Scoring (Part 3: Q15-Q21 + Preview)

- [ ] T042 [P] [US1] Write Question 15 (Sidecar Logging, 6pts) in exams/ckad-simulation2/questions.md
- [ ] T043 [P] [US1] Write score_q15() function for Q15 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T044 [P] [US1] Create q15-deployment.yaml manifest for Q15 at exams/ckad-simulation2/manifests/setup/q15-deployment.yaml
- [ ] T045 [P] [US1] Write Question 16 (ServiceAccount Token, 2pts) in exams/ckad-simulation2/questions.md
- [ ] T046 [P] [US1] Write score_q16() function for Q16 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T047 [P] [US1] Create q16-serviceaccount.yaml manifest at exams/ckad-simulation2/manifests/setup/q16-serviceaccount.yaml
- [ ] T048 [P] [US1] Write Question 17 (Liveness Probe, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T049 [P] [US1] Write score_q17() function for Q17 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T050 [P] [US1] Write Question 18 (Readiness Probe, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T051 [P] [US1] Write score_q18() function for Q18 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T052 [P] [US1] Write Question 19 (Resource Limits, 5pts) in exams/ckad-simulation2/questions.md
- [ ] T053 [P] [US1] Write score_q19() function for Q19 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T054 [P] [US1] Create q19-deployment.yaml manifest for Q19 at exams/ckad-simulation2/manifests/setup/q19-deployment.yaml
- [ ] T055 [P] [US1] Write Question 20 (Labels/Selectors, 4pts) in exams/ckad-simulation2/questions.md
- [ ] T056 [P] [US1] Write score_q20() function for Q20 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T057 [P] [US1] Write Question 21 (Rollback, 3pts) in exams/ckad-simulation2/questions.md
- [ ] T058 [P] [US1] Write score_q21() function for Q21 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T059 [P] [US1] Create q21-deployment.yaml manifest (with history) for Q21 at exams/ckad-simulation2/manifests/setup/q21-deployment.yaml
- [ ] T060 [P] [US1] Write Preview Question P1 (Startup Probe, 4pts) in exams/ckad-simulation2/questions.md
- [ ] T061 [P] [US1] Write score_preview_q1() function for P1 in exams/ckad-simulation2/scoring-functions.sh
- [ ] T062 [P] [US1] Create q-p1-startup-probe.yaml template at exams/ckad-simulation2/templates/q-p1-startup-probe.yaml

### Questions File Header

- [ ] T063 [US1] Add questions.md header with total score and adaptations at exams/ckad-simulation2/questions.md

**Checkpoint**: User Story 1 complete - Exam can be launched, questions displayed, and scored

---

## Phase 4: User Story 2 - View Solutions After Exam (Priority: P2)

**Goal**: Allow users to view detailed solutions after completing an exam

**Independent Test**: Click "View Solutions" in score modal, verify all solutions display correctly

### Backend API (web/server.py)

- [ ] T064 [US2] Add parse_solutions_md() function in web/server.py
- [ ] T065 [US2] Add /api/exam/{exam_id}/solutions GET endpoint in web/server.py
- [ ] T066 [US2] Update /api/score response to include solutions_available flag in web/server.py

### Frontend JavaScript (web/js/app.js)

- [ ] T067 [US2] Add api.getSolutions(examId) function in web/js/app.js
- [ ] T068 [US2] Add solutions state management (state.solutions) in web/js/app.js
- [ ] T069 [US2] Add loadAndShowSolutions() function in web/js/app.js
- [ ] T070 [US2] Add renderSolution(index) function in web/js/app.js
- [ ] T071 [US2] Add solution navigation event handlers in web/js/app.js
- [ ] T072 [US2] Add View Solutions button click handler in web/js/app.js

### Frontend HTML (web/index.html)

- [ ] T073 [US2] Add "View Solutions" button in score modal in web/index.html
- [ ] T074 [US2] Add solutions-view container section in web/index.html
- [ ] T075 [US2] Add solution navigation elements (prev/next/back) in web/index.html
- [ ] T076 [US2] Add solution-content container in web/index.html

### Frontend Styles (web/css/style.css)

- [ ] T077 [P] [US2] Add .solutions-view container styles in web/css/style.css
- [ ] T078 [P] [US2] Add .solution-content markdown styles in web/css/style.css
- [ ] T079 [P] [US2] Add .solution-nav navigation styles in web/css/style.css
- [ ] T080 [P] [US2] Add .solution-status pass/fail indicator styles in web/css/style.css
- [ ] T081 [P] [US2] Add solutions dark theme support in web/css/style.css

### Solutions Content

- [ ] T082 [P] [US2] Create solutions.md for ckad-simulation2 (Q1-Q7) at exams/ckad-simulation2/solutions.md
- [ ] T083 [P] [US2] Add solutions for Q8-Q14 to exams/ckad-simulation2/solutions.md
- [ ] T084 [P] [US2] Add solutions for Q15-Q21 and P1 to exams/ckad-simulation2/solutions.md
- [ ] T085 [P] [US2] Create solutions.md for ckad-simulation1 (Q1-Q7) at exams/ckad-simulation1/solutions.md
- [ ] T086 [P] [US2] Add solutions for Q8-Q14 to exams/ckad-simulation1/solutions.md
- [ ] T087 [P] [US2] Add solutions for Q15-Q22 and preview to exams/ckad-simulation1/solutions.md

**Checkpoint**: User Story 2 complete - Solutions viewable after exam completion for both exams

---

## Phase 5: User Story 3 - Pre-existing Resources Setup (Priority: P3)

**Goal**: Ensure exam setup creates all pre-existing resources correctly

**Independent Test**: Run `./scripts/ckad-setup.sh -e ckad-simulation2` and verify all resources exist

### Additional Setup Manifests

- [ ] T088 [P] [US3] Create q11-networkpolicy-pods.yaml for Q11 at exams/ckad-simulation2/manifests/setup/q11-networkpolicy-pods.yaml
- [ ] T089 [P] [US3] Create q13-helm-releases setup script/manifest at exams/ckad-simulation2/manifests/setup/q13-helm-setup.sh
- [ ] T090 [P] [US3] Create q20-labels-pods.yaml for Q20 at exams/ckad-simulation2/manifests/setup/q20-labels-pods.yaml

**Checkpoint**: User Story 3 complete - All pre-existing resources are created by setup

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, testing, and documentation

### Integration Verification

- [ ] T091 Verify ckad-setup.sh works with ckad-simulation2 exam
- [ ] T092 Verify ckad-score.sh works with ckad-simulation2 exam
- [ ] T093 Verify ckad-cleanup.sh works with ckad-simulation2 exam
- [ ] T094 Verify ckad-exam.sh lists ckad-simulation2 in selection menu
- [ ] T095 Run full cycle test: setup → score (empty) → cleanup → setup

### Documentation Updates

- [ ] T096 [P] Update README.md with ckad-simulation2 information
- [ ] T097 [P] Update constitution.md with solutions feature
- [ ] T098 [P] Update quickstart.md with ckad-simulation2 usage

### Final Validation

- [ ] T099 Test solutions feature with ckad-simulation1
- [ ] T100 Test solutions feature with ckad-simulation2
- [ ] T101 Verify scoring accuracy with known correct answers

**Checkpoint**: Feature complete and validated

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Story 1 (Phase 3)**: Depends on Foundational (exam.conf, namespaces)
- **User Story 2 (Phase 4)**: Depends on User Story 1 (needs questions.md for solutions)
- **User Story 3 (Phase 5)**: Can run in parallel with Phase 4
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 for questions.md content to create matching solutions
- **User Story 3 (P3)**: Can start after US1 manifests are defined - Independent of US2

### Within User Story 1

Questions can be written in parallel ([P]) since they are independent markdown sections.
Scoring functions can be written in parallel ([P]) since they are independent bash functions.
Each question's manifest/template can be written in parallel with its question.

### Within User Story 2

- Backend API endpoints must be implemented before frontend
- HTML structure must exist before JavaScript event handlers
- CSS styles can be written in parallel with other tasks

### Parallel Opportunities

```bash
# All questions can be written in parallel:
Task T007-T062 marked [P] - different sections in questions.md and scoring-functions.sh

# All solutions content can be written in parallel:
Task T082-T087 marked [P] - different files for different exams

# All CSS styles can be written in parallel:
Task T077-T081 marked [P] - different style rules
```

---

## Parallel Example: User Story 1 Questions

```bash
# Write all questions simultaneously:
Task: "Write Question 1 (Namespaces) in exams/ckad-simulation2/questions.md"
Task: "Write Question 2 (Multi-container Pod) in exams/ckad-simulation2/questions.md"
Task: "Write Question 3 (CronJob) in exams/ckad-simulation2/questions.md"
# ... all 21 questions can be written in parallel

# Write all scoring functions simultaneously:
Task: "Write score_q1() in exams/ckad-simulation2/scoring-functions.sh"
Task: "Write score_q2() in exams/ckad-simulation2/scoring-functions.sh"
# ... all 21 scoring functions can be written in parallel
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (directory structure)
2. Complete Phase 2: Foundational (exam.conf, namespaces)
3. Complete Phase 3: User Story 1 (all questions + scoring)
4. **STOP and VALIDATE**: Run ckad-setup.sh, ckad-score.sh, ckad-cleanup.sh
5. Deploy/demo if ready - exam is fully functional

### Incremental Delivery

1. Setup + Foundational → Exam structure ready
2. Add User Story 1 → Test exam functionality → **MVP Complete**
3. Add User Story 2 → Test solutions feature → **Enhanced Learning**
4. Add User Story 3 → Test all manifests → **Full Exam Fidelity**
5. Polish → Documentation and integration → **Production Ready**

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 1 | 3 | Directory structure |
| Phase 2 | 3 | Exam configuration |
| Phase 3 (US1) | 57 | Questions, scoring, manifests, templates |
| Phase 4 (US2) | 24 | Solutions feature (backend + frontend + content) |
| Phase 5 (US3) | 3 | Additional setup manifests |
| Phase 6 | 11 | Integration, testing, documentation |
| **Total** | **101** | |

**Task Distribution by User Story**:
- US1: 60 tasks (exam content)
- US2: 24 tasks (solutions feature)
- US3: 3 tasks (pre-existing resources)
- Shared: 14 tasks (setup + polish)
