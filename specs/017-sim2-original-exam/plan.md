# Implementation Plan: Sim2 Original Exam

**Branch**: `017-sim2-original-exam` | **Date**: 2025-12-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/017-sim2-original-exam/spec.md`

## Summary

Refonte complète de ckad-simulation2 (Dojo Suzaku 🔥) pour remplacer les 21 questions copiées de sim1 par des questions totalement originales. L'examen conserve le même niveau de difficulté (112 points) mais avec des scénarios uniques couvrant tous les domaines CKAD.

## Technical Context

**Language/Version**: Bash 4.0+ (scoring scripts), Markdown (questions/solutions)
**Primary Dependencies**: kubectl, helm, docker (existing CKAD tooling)
**Storage**: N/A (file-based exam content)
**Testing**: Manual execution of scoring functions on test cluster
**Target Platform**: Linux with Kubernetes cluster
**Project Type**: Content update (exam files)
**Performance Goals**: N/A
**Constraints**: 21 questions, 112 points total, ~120 minutes completion time
**Scale/Scope**: Complete exam replacement - 4 main files + manifests + templates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Script-First Automation | PASS | Updates scoring-functions.sh |
| II. Kubernetes-Native Tooling | PASS | All questions use kubectl/helm/docker |
| III. Automated Scoring | PASS | Each question has score_qN() function |
| IV. Exam Fidelity | PASS | Questions follow CKAD exam format |
| V. Idempotent Operations | PASS | Setup creates resources idempotently |
| VI. Modern UI | N/A | No UI changes |

**Gate Status**: PASSED - All principles respected

## Project Structure

### Documentation (this feature)

```text
specs/017-sim2-original-exam/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Question design research
├── quickstart.md        # Validation steps
└── tasks.md             # Implementation tasks
```

### Source Code (exam files)

```text
exams/ckad-simulation2/
├── exam.conf                    # Update: new namespaces
├── questions.md                 # Replace: 21 new questions
├── solutions.md                 # Replace: 21 new solutions
├── scoring-functions.sh         # Replace: 21 scoring functions
├── manifests/setup/
│   ├── namespaces.yaml          # New namespaces
│   ├── phoenix/                 # Pre-existing resources
│   │   └── broken-deployment.yaml
│   ├── ember/
│   │   └── crashloop-pod.yaml
│   └── ...
└── templates/
    ├── 3/job-template.yaml
    ├── 9/canary-base.yaml
    ├── 13/values.yaml
    └── ...
```

**Structure Decision**: Replace all content in existing ckad-simulation2 directory while maintaining the standard exam structure.

## New Exam Design

### Theme: Suzaku (Phénix Vermillon du Sud) 🔥

**Namespaces** (fire/phoenix themed):

- `phoenix` - Main namespace (rebirth)
- `ember` - Small fires (debugging)
- `blaze` - Intense fire (deployments)
- `inferno` - Maximum heat (complex tasks)
- `flame` - Standard fire (services)
- `spark` - Beginning fire (simple tasks)
- `solar` - Sun fire (storage)
- `corona` - Sun atmosphere (networking)
- `flare` - Solar flare (Helm)
- `magma` - Underground fire (security)

### 21 Questions Design

| Q# | Title | Pts | Namespace | Key Differentiator |
|----|-------|-----|-----------|-------------------|
| 1 | API Resources | 1 | - | `kubectl api-resources` vs `get ns` |
| 2 | Deployment Recreate | 5 | blaze | Recreate strategy vs rollback |
| 3 | Job Timeout | 5 | spark | activeDeadlineSeconds vs parallelism |
| 4 | Helm Template | 5 | flare | `helm template` inspection |
| 5 | CrashLoop Fix | 6 | ember | Debug command error vs image error |
| 6 | ConfigMap Items | 5 | flame | items/subPath vs full mount |
| 7 | Secret from File | 5 | magma | `--from-file` vs `--from-literal` |
| 8 | Headless Service | 5 | corona | clusterIP: None vs ClusterIP/NodePort |
| 9 | Canary Deploy | 7 | blaze | Traffic split pattern |
| 10 | Sidecar Processing | 6 | phoenix | Data transform vs log streaming |
| 11 | NS NetworkPolicy | 6 | corona | namespaceSelector vs podSelector |
| 12 | Docker ARG | 6 | inferno | Build-time ARG vs runtime ENV |
| 13 | Helm Values File | 5 | flare | -f values.yaml vs --set |
| 14 | PostStart Hook | 5 | phoenix | Lifecycle hooks vs initContainer |
| 15 | QoS Guaranteed | 5 | spark | Achieve specific QoS class |
| 16 | SA Projected Token | 4 | magma | Projected volume vs default |
| 17 | TCP Probe | 5 | ember | tcpSocket vs httpGet/exec |
| 18 | Named Ports | 5 | flame | targetPort by name vs number |
| 19 | Topology Spread | 6 | blaze | topologySpreadConstraints |
| 20 | Field Selectors | 3 | - | status.phase vs labels |
| 21 | Pod Drain | 3 | solar | kubectl drain/cordon |

**Total**: 112 points

## Implementation Approach

### Phase 1: Infrastructure

1. Update exam.conf with new namespaces
2. Create namespace manifests
3. Create pre-existing resource manifests

### Phase 2: Questions (7 batches of 3)

- Batch 1: Q1-Q3 (simple, Job, intro)
- Batch 2: Q4-Q6 (Helm, debug, ConfigMap)
- Batch 3: Q7-Q9 (Secret, Service, Canary)
- Batch 4: Q10-Q12 (Sidecar, Network, Docker)
- Batch 5: Q13-Q15 (Helm, Lifecycle, QoS)
- Batch 6: Q16-Q18 (SA, Probes, Services)
- Batch 7: Q19-Q21 (Topology, Selectors, Drain)

### Phase 3: Scoring Functions

- Implement score_q1() through score_q21()
- Test each function manually

### Phase 4: Solutions

- Document all solutions with explanations

## Complexity Tracking

No constitution violations - no complexity justification needed.

## Pre-existing Resources Required

| Namespace | Resource | Purpose |
|-----------|----------|---------|
| ember | Pod `crash-app` | Q5: CrashLoopBackOff fix |
| blaze | Deployment `stable-v1` | Q9: Canary base |
| flare | Helm release `phoenix-web` | Q4, Q13: Helm operations |
| solar | PV `solar-pv` | Q21: Storage for drain test |
| corona | Pod `backend-pod` | Q11: NetworkPolicy target |
