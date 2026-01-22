# Quickstart: CKAD Simulation 2 & Solutions Feature

**Date**: 2025-12-05
**Feature**: 002-ckad-simulation2

## Prerequisites

- Kubernetes cluster accessible via kubectl
- Helm 3.x installed
- Docker installed
- Python 3.8+ with uv package manager
- Bash 4.0+

## Quick Start

### 1. Launch CKAD Simulation 2

```bash
# Interactive selection (will show both exams)
./scripts/ckad-exam.sh

# Direct launch
./scripts/ckad-exam.sh -e ckad-simulation2

# Start at specific question
./scripts/ckad-exam.sh -e ckad-simulation2 -q 10
```

### 2. Complete the Exam

- Navigate questions using arrow keys or navigation bar
- Flag questions for review with 'F' key
- Answer questions in `./exam/course/N/` directories
- Use kubectl, helm, docker as needed

### 3. View Your Score

Click "Stop Exam" when finished to see:

- Total score and percentage
- Pass/fail status (66% threshold)
- Per-question breakdown

### 4. Review Solutions

Click "View Solutions" in the score modal to:

- See detailed solutions for each question
- Navigate between solutions
- View pass/fail status per question
- Learn from correct approaches

## New Features

### Solutions Page

After completing an exam, you can now view detailed solutions:

1. **Stop Exam** - End your exam session
2. **View Score** - See your results in the score modal
3. **View Solutions** - Click to see detailed solutions

Solutions include:

- Step-by-step approach
- kubectl/helm commands
- YAML manifests
- Key learning points

### Multiple Exam Support

The simulator now supports multiple exams:

| Exam | Questions | Points | Theme |
|------|-----------|--------|-------|
| ckad-simulation1 | 22 | 113 | Planets (neptune, saturn...) |
| ckad-simulation2 | 21 | 112 | Galaxies (andromeda, orion...) |

## File Structure

### Exam Files Location

```
exams/ckad-simulation2/
├── exam.conf           # Exam configuration
├── questions.md        # All 21 questions
├── solutions.md        # Detailed solutions
├── scoring-functions.sh
├── manifests/setup/    # Pre-existing resources
└── templates/          # Template files
```

### Answer Files Location

```
exam/course/
├── 1/namespaces        # Q1 answer
├── 2/pod.yaml          # Q2 answer
├── ...
└── 21/rollback.log     # Q21 answer
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| ← | Previous question |
| → | Next question |
| F | Flag question for review |

## Scoring Commands

```bash
# Score current exam
./scripts/ckad-score.sh

# Score specific exam
./scripts/ckad-score.sh -e ckad-simulation2

# Score with detailed output
./scripts/ckad-score.sh -e ckad-simulation2 -v
```

## Cleanup Commands

```bash
# Cleanup current exam resources
./scripts/ckad-cleanup.sh

# Cleanup specific exam
./scripts/ckad-cleanup.sh -e ckad-simulation2

# Force cleanup (skip confirmation)
./scripts/ckad-cleanup.sh -e ckad-simulation2 -y
```

## Troubleshooting

### Exam not showing in selection

Verify exam directory exists:

```bash
ls -la exams/ckad-simulation2/
```

### Scoring returns 0 for all questions

Ensure setup was run:

```bash
./scripts/ckad-setup.sh -e ckad-simulation2
```

### Solutions not loading

Check solutions.md exists:

```bash
cat exams/ckad-simulation2/solutions.md
```

## Topics Covered in Simulation 2

- Namespaces and Resource Organization
- Multi-container Pods
- CronJobs and Job Scheduling
- Deployment Scaling and Troubleshooting
- ConfigMaps and Secrets
- Services (ClusterIP, NodePort)
- Persistent Volumes and Claims
- NetworkPolicies
- Container Image Building
- Helm Package Management
- InitContainers and Sidecars
- Probes (Liveness, Readiness, Startup)
- Resource Limits and Requests
- Labels, Selectors, and Annotations
- Rollouts and Rollbacks
