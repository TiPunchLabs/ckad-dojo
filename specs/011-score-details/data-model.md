# Data Model: Score Details Display

## Entities

### ScoreResult

Overall exam scoring result returned by `/api/score` endpoint.

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Whether scoring completed successfully |
| questions | QuestionScore[] | Array of question scores with criteria |
| total_score | integer | Sum of all question scores |
| max_score | integer | Sum of all max possible scores |
| percentage | integer | Calculated percentage (0-100) |
| passed | boolean | True if percentage >= 66 |
| elapsed_seconds | integer | Time taken in seconds |
| elapsed_formatted | string | Time in "MM:SS" format |
| solutions_available | boolean | Whether solutions.md exists |
| exam_id | string | Exam identifier |
| output | string | Raw scoring script output |

### QuestionScore

Individual question scoring result.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Question identifier (e.g., "1", "P1") |
| score | integer | Points earned for this question |
| max_score | integer | Maximum possible points |
| topic | string | Question topic/title |
| passed | boolean | True if score == max_score |
| criteria | Criterion[] | **NEW**: Array of individual criteria results |

### Criterion

Individual evaluation criterion within a question.

| Field | Type | Description |
|-------|------|-------------|
| description | string | Human-readable criterion description |
| passed | boolean | True if criterion was satisfied |

## Relationships

```
ScoreResult
    └── questions: QuestionScore[] (1:N)
            └── criteria: Criterion[] (1:N)
```

## State Transitions

N/A - This is a read-only display feature. No state changes.

## Validation Rules

- `criteria` array may be empty if parsing fails for a question
- `score` should equal count of passed criteria (validation check)
- `max_score` should equal total criteria count (validation check)
