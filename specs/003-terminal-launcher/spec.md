# Feature: Auto-open Terminal on Exam Start

## Summary

When the user confirms to start the exam (by pressing "y"), the system should automatically open a terminal emulator in the project directory, in addition to launching the web interface. This provides a better exam experience by having both the questions and a ready-to-use terminal side by side.

## User Story

As a CKAD exam practitioner, I want a terminal to automatically open when I start the exam, so that I can immediately begin working on questions without manually opening and navigating to the correct directory.

## Requirements

### Functional Requirements

1. **Terminal Detection**: The system MUST detect available terminal emulators in priority order:
   - `terminator` (preferred)
   - `gnome-terminal`
   - `konsole`
   - `xfce4-terminal`
   - `xterm` (fallback)

2. **Terminal Launch**: When the user confirms exam start with "y":
   - Open the detected terminal emulator
   - Set the working directory to `$PROJECT_DIR`
   - Terminal should open in the background (non-blocking)

3. **Graceful Fallback**: If no terminal emulator is found:
   - Display a warning message
   - Continue with web interface launch
   - Do NOT block the exam start

4. **Option to Disable**: Add `--no-terminal` flag to skip terminal launch

### Non-Functional Requirements

1. Terminal opening MUST be non-blocking (exam web server must still start)
2. Terminal detection MUST be fast (< 1 second)
3. MUST work on Linux systems (primary target platform)

## Technical Design

### Terminal Detection Order

```bash
TERMINALS=("terminator" "gnome-terminal" "konsole" "xfce4-terminal" "xterm")
```

### Launch Commands

| Terminal | Command |
|----------|---------|
| terminator | `terminator --working-directory="$dir"` |
| gnome-terminal | `gnome-terminal --working-directory="$dir"` |
| konsole | `konsole --workdir "$dir"` |
| xfce4-terminal | `xfce4-terminal --working-directory="$dir"` |
| xterm | `cd "$dir" && xterm` |

### Integration Point

Function `open_terminal()` called in `start_web()` after user confirmation, before web server launch.

## Acceptance Criteria

- [ ] Terminal opens automatically when user presses "y" to start exam
- [ ] terminator is used if available
- [ ] Falls back to other terminals if terminator not available
- [ ] Warning displayed if no terminal found
- [ ] `--no-terminal` flag skips terminal launch
- [ ] Web server still starts regardless of terminal status
- [ ] Terminal opens in project directory
