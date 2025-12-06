# Tasks: Exam Modal & Timer Improvements

**Input**: spec.md
**Prerequisites**: Existing modal infrastructure (score modal), timer state management

## Phase 1: Custom Stop Exam Modal (US1)

**Goal**: Replace browser confirm() with custom styled modal

- [x] T001 [P] Add confirm modal HTML structure in web/index.html
- [x] T002 [P] Add confirm modal CSS styles (backdrop, centered, dark theme) in web/css/style.css
- [x] T003 Add showConfirmModal() and hideConfirmModal() functions in web/js/app.js
- [x] T004 Replace confirm() call with showConfirmModal() in stopExam handler in web/js/app.js
- [x] T005 Add Escape key handler to close confirm modal in web/js/app.js
- [x] T006 Add backdrop click handler to close confirm modal in web/js/app.js

**Checkpoint**: Custom modal appears when clicking Stop Exam, Cancel closes it

---

## Phase 2: Pause Timer (US2)

**Goal**: Add pause/resume functionality to countdown timer

- [x] T007 [P] Add pause button HTML next to timer display in web/index.html
- [x] T008 [P] Add pause button styles in web/css/style.css
- [x] T009 Add paused state to timer_state in web/server.py
- [x] T010 Add POST /api/timer/pause endpoint to toggle pause in web/server.py
- [x] T011 Update GET /api/timer to return paused state and adjust remaining time in web/server.py
- [x] T012 Add togglePause() function in web/js/app.js
- [x] T013 Update timer display to show paused state (pulsing animation) in web/js/app.js
- [x] T014 Update updateTimer() to handle paused state in web/js/app.js

**Checkpoint**: Timer can be paused/resumed, state persists on refresh

---

## Phase 3: Fix Score Calculation (US3)

**Goal**: Actually calculate score by running ckad-score.sh

- [x] T015 Modify /api/score endpoint to run ckad-score.sh and parse output in web/server.py
- [x] T016 Add parse_score_output() function to extract scores in web/server.py
- [x] T017 Update score modal to display actual scores in web/js/app.js
- [x] T018 Handle scoring errors gracefully (show error in modal) in web/js/app.js

**Checkpoint**: Score modal shows actual calculated score with per-question breakdown

---

## Phase 4: Graceful Cleanup on Close (US4)

**Goal**: Trigger cleanup and stop server when clicking Close

- [x] T019 Add POST /api/cleanup endpoint to run ckad-cleanup.sh in web/server.py
- [x] T020 Add POST /api/shutdown endpoint to stop server gracefully in web/server.py
- [x] T021 Modify Close button handler to call cleanup then shutdown in web/js/app.js
- [x] T022 Show cleanup progress/status in modal in web/js/app.js
- [x] T023 Display "Exam ended" message before server stops in web/js/app.js

**Checkpoint**: Clicking Close triggers cleanup and stops server

---

## Phase 5: Polish & Documentation

- [x] T024 [P] Update README.md with pause timer feature
- [x] T025 [P] Update constitution.md with modal improvements
- [x] T026 Add animation transitions for modal show/hide in web/css/style.css

---

## Dependencies

- **Phase 1**: No dependencies
- **Phase 2**: No dependencies (can run parallel with Phase 1)
- **Phase 3**: Depends on Phase 1 (uses modal)
- **Phase 4**: Depends on Phase 3 (extends score modal)
- **Phase 5**: Depends on all phases

## Parallel Opportunities

```
Phase 1 + Phase 2: Can run in parallel (different functionality)
T001 + T002: Different files
T007 + T008: Different files
```
