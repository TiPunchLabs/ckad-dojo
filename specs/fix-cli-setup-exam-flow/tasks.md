# Tasks: Fix CLI Setup-Exam Flow

**Input**: Design documents from `/specs/fix-cli-setup-exam-flow/`
**Prerequisites**: spec.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Bash Script Modification)

**Purpose**: Add --skip-detection flag support to ckad-exam.sh

- [x] T001 Add SKIP_DETECTION variable initialization in scripts/ckad-exam.sh
- [x] T002 Add --skip-detection flag parsing in argument handling section of scripts/ckad-exam.sh
- [x] T003 Update show_help() to document --skip-detection flag in scripts/ckad-exam.sh

---

## Phase 2: User Story 1 - Seamless Exam Start via CLI (Priority: P1) 🎯 MVP

**Goal**: CLI users can start exams without redundant detection prompts

**Independent Test**: Run `uv run ckad-dojo exam start -e ckad-simulation1` and verify no detection prompt appears

### Implementation for User Story 1

- [x] T004 [US1] Add detection skip logic before "EXISTING EXAM DETECTED" block in scripts/ckad-exam.sh
- [x] T005 [US1] Update cmd_exam_start() to pass --skip-detection flag in ckad_dojo.py
- [x] T006 [US1] Update menu_start_exam() to pass --skip-detection flag in ckad_dojo.py

**Checkpoint**: CLI exam start flow should work without redundant prompts

---

## Phase 3: User Story 2 - Direct Script Usage Unchanged (Priority: P2)

**Goal**: Direct script users still see detection prompt (backward compatibility)

**Independent Test**: Run `./scripts/ckad-exam.sh web -e ckad-simulation1` with existing resources and verify detection prompt appears

### Implementation for User Story 2

- [x] T007 [US2] Verify default behavior (SKIP_DETECTION=false) preserves detection in scripts/ckad-exam.sh
- [x] T008 [US2] Test direct script usage shows detection prompt

**Checkpoint**: Both CLI and direct script usage work as expected

---

## Phase 4: Polish & Validation

**Purpose**: Final verification and cleanup

- [x] T009 Run full integration test: `uv run ckad-dojo exam start -e ckad-simulation1`
- [x] T010 Run direct script test: `./scripts/ckad-exam.sh web -e ckad-simulation1`
- [x] T011 Verify --help shows --skip-detection documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - add flag support first
- **US1 (Phase 2)**: Depends on Phase 1 - uses the new flag
- **US2 (Phase 3)**: No code changes, just verification
- **Polish (Phase 4)**: Depends on US1 and US2

### Task Dependencies

- T001 → T002 → T003 (sequential setup)
- T004 depends on T002 (flag must be parsed first)
- T005, T006 depend on T004 (detection skip must work first)
- T007, T008 can run after T004

### Parallel Opportunities

- T005 and T006 can run in parallel (different functions in same file)
- T009, T010, T011 can run in parallel (independent tests)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Add flag support to bash script
2. Complete Phase 2: Update Python CLI to use the flag
3. **STOP and VALIDATE**: Test `uv run ckad-dojo exam start`
4. If working, proceed to Phase 3 (verification)

### Files Modified

| File | Changes |
|------|---------|
| `scripts/ckad-exam.sh` | Add --skip-detection flag, update help, add skip logic |
| `ckad_dojo.py` | Pass --skip-detection in cmd_exam_start() and menu_start_exam() |

---

## Summary

- **Total Tasks**: 11
- **US1 (CLI Flow)**: 3 tasks (T004-T006)
- **US2 (Backward Compat)**: 2 tasks (T007-T008)
- **Setup/Polish**: 6 tasks
- **Parallel Opportunities**: T005/T006, T009/T010/T011
