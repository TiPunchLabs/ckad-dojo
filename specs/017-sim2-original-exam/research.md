# Research: Sim2 Original Exam

**Feature**: 017-sim2-original-exam
**Date**: 2025-12-19

## Question Differentiation Analysis

### Current Sim2 vs Sim1 Comparison

| Sim2 Current | Sim1 Equivalent | Similarity | Decision |
|--------------|-----------------|------------|----------|
| Q1 Nodes | Q1 Namespaces | 90% | Replace with API Resources |
| Q2 Multi-container | Preview Q3 | 90% | Replace with Recreate Strategy |
| Q3 CronJob | Preview Q2 | 85% | Replace with Job Timeout |
| Q4 Scaling | Q8 Rollback | 60% | Replace with Helm Template |
| Q5 Troubleshoot | N/A | 30% | Keep concept, new scenario |
| Q6 ConfigMap | Q15 | 85% | Replace with Items mount |
| Q7 Secret Env | Q14 | 85% | Replace with from-file |
| Q8 NodePort | Q19 | 90% | Replace with Headless |
| Q9 Pod→Deploy | Q9 | 95% | Replace with Canary |
| Q10 PV/PVC | Q12 | 85% | Replace with EmptyDir |
| Q11 NetworkPolicy | Q20 | 80% | Replace with NS selector |
| Q12 Docker | Q11 | 90% | Replace with ARG |
| Q13 Helm | Q4 | 90% | Replace with values file |
| Q14 InitContainer | Q17 | 90% | Replace with PostStart |
| Q15 Sidecar | Q16 | 90% | Replace with QoS |
| Q16 SA Token | Q5 | 85% | Replace with projected |
| Q17 Liveness | Preview Q1 | 85% | Replace with TCP |
| Q18 Readiness | Q6 | 85% | Replace with Named Ports |
| Q19 Resources | Q21 | 80% | Replace with Topology |
| Q20 Labels | Q22 | 80% | Replace with Field Selectors |
| Q21 Rollback | Q8 | 90% | Replace with Drain |

### New Question Unique Features

Each new question has a distinct learning objective:

| Q# | CKAD Topic | Unique Skill Tested |
|----|------------|---------------------|
| 1 | Core | Discovering available API resources |
| 2 | Deployment | Recreate strategy (zero-downtime alternative) |
| 3 | Jobs | Timeout handling with activeDeadlineSeconds |
| 4 | Helm | Template rendering and debugging |
| 5 | Debug | Fix CrashLoopBackOff (command error) |
| 6 | ConfigMap | Selective key mounting with items |
| 7 | Secret | Creating secrets from files |
| 8 | Service | Headless services for StatefulSet-like access |
| 9 | Deployment | Canary release pattern |
| 10 | Pod Design | Sidecar for data processing |
| 11 | Network | Cross-namespace NetworkPolicy |
| 12 | Docker | Build-time ARG variables |
| 13 | Helm | Values file override |
| 14 | Lifecycle | PostStart/PreStop hooks |
| 15 | Resources | Achieving Guaranteed QoS |
| 16 | Security | ServiceAccount token projection |
| 17 | Probes | TCP socket liveness probe |
| 18 | Service | Named port targeting |
| 19 | Scheduling | Topology spread constraints |
| 20 | Query | Field selectors vs labels |
| 21 | Maintenance | Node drain operations |

## CKAD Domain Coverage Validation

### Target Coverage (from CKAD curriculum)

| Domain | Weight | Questions | Points | Actual % |
|--------|--------|-----------|--------|----------|
| Application Design & Build | 20% | Q3,Q4,Q10,Q12,Q13,Q14 | 32 | 29% |
| Application Deployment | 20% | Q2,Q9,Q19 | 18 | 16% |
| Application Observability | 15% | Q5,Q17,Q21 | 14 | 13% |
| Application Environment/Config/Security | 25% | Q6,Q7,Q15,Q16 | 19 | 17% |
| Services & Networking | 20% | Q1,Q8,Q11,Q18,Q20 | 20 | 18% |

**Analysis**: Coverage is within acceptable range. The "Design & Build" domain is slightly over-represented due to the Docker and Helm questions being foundational skills.

## Namespace Theme Research

**Theme**: Suzaku (朱雀) - Vermillion Bird / Phoenix of the South

Fire-related namespace names selected for thematic consistency:
- `phoenix` - Rebirth, main namespace
- `ember` - Small glowing coals (debugging scenarios)
- `blaze` - Strong fire (deployment scenarios)
- `inferno` - Intense heat (complex scenarios)
- `flame` - Standard fire (service scenarios)
- `spark` - Beginning of fire (simple tasks)
- `solar` - Sun-related fire (storage)
- `corona` - Sun's atmosphere (networking)
- `flare` - Solar flare (Helm operations)
- `magma` - Underground fire (security)

## Pre-existing Resources Design

### Required for Questions

| Resource | Namespace | Question | State |
|----------|-----------|----------|-------|
| Pod `crash-app` | ember | Q5 | CrashLoopBackOff (bad command) |
| Deployment `stable-v1` | blaze | Q9 | 3 replicas, nginx, label=v1 |
| Helm release `phoenix-web` | flare | Q4, Q13 | nginx chart, 1 replica |
| ConfigMap `app-settings` | flame | Q6 | Multi-key config |
| Pod `backend-pod` | corona | Q11 | Running, labeled |
| ServiceAccount `fire-sa` | magma | Q16 | With secret |
| Deployment `web-deploy` | flame | Q18 | Running, needs service |

### Setup Script Requirements

1. Create all namespaces
2. Apply pre-existing resources in order
3. Install Helm release(s)
4. Verify all resources are ready

## Decision Summary

| Decision | Rationale | Alternative Considered |
|----------|-----------|------------------------|
| 21 questions | Match current sim2 | 22 like sim1 - rejected for variety |
| 112 points | Match current difficulty | 113 like sim1 - rejected |
| Fire theme | Suzaku = Phoenix = Fire | Space theme - rejected for consistency |
| Mixed difficulty | CKAD-realistic | All hard - rejected |
| kubectl focus | CKAD tools | Include k9s - rejected (not exam tool) |
