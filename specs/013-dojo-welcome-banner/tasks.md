# Tasks: Dojo Welcome Banner

**Input**: Design documents from `/specs/013-dojo-welcome-banner/`
**Prerequisites**: plan.md, spec.md

**Tests**: No automated tests requested. Manual verification via web interface.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Understand current implementation and prepare for changes

- [x] T001 Review current exam.conf structure in exams/ckad-simulation1/exam.conf
- [x] T002 Review ttyd integration in scripts/ckad-exam.sh

---

## Phase 2: Foundational (Banner Script)

**Purpose**: Create the reusable banner display functionality

**CRITICAL**: This enables the welcome banner to be displayed across all exams

- [x] T003 Create banner.sh library with ASCII art and show_dojo_banner() function in scripts/lib/banner.sh
- [x] T004 Extract ASCII art from ckad_dojo.py and convert to bash format in scripts/lib/banner.sh

**Checkpoint**: After T004, sourcing banner.sh and calling show_dojo_banner should display the ASCII art

---

## Phase 3: User Story 1 - See Personalized Dojo Welcome (Priority: P1)

**Goal**: Users see personalized welcome banner with dojo name when terminal starts

**Independent Test**: Start exam via web interface and verify terminal shows banner with correct dojo name and stats

### Implementation for User Story 1

- [x] T005 [P] [US1] Add DOJO_NAME="Dojo Seiryu" and DOJO_EMOJI="🐉" to exams/ckad-simulation1/exam.conf
- [x] T006 [P] [US1] Add DOJO_NAME="Dojo Suzaku" and DOJO_EMOJI="🔥" to exams/ckad-simulation2/exam.conf
- [x] T007 [P] [US1] Add DOJO_NAME="Dojo Byakko" and DOJO_EMOJI="🐯" to exams/ckad-simulation3/exam.conf
- [x] T008 [P] [US1] Add DOJO_NAME="Dojo Genbu" and DOJO_EMOJI="🐢" to exams/ckad-simulation4/exam.conf
- [x] T009 [US1] Integrate banner display into ttyd startup in scripts/ckad-exam.sh
- [x] T010 [US1] Test ckad-simulation1 shows "Bienvenue au Dojo Seiryu 🐉" with correct stats

**Checkpoint**: User Story 1 complete - all 4 exams display personalized dojo welcome

---

## Phase 4: User Story 2 - Exam Configuration with Dojo Identity (Priority: P2)

**Goal**: Configuration-driven dojo identity for maintainability

**Independent Test**: Verify exam.conf files contain DOJO_NAME and DOJO_EMOJI fields

### Implementation for User Story 2

- [x] T011 [US2] Add fallback defaults in banner.sh for missing DOJO_NAME/DOJO_EMOJI in scripts/lib/banner.sh
- [x] T012 [US2] Verify all 4 exam.conf files have consistent dojo configuration format

**Checkpoint**: User Story 2 complete - graceful fallback if dojo config missing

---

## Phase 5: Polish & Validation

**Purpose**: End-to-end validation across all exams

- [x] T013 Test ckad-simulation1 banner display via web interface
- [x] T014 Test ckad-simulation2 banner display via web interface
- [x] T015 Test ckad-simulation3 banner display via web interface
- [x] T016 Test ckad-simulation4 banner display via web interface
- [x] T017 Verify banner shows correct exam stats (questions, points, duration)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 understanding
- **User Story 1 (Phase 3)**: Depends on Phase 2 (banner.sh must exist)
- **User Story 2 (Phase 4)**: Can run after Phase 2
- **Polish (Phase 5)**: Depends on Phases 3 and 4

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational (banner.sh)
- **User Story 2 (P2)**: Independent - adds fallback handling

### Parallel Opportunities

After Phase 2 (Foundational):
- T005, T006, T007, T008 can all run in parallel (different exam.conf files)

---

## Implementation Strategy

### MVP First (Banner + US1)

1. Complete Phase 1: Setup (understand current code)
2. Complete Phase 2: Create banner.sh with ASCII art
3. Complete Phase 3: Add dojo config and integrate
4. **STOP and VALIDATE**: Test banner in web interface
5. Deploy if ready

### Banner Display Format

```
 ██████╗██╗  ██╗ █████╗ ██████╗        ██████╗  ██████╗      ██╗ ██████╗
██╔════╝██║ ██╔╝██╔══██╗██╔══██╗       ██╔══██╗██╔═══██╗     ██║██╔═══██╗
██║     █████╔╝ ███████║██║  ██║ ████╗ ██║  ██║██║   ██║     ██║██║   ██║
██║     ██╔═██╗ ██╔══██║██║  ██║ ╚═══╝ ██║  ██║██║   ██║██   ██║██║   ██║
╚██████╗██║  ██╗██║  ██║██████╔╝       ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝

        🐉 Bienvenue au Dojo Seiryu 🐉
           22 questions • 113 points • 120 min
```

---

## Notes

- ASCII art reused from ckad_dojo.py (BANNER constant)
- Emojis tested for ttyd compatibility
- Welcome message in French as per user preference
- Exam stats (questions, points, duration) read from exam.conf
