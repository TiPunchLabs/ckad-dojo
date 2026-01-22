# Implementation Plan: Web Terminal Integration

**Branch**: `004-web-terminal-replace` | **Date**: 2025-12-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-web-terminal-replace/spec.md`

## Summary

Replace the auto-open external terminal (terminator, gnome-terminal, etc.) with an embedded web terminal using ttyd. The terminal will be displayed alongside the exam questions in a resizable split layout, providing a unified exam experience similar to the real CKAD exam environment.

## Technical Context

**Language/Version**: Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend)
**Primary Dependencies**: ttyd (external binary for web terminal), existing libs (marked.js, highlight.js)
**Storage**: N/A
**Testing**: Manual testing via `./tests/run-tests.sh`, browser-based verification
**Target Platform**: Linux (primary), macOS (compatible)
**Project Type**: Web application (frontend + bash scripts)
**Performance Goals**: Terminal response within 1 second, no perceptible lag
**Constraints**: ttyd must be installed separately, localhost-only access
**Scale/Scope**: Single user per exam session

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Script-First Automation | ✅ PASS | ttyd is started/stopped via bash scripts |
| II. Kubernetes-Native Tooling | ✅ PASS | ttyd is for UI only, not K8s operations |
| III. Automated Scoring | ✅ N/A | No impact on scoring system |
| IV. Exam Fidelity | ✅ PASS | Improves fidelity - matches real CKAD split screen |
| V. Idempotent Operations | ✅ PASS | ttyd start/stop is idempotent |
| VI. Modern UI | ✅ PASS | Enhances web interface with integrated terminal |

**Gate Result**: PASS - No violations. Feature aligns with all constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/004-web-terminal-replace/
├── plan.md              # This file
├── research.md          # ttyd research and integration notes
├── quickstart.md        # Testing instructions
└── tasks.md             # Implementation tasks
```

### Source Code (repository root)

```text
ckad-dojo/
├── scripts/
│   ├── ckad-exam.sh           # MODIFY: Start/stop ttyd, remove open_terminal
│   └── lib/
│       └── common.sh          # MODIFY: Add ttyd functions, update detect_terminal
├── web/
│   ├── server.py              # MODIFY: Add ttyd status endpoint
│   ├── index.html             # MODIFY: Add terminal iframe and split layout
│   ├── css/style.css          # MODIFY: Add split layout styles
│   └── js/app.js              # MODIFY: Terminal connection handling
└── tests/
    └── test-common.sh         # MODIFY: Add ttyd function tests
```

**Structure Decision**: Extends existing web application structure. No new directories needed. ttyd serves terminal on separate port (7681), embedded via iframe in the main interface.

## Complexity Tracking

No complexity violations - feature uses simple integration pattern (iframe embedding).

## Implementation Approach

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Browser Window                        │
├─────────────────────────┬───────────────────────────────┤
│                         │                               │
│   Question Panel        │   Terminal Panel              │
│   (existing UI)         │   (iframe → ttyd:7681)        │
│                         │                               │
│   ← Resizable divider → │                               │
│                         │                               │
├─────────────────────────┴───────────────────────────────┤
│                    Header (timer, nav)                   │
└─────────────────────────────────────────────────────────┘

Processes:
- Python server (port 9090) - serves exam UI
- ttyd (port 7681) - serves terminal via WebSocket
```

### Key Integration Points

1. **Startup Sequence** (ckad-exam.sh):
   - Check ttyd is installed
   - Start ttyd on port 7681 with bash shell
   - Start Python server on port 9090
   - Open browser to localhost:9090
   - ttyd iframe auto-connects in browser

2. **Shutdown Sequence**:
   - Kill ttyd process (by PID file or pkill)
   - Kill Python server
   - Clean exit

3. **UI Integration**:
   - Add resizable split layout (CSS flexbox + JavaScript drag)
   - Left panel: existing question content
   - Right panel: iframe pointing to ttyd
   - Handle terminal disconnection with overlay message

### ttyd Configuration

```bash
ttyd --port 7681 \
     --writable \
     --cwd "$PROJECT_DIR" \
     bash
```

Options:

- `--port 7681`: Default ttyd port (configurable via --terminal-port)
- `--writable`: Allow input to the terminal
- `--cwd`: Set working directory to project root
- `bash`: Shell to run

## Dependencies

### External (must be installed)

| Dependency | Version | Installation |
|------------|---------|--------------|
| ttyd | 1.7.0+ | `apt install ttyd` or download binary from GitHub |

### Internal (existing)

- Python 3.8+ (already required)
- Modern browser with WebSocket support (already required)
