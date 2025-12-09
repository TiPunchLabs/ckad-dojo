# Feature Specification: CKAD Simulation 3 Exam

**Feature Branch**: `007-ckad-simulation3`
**Created**: 2025-12-08
**Status**: Draft
**Input**: Create a third CKAD exam simulation with Greek mythology theme

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run CKAD Simulation 3 Exam (Priority: P1)

A user wants to practice for the CKAD certification exam by running a complete simulation exam with Greek mythology theme that covers all CKAD domains.

**Why this priority**: Core functionality - without the exam content, users cannot practice.

**Independent Test**: Can be fully tested by running `./scripts/ckad-exam.sh web -e ckad-simulation3` and completing questions.

**Acceptance Scenarios**:

1. **Given** exam files exist in `exams/ckad-simulation3/`, **When** user runs `./scripts/ckad-exam.sh web -e ckad-simulation3`, **Then** the web interface displays all 20 questions with Greek mythology theme
2. **Given** exam is running, **When** user navigates between questions, **Then** question content displays correctly without truncation
3. **Given** exam is selected, **When** setup script runs, **Then** all namespaces (olympus, athena, apollo, etc.) are created and pre-existing resources deployed

---

### User Story 2 - Score Exam Answers (Priority: P1)

A user wants to have their answers automatically scored to verify correctness.

**Why this priority**: Essential for learning - users must know if their solutions are correct.

**Independent Test**: Can be tested by completing questions and running `./scripts/ckad-score.sh -e ckad-simulation3`

**Acceptance Scenarios**:

1. **Given** user has completed questions, **When** scoring script runs, **Then** each question is validated against scoring criteria
2. **Given** correct answers provided, **When** scored, **Then** score reflects accurate point totals (max 105 points)
3. **Given** partial answers, **When** scored, **Then** partial credit awarded where applicable

---

### User Story 3 - View Exam Solutions (Priority: P2)

A user wants to review solutions after completing the exam to learn correct approaches.

**Why this priority**: Learning tool - helps users understand correct implementations.

**Independent Test**: Can be tested by viewing solutions.md in the web interface after exam completion.

**Acceptance Scenarios**:

1. **Given** exam is complete, **When** user clicks "View Solutions", **Then** solutions for all 20 questions are displayed
2. **Given** solutions displayed, **When** user navigates, **Then** markdown renders correctly with code blocks highlighted

---

### User Story 4 - Reset Exam Environment (Priority: P2)

A user wants to reset the environment to retry the exam with a fresh cluster state.

**Why this priority**: Enables repeated practice without manual cleanup.

**Independent Test**: Can be tested by running `./scripts/ckad-cleanup.sh -e ckad-simulation3`

**Acceptance Scenarios**:

1. **Given** exam resources exist, **When** cleanup script runs, **Then** all exam namespaces and resources are removed
2. **Given** cleanup complete, **When** setup runs again, **Then** environment returns to initial exam state

---

### Edge Cases

- What happens when a namespace already exists from a previous attempt? (Should delete and recreate)
- How does system handle if Helm repo is unavailable? (Graceful fallback with warning)
- What if pre-existing Pod from Q8 fails to reach ready state? (Timeout and continue)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Exam MUST contain 20 questions covering all CKAD domains
- **FR-002**: Exam MUST use Greek mythology theme (namespace names: olympus, athena, apollo, artemis, hermes, poseidon, hades, zeus, hera, ares, titan)
- **FR-003**: Total points MUST equal 105 with 66% passing threshold
- **FR-004**: Each question MUST have a corresponding scoring function in `scoring-functions.sh`
- **FR-005**: Setup script MUST create all namespaces and deploy pre-existing resources
- **FR-006**: Setup script MUST deploy Helm releases in `olympus` namespace
- **FR-007**: Questions MUST include tasks for: Namespaces, Pods, Jobs, CronJobs, Deployments, Helm, ConfigMaps, Secrets, Services, NetworkPolicies, PV/PVC, Probes, ServiceAccounts, Labels, Annotations, Container builds

### Key Entities

- **Exam Configuration** (`exam.conf`): Defines exam metadata, duration, namespaces, Helm releases, points
- **Questions** (`questions.md`): 20 questions in markdown format with metadata tables
- **Solutions** (`solutions.md`): Detailed solutions with kubectl/helm commands
- **Scoring Functions** (`scoring-functions.sh`): Bash functions `score_q1()` through `score_q20()` returning `score/max_points`
- **Setup Manifests** (`manifests/setup/`): YAML files for pre-existing resources
- **Templates** (`templates/`): Files copied to exam directories (Dockerfile for Q20)

## Question Distribution by CKAD Domain

| Domain | Questions | Points |
|--------|-----------|--------|
| Application Design and Build | Q2, Q12, Q17, Q20 | 26 |
| Application Deployment | Q4, Q8, Q16 | 15 |
| Application Observability and Maintenance | Q13, Q18, Q19 | 15 |
| Application Environment, Configuration and Security | Q5, Q6, Q7, Q10, Q14 | 27 |
| Services and Networking | Q9, Q10 | 12 |
| Storage | Q11 | 6 |
| Core Concepts | Q1, Q3, Q15 | 11 |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 20 questions render correctly in web interface
- **SC-002**: Setup script completes in under 2 minutes
- **SC-003**: All scoring functions execute correctly and return valid score/max format
- **SC-004**: Cleanup script removes all exam resources without errors
- **SC-005**: Unit tests pass for all exam-specific setup/cleanup functions
- **SC-006**: Exam difficulty comparable to ckad-simulation1 and ckad-simulation2
