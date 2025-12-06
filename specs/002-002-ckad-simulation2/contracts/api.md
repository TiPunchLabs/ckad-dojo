# API Contracts: Solutions Feature

**Date**: 2025-12-05
**Feature**: 002-ckad-simulation2

## New Endpoints

### GET /api/exam/{exam_id}/solutions

Retrieves all solutions for a specific exam.

**Request**:
```
GET /api/exam/ckad-simulation2/solutions
```

**Response** (200 OK):
```json
{
  "exam_id": "ckad-simulation2",
  "solutions": [
    {
      "id": "1",
      "topic": "Namespaces",
      "approach": "## Expected Approach\n\nList all namespaces...",
      "key_points": [
        "Use kubectl get ns to list namespaces",
        "Output can include additional columns"
      ]
    },
    {
      "id": "2",
      "topic": "Multi-container Pod",
      "approach": "## Expected Approach\n\n1. Create pod with two containers...",
      "key_points": [
        "Multi-container pods share network namespace",
        "Use same port requires different containers"
      ]
    }
  ]
}
```

**Response** (404 Not Found):
```json
{
  "error": "Solutions not available for this exam"
}
```

### GET /api/exam/{exam_id}/solutions/{question_id}

Retrieves solution for a specific question.

**Request**:
```
GET /api/exam/ckad-simulation2/solutions/1
```

**Response** (200 OK):
```json
{
  "id": "1",
  "topic": "Namespaces",
  "approach": "## Expected Approach\n\n```bash\nkubectl get ns > ./exam/course/1/namespaces\n```\n\n### Key Points\n\n- Output includes NAME, STATUS, AGE columns\n- All exam namespaces should be visible",
  "key_points": [
    "Use kubectl get ns to list namespaces",
    "Output can include additional columns"
  ]
}
```

## Existing Endpoints (Reference)

### GET /api/exams
Lists all available exams.

### GET /api/exam/{exam_id}/config
Returns exam configuration.

### GET /api/exam/{exam_id}/questions
Returns all questions for an exam.

### POST /api/score
Runs scoring and returns results.

**Enhanced Response** (with solutions reference):
```json
{
  "success": true,
  "questions": [
    {
      "id": "1",
      "score": 1,
      "max_score": 1,
      "topic": "Namespaces",
      "passed": true
    },
    {
      "id": "2",
      "score": 3,
      "max_score": 5,
      "topic": "Multi-container Pod",
      "passed": false
    }
  ],
  "total_score": 85,
  "max_score": 112,
  "percentage": 76,
  "passed": true,
  "elapsed_seconds": 5432,
  "elapsed_formatted": "90:32",
  "solutions_available": true
}
```

## UI Components (JavaScript API)

### api.getSolutions(examId)

```javascript
async getSolutions(examId) {
    const response = await fetch(`/api/exam/${examId}/solutions`);
    if (!response.ok) {
        throw new Error('Solutions not available');
    }
    return response.json();
}
```

### api.getSolution(examId, questionId)

```javascript
async getSolution(examId, questionId) {
    const response = await fetch(`/api/exam/${examId}/solutions/${questionId}`);
    if (!response.ok) {
        throw new Error('Solution not found');
    }
    return response.json();
}
```

## State Management

### Solutions State

```javascript
state.solutions = {
    loaded: false,
    data: [],           // Array of solution objects
    currentIndex: 0,    // Current solution being viewed
    scoreResults: null  // Reference to scoring results for pass/fail
};
```

### UI Elements

```javascript
elements.solutionsView = document.getElementById('solutions-view');
elements.solutionContent = document.getElementById('solution-content');
elements.solutionNav = document.getElementById('solution-nav');
elements.solutionPrev = document.getElementById('solution-prev');
elements.solutionNext = document.getElementById('solution-next');
elements.solutionStatus = document.getElementById('solution-status');
elements.backToScore = document.getElementById('back-to-score');
```

## Event Handlers

### View Solutions Button

```javascript
elements.viewSolutions.addEventListener('click', async () => {
    await loadAndShowSolutions(state.currentExam);
});
```

### Solution Navigation

```javascript
elements.solutionPrev.addEventListener('click', () => {
    if (state.solutions.currentIndex > 0) {
        showSolution(state.solutions.currentIndex - 1);
    }
});

elements.solutionNext.addEventListener('click', () => {
    if (state.solutions.currentIndex < state.solutions.data.length - 1) {
        showSolution(state.solutions.currentIndex + 1);
    }
});
```
