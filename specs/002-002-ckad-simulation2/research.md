# Research: CKAD Simulation 2 & Solutions Feature

**Date**: 2025-12-05
**Feature**: 002-ckad-simulation2

## Technical Decisions

### 1. Question Format

**Decision**: Use identical markdown format as ckad-simulation1/questions.md

**Rationale**: Consistent format ensures:
- Web parser compatibility (parse_questions_md in server.py)
- Familiar user experience
- Reuse of existing rendering logic

**Format Structure**:
```markdown
## Question N | Topic

| | |
|---|---|
| **Points** | X/110 (Y%) |
| **Namespace** | namespace-name |
| **Resources** | Resource description |
| **File to create** | `./exam/course/N/filename` |

### Task

[Detailed task description]
```

### 2. Solutions Format

**Decision**: Create solutions.md with paired question-solution format

**Rationale**:
- Mirrors questions.md structure for consistency
- Enables reuse of markdown parser
- Supports syntax highlighting via existing code block rendering

**Format Structure**:
```markdown
## Solution N | Topic

### Expected Approach

[Step-by-step solution with commands and YAML]

### Key Points

- [Important concept 1]
- [Important concept 2]
```

### 3. Namespace Theme

**Decision**: Galaxy/Constellation theme (distinct from simulation1's planetary theme)

**Namespaces Selected**:
- andromeda, orion, pegasus, cygnus, lyra
- aquila, draco, phoenix, hydra, centaurus, cassiopeia

**Rationale**:
- Thematic consistency within exam
- Clear differentiation from simulation1 (neptune, saturn, mars, etc.)
- 11 namespaces match simulation1's count

### 4. Scoring Function Pattern

**Decision**: Follow established pattern from scoring-functions.sh

**Pattern**:
```bash
score_qN() {
    local score=0
    local total=X
    echo "Question N | Topic"

    # Check 1
    local result=$(kubectl ... 2>/dev/null)
    check_criterion "Description" "$([ condition ] && echo true || echo false)" && ((score++))

    # ... more checks ...

    echo "$score/$total"
    return $score
}
```

**Rationale**: Consistency with existing scoring system ensures compatibility with ckad-score.sh

### 5. Solutions Web Integration

**Decision**: Add new API endpoint `/api/exam/{exam_id}/solutions` and UI components

**Implementation Approach**:
1. Parse solutions.md similarly to questions.md
2. Add "View Solutions" button in score modal
3. Create solutions view with navigation
4. Show pass/fail status per question from scoring results

**Rationale**: Minimal changes to existing architecture, leverages existing patterns

### 6. Question Point Distribution

**Decision**: 21 questions, ~110 total points, matching simulation1 difficulty curve

**Distribution**:
| Points | Count | Total |
|--------|-------|-------|
| 1-2    | 3     | 5     |
| 3-4    | 4     | 14    |
| 5-6    | 8     | 44    |
| 7-8    | 4     | 30    |
| 9-10   | 2     | 19    |
| **Total** | **21** | **112** |

**Rationale**: Matches simulation1's difficulty distribution (mix of quick wins and complex challenges)

## Alternatives Considered

### Question Format Alternatives

| Option | Considered | Rejected Because |
|--------|-----------|------------------|
| JSON format | Yes | Breaks existing web parser |
| YAML frontmatter | Yes | Adds complexity without benefit |
| Separate files per question | Yes | Harder to maintain and navigate |

### Solutions Display Alternatives

| Option | Considered | Rejected Because |
|--------|-----------|------------------|
| Inline in questions | Yes | Would spoil during exam |
| Separate solutions app | Yes | Over-engineering |
| PDF download | Yes | Breaks web-first approach |

### Namespace Alternatives

| Option | Considered | Rejected Because |
|--------|-----------|------------------|
| Mythological (zeus, hera) | Yes | Less technical feel |
| Tech companies (google-ns) | Yes | Trademark concerns |
| Generic (team-a, team-b) | Yes | Less memorable |

## Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| kubectl | 1.28+ | Kubernetes CLI for scoring |
| helm | 3.x | Helm operations questions |
| docker | latest | Container building questions |
| Python 3.x | 3.8+ | Web server (standard library) |
| bash | 4.0+ | Script execution |

## Integration Points

1. **ckad-setup.sh**: Source exam-specific scoring-functions.sh
2. **ckad-score.sh**: Load functions from exams/{exam_id}/scoring-functions.sh
3. **web/server.py**: Add `/api/exam/{exam_id}/solutions` endpoint
4. **web/js/app.js**: Add solutions view and navigation

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Scoring bugs | Medium | High | Comprehensive test answers |
| Question ambiguity | Low | Medium | Clear task descriptions |
| Solutions spoilers | Low | Low | Only show after exam end |
| Namespace conflicts | Low | Medium | Distinct theme from sim1 |
