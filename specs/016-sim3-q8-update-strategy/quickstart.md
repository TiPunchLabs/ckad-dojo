# Quickstart: Sim3 Q8 Update Strategy

## Validation Steps

### 1. Verify Question Content

```bash
# Q8 should mention "Update Strategy" not "Rollback"
grep -A 20 "## Question 8" exams/ckad-simulation3/questions.md
```

Expected: Title contains "Update Strategy", task mentions maxSurge/maxUnavailable

### 2. Verify Solution Content

```bash
# Solution should show kubectl patch command
grep -A 15 "## Question 8" exams/ckad-simulation3/solutions.md
```

Expected: Shows `kubectl patch deployment` with strategy configuration

### 3. Test Scoring (requires cluster)

```bash
# Setup exam environment
./scripts/ckad-setup.sh -e ckad-simulation3

# Apply correct answer
kubectl patch deployment battle-app -n ares -p '{
  "spec": {
    "strategy": {
      "type": "RollingUpdate",
      "rollingUpdate": {
        "maxSurge": 2,
        "maxUnavailable": 1
      }
    }
  }
}'

# Run scoring
./scripts/ckad-score.sh -e ckad-simulation3 | grep -A 10 "Question 8"
```

Expected: Score shows 6/6 with all criteria PASS

### 4. Verify Differentiation

```bash
# Sim1 Q8 should still be rollback
grep "## Question 8" exams/ckad-simulation1/questions.md
# Sim3 Q8 should be update strategy
grep "## Question 8" exams/ckad-simulation3/questions.md
```

Expected: Different titles confirming unique questions

### 5. Cleanup

```bash
./scripts/ckad-cleanup.sh -e ckad-simulation3
```
