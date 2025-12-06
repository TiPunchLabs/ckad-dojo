# Feature Specification: CKAD Exam Simulator

**Feature Branch**: `001-ckad-exam-simulator`
**Created**: 2025-12-04
**Updated**: 2025-12-05
**Status**: Implemented
**Input**: Configure Kubernetes cluster for local CKAD exam simulation with automated scoring, web interface, and timer

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Setup Exam Environment (Priority: P1)

As a CKAD candidate, I want to configure my local Kubernetes cluster with all the pre-requisites needed for the exam simulation, so that I can practice answering exam questions in a realistic environment.

**Why this priority**: Without the exam environment properly configured, no questions can be answered. This is the foundational requirement that enables all other functionality.

**Independent Test**: Can be fully tested by running the setup script and verifying all namespaces, pre-existing resources, and file directories are created correctly.

**Acceptance Scenarios**:

1. **Given** an empty kubeadm cluster, **When** I run the setup script, **Then** all 11 required namespaces are created (neptune, saturn, earth, mars, pluto, jupiter, mercury, venus, moon, sun, shell-intern)
2. **Given** the setup script has run, **When** I check the cluster, **Then** all pre-existing resources needed for exam questions are deployed (existing Deployments, Pods, Services, ServiceAccounts, Secrets)
3. **Given** the setup script has run, **When** I check the local filesystem, **Then** the `./exam/course/` directory structure exists with subdirectories for each question (1-22, p1, p2)
4. **Given** pre-existing YAML template files are needed for certain questions, **When** the setup completes, **Then** these files are placed in the correct `./exam/course/N/` directories

---

### User Story 2 - Automated Scoring (Priority: P2)

As a CKAD candidate, I want to run a scoring script after answering questions to see my score and which criteria I passed or failed, so that I can understand my progress and identify areas for improvement.

**Why this priority**: Scoring provides essential feedback on exam performance. Without it, users cannot evaluate their answers.

**Independent Test**: Can be fully tested by running the score script on a cluster with known correct/incorrect answers and verifying the output matches expected scores.

**Acceptance Scenarios**:

1. **Given** I have answered some exam questions, **When** I run the scoring script, **Then** I see a detailed breakdown of points per question
2. **Given** a question has multiple scoring criteria, **When** the script evaluates it, **Then** each criterion is individually marked as PASS or FAIL with its point value
3. **Given** I have answered all questions, **When** the script completes, **Then** I see a total score and percentage (e.g., "87/113 - 77%")
4. **Given** I have not completed a question, **When** the script runs, **Then** that question shows 0 points without errors
5. **Given** the cluster is in any state, **When** I run the scoring script, **Then** no resources are modified (read-only operation)

---

### User Story 3 - Cleanup Environment (Priority: P3)

As a CKAD candidate, I want to completely reset my cluster to its pre-exam state, so that I can start a fresh exam simulation or return my cluster to normal use.

**Why this priority**: Essential for retaking the exam or cleaning up after practice, but not needed for the core exam experience.

**Independent Test**: Can be fully tested by running cleanup after setup and verifying all exam-related resources are removed.

**Acceptance Scenarios**:

1. **Given** an exam environment has been set up, **When** I run the cleanup script, **Then** all exam-specific namespaces are deleted
2. **Given** Helm releases were created for the exam, **When** cleanup runs, **Then** all exam-related Helm releases are uninstalled
3. **Given** the `./exam/course/` directory exists with user answers, **When** cleanup runs, **Then** the directory and all contents are removed
4. **Given** some resources were already manually deleted, **When** cleanup runs, **Then** no errors occur (idempotent operation)

---

### User Story 4 - Web Interface with Timer (Priority: P4)

As a CKAD candidate, I want a web-based interface to view questions with an integrated 120-minute countdown timer, so that I can practice under realistic exam conditions.

**Why this priority**: Provides a modern, realistic exam experience with time pressure simulation.

**Independent Test**: Can be fully tested by launching the web interface and verifying timer, navigation, and display work correctly.

**Acceptance Scenarios**:

1. **Given** I launch the web interface, **When** I select an exam, **Then** the 120-minute countdown timer starts automatically
2. **Given** the timer is running, **When** I navigate between questions, **Then** the timer continues uninterrupted
3. **Given** the timer reaches warning thresholds (15 min, 5 min, 1 min), **Then** the timer display changes color (yellow, then red)
4. **Given** the timer reaches 0, **When** time expires, **Then** a modal appears indicating time is up and the interface is blocked
5. **Given** I am viewing a question, **When** I press arrow keys, **Then** I navigate to previous/next question
6. **Given** I want to review certain questions, **When** I click "Flag", **Then** the question is marked and visible in the flagged list
7. **Given** I prefer dark or light mode, **When** I toggle the theme, **Then** the interface switches accordingly
8. **Given** I want to end the exam early, **When** I click "Stop Exam", **Then** I see a confirmation dialog, the timer stops, and my score is calculated and displayed

---

### User Story 5 - Multi-Exam Support (Priority: P5)

As a CKAD candidate, I want to be able to select from multiple available exams, so that I can practice with different question sets.

**Why this priority**: Allows future expansion with additional exam simulations.

**Independent Test**: Can be tested by creating a second exam and verifying it appears in the list and can be launched.

**Acceptance Scenarios**:

1. **Given** multiple exams exist in `exams/` directory, **When** I run list command, **Then** all available exams are displayed
2. **Given** I select a specific exam, **When** setup runs, **Then** only that exam's resources are deployed
3. **Given** each exam has its own configuration, **When** I launch it, **Then** the correct duration, questions, and scoring are used

---

### User Story 6 - Helm Question Environment (Priority: P6)

As a CKAD candidate, I want the Helm-based questions (Q4) to be properly configured with the required Helm releases and repository, so that I can practice Helm operations as in the real exam.

**Why this priority**: Helm is one specific topic in the exam; the simulator should support it but it's not critical for the majority of questions.

**Independent Test**: Can be fully tested by verifying Helm releases exist after setup and can be manipulated as per Q4 requirements.

**Acceptance Scenarios**:

1. **Given** the setup script has run, **When** I list Helm releases in namespace mercury, **Then** I see the pre-installed releases (internal-issue-report-apiv1, internal-issue-report-apiv2, internal-issue-report-app)
2. **Given** the bitnami Helm repository is configured, **When** I search for nginx, **Then** charts are available

---

### User Story 7 - Docker/Podman Question Environment (Priority: P7)

As a CKAD candidate, I want the container-based question (Q11) to be properly configured with required files and a local registry, so that I can practice container image building and pushing with both Docker and Podman.

**Why this priority**: This is a single question requiring specific infrastructure; important but lower priority than core Kubernetes questions.

**Independent Test**: Can be fully tested by verifying Dockerfile exists, registry is accessible, and images can be pushed/pulled with both Docker and Podman.

**Acceptance Scenarios**:

1. **Given** setup has run, **When** I check `./exam/course/11/image/`, **Then** I find the Dockerfile and Go application source files
2. **Given** a local registry is deployed, **When** I push an image with Docker to `localhost:5000/sun-cipher:v1-docker`, **Then** the push succeeds
3. **Given** a local registry is deployed, **When** I push an image with Podman to `localhost:5000/sun-cipher:v1-podman`, **Then** the push succeeds
4. **Given** I build and run a container with Podman, **When** I check its logs, **Then** the application output is visible

---

### Edge Cases

- What happens when the cluster already has some exam namespaces from a previous run?
  - Setup script skips existing namespaces and only creates missing ones
- What happens when a pre-existing resource fails to deploy during setup?
  - Setup script reports the error clearly and continues with remaining resources
- What happens when the user runs scoring before any questions are answered?
  - Score script shows 0/113 without errors
- What happens when the cleanup script is run twice?
  - Second run completes without errors (idempotent)
- What happens when the web server port is already in use?
  - User is notified and can use --port option to specify alternative

## Requirements *(mandatory)*

### Functional Requirements

#### Setup Script (ckad-setup.sh)

- **FR-001**: System MUST create all required namespaces: default (use existing), neptune, saturn, earth, mars, pluto, jupiter, mercury, venus, moon, sun, shell-intern
- **FR-002**: System MUST create pre-existing Deployments for questions that require modifying existing resources (Q8, Q9, Q15, Q16, Q17, Q18, Q19, Q20)
- **FR-003**: System MUST create pre-existing Pods for questions requiring Pod manipulation (Q7, Q14, Q22)
- **FR-004**: System MUST create pre-existing Services for questions requiring Service modification (Q18, Q19)
- **FR-005**: System MUST create ServiceAccounts and Secrets for questions Q5 and Q21 (neptune-sa-v2)
- **FR-006**: System MUST create the `./exam/course/` directory structure with subdirectories 1-22, p1, p2
- **FR-007**: System MUST place template YAML files in appropriate directories where questions reference them (Q9, Q14, Q15, Q16, Q17)
- **FR-008**: System MUST configure Helm releases in mercury namespace for Q4
- **FR-009**: System MUST deploy a local Docker registry accessible at localhost:5000 for Q11
- **FR-010**: System MUST create Dockerfile and application source in `./exam/course/11/image/` for Q11
- **FR-011**: System MUST be idempotent - safe to re-run without causing errors or duplicate resources
- **FR-012**: System MUST support exam selection via -e/--exam parameter

#### Scoring Script (ckad-score.sh)

- **FR-013**: System MUST evaluate all 22 main questions plus 2 preview questions
- **FR-014**: System MUST check each criterion defined in `scorring.md` for each question
- **FR-015**: System MUST display per-question scores showing earned/possible points
- **FR-016**: System MUST display individual criterion results (PASS/FAIL) for each question
- **FR-017**: System MUST calculate and display total score with percentage
- **FR-018**: System MUST perform read-only operations - never modify cluster state
- **FR-019**: System MUST handle missing resources gracefully (0 points, no errors)
- **FR-020**: System MUST verify file existence and content for file-based criteria
- **FR-021**: System MUST support exam selection via -e/--exam parameter

#### Cleanup Script (ckad-cleanup.sh)

- **FR-022**: System MUST delete all exam-specific namespaces
- **FR-023**: System MUST uninstall all Helm releases in exam namespaces
- **FR-024**: System MUST remove the `./exam/course/` directory and all contents
- **FR-025**: System MUST remove the local Docker registry deployment
- **FR-026**: System MUST be idempotent - safe to re-run without causing errors
- **FR-027**: System MUST stop any running exam timer
- **FR-028**: System MUST support exam selection via -e/--exam parameter

#### Web Interface (web/)

- **FR-029**: System MUST provide a web-based question viewer accessible at localhost:9090
- **FR-030**: System MUST display a 120-minute countdown timer that starts when exam is selected
- **FR-031**: System MUST allow navigation between questions via buttons, dropdown, and keyboard arrows
- **FR-032**: System MUST display question metadata (points, namespace, resources, files)
- **FR-033**: System MUST render markdown content with syntax highlighting for code blocks
- **FR-034**: System MUST allow flagging questions for later review
- **FR-035**: System MUST display flagged questions count and provide quick access to flagged list
- **FR-036**: System MUST show visual warnings when time is running low (15 min, 5 min, 1 min)
- **FR-037**: System MUST block the interface and show message when time expires
- **FR-038**: System MUST support dark and light themes with persistence
- **FR-039**: System MUST show a discreet progress indicator (current/total questions)
- **FR-047**: System MUST provide a "Stop Exam" button to end the exam early
- **FR-048**: System MUST show confirmation dialog before stopping the exam
- **FR-049**: System MUST calculate and display final score when exam is stopped
- **FR-050**: System MUST display per-question scores in the results modal
- **FR-051**: System MUST display elapsed time in the results modal
- **FR-052**: System MUST indicate PASSED/FAILED status based on 66% threshold

#### Exam Launcher (ckad-exam.sh)

- **FR-040**: System MUST provide 'web' command to launch web interface (default)
- **FR-041**: System MUST provide 'start' command for terminal-only mode
- **FR-042**: System MUST provide 'list' command to show available exams
- **FR-043**: System MUST provide 'status' command to show current exam state
- **FR-044**: System MUST provide 'stop' command to end exam session
- **FR-045**: System MUST verify prerequisites before starting exam
- **FR-046**: System MUST offer to run setup if environment is not configured

### Key Entities

- **Namespace**: Logical isolation unit in Kubernetes; 11 namespaces represent different "teams" in exam scenario
- **Question**: An exam item requiring the user to create/modify Kubernetes resources; has unique ID, description, and scoring criteria
- **Scoring Criterion**: A single pass/fail check for a question; contributes points to question score
- **Pre-existing Resource**: A Kubernetes resource created by setup that the user must modify or interact with
- **Template File**: A YAML file provided to the user as starting point for certain questions
- **Exam**: A collection of questions with configuration (duration, passing score, etc.)
- **Timer**: Countdown mechanism tracking exam time remaining

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can set up the complete exam environment in under 5 minutes on a standard kubeadm cluster
- **SC-002**: Users can obtain their exam score in under 2 minutes after running the scoring script
- **SC-003**: 100% of the 113+ scoring criteria from `scorring.md` are automatically evaluated
- **SC-004**: Users can complete a full exam cycle (setup -> practice -> score -> cleanup) without manual intervention
- **SC-005**: All 24 questions (22 main + 2 preview) are supported with appropriate pre-requisites
- **SC-006**: Cleanup restores cluster to pre-exam state with no orphaned resources
- **SC-007**: Scripts can be re-run without errors after partial completion or failures
- **SC-008**: Web interface loads in under 2 seconds and timer updates accurately
- **SC-009**: Multiple exams can be managed independently

## Assumptions

- User has a working kubeadm cluster with kubectl configured
- User has Helm 3.x installed and configured
- User has Docker installed and accessible
- User has Podman installed and accessible
- User has Python 3.x installed (for web interface)
- User has bash 4.0+ available
- Cluster has sufficient resources for exam workloads (standard single-node cluster is sufficient)
- User has read/write access to the project directory for `./exam/course/` files
- Network policies (if any) allow standard pod-to-pod communication within namespaces
- A modern web browser is available for the web interface
