# Tasks: CLI Shell Autocompletion

**Input**: Design documents from `/specs/010-cli-autocompletion/`
**Prerequisites**: spec.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Completion Command Infrastructure)

**Purpose**: Add completion subcommand structure to CLI

- [x] T001 Add completion subcommand to argument parser in ckad_dojo.py
- [x] T002 Add cmd_completion() handler function in ckad_dojo.py
- [x] T003 Route completion command in main() function in ckad_dojo.py

---

## Phase 2: User Story 1 & 4 - Bash Completion + Installation Instructions (Priority: P1) 🎯 MVP

**Goal**: Users can generate and install bash completion scripts with clear instructions

**Independent Test**: Run `uv run ckad-dojo completion bash` and verify valid bash script is output

### Implementation for User Story 1 & 4

- [x] T004 [US1] Create generate_bash_completion() function in ckad_dojo.py
- [x] T005 [US1] Add bash completion for top-level commands (exam, setup, score, cleanup, list, info, status, completion) in generate_bash_completion()
- [x] T006 [US1] Add bash completion for exam subcommands (start, stop) in generate_bash_completion()
- [x] T007 [US1] Add bash completion for options (-e, --exam, -V, --version, --no-color, --help) in generate_bash_completion()
- [x] T008 [US1] Add dynamic exam ID completion from exams/ directory in generate_bash_completion()
- [x] T009 [US4] Add get_installation_instructions() function for bash in ckad_dojo.py
- [x] T010 [US4] Display installation instructions in completion --help output in ckad_dojo.py

**Checkpoint**: Bash completion works with all commands, subcommands, options, and dynamic exam IDs

---

## Phase 3: User Story 2 - Zsh Completion (Priority: P2)

**Goal**: Users can generate zsh completion scripts with descriptions

**Independent Test**: Run `uv run ckad-dojo completion zsh` and verify valid zsh script is output

### Implementation for User Story 2

- [x] T011 [US2] Create generate_zsh_completion() function in ckad_dojo.py
- [x] T012 [US2] Add zsh completion for commands with descriptions in generate_zsh_completion()
- [x] T013 [US2] Add zsh completion for subcommands and options in generate_zsh_completion()
- [x] T014 [US2] Add dynamic exam ID completion for zsh in generate_zsh_completion()
- [x] T015 [US4] Add get_installation_instructions() for zsh in ckad_dojo.py

**Checkpoint**: Zsh completion works with all commands and shows descriptions

---

## Phase 4: User Story 3 - Fish Completion (Priority: P3)

**Goal**: Users can generate fish completion scripts

**Independent Test**: Run `uv run ckad-dojo completion fish` and verify valid fish script is output

### Implementation for User Story 3

- [x] T016 [US3] Create generate_fish_completion() function in ckad_dojo.py
- [x] T017 [US3] Add fish completion for commands with descriptions in generate_fish_completion()
- [x] T018 [US3] Add fish completion for subcommands and options in generate_fish_completion()
- [x] T019 [US3] Add dynamic exam ID completion for fish in generate_fish_completion()
- [x] T020 [US4] Add get_installation_instructions() for fish in ckad_dojo.py

**Checkpoint**: Fish completion works with all commands

---

## Phase 5: Polish & Validation

**Purpose**: Final verification and error handling

- [x] T021 Add error handling for unsupported shell in cmd_completion()
- [x] T022 Test `uv run ckad-dojo completion bash` outputs valid script
- [x] T023 Test `uv run ckad-dojo completion zsh` outputs valid script
- [x] T024 Test `uv run ckad-dojo completion fish` outputs valid script
- [x] T025 Test `uv run ckad-dojo completion --help` shows installation instructions
- [x] T026 Test `uv run ckad-dojo completion` without argument shows error with supported shells

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - add command structure first
- **US1 & US4 (Phase 2)**: Depends on Phase 1 - MVP with bash
- **US2 (Phase 3)**: Depends on Phase 1 - can run parallel to Phase 2
- **US3 (Phase 4)**: Depends on Phase 1 - can run parallel to Phase 2/3
- **Polish (Phase 5)**: Depends on all user stories

### Task Dependencies

- T001 → T002 → T003 (sequential setup)
- T004 → T005 → T006 → T007 → T008 (bash implementation sequence)
- T009, T010 can run after T004
- T011-T015 can start after T003 (parallel to bash)
- T016-T020 can start after T003 (parallel to bash/zsh)

### Parallel Opportunities

- T005, T006, T007, T008 work on same function but different sections
- T011-T014 (zsh) can run parallel to T004-T008 (bash)
- T016-T019 (fish) can run parallel to bash/zsh
- T022, T023, T024 can run in parallel (independent tests)

---

## Implementation Strategy

### MVP First (User Story 1 + 4 Only)

1. Complete Phase 1: Add completion subcommand
2. Complete Phase 2: Bash completion + instructions
3. **STOP and VALIDATE**: Test `uv run ckad-dojo completion bash`
4. If working, proceed to Phase 3 (zsh) and Phase 4 (fish)

### Files Modified

| File | Changes |
|------|---------|
| `ckad_dojo.py` | Add completion subcommand, generate functions for bash/zsh/fish |

---

## Summary

- **Total Tasks**: 26
- **US1 (Bash)**: 5 tasks (T004-T008)
- **US2 (Zsh)**: 5 tasks (T011-T015)
- **US3 (Fish)**: 5 tasks (T016-T020)
- **US4 (Instructions)**: Integrated in US1-US3 (T009, T010, T015, T020)
- **Setup/Polish**: 9 tasks
- **Parallel Opportunities**: US2 and US3 can run parallel to US1
