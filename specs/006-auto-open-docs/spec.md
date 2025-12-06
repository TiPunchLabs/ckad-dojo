# Feature Spec: Auto-Open Documentation Tabs

## Overview

When launching the CKAD exam simulator, automatically open browser tabs with the official Kubernetes and Helm documentation to simulate the real exam environment where candidates have access to these resources.

## User Story

**As a** CKAD exam candidate
**I want** the documentation tabs to open automatically when I start an exam
**So that** I have quick access to the same resources available during the real CKAD exam

## Requirements

### Functional Requirements

1. **FR1**: When launching the exam in web mode, open two additional browser tabs:
   - https://kubernetes.io/docs/home/ (Kubernetes Documentation)
   - https://helm.sh/docs (Helm Documentation)

2. **FR2**: Documentation tabs should open alongside the exam interface tab

3. **FR3**: Provide a `--no-docs` flag to disable auto-opening documentation tabs

4. **FR4**: Support multiple platforms (Linux with xdg-open, macOS with open)

### Non-Functional Requirements

1. **NFR1**: Tab opening should not block exam startup
2. **NFR2**: Graceful degradation if browser opening fails (warn, don't error)

## Technical Design

### Implementation Location

- Modify `scripts/ckad-exam.sh` to open documentation tabs after launching the web server
- Add helper function `open_docs_tabs()` in `scripts/lib/common.sh`

### Browser Detection

Use platform-appropriate commands:
- **Linux**: `xdg-open`
- **macOS**: `open`
- **WSL**: `wslview` or `cmd.exe /c start`

### Command Line Options

```bash
./scripts/ckad-exam.sh web           # Opens exam + docs tabs
./scripts/ckad-exam.sh web --no-docs # Opens exam only
```

## Acceptance Criteria

- [ ] Running `./scripts/ckad-exam.sh web` opens 3 browser tabs (exam + 2 docs)
- [ ] Running `./scripts/ckad-exam.sh web --no-docs` opens only the exam tab
- [ ] Works on Linux (xdg-open) and macOS (open)
- [ ] Exam starts even if browser tab opening fails
