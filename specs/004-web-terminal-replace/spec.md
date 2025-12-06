# Feature Specification: Web Terminal Integration

**Feature Branch**: `004-web-terminal-replace`
**Created**: 2025-12-06
**Status**: Draft
**Input**: User description: "Replace auto-open terminal with embedded web terminal using ttyd"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Exam Experience (Priority: P1)

As a CKAD exam practitioner, I want to have both the exam questions and the terminal in the same browser window so that I don't need to switch between windows and can focus on the exam.

**Why this priority**: This is the core value proposition - providing a seamless, integrated exam experience that mirrors the real CKAD exam environment where questions and terminal are visible together.

**Independent Test**: Can be fully tested by launching the exam, seeing both the question panel and terminal in the same interface, and executing kubectl commands directly in the embedded terminal.

**Acceptance Scenarios**:

1. **Given** the user launches the exam with `./scripts/ckad-exam.sh`, **When** the browser opens, **Then** both the exam questions and an interactive terminal are visible in the same window.
2. **Given** the user is viewing a question, **When** they type a kubectl command in the terminal, **Then** the command executes and output is displayed without leaving the exam interface.
3. **Given** the user is in the exam, **When** they navigate between questions, **Then** the terminal session persists and previous command history remains available.

---

### User Story 2 - Terminal Functionality (Priority: P1)

As a user, I want the embedded terminal to function like a real terminal so that I can use all kubectl, helm, and bash commands required for the exam.

**Why this priority**: Equal priority with Story 1 - a non-functional terminal would make the entire feature useless.

**Independent Test**: Can be tested by executing complex commands like `kubectl apply`, piping commands, using vim/nano editors, and verifying output is correctly displayed.

**Acceptance Scenarios**:

1. **Given** the terminal is displayed, **When** I run `kubectl get pods -A`, **Then** I see the correct output with proper formatting.
2. **Given** the terminal is active, **When** I use vim to edit a YAML file, **Then** vim displays correctly with syntax highlighting and cursor movement.
3. **Given** the terminal is active, **When** I use tab completion, **Then** bash completion works for commands, file paths, and kubectl resources.
4. **Given** the terminal is active, **When** I press Ctrl+C, Ctrl+D, or other control sequences, **Then** they are correctly transmitted and executed.

---

### User Story 3 - Layout Control (Priority: P2)

As a user, I want to control the layout between questions and terminal so that I can adjust the view based on my preferences.

**Why this priority**: Enhances usability but exam can still be completed with a fixed layout.

**Independent Test**: Can be tested by resizing the terminal panel and verifying both panels remain usable.

**Acceptance Scenarios**:

1. **Given** the exam interface is displayed, **When** I drag the divider between questions and terminal, **Then** the panels resize accordingly.
2. **Given** I have resized the layout, **When** I navigate to another question, **Then** the layout preference persists.

---

### User Story 4 - Graceful Degradation (Priority: P3)

As a user, I want clear feedback if the terminal component fails to load so that I can troubleshoot or use an alternative.

**Why this priority**: Important for user experience but failure should be rare.

**Independent Test**: Can be tested by simulating ttyd failure and verifying appropriate error message is shown.

**Acceptance Scenarios**:

1. **Given** ttyd is not installed, **When** I launch the exam, **Then** I see a clear error message with installation instructions.
2. **Given** ttyd crashes during the exam, **When** the connection is lost, **Then** the interface shows "Terminal disconnected" with a reconnect button.

---

### Edge Cases

- What happens when the user opens multiple browser tabs? Each tab shares the same terminal session (ttyd limitation).
- How does the system handle terminal resize when the browser window is resized? The terminal adapts dynamically via WebSocket resize events.
- What happens if the user's shell exits (e.g., types `exit`)? The terminal shows a reconnect message.
- How does the system handle slow network connections? Since this is localhost-only, latency is not a concern.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST embed an interactive terminal in the exam web interface alongside the question panel.
- **FR-002**: System MUST use ttyd as the terminal backend for WebSocket-based terminal access.
- **FR-003**: Terminal MUST support full ANSI escape sequences for colors, cursor movement, and terminal applications (vim, less, etc.).
- **FR-004**: Terminal MUST persist across question navigation (same shell session throughout the exam).
- **FR-005**: System MUST start ttyd automatically when launching the exam web interface.
- **FR-006**: System MUST stop ttyd when the exam is stopped or the server is shut down.
- **FR-007**: Terminal MUST start in the project directory (`$PROJECT_DIR`).
- **FR-008**: System MUST display clear error messages if ttyd is not installed, with installation instructions.
- **FR-009**: The `--no-terminal` flag MUST disable the embedded terminal panel (for users who prefer external terminal).
- **FR-010**: System MUST provide a resizable split layout between questions and terminal.
- **FR-011**: System MUST detect terminal disconnection and offer reconnection.

### Key Entities

- **Terminal Session**: The active shell instance running via ttyd, identified by the ttyd process.
- **Split Layout**: The UI component managing the division between question panel and terminal panel.
- **ttyd Process**: Background process serving the terminal over WebSocket.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can execute kubectl commands within 1 second of typing (no perceptible delay).
- **SC-002**: Terminal supports all standard exam operations (kubectl, helm, vim, cat, grep, etc.) without functionality loss.
- **SC-003**: 100% of users can complete the exam without needing to open an external terminal.
- **SC-004**: Terminal session persists for the entire exam duration (up to 120 minutes) without disconnection under normal conditions.
- **SC-005**: Initial exam load time increases by no more than 2 seconds compared to the current implementation.

## Assumptions

- **A-001**: ttyd can be installed as a single binary without additional dependencies on the target system.
- **A-002**: Users have access to install ttyd or it can be bundled/downloaded automatically.
- **A-003**: The default terminal size is acceptable, with dynamic resize support.
- **A-004**: A single terminal session per exam is sufficient (no multiple terminals needed).
- **A-005**: ttyd's default port (7681) can be used, or the port can be configured if 7681 is unavailable.

## Out of Scope

- Multiple terminal tabs/windows within the interface
- Terminal session recording or replay
- Remote terminal access (terminal is only accessible locally)
- Custom shell configuration (uses user's default shell)
