# Quickstart: Web Terminal Integration Testing

## Prerequisites

1. Install ttyd:
   ```bash
   # Ubuntu/Debian
   sudo apt install ttyd

   # macOS
   brew install ttyd

   # Verify installation
   ttyd --version
   ```

2. Ensure existing requirements are met:
   ```bash
   uv --version
   kubectl cluster-info
   ```

## Testing User Story 1: Unified Exam Experience

### Test 1.1: Launch and View

1. Start the exam:
   ```bash
   ./scripts/ckad-exam.sh
   ```

2. Verify:
   - [ ] Browser opens with exam interface
   - [ ] Terminal panel visible on the right side
   - [ ] Question content visible on the left side
   - [ ] Both panels are side by side in split view

### Test 1.2: Execute Commands

1. In the terminal panel, run:
   ```bash
   kubectl get pods -A
   ```

2. Verify:
   - [ ] Command executes successfully
   - [ ] Output displays in terminal
   - [ ] No need to switch windows

### Test 1.3: Session Persistence

1. Navigate to different questions using arrows
2. Return to original question

3. Verify:
   - [ ] Terminal session persists
   - [ ] Command history available (press up arrow)

## Testing User Story 2: Terminal Functionality

### Test 2.1: kubectl Commands

```bash
kubectl get nodes
kubectl get namespaces
kubectl describe pod <any-pod>
```

- [ ] All commands work correctly
- [ ] Output formatting preserved

### Test 2.2: vim/nano Editing

```bash
vim /tmp/test.yaml
# or
nano /tmp/test.yaml
```

- [ ] Editor opens correctly
- [ ] Cursor movement works
- [ ] Can save and exit

### Test 2.3: Tab Completion

```bash
kubectl get <TAB><TAB>
cd ./exa<TAB>
```

- [ ] Bash completion works
- [ ] kubectl completion works (if configured)

### Test 2.4: Control Sequences

- [ ] Ctrl+C interrupts running command
- [ ] Ctrl+D (on empty line) shows exit prompt
- [ ] Ctrl+L clears screen

## Testing User Story 3: Layout Control

### Test 3.1: Resize Panels

1. Drag the divider between panels left/right

2. Verify:
   - [ ] Both panels resize smoothly
   - [ ] Content adapts to new size
   - [ ] Terminal adjusts columns/rows

### Test 3.2: Layout Persistence

1. Resize to preferred layout
2. Navigate between questions

3. Verify:
   - [ ] Layout preference persists
   - [ ] Terminal size maintained

## Testing User Story 4: Graceful Degradation

### Test 4.1: ttyd Not Installed

1. Temporarily rename ttyd:
   ```bash
   sudo mv /usr/bin/ttyd /usr/bin/ttyd.bak
   ```

2. Try to launch exam:
   ```bash
   ./scripts/ckad-exam.sh
   ```

3. Verify:
   - [ ] Clear error message displayed
   - [ ] Installation instructions shown

4. Restore ttyd:
   ```bash
   sudo mv /usr/bin/ttyd.bak /usr/bin/ttyd
   ```

### Test 4.2: Terminal Disconnection

1. Start exam normally
2. Kill ttyd process:
   ```bash
   pkill ttyd
   ```

3. Verify:
   - [ ] "Terminal disconnected" message appears
   - [ ] Reconnect button is shown

## Testing --no-terminal Flag

1. Launch with flag:
   ```bash
   ./scripts/ckad-exam.sh --no-terminal
   ```

2. Verify:
   - [ ] Exam interface shows without terminal panel
   - [ ] Full width for question panel
   - [ ] Message indicating terminal disabled

## Edge Cases

### Multiple Browser Tabs

1. Open exam in two browser tabs
2. Verify:
   - [ ] Both tabs show same terminal (expected ttyd behavior)
   - [ ] Commands typed in one appear in other

### Shell Exit

1. In terminal, type:
   ```bash
   exit
   ```

2. Verify:
   - [ ] Reconnect message or new shell spawns

### Browser Resize

1. Resize browser window
2. Verify:
   - [ ] Layout adapts
   - [ ] Terminal content remains readable
   - [ ] No horizontal scrolling in terminal (rewraps)

## Performance Verification

- [ ] Terminal responds within 1 second of typing
- [ ] No noticeable lag when scrolling output
- [ ] Exam loads within 2 seconds of previous load time
