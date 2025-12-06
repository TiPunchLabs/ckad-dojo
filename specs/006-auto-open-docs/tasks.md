# Tasks: Auto-Open Documentation Tabs

**Input**: spec.md
**Prerequisites**: Existing ckad-exam.sh web mode implementation

## Phase 1: Implementation

- [x] T001 Add open_browser_tab() helper function in scripts/lib/common.sh
- [x] T002 Add open_docs_tabs() function to open K8s and Helm docs in scripts/lib/common.sh
- [x] T003 Add --no-docs flag parsing in scripts/ckad-exam.sh
- [x] T004 Call open_docs_tabs() after web server starts in scripts/ckad-exam.sh
- [x] T005 Update help text with --no-docs option in scripts/ckad-exam.sh

**Checkpoint**: Exam launch opens 3 browser tabs (exam + 2 docs)

---

## Phase 2: Documentation

- [x] T006 [P] Update README.md with --no-docs option
- [x] T007 [P] Update constitution.md with auto-open docs feature

---

## Dependencies

- **Phase 1**: No dependencies
- **Phase 2**: Depends on Phase 1
