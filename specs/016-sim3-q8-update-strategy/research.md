# Research: Sim3 Q8 Update Strategy

**Feature**: 016-sim3-q8-update-strategy
**Date**: 2025-12-14

## Current State Analysis

### Q8 Comparison: Sim1 vs Sim3

| Aspect | Sim1 Q8 | Sim3 Q8 (Current) |
|--------|---------|-------------------|
| Title | Deployment, Rollouts | Deployment Rollback |
| Points | 4 | 6 |
| Namespace | neptune | ares |
| Deployment | api-new-c32 | battle-app |
| Task | Check history, find working revision, rollback | Rollback to previous, write revision number |
| Core Skill | `kubectl rollout history/undo` | `kubectl rollout undo` |

**Problem**: Both questions test the same core skill (deployment rollback).

## Decision: Replace with Update Strategy

**Rationale**:
- RollingUpdate strategy configuration is a distinct CKAD skill
- Tests understanding of `maxSurge` and `maxUnavailable`
- Same complexity level (6 points)
- Reuses existing `battle-app` Deployment in `ares` namespace

**Alternatives Considered**:
1. ~~Blue/Green deployment~~ - Too complex for 6 points
2. ~~Recreate strategy~~ - Too simple (just set type)
3. **RollingUpdate with constraints** - Perfect balance of difficulty

## Files to Modify

1. **exams/ckad-simulation3/questions.md**
   - Replace Q8 section (Deployment Rollback → Update Strategy)
   - Update title, task description, output file reference

2. **exams/ckad-simulation3/solutions.md**
   - Replace Q8 solution
   - Show `kubectl patch` command for strategy config

3. **exams/ckad-simulation3/scoring-functions.sh**
   - Update `score_q8()` function
   - Validate strategy type, maxSurge, maxUnavailable

## Scoring Function Design

Current sim3 score_q8():
```bash
score_q8() {
    # Checks: deployment exists, available replicas,
    # rollback-info.txt exists, contains revision number,
    # uses working image
}
```

New score_q8():
```bash
score_q8() {
    local score=0
    local total=6

    echo "Question 8 | Deployment Update Strategy"

    # Check Deployment exists (1 pt)
    # Check strategy type is RollingUpdate (1 pt)
    # Check maxSurge is 2 (2 pts)
    # Check maxUnavailable is 1 (2 pts)

    echo "$score/$total"
}
```

## Setup Changes

**No setup changes required**: The `battle-app` Deployment already exists in `ares` namespace from the original question setup. The user just needs to modify its strategy configuration.
