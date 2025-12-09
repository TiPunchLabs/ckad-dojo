# Feature Specification: CKAD Simulation 4 - Norse Mythology Theme

**Feature Branch**: `009-ckad-simulation4`
**Created**: 2025-12-09
**Status**: Draft
**Input**: Exam de simulation CKAD nommé ckad-simulation4 avec thème mythologie nordique (namespaces: odin, thor, loki, freya, heimdall, baldur, tyr, njord, asgard). 22 questions couvrant tous les domaines CKAD.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete CKAD Exam Practice Session (Priority: P1)

A CKAD certification candidate wants to practice with a full simulation exam that covers all CKAD domains using Norse mythology themed namespaces for an immersive and memorable learning experience.

**Why this priority**: Core value proposition - provides complete exam simulation experience covering all CKAD curriculum domains.

**Independent Test**: Run `./scripts/ckad-exam.sh web -e ckad-simulation4` and verify 22 questions load with Norse mythology themed resources, timer works, and all question types are accessible.

**Acceptance Scenarios**:

1. **Given** the user selects ckad-simulation4, **When** they start the exam, **Then** 22 questions are displayed with 120-minute timer
2. **Given** the exam is running, **When** user navigates questions, **Then** they see Norse mythology themed namespaces (odin, thor, loki, etc.)
3. **Given** all 22 questions, **When** user reviews content, **Then** questions span all 5 CKAD domains with varying point values totaling ~115 points

---

### User Story 2 - Automated Scoring with Detailed Feedback (Priority: P1)

A user who has completed the exam wants to check their score with detailed per-question breakdown to identify areas needing improvement.

**Why this priority**: Essential for learning - users need feedback to understand their performance.

**Independent Test**: After attempting questions, run `./scripts/ckad-score.sh -e ckad-simulation4` and verify scores are calculated with breakdown.

**Acceptance Scenarios**:

1. **Given** user has attempted exam questions, **When** they run the scoring script, **Then** each question is scored against defined criteria
2. **Given** scoring completes, **When** results display, **Then** user sees points earned per question and total percentage
3. **Given** some questions incomplete, **When** scoring runs, **Then** partial credit is awarded where applicable

---

### User Story 3 - Environment Setup and Cleanup (Priority: P1)

A user wants to set up the exam environment with all pre-existing resources required for questions, and cleanly reset for retry.

**Why this priority**: Required for exam functionality - questions depend on pre-existing cluster resources.

**Independent Test**: Run `./scripts/ckad-setup.sh -e ckad-simulation4` and verify namespaces and resources are created.

**Acceptance Scenarios**:

1. **Given** clean cluster, **When** setup runs, **Then** 9 namespaces are created (odin, thor, loki, freya, heimdall, baldur, tyr, njord, asgard)
2. **Given** setup completes, **When** user checks cluster, **Then** pre-existing deployments, services, and resources are available
3. **Given** completed exam, **When** cleanup runs, **Then** all exam resources are removed for fresh retry

---

### User Story 4 - View Solutions After Exam (Priority: P2)

A user wants to review correct solutions after completing the exam to learn from mistakes.

**Why this priority**: Important for learning but not blocking for core exam functionality.

**Independent Test**: Access solutions.md in web interface after exam completion.

**Acceptance Scenarios**:

1. **Given** exam completed, **When** user opens solutions viewer, **Then** all 22 solutions are displayed with explanations
2. **Given** viewing solutions, **When** user reviews a question, **Then** kubectl commands and YAML manifests are shown

---

### Edge Cases

- What happens when Kubernetes cluster is unavailable? Display clear error message with connectivity check.
- What happens when some namespaces already exist? Setup is idempotent and handles existing resources gracefully.
- What happens when user interrupts setup mid-way? Cleanup script removes partial state.
- What happens when Helm is not installed? Display warning for Helm-related questions but allow exam to continue.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Exam MUST contain exactly 22 questions covering all 5 CKAD domains
- **FR-002**: Exam MUST use 9 Norse mythology themed namespaces: odin, thor, loki, freya, heimdall, baldur, tyr, njord, asgard
- **FR-003**: Total points MUST be approximately 115 points with 66% passing threshold
- **FR-004**: Exam duration MUST be 120 minutes
- **FR-005**: Each question MUST have automated scoring functions with partial credit support
- **FR-006**: Setup script MUST create all pre-existing resources required by questions
- **FR-007**: Cleanup script MUST remove all exam-related resources idempotently
- **FR-008**: Solutions MUST be provided for all questions with explanations

### Question Distribution Requirements

- **FR-009**: APPLICATION DESIGN AND BUILD domain MUST include: multi-container pods, init containers, jobs, cronjobs, PV/PVC, StorageClass (minimum 5 questions)
- **FR-010**: APPLICATION DEPLOYMENT domain MUST include: deployments, scaling, rolling updates, rollbacks, Helm charts (minimum 4 questions)
- **FR-011**: SERVICES AND NETWORKING domain MUST include: ClusterIP/NodePort services, NetworkPolicies, Ingress (minimum 4 questions)
- **FR-012**: APPLICATION ENVIRONMENT CONFIG AND SECURITY domain MUST include: ConfigMaps, Secrets, RBAC, ServiceAccounts, SecurityContext, ResourceQuotas (minimum 5 questions)
- **FR-013**: APPLICATION OBSERVABILITY AND MAINTENANCE domain MUST include: readiness/liveness probes, debugging, logs (minimum 4 questions)

### Key Entities

- **Exam Configuration (exam.conf)**: Defines exam metadata - name, ID, duration, namespaces, points, Helm releases
- **Question**: Individual exam item with question text, point value, scoring criteria, and solution
- **Namespace**: Norse mythology themed Kubernetes namespace (odin, thor, loki, freya, heimdall, baldur, tyr, njord, asgard)
- **Pre-existing Resource**: Kubernetes objects deployed during setup that questions reference
- **Scoring Function**: Bash function that validates user's answer against expected criteria

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full 22-question exam within 120 minutes
- **SC-002**: Automated scoring provides results for all questions within 60 seconds
- **SC-003**: Setup creates all required resources with zero manual intervention
- **SC-004**: All 5 CKAD domains are covered with appropriate question distribution
- **SC-005**: Each question has clear, testable acceptance criteria in scoring functions
- **SC-006**: Exam difficulty matches simulation1.md reference (similar complexity and point distribution)

## Assumptions

- Python 3.8+ and uv are available for web interface
- kubectl is configured with cluster access
- Helm 3.x is installed for Helm-related questions
- Docker or Podman is available for container image questions
- User has permissions to create/delete namespaces and cluster resources
