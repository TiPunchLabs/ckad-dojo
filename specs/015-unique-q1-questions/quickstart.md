# Quickstart: Unique Q1 Questions

**Feature**: 015-unique-q1-questions
**Date**: 2025-12-14

## Verification Steps

### 1. Verify Q1 Uniqueness

```bash
# Check Q1 titles across all simulations
grep -h "## Question 1" exams/*/questions.md
```

Expected output:

- sim1: "Question 1 | Namespaces"
- sim2: "Question 1 | Nodes" (NEW)
- sim3: "Question 1 | Namespaces" (filtered)

### 2. Test sim2 Q1 Scoring

```bash
# Setup exam
./scripts/ckad-setup.sh -e ckad-simulation2

# Complete Q1 (save nodes to file)
kubectl get nodes > ./exam/course/1/nodes

# Check score
./scripts/ckad-score.sh -e ckad-simulation2
```

Expected: Q1 shows 1/1 points

### 3. Test sim2 Q1 Failure Case

```bash
# Create incorrect file
echo "wrong content" > ./exam/course/1/nodes

# Check score
./scripts/ckad-score.sh -e ckad-simulation2
```

Expected: Q1 shows 0/1 points

### 4. Verify Solutions Match Questions

```bash
# View Q1 solution for sim2
grep -A 20 "## Question 1" exams/ckad-simulation2/solutions.md
```

Expected: Shows `kubectl get nodes` command

## Post-Implementation Checklist

- [ ] sim1 Q1 unchanged (list namespaces)
- [ ] sim2 Q1 changed to list nodes
- [ ] sim3 Q1 unchanged (list namespaces with "a")
- [ ] sim2 scoring returns 1/1 for correct answer
- [ ] sim2 scoring returns 0/1 for incorrect answer
- [ ] sim2 solutions updated
