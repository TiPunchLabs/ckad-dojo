---
description: Create a new CKAD simulation from a Q&A input file or generate original questions covering all CKAD domains
---

# Create CKAD Simulation

Create a new CKAD exam simulation, either from an input file or by generating original questions.

## User Input

```text
$ARGUMENTS
```

**Two modes:**

1. **With file path**: Parse questions from the provided file
2. **Without arguments**: Generate a completely new simulation with original questions

## Prerequisites

Before proceeding, **ALWAYS read**:

1. `.specify/memory/constitution.md` - Project principles and standards
2. `CLAUDE.md` - Development guidelines and exam structure
3. **All existing simulations** to avoid repetition:
   - `exams/ckad-simulation1/questions.md`
   - `exams/ckad-simulation2/questions.md`
   - `exams/ckad-simulation3/questions.md`
   - `exams/ckad-simulation4/questions.md`

## Mode Detection

```
IF $ARGUMENTS is empty or not a valid file path:
    → Mode: GENERATE NEW (create original questions)
ELSE:
    → Mode: IMPORT (parse from file)
```

---

## Mode A: Import from File

When `$ARGUMENTS` contains a valid file path:

### A.1 Parse Input File

Read the file and extract Q&A pairs. Supported formats:

```markdown
## Question N: Title
Task description...
### Solution
Solution content...
```

Or any reasonable Q&A format.

### A.2 Extract for Each Question

- Topic/Title (CKAD domain)
- Task description
- Points (estimate: 1-2 simple, 3-5 medium, 6-8 complex)
- Required Kubernetes resources
- Complete solution

### A.3 Validate & Correct

Continue to **Phase 2: Validation** below.

---

## Mode B: Generate New Simulation

When `$ARGUMENTS` is empty:

### B.1 Analyze Existing Simulations

**CRITICAL: Read ALL existing questions to avoid repetition.**

```bash
# Read all existing questions
cat exams/ckad-simulation1/questions.md
cat exams/ckad-simulation2/questions.md
cat exams/ckad-simulation3/questions.md
cat exams/ckad-simulation4/questions.md
```

**Build an inventory of existing topics:**

| Simulation | Topics Already Covered |
|------------|------------------------|
| sim1 | Namespaces, Pods, Jobs, CronJobs, Helm, ServiceAccounts, Secrets, Probes, Rollouts, Services, PV/PVC, ConfigMaps, Logging sidecars, InitContainers, NetworkPolicies, Resources |
| sim2 | (extract from questions.md) |
| sim3 | (extract from questions.md) |
| sim4 | ResourceQuota, HPA, StatefulSet, DaemonSet, PriorityClass, ... |

### B.2 CKAD Curriculum Coverage Analysis

**CRITICAL: Ensure comprehensive CKAD coverage across all simulations.**

After reading existing simulations, check coverage for EACH topic below.
Mark [x] if covered, [ ] if not covered. Prioritize uncovered topics.

---

#### **1. Application Design and Build (20%)**

**Container Images:**

- [ ] Define, build and modify container images (Dockerfile)
- [ ] Build container image from source code
- [ ] Tag and push images to registry
- [ ] Use multi-stage builds

**Pods:**

- [ ] Create and configure Pods
- [ ] Pod resource requests and limits
- [ ] Pod with multiple containers
- [ ] Static Pods

**Multi-container Patterns:**

- [ ] Sidecar container pattern
- [ ] Ambassador container pattern
- [ ] Adapter container pattern
- [ ] Shared volumes between containers

**Init Containers:**

- [ ] Init container basics
- [ ] Init container with dependency check
- [ ] Multiple init containers (ordering)

**Jobs and CronJobs:**

- [ ] Job with completions and parallelism
- [ ] Job backoffLimit and activeDeadlineSeconds
- [ ] CronJob schedule syntax
- [ ] CronJob concurrencyPolicy (Allow, Forbid, Replace)
- [ ] CronJob successfulJobsHistoryLimit/failedJobsHistoryLimit

**Container Lifecycle:**

- [ ] postStart hook
- [ ] preStop hook
- [ ] terminationGracePeriodSeconds

---

#### **2. Application Deployment (20%)**

**Deployments:**

- [ ] Create and manage Deployments
- [ ] Deployment replicas and selector
- [ ] Rolling update strategy
- [ ] maxSurge and maxUnavailable
- [ ] Rollout history and revision
- [ ] Rollback to specific revision
- [ ] Pause and resume rollout

**Deployment Strategies:**

- [ ] RollingUpdate (default)
- [ ] Recreate strategy
- [ ] Blue/Green deployment pattern
- [ ] Canary deployment pattern

**Helm:**

- [ ] Install Helm chart
- [ ] Upgrade Helm release
- [ ] Rollback Helm release
- [ ] Helm release history
- [ ] Helm values override (--set, -f)
- [ ] Helm uninstall
- [ ] Search Helm repos
- [ ] Create Helm chart (helm create)
- [ ] Helm template rendering

---

#### **3. Application Observability and Maintenance (15%)**

**Logs:**

- [ ] kubectl logs (single container)
- [ ] kubectl logs -c (multi-container)
- [ ] kubectl logs --previous
- [ ] kubectl logs -f (follow)
- [ ] Logging sidecar pattern

**Probes:**

- [ ] Liveness probe (httpGet)
- [ ] Liveness probe (exec command)
- [ ] Liveness probe (tcpSocket)
- [ ] Readiness probe
- [ ] Startup probe
- [ ] Probe parameters (initialDelaySeconds, periodSeconds, failureThreshold)

**Debugging:**

- [ ] kubectl describe
- [ ] kubectl get events
- [ ] kubectl exec
- [ ] kubectl debug (ephemeral containers)
- [ ] kubectl top pods/nodes

**Maintenance:**

- [ ] Pod Disruption Budgets (PDB)
- [ ] Node drain and cordon
- [ ] Taints and tolerations

---

#### **4. Application Environment, Configuration and Security (25%)**

**ConfigMaps:**

- [ ] Create ConfigMap from literal
- [ ] Create ConfigMap from file
- [ ] Create ConfigMap from directory
- [ ] Mount ConfigMap as volume
- [ ] Use ConfigMap as environment variables
- [ ] ConfigMap with envFrom

**Secrets:**

- [ ] Create Secret (generic/opaque)
- [ ] Create Secret from file
- [ ] Secret type: docker-registry
- [ ] Secret type: tls
- [ ] Mount Secret as volume
- [ ] Use Secret as environment variables
- [ ] Secret with envFrom

**ServiceAccounts:**

- [ ] Create ServiceAccount
- [ ] Assign ServiceAccount to Pod
- [ ] ServiceAccount token auto-mount
- [ ] ServiceAccount token projection
- [ ] Disable auto-mount of SA token

**Security Context:**

- [ ] runAsUser / runAsGroup
- [ ] runAsNonRoot
- [ ] readOnlyRootFilesystem
- [ ] allowPrivilegeEscalation
- [ ] capabilities (add/drop)
- [ ] seccompProfile
- [ ] Pod-level vs container-level securityContext

**RBAC:**

- [ ] Role and RoleBinding
- [ ] ClusterRole and ClusterRoleBinding
- [ ] ServiceAccount with Role
- [ ] Verify permissions (kubectl auth can-i)

**Resource Management:**

- [ ] Resource requests (cpu, memory)
- [ ] Resource limits (cpu, memory)
- [ ] ResourceQuota
- [ ] LimitRange

---

#### **5. Services and Networking (20%)**

**Services:**

- [ ] ClusterIP service
- [ ] NodePort service
- [ ] LoadBalancer service (concept)
- [ ] ExternalName service
- [ ] Headless service (clusterIP: None)
- [ ] Service with named ports
- [ ] Service selectors

**Ingress:**

- [ ] Create Ingress resource
- [ ] Ingress with single service
- [ ] Ingress with path-based routing
- [ ] Ingress with host-based routing
- [ ] Ingress pathType (Prefix, Exact, ImplementationSpecific)
- [ ] Ingress with TLS termination
- [ ] Ingress annotations

**Network Policies:**

- [ ] NetworkPolicy ingress rules
- [ ] NetworkPolicy egress rules
- [ ] NetworkPolicy with podSelector
- [ ] NetworkPolicy with namespaceSelector
- [ ] NetworkPolicy with ipBlock
- [ ] Default deny policy
- [ ] Allow all policy

**DNS:**

- [ ] Service DNS resolution
- [ ] Pod DNS resolution
- [ ] Headless service DNS (pod-name.service-name)

---

#### **6. Storage (Bonus - often tested)**

**Volumes:**

- [ ] emptyDir volume
- [ ] hostPath volume
- [ ] configMap volume
- [ ] secret volume
- [ ] projected volume

**Persistent Storage:**

- [ ] PersistentVolume (PV)
- [ ] PersistentVolumeClaim (PVC)
- [ ] StorageClass
- [ ] Volume access modes (RWO, ROX, RWX)
- [ ] Volume reclaim policies
- [ ] Dynamic provisioning

---

#### **7. Advanced Workloads (Bonus)**

**StatefulSets:**

- [ ] Create StatefulSet
- [ ] Headless service for StatefulSet
- [ ] volumeClaimTemplates
- [ ] Ordered pod management
- [ ] Pod identity (ordinal index)

**DaemonSets:**

- [ ] Create DaemonSet
- [ ] DaemonSet with tolerations
- [ ] DaemonSet on specific nodes

**Other:**

- [ ] HorizontalPodAutoscaler (HPA)
- [ ] PriorityClass
- [ ] Pod topology spread constraints
- [ ] Pod affinity/anti-affinity

### B.3 Generate 20 Original Questions

**Rules for new questions:**

1. **NO DUPLICATE SCENARIOS** - Each question must be unique across all simulations
2. **VARY THE APPROACH** - Even if topic exists, use different angle/complexity
3. **REAL-WORLD SCENARIOS** - Questions should reflect actual use cases
4. **PROGRESSIVE DIFFICULTY** - Mix of 1-8 point questions
5. **COVER GAPS** - Prioritize topics not yet covered

**Question Generation Template:**

For each question, define:

```yaml
question_number: N
title: "Descriptive Title"
topic: "CKAD Domain"
points: X  # 1-8 based on complexity
namespace: "{themed-namespace}"
resources:
  - type: ResourceType
    name: resource-name
pre_existing: []  # Resources that must exist before
task: |
  Clear, unambiguous task description.
  Specific values and requirements.
  Verification command suggestion.
solution:
  yaml: |
    # Complete YAML manifest
  commands: |
    # kubectl commands
scoring_criteria:
  - "Resource exists"
  - "Property X = value"
  - "Status is Running"
```

### B.4 Ensure Uniqueness

For each generated question, verify:

- [ ] Scenario not used in sim1-4
- [ ] Resource names are unique
- [ ] Approach differs from similar topics
- [ ] Adds educational value

---

## Phase 2: Validation & Correction

**Validate each question against CKAD domains:**

- Application Design and Build (20%)
- Application Deployment (20%)
- Application Observability and Maintenance (15%)
- Application Environment, Configuration and Security (25%)
- Services and Networking (20%)

**Verify Kubernetes correctness:**

- Valid `apiVersion` (apps/v1, v1, networking.k8s.io/v1, etc.)
- Correct spec fields and values
- Proper YAML syntax
- Working kubectl commands

**Auto-correct issues:**

- Update deprecated apiVersions
- Fix missing required fields
- Correct resource type names

**Report all corrections:**

```markdown
| Question | Issue | Original | Corrected |
|----------|-------|----------|-----------|
```

## Phase 3: Determine Simulation Number

```bash
# Find next available simulation number
ls -d exams/ckad-simulation* 2>/dev/null | sort -V | tail -1
```

Current simulations:

- ckad-simulation1: Dojo Seiryu 🐉 (22 questions, 113 points)
- ckad-simulation2: Dojo Suzaku 🔥 (21 questions, 112 points)
- ckad-simulation3: Dojo Byakko 🐯 (20 questions, 105 points)
- ckad-simulation4: Dojo Genbu 🐢 (20 questions, 105 points)

## Phase 4: Select Dojo Theme

**Shishin (四神) Extended Themes:**

| Sim | Dojo | Emoji | Guardian | Quote (Japanese + French) | Namespaces |
|-----|------|-------|----------|---------------------------|------------|
| 5 | Kirin | 🦄 | Qilin Céleste du Centre | 「麒麟は天空を駆ける」- Le qilin parcourt les cieux | celestial, aurora, nebula, cosmos, stellar, orbit, galaxy, void, astral, zenith |
| 6 | Tengu | 👺 | Tengu des Montagnes | 「天狗は山を守る」- Le tengu protège la montagne | peak, summit, cliff, ridge, valley, cave, stone, mist, alpine, crest |
| 7 | Kappa | 🐸 | Kappa des Rivières | 「河童は水を知る」- Le kappa connaît les eaux | stream, pond, marsh, delta, spring, brook, rapids, cascade, shoal, eddy |
| 8 | Tanuki | 🦝 | Tanuki des Forêts | 「狸は森に潜む」- Le tanuki se cache dans la forêt | grove, thicket, glade, meadow, fern, moss, root, bark, canopy, hollow |

## Phase 5: Generate All Files

Create directory: `exams/ckad-simulation{N}/`

### 5.1 exam.conf

```bash
# CKAD Simulation {N} - Exam Configuration

EXAM_NAME="CKAD Simulation {N}"
EXAM_ID="ckad-simulation{N}"
EXAM_VERSION="1.0"

DOJO_NAME="Dojo {Name}"
DOJO_EMOJI="{emoji}"
DOJO_TITLE="{French Title}"
DOJO_QUOTE="{quote}"

EXAM_DURATION=120
EXAM_WARNING_TIME=15
ALLOW_TIMER_PAUSE=true

TOTAL_QUESTIONS={count}
PREVIEW_QUESTIONS=1
TOTAL_POINTS={total}
PASSING_PERCENTAGE=66

EXAM_NAMESPACES=(
    "{ns1}" "{ns2}" "{ns3}" "{ns4}" "{ns5}"
    "{ns6}" "{ns7}" "{ns8}" "{ns9}" "{ns10}"
)

HELM_NAMESPACE="{first-namespace}"
HELM_RELEASES=()

REGISTRY_HOST="localhost"
REGISTRY_PORT="5000"
REGISTRY_NAME="registry"

EXAM_PATH_PREFIX="/opt/course"
LOCAL_PATH_PREFIX="exam/course"

QUESTIONS_FILE="questions.md"
SCORING_FUNCTIONS="scoring-functions.sh"
```

### 5.2 questions.md

```markdown
# CKAD Exam Simulator - Dojo {Name} {Emoji}

> **Total Score**: {total} points | **Passing Score**: ~66% ({passing} points)
>
> *「{Japanese}」 - {French}*
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | {Title}

| | |
|---|---|
| **Points** | {points} |
| **Namespace** | `{namespace}` |
| **Resources** | {Type} `{name}` |

### Task

{Clear task description}

---
```

### 5.3 solutions.md

```markdown
# CKAD Simulation {N} - Solutions (Dojo {Name} {Emoji})

> **Total Score**: {total} points | **Passing Score**: ~66% ({passing} points)

---

## Question 1 | {Title} ({points} points)

### Solution

```yaml
{Complete YAML manifest}
```

```bash
{kubectl commands}
```

---

```

### 5.4 scoring-functions.sh

```bash
#!/bin/bash
# scoring-functions.sh - CKAD Simulation {N} Scoring Functions
# Dojo {Name} - {count} questions, {total} points total

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

check_criterion() {
    if eval "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Q1: {Title} ({points} points)
score_q1() {
    local score=0
    local max_points={points}

    if kubectl get {resource} {name} -n {namespace} &>/dev/null; then
        ((score++))
        # Additional checks...
    fi

    echo "$score/$max_points"
}
```

### 5.5 manifests/setup/

- `namespaces.yaml` - All 10 themed namespaces
- `q{N}-{resource}.yaml` - Pre-existing resources

### 5.6 templates/ (if needed)

- `q{N}-{description}.yaml` - Starting templates for questions

## Phase 6: Validation

```bash
shellcheck exams/ckad-simulation{N}/scoring-functions.sh
bash -n exams/ckad-simulation{N}/scoring-functions.sh
```

## Phase 7: Summary

```markdown
## ✅ Simulation Created: ckad-simulation{N}

**Mode:** {IMPORT from file | GENERATED original}
**Dojo:** {Name} {Emoji} - {Title}
**Questions:** {count}
**Total Points:** {total}
**Passing Score:** {passing} points (66%)

### Files Generated

| File | Lines |
|------|-------|
| exam.conf | ~60 |
| questions.md | ~{X} |
| solutions.md | ~{X} |
| scoring-functions.sh | ~{X} |
| manifests/setup/*.yaml | {count} files |

### CKAD Domain Coverage (this simulation)

| Domain | Weight | Questions | Coverage |
|--------|--------|-----------|----------|
| Application Design and Build | 20% | Q{X}, Q{Y} | {topics} |
| Application Deployment | 20% | Q{X}, Q{Y} | {topics} |
| Application Observability | 15% | Q{X}, Q{Y} | {topics} |
| Environment, Config & Security | 25% | Q{X}, Q{Y} | {topics} |
| Services and Networking | 20% | Q{X}, Q{Y} | {topics} |

### New Topics Covered (not in sim1-4)

- {Topic 1}
- {Topic 2}
- ...

### Cumulative Coverage (all simulations)

After this simulation, the following CKAD topics are now covered:
- Total unique topics: {X}/{Y} ({Z}%)
- Remaining gaps: {list of uncovered topics if any}

### Question Distribution

| # | Topic | Points | Namespace | Domain |
|---|-------|--------|-----------|--------|
| 1 | {Topic} | {pts} | {ns} | {domain} |

### Next Steps

1. Review: `less exams/ckad-simulation{N}/questions.md`
2. Setup: `./scripts/ckad-setup.sh -e ckad-simulation{N}`
3. Test: `./scripts/ckad-score.sh -e ckad-simulation{N}`
4. Start: `uv run ckad-dojo exam start -e {N}`
```

## Quality Standards

1. **Scripts MUST be idempotent**
2. **Scoring MUST be deterministic**
3. **Use native K8s tooling only**
4. **NO REPEATED QUESTIONS** across simulations
5. **Questions achievable in 1-10 min each**
