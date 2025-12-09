# Research: Score Details Display

## Decision 1: Parsing Strategy for Criteria Output

**Decision**: Parse ANSI-colored output from scoring script using regex patterns for `✓` (PASS) and `✗` (FAIL) markers.

**Rationale**: The existing scoring functions use `print_success` and `print_fail` which output colored text with checkmarks. Parsing this output avoids modifying the bash scripts while extracting all needed data.

**Alternatives considered**:
- JSON output from scoring scripts - Rejected: requires modifying all scoring functions across 4 exams
- Separate metadata file - Rejected: adds complexity, scoring output already contains all data

**Output Format Analysis**:
```
Question 2 | Multi-container Pod
✓ Pod multi-container-pod exists
✓ Pod is Running
✗ Pod has 2 containers
✓ First container uses nginx image
✗ Second container uses busybox image
3/5
```

Pattern to match: `^[✓✗]\s+(.+)$` where `✓` = pass, `✗` = fail

## Decision 2: UI Pattern for Criteria Display

**Decision**: Expandable/collapsible rows in the score modal questions list.

**Rationale**:
- Keeps summary view clean (question score + topic only)
- Allows drill-down into details on demand
- Familiar UX pattern (accordion)
- No additional libraries needed (vanilla JS)

**Alternatives considered**:
- Inline display of all criteria - Rejected: clutters modal, overwhelming with 20+ questions
- Separate details page - Rejected: breaks flow, requires navigation
- Tooltip on hover - Rejected: not mobile-friendly, transient

## Decision 3: Visual Indicators

**Decision**: Use existing color scheme with icons:
- Full score (5/5): Green checkmark ✓
- Partial score (3/5): Orange/yellow warning ⚠
- Zero score (0/5): Red cross ✗

Individual criteria within expanded row:
- PASS: Green text with ✓
- FAIL: Red text with ✗

**Rationale**: Consistent with existing theme colors and scoring conventions.

## Decision 4: Data Structure

**Decision**: Extend existing API response to include criteria array per question:

```json
{
  "questions": [
    {
      "id": "1",
      "score": 3,
      "max_score": 5,
      "topic": "Multi-container Pod",
      "passed": false,
      "criteria": [
        {"description": "Pod multi-container-pod exists", "passed": true},
        {"description": "Pod is Running", "passed": true},
        {"description": "Pod has 2 containers", "passed": false},
        ...
      ]
    }
  ]
}
```

**Rationale**: Backward compatible (criteria is optional), frontend can display criteria if present.
