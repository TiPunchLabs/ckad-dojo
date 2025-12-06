# Feature Specification: CKAD Simulation 2 & Solutions Feature

**Feature Branch**: `002-ckad-simulation2`
**Created**: 2025-12-05
**Status**: Draft
**Input**: Create a new CKAD exam (ckad-simulation2) with 21 questions at the same difficulty level as simulation1, fully functional in the project (setup, score, cleanup). Add a solutions page feature that displays questions with their solutions after exam completion, applicable to all exams.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete New CKAD Exam Session (Priority: P1)

As a CKAD candidate, I want to practice with a second complete exam simulation (ckad-simulation2) so that I can diversify my training and encounter different question scenarios.

**Why this priority**: The primary goal is to provide a new, complete, fully functional exam with 21 questions covering all CKAD domains at the same difficulty level as simulation1.

**Independent Test**: Can be fully tested by launching `./scripts/ckad-exam.sh -e ckad-simulation2`, completing questions, running `./scripts/ckad-score.sh -e ckad-simulation2`, and verifying all 21 questions are scored correctly.

**Acceptance Scenarios**:

1. **Given** I am at the exam launcher, **When** I select ckad-simulation2, **Then** the exam loads with 21 questions and a 120-minute timer
2. **Given** the exam is running, **When** I navigate through questions, **Then** I see questions covering all CKAD domains (Pods, Deployments, Services, ConfigMaps, Secrets, PVs, NetworkPolicies, etc.)
3. **Given** I complete questions in ckad-simulation2, **When** I run the scoring script, **Then** I receive a detailed score breakdown for all 21 questions
4. **Given** I want to reset the exam, **When** I run cleanup, **Then** all ckad-simulation2 resources are removed from the cluster

---

### User Story 2 - View Solutions After Exam (Priority: P2)

As a CKAD candidate, I want to view the correct solutions for each question after I finish my exam so that I can learn from my mistakes and understand the expected approach.

**Why this priority**: This learning feature enhances the educational value of the simulator by providing immediate feedback with detailed solutions.

**Independent Test**: Can be tested by clicking "View Solutions" in the score modal after exam completion, and verifying each question displays its solution content.

**Acceptance Scenarios**:

1. **Given** I have stopped the exam and see my score, **When** I click "View Solutions", **Then** I see a page with all questions and their detailed solutions
2. **Given** I am viewing solutions, **When** I look at a question I failed, **Then** I see the expected commands, YAML manifests, and explanations
3. **Given** I am viewing solutions, **When** I want to return to the score summary, **Then** I can navigate back easily
4. **Given** the solutions feature exists, **When** I use any exam (simulation1 or simulation2), **Then** solutions are available for that specific exam

---

### User Story 3 - Exam Setup with Pre-existing Resources (Priority: P3)

As a CKAD candidate, I want the exam setup to create all necessary pre-existing resources (broken deployments, pods to fix, services to troubleshoot) so that the exam experience matches the real CKAD certification.

**Why this priority**: Realistic exam conditions require pre-configured resources that students must diagnose, modify, or fix.

**Independent Test**: Can be tested by running `./scripts/ckad-setup.sh -e ckad-simulation2` and verifying all expected namespaces, pods, deployments, and services exist in the cluster.

**Acceptance Scenarios**:

1. **Given** I run the setup script for ckad-simulation2, **When** setup completes, **Then** all required namespaces are created (andromeda, orion, pegasus, cygnus, lyra, aquila, draco, phoenix, hydra, centaurus, cassiopeia)
2. **Given** setup is complete, **When** I check for pre-existing resources, **Then** I find deployments, pods, and services matching question requirements
3. **Given** some resources have intentional issues, **When** I examine them, **Then** I can identify the problems to fix (typos, misconfigurations)
4. **Given** I run setup multiple times, **When** resources already exist, **Then** setup is idempotent and completes successfully

---

### Edge Cases

- What happens when solutions.md file is missing for an exam? System displays graceful message indicating solutions are not yet available
- How does system handle viewing solutions when exam was never started? Solutions button is only visible after exam completion
- What happens if user tries to run ckad-simulation2 setup when simulation1 resources exist? System detects conflict and offers cleanup as per existing behavior
- How does scoring handle partially answered multi-part questions? Each criterion is scored independently as per existing behavior

## Requirements *(mandatory)*

### Functional Requirements

#### CKAD Simulation 2 Exam Content

- **FR-001**: System MUST provide 21 main questions covering all CKAD exam domains
- **FR-002**: System MUST include questions at the same difficulty level as ckad-simulation1 (mix of 1-10 point questions)
- **FR-003**: System MUST provide a total score of approximately 110 points with 66% passing threshold
- **FR-004**: System MUST use galaxy/constellation themed namespaces distinct from simulation1
- **FR-005**: System MUST include at least 1 preview/bonus question not counted in main score

#### Question Topic Coverage

- **FR-006**: Exam MUST include questions on Pods (creation, multi-container, resource limits)
- **FR-007**: Exam MUST include questions on Deployments (creation, updates, rollbacks, scaling)
- **FR-008**: Exam MUST include questions on Services (ClusterIP, NodePort, troubleshooting)
- **FR-009**: Exam MUST include questions on ConfigMaps and Secrets (creation, mounting, environment variables)
- **FR-010**: Exam MUST include questions on Persistent Volumes and Claims
- **FR-011**: Exam MUST include questions on Jobs and CronJobs
- **FR-012**: Exam MUST include questions on NetworkPolicies
- **FR-013**: Exam MUST include questions on Probes (liveness, readiness, startup)
- **FR-014**: Exam MUST include questions on ServiceAccounts and RBAC concepts
- **FR-015**: Exam MUST include questions on Helm operations
- **FR-016**: Exam MUST include questions on container image building (Docker/Podman)
- **FR-017**: Exam MUST include questions on InitContainers and Sidecars
- **FR-018**: Exam MUST include questions on Labels, Annotations, and Selectors

#### Exam Infrastructure

- **FR-019**: System MUST provide exam.conf configuration file for ckad-simulation2
- **FR-020**: System MUST provide questions.md file with all 21 questions in standard format
- **FR-021**: System MUST provide scoring-functions.sh with score_q1() through score_q21() functions
- **FR-022**: System MUST provide manifests/setup/ directory with pre-existing resources
- **FR-023**: System MUST provide templates/ directory with template files for applicable questions
- **FR-024**: System MUST create exam/course/ directories for student answers during setup

#### Solutions Feature

- **FR-025**: System MUST provide a solutions.md file for each exam containing detailed solutions
- **FR-026**: Web interface MUST display "View Solutions" button in score modal after exam completion
- **FR-027**: Solutions page MUST display each question with its solution including commands and YAML
- **FR-028**: Solutions MUST include explanations for why each approach is correct
- **FR-029**: Solutions page MUST allow navigation between questions (previous/next)
- **FR-030**: Solutions page MUST indicate which questions user passed/failed
- **FR-031**: System MUST parse solutions.md and render markdown with syntax highlighting
- **FR-032**: Solutions feature MUST be available for all exams (simulation1 and simulation2)

#### Integration with Existing Scripts

- **FR-033**: ckad-setup.sh MUST support ckad-simulation2 via -e flag
- **FR-034**: ckad-score.sh MUST support ckad-simulation2 via -e flag
- **FR-035**: ckad-cleanup.sh MUST support ckad-simulation2 via -e flag
- **FR-036**: ckad-exam.sh MUST list ckad-simulation2 in interactive selection menu

### Key Entities

- **Exam**: Configuration (exam.conf), questions (questions.md), solutions (solutions.md), scoring (scoring-functions.sh)
- **Question**: ID, topic, points, namespace, resources, task description, solution
- **Solution**: Question reference, step-by-step commands, YAML manifests, explanation
- **Namespace Set**: Collection of themed namespaces for exam isolation (galaxy/constellation theme)
- **Pre-existing Resource**: Deployment, Pod, Service, or other resource created during setup for student interaction

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 21 questions in ckad-simulation2 can be completed and scored within the 120-minute time limit
- **SC-002**: Scoring accuracy matches 100% against known correct answers (automated test with expected solutions)
- **SC-003**: Setup script creates all required resources in under 60 seconds on a standard cluster
- **SC-004**: Cleanup script removes all exam resources in under 30 seconds
- **SC-005**: Solutions page loads and displays all content within 2 seconds
- **SC-006**: 100% of questions have corresponding solutions with at least one valid approach
- **SC-007**: Both ckad-simulation1 and ckad-simulation2 work identically with the new solutions feature
- **SC-008**: Interactive exam selection correctly displays and launches both exams

## Assumptions

- Users have a functioning Kubernetes cluster with kubectl, helm, docker/podman access
- The existing exam infrastructure (scripts, web interface) is stable and requires minimal modifications
- Question difficulty is assessed based on point value and complexity matching simulation1 patterns
- Solutions will be displayed in read-only mode after exam completion (no editing)
- Galaxy/constellation theme for namespaces provides sufficient distinctness from simulation1's planetary theme
- solutions.md will be created for ckad-simulation1 as part of this feature implementation

## Out of Scope

- Real-time hints or help during the exam
- Solution submission or grading beyond the existing scoring system
- Multi-language support for questions or solutions
- Timed practice mode for individual questions
- Comparison of user answers with expected solutions (only pass/fail displayed)
