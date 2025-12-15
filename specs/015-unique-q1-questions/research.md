# Research: Unique Q1 Questions

**Feature**: 015-unique-q1-questions
**Date**: 2025-12-14

## Current State Analysis

### Q1 Comparison Across Simulations

| Simulation | Q1 Task | Points | Output File | Unique? |
|------------|---------|--------|-------------|---------|
| ckad-simulation1 | List all namespaces | 1 | `./exam/course/1/namespaces` | Baseline |
| ckad-simulation2 | List all namespaces | 1 | `./exam/course/1/namespaces` | **DUPLICATE** |
| ckad-simulation3 | List namespaces containing "a" | 1 | `./exam/course/1/namespaces` | Unique (filter) |

### Decision: Replace sim2 Q1 with Node Listing

**Rationale**:
- `kubectl get nodes` is a valid CKAD operation
- Equivalent difficulty (1 point, single command)
- Provides variety from namespace operations
- Matches exam warm-up pattern

**Alternatives Considered**:
- List pods in default namespace - rejected (too similar to other questions)
- List services - rejected (less fundamental)
- Cluster info - rejected (not typically a CKAD question format)

## Files to Modify

1. **exams/ckad-simulation2/questions.md**
   - Replace Q1 task text
   - Update output file from `namespaces` to `nodes`

2. **exams/ckad-simulation2/solutions.md**
   - Replace Q1 solution
   - Show `kubectl get nodes` command

3. **exams/ckad-simulation2/scoring-functions.sh**
   - Update `score_q1()` function
   - Check for node output file
   - Validate content contains node names

## Scoring Function Pattern

Current sim1 score_q1():
```bash
score_q1() {
    local score=0
    local max_points=1
    local file="./exam/course/1/namespaces"

    if [[ -f "$file" ]] && grep -q "default" "$file"; then
        score=1
    fi

    echo "$score/$max_points"
}
```

New sim2 score_q1() pattern:
```bash
score_q1() {
    local score=0
    local max_points=1
    local file="./exam/course/1/nodes"

    if [[ -f "$file" ]] && grep -qE "Ready|NotReady" "$file"; then
        score=1
    fi

    echo "$score/$max_points"
}
```
