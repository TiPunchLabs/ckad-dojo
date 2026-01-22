# Tasks: CKAD Simulation 4 - Norse Mythology Theme

**Input**: Design documents from `/specs/009-ckad-simulation4/`
**Prerequisites**: plan.md, spec.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Create exam directory structure and configuration

- [x] T001 Create exam directory structure at exams/ckad-simulation4/
- [x] T002 Create exam configuration in exams/ckad-simulation4/exam.conf with Norse namespaces
- [x] T003 Create manifests directory at exams/ckad-simulation4/manifests/setup/
- [x] T004 Create templates directory at exams/ckad-simulation4/templates/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create base namespace manifest required by all questions

**⚠️ CRITICAL**: Questions depend on namespaces being defined first

- [x] T005 Create namespaces.yaml with 9 Norse mythology namespaces in exams/ckad-simulation4/manifests/setup/namespaces.yaml

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Complete CKAD Exam Practice Session (Priority: P1) 🎯 MVP

**Goal**: Create 22 questions covering all 5 CKAD domains with Norse mythology theme

**Independent Test**: Run `./scripts/ckad-exam.sh web -e ckad-simulation4` and verify 22 questions load

### Domain 1: Application Design & Build (Q1-Q6)

- [x] T006 [P] [US1] Write Q1 (5pts) - Multi-container pod with sidecar in namespace odin - exams/ckad-simulation4/questions.md
- [x] T007 [P] [US1] Write Q2 (5pts) - Job with completions/parallelism in namespace thor - exams/ckad-simulation4/questions.md
- [x] T008 [P] [US1] Write Q3 (5pts) - Init container pod in namespace loki - exams/ckad-simulation4/questions.md
- [x] T009 [P] [US1] Write Q4 (5pts) - CronJob with schedule in namespace freya - exams/ckad-simulation4/questions.md
- [x] T010 [P] [US1] Write Q5 (6pts) - PersistentVolume and PVC in namespace heimdall - exams/ckad-simulation4/questions.md
- [x] T011 [P] [US1] Write Q6 (4pts) - StorageClass creation in namespace baldur - exams/ckad-simulation4/questions.md

### Domain 2: Application Deployment (Q7-Q10)

- [x] T012 [P] [US1] Write Q7 (5pts) - Deployment with strategy in namespace tyr - exams/ckad-simulation4/questions.md
- [x] T013 [P] [US1] Write Q8 (5pts) - Scale deployment in namespace njord - exams/ckad-simulation4/questions.md
- [x] T014 [P] [US1] Write Q9 (6pts) - Rollback deployment (pre-existing broken) in namespace njord - exams/ckad-simulation4/questions.md
- [x] T015 [P] [US1] Write Q10 (5pts) - Helm chart troubleshooting in namespace asgard - exams/ckad-simulation4/questions.md

### Domain 3: Services & Networking (Q11-Q14)

- [x] T016 [P] [US1] Write Q11 (5pts) - ClusterIP service in namespace thor - exams/ckad-simulation4/questions.md
- [x] T017 [P] [US1] Write Q12 (6pts) - NetworkPolicy ingress/egress in namespace freya - exams/ckad-simulation4/questions.md
- [x] T018 [P] [US1] Write Q13 (5pts) - Ingress resource in namespace baldur - exams/ckad-simulation4/questions.md
- [x] T019 [P] [US1] Write Q14 (5pts) - NodePort service in namespace asgard - exams/ckad-simulation4/questions.md

### Domain 4: Environment, Config & Security (Q15-Q19)

- [x] T020 [P] [US1] Write Q15 (5pts) - RBAC Role and RoleBinding in namespace odin - exams/ckad-simulation4/questions.md
- [x] T021 [P] [US1] Write Q16 (5pts) - Secret creation and mounting in namespace loki - exams/ckad-simulation4/questions.md
- [x] T022 [P] [US1] Write Q17 (6pts) - SecurityContext capabilities in namespace heimdall - exams/ckad-simulation4/questions.md
- [x] T023 [P] [US1] Write Q18 (5pts) - ResourceQuota in namespace tyr - exams/ckad-simulation4/questions.md
- [x] T024 [P] [US1] Write Q19 (5pts) - ConfigMap from file in namespace njord - exams/ckad-simulation4/questions.md

### Domain 5: Observability & Maintenance (Q20-Q22)

- [x] T025 [P] [US1] Write Q20 (6pts) - Readiness and Liveness probes in namespace asgard - exams/ckad-simulation4/questions.md
- [x] T026 [P] [US1] Write Q21 (5pts) - Debug pod with logs in namespace asgard - exams/ckad-simulation4/questions.md
- [x] T027 [P] [US1] Write Q22 (6pts) - Container image build and push in namespace asgard - exams/ckad-simulation4/questions.md

**Checkpoint**: All 22 questions written (115 points total)

---

## Phase 4: User Story 2 - Automated Scoring (Priority: P1)

**Goal**: Create scoring functions for all 22 questions with partial credit support

**Independent Test**: Run `./scripts/ckad-score.sh -e ckad-simulation4` after answering questions

- [x] T028 [US2] Create scoring-functions.sh header with source common.sh in exams/ckad-simulation4/scoring-functions.sh
- [x] T029 [P] [US2] Implement score_q1() for multi-container pod - exams/ckad-simulation4/scoring-functions.sh
- [x] T030 [P] [US2] Implement score_q2() for job - exams/ckad-simulation4/scoring-functions.sh
- [x] T031 [P] [US2] Implement score_q3() for init container - exams/ckad-simulation4/scoring-functions.sh
- [x] T032 [P] [US2] Implement score_q4() for cronjob - exams/ckad-simulation4/scoring-functions.sh
- [x] T033 [P] [US2] Implement score_q5() for PV/PVC - exams/ckad-simulation4/scoring-functions.sh
- [x] T034 [P] [US2] Implement score_q6() for storageclass - exams/ckad-simulation4/scoring-functions.sh
- [x] T035 [P] [US2] Implement score_q7() for deployment strategy - exams/ckad-simulation4/scoring-functions.sh
- [x] T036 [P] [US2] Implement score_q8() for scaling - exams/ckad-simulation4/scoring-functions.sh
- [x] T037 [P] [US2] Implement score_q9() for rollback - exams/ckad-simulation4/scoring-functions.sh
- [x] T038 [P] [US2] Implement score_q10() for helm - exams/ckad-simulation4/scoring-functions.sh
- [x] T039 [P] [US2] Implement score_q11() for clusterip service - exams/ckad-simulation4/scoring-functions.sh
- [x] T040 [P] [US2] Implement score_q12() for networkpolicy - exams/ckad-simulation4/scoring-functions.sh
- [x] T041 [P] [US2] Implement score_q13() for ingress - exams/ckad-simulation4/scoring-functions.sh
- [x] T042 [P] [US2] Implement score_q14() for nodeport service - exams/ckad-simulation4/scoring-functions.sh
- [x] T043 [P] [US2] Implement score_q15() for RBAC - exams/ckad-simulation4/scoring-functions.sh
- [x] T044 [P] [US2] Implement score_q16() for secret - exams/ckad-simulation4/scoring-functions.sh
- [x] T045 [P] [US2] Implement score_q17() for securitycontext - exams/ckad-simulation4/scoring-functions.sh
- [x] T046 [P] [US2] Implement score_q18() for resourcequota - exams/ckad-simulation4/scoring-functions.sh
- [x] T047 [P] [US2] Implement score_q19() for configmap - exams/ckad-simulation4/scoring-functions.sh
- [x] T048 [P] [US2] Implement score_q20() for probes - exams/ckad-simulation4/scoring-functions.sh
- [x] T049 [P] [US2] Implement score_q21() for debug/logs - exams/ckad-simulation4/scoring-functions.sh
- [x] T050 [P] [US2] Implement score_q22() for container build - exams/ckad-simulation4/scoring-functions.sh

**Checkpoint**: All 22 scoring functions implemented

---

## Phase 5: User Story 3 - Environment Setup and Cleanup (Priority: P1)

**Goal**: Create pre-existing resources required by questions

**Independent Test**: Run `./scripts/ckad-setup.sh -e ckad-simulation4` and verify namespaces/resources exist

### Pre-existing Deployments and Resources

- [x] T051 [P] [US3] Create q08-deployment.yaml for scaling question in exams/ckad-simulation4/manifests/setup/
- [x] T052 [P] [US3] Create q09-deployment.yaml for rollback question (with broken revision) in exams/ckad-simulation4/manifests/setup/
- [x] T053 [P] [US3] Create q11-pod.yaml for service question in exams/ckad-simulation4/manifests/setup/
- [x] T054 [P] [US3] Create q12-pods.yaml for networkpolicy question in exams/ckad-simulation4/manifests/setup/
- [x] T055 [P] [US3] Create q14-deployment.yaml for nodeport question in exams/ckad-simulation4/manifests/setup/
- [x] T056 [P] [US3] Create q21-broken-pod.yaml for debug question in exams/ckad-simulation4/manifests/setup/

### Templates for Questions

- [x] T057 [P] [US3] Create q01-sidecar.yaml template in exams/ckad-simulation4/templates/
- [x] T058 [P] [US3] Create q05-pv-pvc.yaml template in exams/ckad-simulation4/templates/
- [x] T059 [P] [US3] Create q13-ingress.yaml template in exams/ckad-simulation4/templates/
- [x] T060 [P] [US3] Create q22-image/ directory with Dockerfile and app.sh in exams/ckad-simulation4/templates/

### Post-Setup Configuration

- [x] T061 [US3] Add post-setup for Q9 rollback (broken revision) in scripts/lib/setup-functions.sh

**Checkpoint**: All pre-existing resources and templates ready

---

## Phase 6: User Story 4 - View Solutions After Exam (Priority: P2)

**Goal**: Create solutions for all 22 questions with explanations

**Independent Test**: Open solutions viewer in web interface after exam

- [x] T062 [US4] Create solutions.md header in exams/ckad-simulation4/solutions.md
- [x] T063 [P] [US4] Write solution for Q1-Q6 (Application Design & Build) - exams/ckad-simulation4/solutions.md
- [x] T064 [P] [US4] Write solution for Q7-Q10 (Application Deployment) - exams/ckad-simulation4/solutions.md
- [x] T065 [P] [US4] Write solution for Q11-Q14 (Services & Networking) - exams/ckad-simulation4/solutions.md
- [x] T066 [P] [US4] Write solution for Q15-Q19 (Environment, Config & Security) - exams/ckad-simulation4/solutions.md
- [x] T067 [P] [US4] Write solution for Q20-Q22 (Observability & Maintenance) - exams/ckad-simulation4/solutions.md

**Checkpoint**: All solutions documented

---

## Phase 7: Polish & Integration

**Purpose**: Final integration and documentation updates

- [x] T068 Update constitution.md with ckad-simulation4 info in .specify/memory/constitution.md
- [x] T069 Update README.md with 4 exams info
- [x] T070 Verify exam discovery works with `uv run ckad-dojo list`
- [x] T071 Run full integration test: setup, exam, score, cleanup

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - creates namespaces.yaml
- **US1 Questions (Phase 3)**: Depends on Foundational
- **US2 Scoring (Phase 4)**: Can run in parallel with US1 (references same questions)
- **US3 Manifests (Phase 5)**: Can run in parallel with US1/US2
- **US4 Solutions (Phase 6)**: Can run in parallel with US1/US2/US3
- **Polish (Phase 7)**: Depends on all user stories complete

### Parallel Opportunities

All tasks marked [P] within the same phase can run in parallel:

- T006-T027: All 22 questions can be written in parallel
- T029-T050: All 22 scoring functions can be implemented in parallel
- T051-T060: All manifests and templates can be created in parallel
- T063-T067: All solution sections can be written in parallel

---

## Implementation Strategy

### MVP First (Questions Only)

1. Complete Phase 1: Setup - Create directory structure
2. Complete Phase 2: Foundational - Create namespaces.yaml
3. Complete Phase 3: US1 - Write all 22 questions
4. **STOP and VALIDATE**: Verify questions load in web interface

### Full Implementation

1. After MVP: Add scoring functions (Phase 4)
2. Add pre-existing resources (Phase 5)
3. Add solutions (Phase 6)
4. Polish and integration (Phase 7)

---

## Summary

- **Total Tasks**: 71
- **US1 (Questions)**: 22 tasks
- **US2 (Scoring)**: 23 tasks
- **US3 (Resources)**: 11 tasks
- **US4 (Solutions)**: 6 tasks
- **Setup/Polish**: 9 tasks
- **Parallel Opportunities**: 60+ tasks can run in parallel within their phases
