# Implementation Plan: CKAD Simulation 2 & Solutions Feature

**Branch**: `002-ckad-simulation2` | **Date**: 2025-12-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-002-ckad-simulation2/spec.md`

## Summary

Create a new complete CKAD exam simulation (ckad-simulation2) with 21 questions covering all CKAD domains, plus implement a solutions viewing feature that allows users to review detailed solutions after completing any exam. The exam uses galaxy/constellation-themed namespaces and follows the established patterns from ckad-simulation1.

## Technical Context

**Language/Version**: Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend)
**Primary Dependencies**: kubectl, helm, docker, uv (Python runner)
**Storage**: File-based (YAML manifests, markdown files)
**Testing**: Manual testing + automated scoring verification
**Target Platform**: Linux (bash scripts, kubeadm cluster)
**Project Type**: Multi-component (scripts + web)
**Performance Goals**: Setup < 60s, Scoring < 30s, Solutions page load < 2s
**Constraints**: No external dependencies beyond standard CKAD exam tools
**Scale/Scope**: 21 questions, ~112 points, 11 namespaces

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance | Notes |
|-----------|------------|-------|
| I. Script-First Automation | PASS | All exam operations via bash scripts |
| II. Kubernetes-Native Tooling | PASS | Uses kubectl, helm, docker only |
| III. Automated Scoring | PASS | scoring-functions.sh follows established pattern |
| IV. Exam Fidelity | PASS | Questions match CKAD exam style and difficulty |
| V. Idempotent Operations | PASS | Setup/cleanup scripts will be idempotent |
| VI. Modern UI | PASS | Solutions feature extends existing web interface |

**Gate Status**: PASSED - No violations

## Project Structure

### Documentation (this feature)

```text
specs/002-002-ckad-simulation2/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── api.md           # Solutions API contract
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
exams/ckad-simulation2/           # NEW: Complete exam package
├── exam.conf                     # Exam configuration
├── questions.md                  # 21 main + 1 preview questions
├── solutions.md                  # NEW: Detailed solutions
├── scoring-functions.sh          # Scoring logic for all questions
├── manifests/
│   └── setup/
│       ├── namespaces.yaml       # 11 galaxy/constellation namespaces
│       ├── q04-deployment.yaml   # Pre-existing deployment
│       ├── q05-broken-deploy.yaml # Deployment to troubleshoot
│       ├── q08-service.yaml      # Pre-existing service
│       ├── q09-pod.yaml          # Pod for conversion
│       ├── q15-deployment.yaml   # Deployment for sidecar
│       ├── q19-deployment.yaml   # Deployment for resource limits
│       └── q21-deployment.yaml   # Deployment for rollback
└── templates/
    ├── q07-cronjob.yaml          # CronJob template
    ├── q09-pod.yaml              # Pod conversion template
    ├── q12-image/
    │   ├── Dockerfile            # Container build template
    │   └── app.py                # Python app source
    ├── q14-initcontainer.yaml    # InitContainer template
    └── q-p1-startup-probe.yaml   # Preview question template

exams/ckad-simulation1/           # MODIFIED: Add solutions
└── solutions.md                  # NEW: Solutions for simulation1

web/
├── server.py                     # MODIFIED: Add /api/exam/{id}/solutions
├── index.html                    # MODIFIED: Add solutions view
├── css/style.css                 # MODIFIED: Add solutions styles
└── js/app.js                     # MODIFIED: Add solutions logic

scripts/lib/
└── common.sh                     # Existing (no changes needed)
```

**Structure Decision**: Extends existing multi-exam architecture under `exams/` directory. Solutions feature is integrated into the existing web interface.

## Implementation Phases

### Phase 1: Exam Infrastructure (P1)

Create the base exam structure:

1. **exam.conf** - Exam configuration with 21 questions, 112 points
2. **namespaces.yaml** - 11 galaxy/constellation namespaces
3. **Scoring helper integration** - Source common.sh for check_criterion

### Phase 2: Questions & Scoring (P1)

Create 21 questions with corresponding scoring functions:

| Q# | Topic | Points | Complexity |
|----|-------|--------|------------|
| 1 | Namespaces | 1 | Simple |
| 2 | Multi-container Pod | 5 | Medium |
| 3 | CronJob | 5 | Medium |
| 4 | Deployment Scaling | 4 | Simple |
| 5 | Deployment Troubleshooting | 6 | Medium |
| 6 | ConfigMap Volume | 5 | Medium |
| 7 | Secret Env Vars | 5 | Medium |
| 8 | Service NodePort | 4 | Simple |
| 9 | Pod → Deployment | 8 | Complex |
| 10 | PV/PVC | 6 | Medium |
| 11 | NetworkPolicy | 6 | Medium |
| 12 | Container Build | 7 | Complex |
| 13 | Helm Operations | 5 | Medium |
| 14 | InitContainer | 5 | Medium |
| 15 | Sidecar Logging | 6 | Medium |
| 16 | ServiceAccount Token | 2 | Simple |
| 17 | Liveness Probe | 5 | Medium |
| 18 | Readiness Probe | 5 | Medium |
| 19 | Resource Limits | 5 | Medium |
| 20 | Labels/Selectors | 4 | Simple |
| 21 | Rollback | 3 | Simple |
| P1 | Startup Probe | 4 | Medium |

### Phase 3: Pre-existing Resources (P1)

Create manifests for questions requiring pre-setup:

- Q4: Deployment to scale
- Q5: Broken deployment (intentional typo)
- Q8: Existing service
- Q9: Pod for conversion
- Q15: Deployment needing sidecar
- Q19: Deployment for resource modification
- Q21: Deployment with history for rollback

### Phase 4: Templates (P1)

Create template files provided to students:

- Q7: CronJob template
- Q9: Pod YAML template
- Q12: Dockerfile + Python app
- Q14: InitContainer template
- P1: Startup probe template

### Phase 5: Solutions Feature (P2)

#### Backend (web/server.py)

1. Add `parse_solutions_md()` function
2. Add `/api/exam/{exam_id}/solutions` endpoint
3. Add `/api/exam/{exam_id}/solutions/{question_id}` endpoint
4. Update `/api/score` response to include `solutions_available`

#### Frontend (web/js/app.js)

1. Add `api.getSolutions()` function
2. Add `api.getSolution()` function
3. Add solutions state management
4. Add `showSolutions()` function
5. Add `renderSolution()` function
6. Add solution navigation handlers
7. Add "View Solutions" button in score modal

#### Styling (web/css/style.css)

1. Add `.solutions-view` container styles
2. Add `.solution-content` markdown styles
3. Add `.solution-nav` navigation styles
4. Add `.solution-status` pass/fail indicator styles
5. Add responsive layout for solutions view

#### HTML (web/index.html)

1. Add solutions view container
2. Add solution navigation elements
3. Add "View Solutions" button in score modal
4. Add back button to score modal

### Phase 6: Solutions Content (P2)

1. Create `exams/ckad-simulation2/solutions.md` with all 22 solutions
2. Create `exams/ckad-simulation1/solutions.md` with all 24 solutions

### Phase 7: Testing & Integration

1. Test setup script creates all resources
2. Test scoring with known correct answers
3. Test cleanup removes all resources
4. Test web interface launches both exams
5. Test solutions display correctly
6. Test navigation between solutions

## Complexity Tracking

> No violations to justify - all requirements align with constitution principles.

## Testing Strategy

1. **Setup Testing**: Verify all namespaces and resources created
2. **Scoring Testing**: Run with known correct answers, verify 100% score
3. **Cleanup Testing**: Verify clean removal, re-run setup successfully
4. **Web Interface Testing**: Manual testing of solutions navigation
5. **Cross-Exam Testing**: Verify both exams work with solutions

## Dependencies

| Component | Depends On | Status |
|-----------|-----------|--------|
| questions.md | exam.conf | Ready |
| scoring-functions.sh | common.sh | Ready |
| manifests/*.yaml | namespaces.yaml | Ready |
| solutions.md | questions.md | Ready |
| web/server.py solutions | solutions.md | Ready |
| web/js/app.js solutions | server.py solutions | Ready |

## Estimated Effort

| Phase | Tasks | Complexity |
|-------|-------|------------|
| Phase 1: Infrastructure | 3 | Low |
| Phase 2: Questions | 22 | High |
| Phase 3: Manifests | 8 | Medium |
| Phase 4: Templates | 5 | Medium |
| Phase 5: Solutions Feature | 15 | Medium |
| Phase 6: Solutions Content | 46 | High |
| Phase 7: Testing | 5 | Medium |

**Total Estimated Tasks**: ~100+
