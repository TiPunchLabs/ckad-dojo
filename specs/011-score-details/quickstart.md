# Quickstart: Score Details Display

## Test Scenarios

### Scenario 1: View Criteria After Exam Stop

**Setup**:

1. Start exam: `./scripts/ckad-exam.sh -e ckad-simulation2`
2. Answer some questions partially (intentionally make mistakes)
3. Click "Stop Exam" button

**Expected Result**:

- Score modal appears with percentage and total score
- Questions list shows each question with score (e.g., "3/5")
- Questions with partial scores show warning indicator (orange)
- Questions with full scores show success indicator (green)
- Questions with zero scores show failure indicator (red)

### Scenario 2: Expand Question to See Criteria

**Setup**:

1. From Scenario 1, score modal is displayed
2. Click on a question row that has partial score (e.g., Q2 with 3/5)

**Expected Result**:

- Question row expands to show criteria list
- Each criterion shows:
  - ✓ Green for passed (e.g., "✓ Pod exists")
  - ✗ Red for failed (e.g., "✗ Pod has 2 containers")
- Criteria count matches the score (3 passed, 2 failed = 3/5)

### Scenario 3: Collapse Expanded Question

**Setup**:

1. From Scenario 2, criteria are expanded for Q2
2. Click on Q2 row again

**Expected Result**:

- Criteria collapse back
- Only question summary visible (score + topic)

### Scenario 4: Multiple Questions Expanded

**Setup**:

1. Expand Q2 criteria
2. Expand Q5 criteria (without collapsing Q2)

**Expected Result**:

- Both Q2 and Q5 show criteria
- Each question's criteria are independent
- Scrolling works correctly within modal

### Scenario 5: Dark/Light Theme Support

**Setup**:

1. Display score modal with criteria expanded
2. Toggle theme using theme button

**Expected Result**:

- Criteria colors remain visible in both themes
- Green (pass) and red (fail) have sufficient contrast
- Expand/collapse icons are visible

### Scenario 6: API Response Structure

**Setup**:

1. Run scoring via API: `curl http://localhost:9090/api/score`

**Expected Result**:

```json
{
  "success": true,
  "questions": [
    {
      "id": "1",
      "score": 1,
      "max_score": 1,
      "topic": "Namespaces",
      "passed": true,
      "criteria": [
        {"description": "File contains namespace list", "passed": true}
      ]
    },
    {
      "id": "2",
      "score": 3,
      "max_score": 5,
      "topic": "Multi-container Pod",
      "passed": false,
      "criteria": [
        {"description": "Pod multi-container-pod exists", "passed": true},
        {"description": "Pod is Running", "passed": true},
        {"description": "Pod has 2 containers", "passed": false},
        {"description": "First container uses nginx image", "passed": true},
        {"description": "Second container uses busybox image", "passed": false}
      ]
    }
  ],
  "total_score": 4,
  "max_score": 6,
  "percentage": 66,
  "passed": true
}
```

## Manual Verification Checklist

- [ ] Score modal displays after exam stop
- [ ] All questions show score and topic
- [ ] Visual indicators match score status (green/orange/red)
- [ ] Clicking question expands criteria
- [ ] Criteria show correct PASS/FAIL status
- [ ] Clicking expanded question collapses it
- [ ] Dark theme: criteria colors visible
- [ ] Light theme: criteria colors visible
- [ ] Scrolling works with many questions
- [ ] API returns criteria in response
