# Tasks: Auto-open Terminal on Exam Start

## Phase 1: Implementation

### Task 1.1: Add terminal detection function
- [ ] Create `detect_terminal()` function in `scripts/lib/common.sh`
- [ ] Check terminals in priority order: terminator, gnome-terminal, konsole, xfce4-terminal, xterm
- [ ] Return terminal name or empty string if none found

### Task 1.2: Add terminal launch function
- [ ] Create `open_terminal()` function in `scripts/lib/common.sh`
- [ ] Handle different launch commands per terminal emulator
- [ ] Launch in background (non-blocking)
- [ ] Set working directory to project root

### Task 1.3: Integrate into ckad-exam.sh
- [ ] Add `--no-terminal` option to argument parser
- [ ] Add `NO_TERMINAL` variable
- [ ] Call `open_terminal()` in `start_web()` after user confirmation
- [ ] Display warning if no terminal available

### Task 1.4: Update help text
- [ ] Add `--no-terminal` option to `show_help()` function

## Phase 2: Documentation

### Task 2.1: Update constitution.md
- [ ] Add terminal auto-launch to "Implemented Features" section

### Task 2.2: Update README.md
- [ ] Add `--no-terminal` option to launch options table
- [ ] Document terminal priority order

## Phase 3: Testing

### Task 3.1: Manual testing
- [ ] Test with terminator installed
- [ ] Test fallback to other terminals
- [ ] Test `--no-terminal` flag
- [ ] Test when no terminal available
