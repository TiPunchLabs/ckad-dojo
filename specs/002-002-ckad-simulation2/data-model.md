# Data Model: CKAD Simulation 2 & Solutions Feature

**Date**: 2025-12-05
**Feature**: 002-ckad-simulation2

## Entity Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      Exam       │────▶│    Question     │────▶│    Solution     │
│   (exam.conf)   │     │ (questions.md)  │     │ (solutions.md)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Namespace     │     │ ScoringFunction │     │   ScoreResult   │
│   (manifests)   │     │  (scoring-*.sh) │     │   (API state)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Entity Definitions

### Exam

**Source**: `exams/{exam_id}/exam.conf`

| Field | Type | Description |
|-------|------|-------------|
| EXAM_NAME | string | Display name (e.g., "CKAD Simulation 2") |
| EXAM_ID | string | Unique identifier (e.g., "ckad-simulation2") |
| EXAM_VERSION | string | Version number (e.g., "1.0") |
| EXAM_DURATION | integer | Duration in minutes (default: 120) |
| EXAM_WARNING_TIME | integer | Warning threshold in minutes (default: 15) |
| TOTAL_QUESTIONS | integer | Number of main questions |
| PREVIEW_QUESTIONS | integer | Number of bonus preview questions |
| TOTAL_POINTS | integer | Maximum achievable score |
| PASSING_PERCENTAGE | integer | Pass threshold percentage (default: 66) |
| EXAM_NAMESPACES | array[string] | Required Kubernetes namespaces |
| HELM_RELEASES | array[string] | Pre-installed Helm releases |

**Example (ckad-simulation2)**:

```bash
EXAM_NAME="CKAD Simulation 2"
EXAM_ID="ckad-simulation2"
EXAM_VERSION="1.0"
EXAM_DURATION=120
EXAM_WARNING_TIME=15
TOTAL_QUESTIONS=21
PREVIEW_QUESTIONS=1
TOTAL_POINTS=112
PASSING_PERCENTAGE=66
EXAM_NAMESPACES=(
    "andromeda" "orion" "pegasus" "cygnus" "lyra"
    "aquila" "draco" "phoenix" "hydra" "centaurus" "cassiopeia"
)
```

### Question

**Source**: `exams/{exam_id}/questions.md`

| Field | Type | Description |
|-------|------|-------------|
| id | string | Question number (e.g., "1", "P1" for preview) |
| number | integer/string | Numeric or alphanumeric identifier |
| topic | string | CKAD domain (e.g., "Pods", "Deployments") |
| points | integer | Points for this question |
| namespace | string | Target Kubernetes namespace |
| resources | string | Resources involved |
| files | string | Files to create |
| content | string | Full markdown task description |

**Validation Rules**:

- id: Required, unique within exam
- points: 1-10 range
- namespace: Must exist in EXAM_NAMESPACES or be "default"

### Solution

**Source**: `exams/{exam_id}/solutions.md`

| Field | Type | Description |
|-------|------|-------------|
| question_id | string | Reference to question id |
| topic | string | Same topic as question |
| approach | string | Step-by-step solution (markdown) |
| key_points | array[string] | Important concepts to remember |
| commands | array[string] | Essential kubectl/helm commands |
| yaml_snippets | array[object] | YAML manifests with descriptions |

**Format**:

```markdown
## Solution N | Topic

### Expected Approach

[Markdown with code blocks]

### Key Points

- Point 1
- Point 2

### Commands

```bash
kubectl create ...
```

### YAML

```yaml
apiVersion: v1
kind: Pod
...
```

```

### ScoringFunction

**Source**: `exams/{exam_id}/scoring-functions.sh`

| Field | Type | Description |
|-------|------|-------------|
| function_name | string | `score_q{N}` or `score_preview_q{N}` |
| total_criteria | integer | Number of checkpoints |
| checks | array[Check] | Individual scoring criteria |

**Check Structure**:
| Field | Type | Description |
|-------|------|-------------|
| description | string | Human-readable criterion |
| condition | string | Bash expression evaluating to "true"/"false" |
| points | integer | Always 1 (per criterion) |

### ScoreResult (API State)

**Source**: In-memory (web/server.py)

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Scoring completed successfully |
| questions | array[QuestionScore] | Per-question results |
| total_score | integer | Sum of all points earned |
| max_score | integer | Maximum possible score |
| percentage | integer | Score percentage |
| passed | boolean | percentage >= 66 |
| elapsed_seconds | integer | Time taken |
| elapsed_formatted | string | "MM:SS" format |

**QuestionScore**:
| Field | Type | Description |
|-------|------|-------------|
| id | string | Question identifier |
| score | integer | Points earned |
| max_score | integer | Points possible |
| topic | string | Question topic |
| passed | boolean | score == max_score |

## File Structure

### Exam Directory Structure

```

exams/ckad-simulation2/
├── exam.conf                    # Exam configuration
├── questions.md                 # 21 questions + 1 preview
├── solutions.md                 # Solutions for all questions (NEW)
├── scoring-functions.sh         # Scoring logic
├── manifests/
│   └── setup/
│       ├── namespaces.yaml      # 11 namespaces
│       ├── q02-pod.yaml         # Pre-existing resources
│       ├── q05-deployment.yaml
│       ├── q08-service.yaml
│       └── ...
└── templates/
    ├── q07-cronjob.yaml         # Template files
    ├── q12-image/
    │   ├── Dockerfile
    │   └── app.py
    └── ...

```

### Student Answer Directory

```

exam/course/
├── 1/                   # Question 1 answers
├── 2/                   # Question 2 answers
├── ...
├── 21/                  # Question 21 answers
└── p1/                  # Preview question 1 answers

```

## State Transitions

### Exam Session States

```

┌──────────┐   select    ┌──────────┐   start    ┌─────────┐
│  IDLE    │────────────▶│ SELECTED │───────────▶│ RUNNING │
└──────────┘             └──────────┘            └─────────┘
                                                      │
                              ┌───────────────────────┤
                              │ stop/timeout          │
                              ▼                       │
                         ┌──────────┐                 │
                         │ SCORING  │◀────────────────┘
                         └──────────┘
                              │
                              │ complete
                              ▼
                         ┌──────────┐   view     ┌───────────┐
                         │ SCORED   │───────────▶│ SOLUTIONS │
                         └──────────┘            └───────────┘

```

### Question States (per session)

```

UNANSWERED ──▶ ATTEMPTED ──▶ FLAGGED ──▶ REVIEWED
     │              │            │           │
     └──────────────┴────────────┴───────────┘
                      (navigation)

```

## CKAD Simulation 2 Questions Overview

| # | Topic | Points | Namespace | Type |
|---|-------|--------|-----------|------|
| 1 | Namespaces | 1 | - | File output |
| 2 | Multi-container Pod | 5 | andromeda | Create |
| 3 | CronJob | 5 | orion | Create |
| 4 | Deployment Scaling | 4 | pegasus | Modify |
| 5 | Deployment Troubleshooting | 6 | cygnus | Fix |
| 6 | ConfigMap Volume Mount | 5 | lyra | Create |
| 7 | Secret Environment Variables | 5 | aquila | Create |
| 8 | Service NodePort | 4 | draco | Create |
| 9 | Pod → Deployment Conversion | 8 | phoenix | Convert |
| 10 | PV/PVC Creation | 6 | hydra | Create |
| 11 | NetworkPolicy | 6 | centaurus | Create |
| 12 | Container Image Build | 7 | cassiopeia | Build |
| 13 | Helm Install/Upgrade | 5 | andromeda | Helm |
| 14 | InitContainer | 5 | orion | Create |
| 15 | Sidecar Logging | 6 | pegasus | Modify |
| 16 | ServiceAccount Token | 2 | cygnus | Extract |
| 17 | Liveness Probe | 5 | lyra | Create |
| 18 | Readiness Probe | 5 | aquila | Create |
| 19 | Resource Limits | 5 | draco | Modify |
| 20 | Labels and Selectors | 4 | phoenix | Create |
| 21 | Rollback Deployment | 3 | hydra | Rollback |
| P1 | Startup Probe (Preview) | 4 | centaurus | Create |

**Total**: 112 points (21 main questions) + 4 preview points
