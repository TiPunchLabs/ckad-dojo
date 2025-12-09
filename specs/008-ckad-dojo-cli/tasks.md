# Tasks: Centralized CKAD-Dojo CLI

**Input**: Design documents from `/specs/008-ckad-dojo-cli/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US5)

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Create project structure and uv configuration

- [x] T001 Create pyproject.toml with script entry point at project root
- [x] T002 Create ckad_dojo.py skeleton with main() entry point at project root
- [x] T003 Verify `uv run ckad-dojo --version` works

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Core utilities and helpers that all user stories depend on

- [x] T004 Implement color output utilities (ANSI colors, --no-color support) in ckad_dojo.py
- [x] T005 Implement exam discovery function (scan exams/ directory) in ckad_dojo.py
- [x] T006 Implement exam config parser (read exam.conf files) in ckad_dojo.py
- [x] T007 Implement script runner wrapper (subprocess calls to bash scripts) in ckad_dojo.py
- [x] T008 Implement prerequisite checker (kubectl, helm, docker/podman) in ckad_dojo.py
- [x] T009 Implement ASCII banner display in ckad_dojo.py
- [x] T010 Implement signal handler for Ctrl+C graceful shutdown in ckad_dojo.py

**Checkpoint**: Foundation ready - can discover exams and call bash scripts

---

## Phase 3: User Story 1 - Interactive Menu (Priority: P1)

**Goal**: Launch exam via single command with interactive menu

**Independent Test**: Run `uv run ckad-dojo` and verify interactive menu appears

### Implementation for User Story 1

- [x] T011 [US1] Implement main menu display with numbered options in ckad_dojo.py
- [x] T012 [US1] Implement exam selection submenu (list exams for selection) in ckad_dojo.py
- [x] T013 [US1] Implement menu input handler with validation in ckad_dojo.py
- [x] T014 [US1] Implement "Start Exam" flow (setup + exam launch) in ckad_dojo.py
- [x] T015 [US1] Implement "Score Exam" menu option in ckad_dojo.py
- [x] T016 [US1] Implement "Cleanup" menu option in ckad_dojo.py
- [x] T017 [US1] Connect menu to script runner for all operations in ckad_dojo.py

**Checkpoint**: Users can run `uv run ckad-dojo` and complete full exam workflow via menu

---

## Phase 4: User Story 2 - Direct CLI Commands (Priority: P1)

**Goal**: Run operations directly via command line arguments

**Independent Test**: Run `uv run ckad-dojo exam start -e ckad-simulation1` without prompts

### Implementation for User Story 2

- [x] T018 [US2] Implement argparse parser with subcommands in ckad_dojo.py
- [x] T019 [US2] Implement `exam start` subcommand in ckad_dojo.py
- [x] T020 [US2] Implement `exam stop` subcommand in ckad_dojo.py
- [x] T021 [US2] Implement `score` command in ckad_dojo.py
- [x] T022 [US2] Implement `cleanup` command in ckad_dojo.py
- [x] T023 [US2] Implement `-e/--exam` option parsing for all commands in ckad_dojo.py
- [x] T024 [US2] Implement command routing (no args → menu, with args → direct) in ckad_dojo.py

**Checkpoint**: All commands work directly via CLI without interactive prompts

---

## Phase 5: User Story 3 - Status and Information (Priority: P2)

**Goal**: View exam status and information

**Independent Test**: Run `uv run ckad-dojo list` and see all exams with details

### Implementation for User Story 3

- [x] T025 [US3] Implement `list` command (table of exams with details) in ckad_dojo.py
- [x] T026 [US3] Implement `info` command (full exam configuration) in ckad_dojo.py
- [x] T027 [US3] Implement `status` command (check namespace existence, running state) in ckad_dojo.py
- [x] T028 [US3] Add formatted table output for list command in ckad_dojo.py

**Checkpoint**: Users can view all exam information via CLI

---

## Phase 6: User Story 4 - Setup Only (Priority: P2)

**Goal**: Set up exam environment without launching interface

**Independent Test**: Run `uv run ckad-dojo setup -e ckad-simulation1` and verify namespaces created

### Implementation for User Story 4

- [x] T029 [US4] Implement `setup` command (calls ckad-setup.sh only) in ckad_dojo.py
- [x] T030 [US4] Add setup completion message with next steps in ckad_dojo.py

**Checkpoint**: Users can setup exam environment independently

---

## Phase 7: User Story 5 - Help System (Priority: P3)

**Goal**: Comprehensive help and documentation

**Independent Test**: Run `uv run ckad-dojo --help` and see all commands documented

### Implementation for User Story 5

- [x] T031 [US5] Configure argparse help strings for all commands in ckad_dojo.py
- [x] T032 [US5] Add command descriptions and examples in help text in ckad_dojo.py
- [x] T033 [US5] Implement `--version` option in ckad_dojo.py

**Checkpoint**: Help covers 100% of commands and options

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, edge cases, and final integration

- [x] T034 Implement error handling for missing exams directory in ckad_dojo.py
- [x] T035 Implement error handling for script execution failures in ckad_dojo.py
- [x] T036 Implement cluster connectivity check with helpful error messages in ckad_dojo.py
- [x] T037 Add --no-color global option implementation in ckad_dojo.py
- [x] T038 Test all commands end-to-end and fix any issues
- [x] T039 Verify pyproject.toml script entry point works correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion
- **User Stories (Phase 3-7)**: All depend on Phase 2 completion
  - US1 and US2 can proceed in parallel (both P1 priority)
  - US3 and US4 can proceed in parallel (both P2 priority)
  - US5 can start after US1/US2 complete
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (Interactive Menu)**: Needs foundational components (T004-T010)
- **US2 (Direct CLI)**: Needs foundational components, can run parallel with US1
- **US3 (Status/Info)**: Needs exam discovery and config parser from Phase 2
- **US4 (Setup Only)**: Needs script runner from Phase 2
- **US5 (Help)**: Needs argparse structure from US2

### Parallel Opportunities

```bash
# Phase 2 - All foundational tasks can run in parallel:
T004, T005, T006, T007, T008, T009, T010

# Phase 3+4 - US1 and US2 can run in parallel:
# Developer A: T011-T017 (Menu)
# Developer B: T018-T024 (CLI)

# Phase 5+6 - US3 and US4 can run in parallel:
# Developer A: T025-T028 (Status/Info)
# Developer B: T029-T030 (Setup)
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T010)
3. Complete Phase 3: Interactive Menu (T011-T017)
4. Complete Phase 4: Direct CLI (T018-T024)
5. **STOP and VALIDATE**: Test `uv run ckad-dojo` and direct commands
6. Deploy/demo MVP

### Full Feature Delivery

7. Add Phase 5: Status/Info commands
8. Add Phase 6: Setup-only command
9. Add Phase 7: Help system
10. Complete Phase 8: Polish

---

## Summary

| Phase | Tasks | Description | Status |
|-------|-------|-------------|--------|
| Phase 1 | T001-T003 | Setup | COMPLETE |
| Phase 2 | T004-T010 | Foundational | COMPLETE |
| Phase 3 (US1) | T011-T017 | Interactive Menu | COMPLETE |
| Phase 4 (US2) | T018-T024 | Direct CLI | COMPLETE |
| Phase 5 (US3) | T025-T028 | Status/Info | COMPLETE |
| Phase 6 (US4) | T029-T030 | Setup Only | COMPLETE |
| Phase 7 (US5) | T031-T033 | Help System | COMPLETE |
| Phase 8 | T034-T039 | Polish | COMPLETE |

**Total Tasks**: 39
**Completed Tasks**: 39
**Status**: ALL TASKS COMPLETE
