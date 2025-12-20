# Quickstart: Sim2 Original Exam

## Validation Steps

### 1. Verify Exam Configuration

```bash
# Check exam.conf has new namespaces
cat exams/ckad-simulation2/exam.conf | grep EXAM_NAMESPACES

# Expected: phoenix, ember, blaze, inferno, flame, spark, solar, corona, flare, magma
```

### 2. Verify Questions Count

```bash
# Count questions in questions.md
grep -c "^## Question" exams/ckad-simulation2/questions.md

# Expected: 21
```

### 3. Verify Total Points

```bash
# Extract points from questions.md and sum
grep -oP '\*\*Points\*\* \| \K\d+' exams/ckad-simulation2/questions.md | \
  awk '{sum+=$1} END {print sum}'

# Expected: 112
```

### 4. Verify Scoring Functions

```bash
# Count scoring functions
grep -c "^score_q" exams/ckad-simulation2/scoring-functions.sh

# Expected: 21
```

### 5. Test Setup (requires cluster)

```bash
# Run setup
./scripts/ckad-setup.sh -e ckad-simulation2

# Verify namespaces created
kubectl get ns | grep -E "phoenix|ember|blaze|inferno|flame|spark|solar|corona|flare|magma"

# Expected: 10 namespaces
```

### 6. Test Scoring (requires cluster + answers)

```bash
# Score with no answers (baseline)
./scripts/ckad-score.sh -e ckad-simulation2

# Expected: 0/112 (or partial for pre-existing resources)
```

### 7. Verify Differentiation from Sim1

```bash
# Check no duplicate question titles
comm -12 \
  <(grep "^## Question" exams/ckad-simulation1/questions.md | sort) \
  <(grep "^## Question" exams/ckad-simulation2/questions.md | sort)

# Expected: Empty output (no matches)
```

### 8. Cleanup Test

```bash
./scripts/ckad-cleanup.sh -e ckad-simulation2

# Verify namespaces removed
kubectl get ns | grep -E "phoenix|ember|blaze" | wc -l

# Expected: 0
```

## Sample Question Validation

### Q1 - API Resources (1 point)

```bash
# Answer
kubectl api-resources > ./exam/course/1/api-resources

# Verify scoring
./scripts/ckad-score.sh -e ckad-simulation2 | grep "Question 1"

# Expected: 1/1
```

### Q5 - CrashLoop Fix (6 points)

```bash
# Check initial state
kubectl get pod crash-app -n ember

# Expected: CrashLoopBackOff

# Fix the pod (edit command)
kubectl edit pod crash-app -n ember
# Change: command: ["sleepx"] to command: ["sleep"]

# Verify fix
kubectl get pod crash-app -n ember

# Expected: Running
```

### Q9 - Canary Deployment (7 points)

```bash
# Check existing stable deployment
kubectl get deploy stable-v1 -n blaze

# Create canary
kubectl create deploy canary-v2 -n blaze --image=nginx:1.22 --replicas=1
kubectl label deploy canary-v2 -n blaze version=v2

# Verify
kubectl get deploy -n blaze

# Expected: stable-v1 (3 replicas), canary-v2 (1 replica)
```

## Full Exam Test

```bash
# Complete exam flow
./scripts/ckad-setup.sh -e ckad-simulation2
./scripts/ckad-exam.sh web -e ckad-simulation2

# After completing exam:
./scripts/ckad-score.sh -e ckad-simulation2
./scripts/ckad-cleanup.sh -e ckad-simulation2
```
