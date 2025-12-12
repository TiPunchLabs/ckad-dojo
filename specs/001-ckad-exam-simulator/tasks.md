# Tasks: CKAD Exam Simulator

**Input**: Design documents from `/specs/001-ckad-exam-simulator/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md
**Status**: Implemented

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US7)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure) ✅ COMPLETED

**Purpose**: Project initialization and directory structure

- [x] T001 Create scripts directory at scripts/
- [x] T002 Create manifests/setup/ directory structure
- [x] T003 Create templates/ directory structure
- [x] T004 [P] Create scripts/lib/ directory for shared functions
- [x] T005 [P] Create common.sh with shared utilities in scripts/lib/common.sh

**Checkpoint**: ✅ Directory structure ready for implementation

---

## Phase 2: Foundational (Blocking Prerequisites) ✅ COMPLETED

**Purpose**: Shared library functions and manifests needed by all scripts

### Manifests Creation

- [x] T006 [P] Create namespaces.yaml with all 11 namespaces in manifests/setup/namespaces.yaml
- [x] T007 [P] Create q05-serviceaccount.yaml (neptune-sa-v2) in manifests/setup/q05-serviceaccount.yaml
- [x] T008 [P] Create q07-saturn-pods.yaml (6 webserver pods) in manifests/setup/q07-saturn-pods.yaml
- [x] T009 [P] Create q08-deployment.yaml (api-new-c32 with typo) in manifests/setup/q08-deployment.yaml
- [x] T010 [P] Create q09-holy-api-pod.yaml in manifests/setup/q09-holy-api-pod.yaml
- [x] T011 [P] Create q14-secret-handler.yaml in manifests/setup/q14-secret-handler.yaml
- [x] T012 [P] Create q15-web-moon-deploy.yaml in manifests/setup/q15-web-moon-deploy.yaml
- [x] T013 [P] Create q16-cleaner-deploy.yaml in manifests/setup/q16-cleaner-deploy.yaml
- [x] T014 [P] Create q18-manager-api.yaml (deployment + broken service) in manifests/setup/q18-manager-api.yaml
- [x] T015 [P] Create q19-jupiter-crew.yaml (deployment + service) in manifests/setup/q19-jupiter-crew.yaml
- [x] T016 [P] Create q20-venus-deployments.yaml (api + frontend + services) in manifests/setup/q20-venus-deployments.yaml
- [x] T017 [P] Create q22-sun-pods.yaml (16 pods with labels) in manifests/setup/q22-sun-pods.yaml

### Template Files Creation

- [x] T018 [P] Create q09-holy-api-pod.yaml template in templates/q09-holy-api-pod.yaml
- [x] T019 [P] Create q14-secret-handler.yaml template in templates/q14-secret-handler.yaml
- [x] T020 [P] Create q16-cleaner.yaml template in templates/q16-cleaner.yaml
- [x] T021 [P] Create q17-test-init-container.yaml template in templates/q17-test-init-container.yaml
- [x] T022 [P] Create q11-image/Dockerfile in templates/q11-image/Dockerfile
- [x] T023 [P] Create q11-image/main.go in templates/q11-image/main.go
- [x] T024 [P] Create q-p1-project-23-api.yaml template in templates/q-p1-project-23-api.yaml

**Checkpoint**: ✅ All manifests and templates ready

---

## Phase 3: User Story 1 - Setup Exam Environment ✅ COMPLETED

**Goal**: Configure cluster with all pre-requisites for 24 exam questions

- [x] T025 [US1] Create setup-functions.sh with namespace creation in scripts/lib/setup-functions.sh
- [x] T026 [US1] Add resource deployment functions to scripts/lib/setup-functions.sh
- [x] T027 [US1] Add directory structure creation to scripts/lib/setup-functions.sh
- [x] T028 [US1] Add template file copying to scripts/lib/setup-functions.sh
- [x] T029 [US1] Create main ckad-setup.sh script in scripts/ckad-setup.sh
- [x] T030 [US1] Add idempotency checks (skip existing resources) to scripts/ckad-setup.sh
- [x] T031 [US1] Add progress output and summary to scripts/ckad-setup.sh
- [x] T032 [US1] Make scripts executable with chmod +x scripts/*.sh

**Checkpoint**: ✅ `./scripts/ckad-setup.sh` creates complete exam environment

---

## Phase 4: User Story 2 - Automated Scoring ✅ COMPLETED

**Goal**: Evaluate all 113+ scoring criteria and display results

- [x] T033 [US2] Create scoring-functions.sh skeleton in scripts/lib/scoring-functions.sh
- [x] T034-T057 [US2] Implement all score_qN() functions (Q1-Q22, P1, P2) in scripts/lib/scoring-functions.sh
- [x] T058 [US2] Create main ckad-score.sh with table output in scripts/ckad-score.sh
- [x] T059 [US2] Add total score calculation and percentage in scripts/ckad-score.sh

**Checkpoint**: ✅ `./scripts/ckad-score.sh` evaluates all criteria correctly

---

## Phase 5: User Story 3 - Cleanup Environment ✅ COMPLETED

**Goal**: Reset cluster to pre-exam state

- [x] T060 [US3] Create cleanup functions in scripts/lib/setup-functions.sh
- [x] T061 [US3] Add namespace deletion function (idempotent)
- [x] T062 [US3] Add Helm release cleanup function
- [x] T063 [US3] Add directory cleanup function
- [x] T064 [US3] Add registry container cleanup function
- [x] T065 [US3] Create main ckad-cleanup.sh script in scripts/ckad-cleanup.sh
- [x] T066 [US3] Add confirmation prompt and progress output

**Checkpoint**: ✅ `./scripts/ckad-cleanup.sh` fully resets environment

---

## Phase 6: User Story 4 - Web Interface with Timer ✅ COMPLETED

**Goal**: Provide web-based question viewer with integrated 120-minute countdown timer

- [x] T067 [US4] Create web/ directory structure
- [x] T068 [US4] Create Python web server with API in web/server.py
- [x] T069 [US4] Create HTML interface in web/index.html
- [x] T070 [US4] Create CSS styles with dark/light themes in web/css/style.css
- [x] T071 [US4] Create JavaScript application logic in web/js/app.js
- [x] T072 [US4] Add exam selection screen with exam list
- [x] T073 [US4] Implement 120-minute countdown timer with visual warnings
- [x] T074 [US4] Add question navigation (arrows, dropdown, keyboard)
- [x] T075 [US4] Add question flagging for review
- [x] T076 [US4] Add dark/light theme toggle with persistence
- [x] T077 [US4] Add time's up modal that blocks interface
- [x] T078 [US4] Add question metadata display (points, namespace, resources, files)
- [x] T079 [US4] Implement markdown rendering with syntax highlighting
- [x] T080 [US4] Update ckad-exam.sh with `web` command (default)

**Checkpoint**: ✅ Web interface fully functional at http://localhost:9090

---

## Phase 7: User Story 5 - Multi-Exam Support ✅ COMPLETED

**Goal**: Support multiple exam configurations

- [x] T081 [US5] Create exams/ directory structure
- [x] T082 [US5] Create exam.conf configuration format
- [x] T083 [US5] Create questions.md format for exam questions
- [x] T084 [US5] Add exam selection to setup script (-e/--exam)
- [x] T085 [US5] Add exam selection to score script (-e/--exam)
- [x] T086 [US5] Add exam selection to cleanup script (-e/--exam)
- [x] T087 [US5] Add `list` command to ckad-exam.sh
- [x] T088 [US5] Create ckad-simulation1 exam in exams/ckad-simulation1/

**Checkpoint**: ✅ Multi-exam architecture working

---

## Phase 8: User Story 6 - Helm Question Environment ✅ COMPLETED

**Goal**: Configure Helm releases and repository for Q4

- [x] T089 [US6] Add Helm repo setup function to scripts/lib/setup-functions.sh
- [x] T090 [US6] Add Helm releases installation to setup script
- [x] T091 [US6] Add Helm-specific scoring to score_q4()
- [x] T092 [US6] Add Helm cleanup to cleanup script

**Checkpoint**: ✅ Q4 Helm environment fully functional

---

## Phase 9: User Story 7 - Docker Question Environment ✅ COMPLETED

**Goal**: Configure local registry and Q11 files

- [x] T093 [US7] Add registry container start function to scripts/lib/setup-functions.sh
- [x] T094 [US7] Update ckad-setup.sh to start registry
- [x] T095 [US7] Ensure Q11 templates are copied correctly during setup
- [x] T096 [US7] Update score_q11() to use docker commands
- [x] T097 [US7] Add registry cleanup to ckad-cleanup.sh

**Checkpoint**: ✅ Q11 Docker environment fully functional

---

## Phase 10: Polish & Documentation ✅ COMPLETED

**Purpose**: Final touches and validation

- [x] T098 Update quickstart.md with web interface instructions
- [x] T099 Add helpful error messages to all scripts
- [x] T100 Add color output for PASS/FAIL in scoring script
- [x] T101 Add --help option to all scripts
- [x] T102 Validate full cycle: setup → score → cleanup → setup
- [x] T103 Update spec.md with all implemented features
- [x] T104 Update plan.md with final project structure
- [x] T105 Update data-model.md with web interface state

---

## Phase 11: Stop Exam & Scoring Integration ✅ COMPLETED

**Goal**: Allow users to stop the exam early and see their score in the web interface

- [x] T106 [US4] Add subprocess import to web/server.py
- [x] T107 [US4] Create run_scoring_script() function in web/server.py
- [x] T108 [US4] Add /api/score POST endpoint in web/server.py
- [x] T109 [US4] Add "Stop Exam" button (btn-danger) to footer in web/index.html
- [x] T110 [US4] Create score results modal (modal-score) in web/index.html
- [x] T111 [US4] Add getScore() API function in web/js/app.js
- [x] T112 [US4] Add stopExam() function with confirmation in web/js/app.js
- [x] T113 [US4] Add renderQuestionScores() function in web/js/app.js
- [x] T114 [US4] Add event listeners for Stop Exam and modal buttons in web/js/app.js
- [x] T115 [US4] Add btn-danger styles in web/css/style.css
- [x] T116 [US4] Add score modal styles (.modal-score, .score-summary, etc.) in web/css/style.css
- [x] T117 [US4] Add score question item styles (.score-question-item) in web/css/style.css
- [x] T118 Update spec.md with Stop Exam acceptance scenarios (FR-047 to FR-052)
- [x] T119 Update plan.md with Phase 4: Stop Exam & Scoring Integration
- [x] T120 Update tasks.md with Phase 11 tasks
- [x] T121 Update constitution.md with Stop Exam feature
- [x] T122 Update quickstart.md with Stop Exam instructions

**Checkpoint**: ✅ Stop Exam feature fully functional with score display

---

## Phase 12: Interactive Exam Selection ✅ COMPLETED

**Goal**: Add interactive menu for exam and question selection at launch

- [x] T123 [US5] Add get_available_exams() function in scripts/ckad-exam.sh
- [x] T124 [US5] Add select_exam_interactive() function with menu display
- [x] T125 [US5] Add detect_existing_exam_resources() function to check cluster
- [x] T126 [US5] Add check_and_offer_cleanup() function with 3 options
- [x] T127 [US5] Add select_starting_question() function for question selection
- [x] T128 [US5] Add -e/--exam option to argument parsing
- [x] T129 [US5] Add -q/--question option to argument parsing
- [x] T130 [US5] Update start_web() to accept start_question parameter
- [x] T131 [US5] Update start_exam() to accept start_question parameter
- [x] T132 [US4] Add start_question to timer_state in web/server.py
- [x] T133 [US4] Update get_timer_state() to return start_question
- [x] T134 [US4] Update main() to accept start_question argument
- [x] T135 [US4] Update resumeExam() in web/js/app.js to use start_question
- [x] T136 [US4] Update checkExistingSession() to pass start_question
- [x] T137 Update README.md with new launch options
- [x] T138 Update constitution.md with interactive selection features

**Checkpoint**: ✅ Interactive exam selection fully functional

---

## Summary

| Phase | Description | Status |
|-------|-------------|--------|
| Setup | Directory structure | ✅ Completed |
| Foundational | Manifests & templates | ✅ Completed |
| US1 Setup | ckad-setup.sh script | ✅ Completed |
| US2 Scoring | ckad-score.sh script | ✅ Completed |
| US3 Cleanup | ckad-cleanup.sh script | ✅ Completed |
| US4 Web Interface | Web UI with timer | ✅ Completed |
| US5 Multi-Exam | Exam architecture | ✅ Completed |
| US6 Helm | Helm environment | ✅ Completed |
| US7 Docker | Docker environment | ✅ Completed |
| Polish | Documentation | ✅ Completed |
| Stop Exam | Scoring integration in web UI | ✅ Completed |
| Interactive Selection | Exam & question selection menu | ✅ Completed |

**Total Tasks**: 138
**Completed**: 138 (100%)
**Implementation Status**: ✅ FULLY IMPLEMENTED
