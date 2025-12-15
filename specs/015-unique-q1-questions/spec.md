# Feature Specification: Unique Q1 Questions Across CKAD Simulations

**Feature Branch**: `015-unique-q1-questions`
**Created**: 2025-12-14
**Status**: Draft
**Input**: Rendre les questions Q1 uniques entre toutes les simulations CKAD. La Q1 de simulation2 est quasi-identique à celle de simulation1 (lister les namespaces). Chaque simulation doit avoir une Q1 inédite et différente des autres, tout en restant une question d'échauffement simple (1 point).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unique Warm-up Questions (Priority: P1)

As a CKAD candidate practicing with multiple simulations, I want each exam to start with a different warm-up question so that I don't feel like I'm repeating the same exercise and each simulation feels fresh.

**Why this priority**: Core issue - identical Q1 questions reduce the value of having multiple simulations and make practice feel repetitive.

**Independent Test**: Run each simulation and verify Q1 is unique, simple (1 point), and tests a different basic kubectl skill.

**Acceptance Scenarios**:

1. **Given** a user starts ckad-simulation1, **When** they read Q1, **Then** they see a question about listing namespaces
2. **Given** a user starts ckad-simulation2, **When** they read Q1, **Then** they see a different question (not namespace listing)
3. **Given** a user starts ckad-simulation3, **When** they read Q1, **Then** they see a different question from sim1 and sim2
4. **Given** all 3 simulations Q1, **When** compared, **Then** each tests a distinct kubectl basic operation

---

### User Story 2 - Correct Scoring for New Questions (Priority: P1)

As a user completing an exam, I want the new Q1 questions to be correctly scored so that I receive accurate feedback on my answers.

**Why this priority**: Scoring must work correctly for the exam to be usable.

**Independent Test**: Complete each Q1 and verify scoring returns correct points based on the answer.

**Acceptance Scenarios**:

1. **Given** user completes sim2 new Q1 correctly, **When** scoring runs, **Then** they receive 1/1 point
2. **Given** user completes sim2 new Q1 incorrectly, **When** scoring runs, **Then** they receive 0/1 point
3. **Given** user completes sim3 Q1 correctly, **When** scoring runs, **Then** they receive 1/1 point

---

### User Story 3 - Solutions Available (Priority: P2)

As a user reviewing their exam, I want to see the correct solution for each new Q1 so I can learn from my mistakes.

**Why this priority**: Solutions are important for learning but not blocking for exam functionality.

**Independent Test**: Open solutions.md for each simulation and verify Q1 solution matches the new question.

**Acceptance Scenarios**:

1. **Given** user views sim2 solutions, **When** they look at Q1, **Then** they see the correct solution for the new question
2. **Given** user views sim3 solutions, **When** they look at Q1, **Then** they see the correct solution matching the question

---

### Edge Cases

- What happens if namespace themes affect Q1 content? Q1 should use appropriate theme (constellation for sim2, greek for sim3)
- What happens if scoring file path doesn't exist? Scoring function should handle gracefully and return 0 points

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Simulation 1 Q1 MUST remain unchanged (list all namespaces - baseline reference)
- **FR-002**: Simulation 2 Q1 MUST be replaced with a unique, different kubectl basic operation
- **FR-003**: Simulation 3 Q1 MUST be verified unique or adjusted if too similar to others
- **FR-004**: Each Q1 MUST be worth exactly 1 point (warm-up difficulty)
- **FR-005**: Each Q1 MUST be solvable with a single kubectl command
- **FR-006**: Each Q1 MUST save output to a file in `./exam/course/1/`
- **FR-007**: Scoring functions MUST accurately validate the new Q1 answers
- **FR-008**: Solutions MUST be updated to reflect the new Q1 questions

### Proposed Q1 Differentiation

| Simulation | Q1 Topic | kubectl Operation |
|------------|----------|-------------------|
| ckad-simulation1 | List namespaces | `kubectl get namespaces` |
| ckad-simulation2 | List nodes | `kubectl get nodes` |
| ckad-simulation3 | List namespaces with "a" | `kubectl get ns \| grep a` |

### Key Entities

- **Question (questions.md)**: Q1 section defining task, points, output file location
- **Solution (solutions.md)**: Q1 section with correct answer and explanation
- **Scoring Function (scoring-functions.sh)**: `score_q1()` function validating user's answer

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Each simulation has a demonstrably unique Q1 (0% overlap in question text)
- **SC-002**: All Q1 scoring functions return correct results (100% accuracy)
- **SC-003**: All Q1 solutions match their corresponding questions
- **SC-004**: All Q1 questions remain at 1 point difficulty level
- **SC-005**: Users completing all 3 simulations encounter 3 different warm-up exercises

## Assumptions

- Simulation 1 Q1 is the baseline and does not need modification
- Simulation 3 Q1 (filter namespaces with "a") is sufficiently different from sim1
- Node listing is a valid CKAD warm-up operation
- Output file location convention `./exam/course/1/` remains consistent
