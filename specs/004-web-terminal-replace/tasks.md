# Tasks: Web Terminal Integration

**Input**: Design documents from `/specs/004-web-terminal-replace/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Prepare bash infrastructure for ttyd management

- [x] T001 Add ttyd helper functions (check_ttyd, start_ttyd, stop_ttyd) in scripts/lib/common.sh
- [x] T002 Add TTYD_PORT and TTYD_PID_FILE variables in scripts/lib/common.sh
- [x] T003 [P] Add --terminal-port option parsing in scripts/ckad-exam.sh

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core ttyd integration that MUST be complete before UI work

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Replace open_terminal() call with start_ttyd() in scripts/ckad-exam.sh web mode startup
- [x] T005 Add stop_ttyd() to cleanup/exit handlers in scripts/ckad-exam.sh
- [x] T006 Update confirmation message to mention embedded terminal in scripts/ckad-exam.sh
- [x] T007 Remove external terminal detection code (TERMINAL_EMULATORS, detect_terminal) from scripts/lib/common.sh

**Checkpoint**: ttyd starts/stops correctly with exam - ready for UI integration

---

## Phase 3: User Story 1 - Unified Exam Experience (Priority: P1) 🎯 MVP

**Goal**: Display exam questions and terminal side-by-side in the same browser window

**Independent Test**: Launch exam, verify split layout with question panel on left and terminal iframe on right

### Implementation for User Story 1

- [x] T008 [P] [US1] Add terminal iframe container and split layout structure in web/index.html
- [x] T009 [P] [US1] Add CSS for split layout (flexbox, .question-panel, .terminal-panel, .split-divider) in web/css/style.css
- [x] T010 [US1] Add terminal iframe element pointing to ttyd port in web/index.html
- [x] T011 [US1] Update .exam-main to use split layout container in web/css/style.css
- [x] T012 [US1] Add state.terminalEnabled flag and terminal DOM references in web/js/app.js
- [x] T013 [US1] Initialize terminal panel visibility based on URL param (?terminal=false) in web/js/app.js

**Checkpoint**: Split layout visible with terminal iframe loading ttyd - basic unified experience works

---

## Phase 4: User Story 2 - Terminal Functionality (Priority: P1)

**Goal**: Ensure embedded terminal works like a real terminal for all exam operations

**Independent Test**: Execute kubectl, vim, and bash commands in embedded terminal, verify full functionality

### Implementation for User Story 2

- [x] T014 [US2] Configure ttyd with --writable flag for input support in scripts/lib/common.sh start_ttyd()
- [x] T015 [US2] Set ttyd working directory to PROJECT_DIR with --cwd flag in scripts/lib/common.sh start_ttyd()
- [x] T016 [US2] Add /api/terminal/status endpoint to check ttyd availability in web/server.py
- [x] T017 [US2] Add terminal status check on page load in web/js/app.js

**Checkpoint**: Terminal fully functional - can execute all exam commands (kubectl, helm, vim, etc.)

---

## Phase 5: User Story 3 - Layout Control (Priority: P2)

**Goal**: Allow users to resize the split between questions and terminal panels

**Independent Test**: Drag divider to resize panels, verify layout persists across navigation

### Implementation for User Story 3

- [x] T018 [P] [US3] Add draggable divider element between panels in web/index.html
- [x] T019 [P] [US3] Add cursor and hover styles for split-divider in web/css/style.css
- [x] T020 [US3] Implement drag resize logic (mousedown, mousemove, mouseup) in web/js/app.js
- [x] T021 [US3] Store layout preference in localStorage in web/js/app.js
- [x] T022 [US3] Load saved layout preference on page load in web/js/app.js
- [x] T023 [US3] Add min-width constraints (20%) to prevent panels from collapsing in web/css/style.css

**Checkpoint**: Panels can be resized with divider, preference persists

---

## Phase 6: User Story 4 - Graceful Degradation (Priority: P3)

**Goal**: Provide clear feedback when terminal fails to load or disconnects

**Independent Test**: Simulate ttyd not installed or crash, verify error messages appear

### Implementation for User Story 4

- [x] T024 [P] [US4] Add ttyd installation check with error message in scripts/lib/common.sh check_ttyd()
- [x] T025 [P] [US4] Add terminal error overlay HTML element in web/index.html
- [x] T026 [P] [US4] Add styles for terminal error overlay and reconnect button in web/css/style.css
- [x] T027 [US4] Detect iframe load failure and show error overlay in web/js/app.js
- [x] T028 [US4] Add reconnect button handler to reload iframe in web/js/app.js
- [x] T029 [US4] Handle --no-terminal flag to hide terminal panel in web/js/app.js

**Checkpoint**: Graceful error handling with clear messages and reconnect option

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation updates and cleanup

- [x] T030 [P] Update README.md with ttyd installation instructions
- [x] T031 [P] Update constitution.md to replace "auto-open terminal" with "embedded web terminal"
- [x] T032 [P] Add ttyd to Required Tools table in README.md
- [x] T033 [P] Update --no-terminal description in help text in scripts/ckad-exam.sh
- [x] T034 Remove open_terminal function from scripts/lib/common.sh
- [x] T035 Update test-common.sh with ttyd function tests in tests/test-common.sh
- [x] T036 Run quickstart.md validation manually

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Independent of US1 (ttyd config)
- **User Story 3 (P2)**: Depends on US1 (needs split layout to exist)
- **User Story 4 (P3)**: Depends on US1 (needs terminal panel to exist)

### Parallel Opportunities

**Phase 1 (Setup)**:

```
T001, T002 (same file - sequential)
T003 (different file - parallel with T001-T002)
```

**Phase 3 (US1)**:

```
T008 + T009 (different files - parallel)
```

**Phase 5 (US3)**:

```
T018 + T019 (different files - parallel)
```

**Phase 6 (US4)**:

```
T024 + T025 + T026 (different files - parallel)
```

**Phase 7 (Polish)**:

```
T030 + T031 + T032 + T033 (all parallel - different files)
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T007)
3. Complete Phase 3: User Story 1 (T008-T013)
4. Complete Phase 4: User Story 2 (T014-T017)
5. **STOP and VALIDATE**: Test unified exam experience with functional terminal
6. This delivers core value - embedded terminal in exam interface

### Incremental Delivery

1. MVP (US1 + US2) → Basic split layout with working terminal
2. Add US3 → Resizable layout
3. Add US4 → Error handling and graceful degradation
4. Polish → Documentation and cleanup

---

## Notes

- US1 and US2 are both P1 and together form the MVP
- US3 (resize) enhances but isn't required for basic functionality
- US4 (error handling) improves UX but exam works without it
- ttyd handles terminal emulation - no custom xterm.js integration needed
- Iframe approach isolates terminal from exam UI, simplifying implementation
