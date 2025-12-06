# Research: Web Terminal Integration

## Decision Summary

| Topic | Decision | Rationale |
|-------|----------|-----------|
| Terminal Backend | ttyd | Single binary, no runtime dependencies, active maintenance |
| Integration Method | iframe | Simple, isolated, no additional JS libraries needed |
| Layout | Flexbox + drag resize | Native CSS, works with existing codebase |

## Web Terminal Options Evaluated

### 1. ttyd (CHOSEN)

**What it is**: A simple command-line tool for sharing terminal over the web.

**Pros**:
- Single binary (written in C with libwebsockets)
- No runtime dependencies (Node.js, Python packages, etc.)
- Very lightweight (~500KB binary)
- Active maintenance (last release 2024)
- Built-in xterm.js frontend
- Supports full terminal emulation (ANSI, 256 colors, etc.)
- Easy to start/stop via command line

**Cons**:
- Must be installed separately (not Python-native)
- Runs on separate port

**Installation**:
```bash
# Ubuntu/Debian
sudo apt install ttyd

# macOS
brew install ttyd

# From binary
curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o ttyd
chmod +x ttyd
```

### 2. xterm.js (NOT CHOSEN)

**What it is**: JavaScript terminal emulator library.

**Why rejected**:
- Requires a backend (node-pty, Python websocket server)
- Would need to implement WebSocket server in Python
- More complex integration
- Need to bundle xterm.js in the project

### 3. wetty (NOT CHOSEN)

**What it is**: Terminal over HTTP using Node.js.

**Why rejected**:
- Requires Node.js runtime
- More complex setup
- Overkill for local-only use

### 4. gotty (NOT CHOSEN)

**What it is**: Share terminal as web application (Go).

**Why rejected**:
- Less actively maintained than ttyd
- Similar feature set but fewer options
- ttyd has better documentation

## Integration Approach

### iframe vs Direct Integration

**Decision**: Use iframe

**Rationale**:
1. **Isolation**: Terminal runs in isolated context, no interference with exam UI
2. **Simplicity**: No need to integrate xterm.js directly
3. **Reliability**: ttyd's built-in frontend is well-tested
4. **Maintenance**: Updates to ttyd automatically include frontend improvements

**Implementation**:
```html
<iframe id="terminal-frame" src="http://localhost:7681"></iframe>
```

### Port Strategy

| Service | Port | Configurable |
|---------|------|--------------|
| Exam UI (Python) | 9090 | Yes (--port) |
| Terminal (ttyd) | 7681 | Yes (--terminal-port) |

**Note**: ttyd's default port is 7681. We keep this to avoid confusion.

## Process Management

### Startup Order

1. Check ttyd is installed (`which ttyd`)
2. Start ttyd in background
3. Start Python server
4. Open browser

### Shutdown

1. Kill Python server (existing code)
2. Kill ttyd by PID or `pkill -f "ttyd.*7681"`

### PID File Management

```bash
TTYD_PID_FILE="/tmp/ckad-dojo-ttyd.pid"

start_ttyd() {
    ttyd --port 7681 --writable bash &
    echo $! > "$TTYD_PID_FILE"
}

stop_ttyd() {
    if [ -f "$TTYD_PID_FILE" ]; then
        kill "$(cat "$TTYD_PID_FILE")" 2>/dev/null
        rm -f "$TTYD_PID_FILE"
    fi
}
```

## UI Layout Design

### Split Layout

```
┌─────────────────────────────────────────────────┐
│ Header (timer, navigation, theme toggle)        │
├───────────────────────┬─────────────────────────┤
│ Question Panel (50%)  │ Terminal Panel (50%)    │
│                       │                         │
│ - Question content    │ - ttyd iframe           │
│ - Metadata            │ - Connection status     │
│ - Navigation          │ - Reconnect button      │
├───────────────────────┴─────────────────────────┤
│ Footer (flag, stop exam)                        │
└─────────────────────────────────────────────────┘
```

### Resizable Divider

Use a draggable divider between panels:
- Minimum panel width: 20%
- Maximum panel width: 80%
- Store preference in localStorage

### CSS Implementation

```css
.exam-split {
    display: flex;
    flex: 1;
}

.question-panel {
    flex: 1;
    min-width: 20%;
    overflow: auto;
}

.terminal-panel {
    flex: 1;
    min-width: 20%;
    position: relative;
}

.split-divider {
    width: 6px;
    background: var(--border-color);
    cursor: col-resize;
}
```

## Error Handling

### Terminal Disconnection

1. Monitor iframe load status
2. Show overlay on connection loss
3. Provide reconnect button
4. Auto-reconnect after 3 seconds

### ttyd Not Installed

```bash
if ! command -v ttyd &> /dev/null; then
    echo "Error: ttyd is not installed"
    echo "Install with: sudo apt install ttyd"
    echo "Or download from: https://github.com/tsl0922/ttyd/releases"
    exit 1
fi
```
