# Tasks: Sim2 Original Exam

**Input**: Design documents from `/specs/017-sim2-original-exam/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US4)

---

## Phase 1: Setup - Configuration

**Purpose**: Initialize exam configuration

- [ ] T001 Update exam.conf with new namespaces in exams/ckad-simulation2/exam.conf
- [ ] T002 Create namespaces.yaml manifest in exams/ckad-simulation2/manifests/setup/namespaces.yaml

**Checkpoint**: `grep EXAM_NAMESPACES exams/ckad-simulation2/exam.conf` shows fire-themed namespaces

---

## Phase 2: Infrastructure - Pre-existing Resources

**Purpose**: Create manifests for resources that must exist before exam starts

- [ ] T003 [P] Create crash-app pod manifest (CrashLoopBackOff) in exams/ckad-simulation2/manifests/setup/ember/crash-app.yaml
- [ ] T004 [P] Create stable-v1 deployment manifest in exams/ckad-simulation2/manifests/setup/blaze/stable-v1.yaml
- [ ] T005 [P] Create app-settings configmap manifest in exams/ckad-simulation2/manifests/setup/flame/app-settings.yaml
- [ ] T006 [P] Create backend-pod manifest in exams/ckad-simulation2/manifests/setup/corona/backend-pod.yaml
- [ ] T007 [P] Create fire-sa serviceaccount manifest in exams/ckad-simulation2/manifests/setup/magma/fire-sa.yaml
- [ ] T008 [P] Create web-deploy deployment manifest in exams/ckad-simulation2/manifests/setup/flame/web-deploy.yaml
- [ ] T009 Create Helm setup script section in exams/ckad-simulation2/manifests/setup/helm-releases.sh

**Checkpoint**: All manifests apply without error

---

## Phase 3: Questions Batch 1 (Q1-Q7) - Core Basics

**Goal**: Implement first 7 questions (31 points)

### Questions

- [ ] T010 [US1] Write Q1 (API Resources, 1pt) in exams/ckad-simulation2/questions.md
- [ ] T011 [US1] Write Q2 (Deployment Recreate Strategy, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T012 [US1] Write Q3 (Job Timeout, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T013 [US1] Write Q4 (Helm Template, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T014 [US1] Write Q5 (CrashLoop Fix, 6pt) in exams/ckad-simulation2/questions.md
- [ ] T015 [US1] Write Q6 (ConfigMap Items Mount, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T016 [US1] Write Q7 (Secret from File, 5pt) in exams/ckad-simulation2/questions.md

### Scoring Functions

- [ ] T017 [US2] Implement score_q1() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T018 [US2] Implement score_q2() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T019 [US2] Implement score_q3() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T020 [US2] Implement score_q4() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T021 [US2] Implement score_q5() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T022 [US2] Implement score_q6() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T023 [US2] Implement score_q7() in exams/ckad-simulation2/scoring-functions.sh

### Templates

- [ ] T024 [P] [US3] Create job template in exams/ckad-simulation2/templates/3/job-template.yaml

**Checkpoint**: Questions 1-7 visible in web interface, scoring functions return correct points

---

## Phase 4: Questions Batch 2 (Q8-Q14) - Intermediate

**Goal**: Implement questions 8-14 (39 points)

### Questions

- [ ] T025 [US1] Write Q8 (Headless Service, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T026 [US1] Write Q9 (Canary Deployment, 7pt) in exams/ckad-simulation2/questions.md
- [ ] T027 [US1] Write Q10 (EmptyDir Sidecar, 6pt) in exams/ckad-simulation2/questions.md
- [ ] T028 [US1] Write Q11 (NetworkPolicy Namespace, 6pt) in exams/ckad-simulation2/questions.md
- [ ] T029 [US1] Write Q12 (Docker ARG Build, 6pt) in exams/ckad-simulation2/questions.md
- [ ] T030 [US1] Write Q13 (Helm Values File, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T031 [US1] Write Q14 (PostStart Hook, 5pt) in exams/ckad-simulation2/questions.md

### Scoring Functions

- [ ] T032 [US2] Implement score_q8() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T033 [US2] Implement score_q9() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T034 [US2] Implement score_q10() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T035 [US2] Implement score_q11() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T036 [US2] Implement score_q12() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T037 [US2] Implement score_q13() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T038 [US2] Implement score_q14() in exams/ckad-simulation2/scoring-functions.sh

### Templates

- [ ] T039 [P] [US3] Create canary base template in exams/ckad-simulation2/templates/9/canary-base.yaml
- [ ] T040 [P] [US3] Create Docker image files in exams/ckad-simulation2/templates/12/image/
- [ ] T041 [P] [US3] Create values.yaml template in exams/ckad-simulation2/templates/13/values.yaml

**Checkpoint**: Questions 8-14 visible, scoring works

---

## Phase 5: Questions Batch 3 (Q15-Q21) - Advanced

**Goal**: Implement questions 15-21 (31 points)

### Questions

- [ ] T042 [US1] Write Q15 (QoS Guaranteed, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T043 [US1] Write Q16 (SA Projected Token, 4pt) in exams/ckad-simulation2/questions.md
- [ ] T044 [US1] Write Q17 (TCP Socket Probe, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T045 [US1] Write Q18 (Named Ports, 5pt) in exams/ckad-simulation2/questions.md
- [ ] T046 [US1] Write Q19 (Topology Spread, 6pt) in exams/ckad-simulation2/questions.md
- [ ] T047 [US1] Write Q20 (Field Selectors, 3pt) in exams/ckad-simulation2/questions.md
- [ ] T048 [US1] Write Q21 (Pod Drain, 3pt) in exams/ckad-simulation2/questions.md

### Scoring Functions

- [ ] T049 [US2] Implement score_q15() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T050 [US2] Implement score_q16() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T051 [US2] Implement score_q17() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T052 [US2] Implement score_q18() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T053 [US2] Implement score_q19() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T054 [US2] Implement score_q20() in exams/ckad-simulation2/scoring-functions.sh
- [ ] T055 [US2] Implement score_q21() in exams/ckad-simulation2/scoring-functions.sh

**Checkpoint**: All 21 questions complete, total 112 points

---

## Phase 6: Solutions (US4)

**Goal**: Document all solutions with explanations

- [ ] T056 [US4] Write solutions for Q1-Q7 in exams/ckad-simulation2/solutions.md
- [ ] T057 [US4] Write solutions for Q8-Q14 in exams/ckad-simulation2/solutions.md
- [ ] T058 [US4] Write solutions for Q15-Q21 in exams/ckad-simulation2/solutions.md

**Checkpoint**: All solutions documented with commands and explanations

---

## Phase 7: Polish & Validation

**Purpose**: Final verification and documentation updates

- [ ] T059 Verify total points equals 112 in exams/ckad-simulation2/questions.md
- [ ] T060 Run quickstart.md validation steps
- [ ] T061 Update constitution.md exam statistics in .specify/memory/constitution.md
- [ ] T062 Update README.md with new sim2 description in README.md

**Checkpoint**: All validation passes, documentation updated

---

## Dependencies & Execution Order

```text
Phase 1 (Setup) → Phase 2 (Infrastructure) → Phase 3-5 (Questions) → Phase 6 (Solutions) → Phase 7 (Polish)
```

### Parallel Opportunities

```text
Phase 2: T003-T008 can run in parallel (different manifest files)
Phase 3-5: Question writing (T010-T048) can be parallelized in batches
Phase 6: T056-T058 can run in parallel (different sections)
```

---

## Implementation Strategy

### MVP First

1. Complete Phase 1-2 (infrastructure)
2. Complete Phase 3 (Q1-Q7) - First 7 questions usable
3. **VALIDATE**: Test with `./scripts/ckad-exam.sh web -e ckad-simulation2`
4. Complete remaining phases

### Batch Implementation

For each question batch:
1. Write all questions in batch
2. Implement all scoring functions in batch
3. Create required templates
4. Test batch before moving to next

---

## Summary

| Phase | Tasks | Description | Points |
|-------|-------|-------------|--------|
| Phase 1 | T001-T002 | Setup | - |
| Phase 2 | T003-T009 | Infrastructure | - |
| Phase 3 | T010-T024 | Q1-Q7 | 31 |
| Phase 4 | T025-T041 | Q8-Q14 | 39 |
| Phase 5 | T042-T055 | Q15-Q21 | 42 |
| Phase 6 | T056-T058 | Solutions | - |
| Phase 7 | T059-T062 | Polish | - |

**Total Tasks**: 62
**Total Questions**: 21
**Total Points**: 112
**Parallel Opportunities**: Manifests (Phase 2), Templates (Phase 3-5)
**MVP Scope**: Phase 1-3 (first 7 questions)
