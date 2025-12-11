# Feature Specification: Dojo Welcome Banner

**Feature Branch**: `013-dojo-welcome-banner`
**Created**: 2025-12-11
**Status**: Draft
**Input**: Add welcome banner with ASCII art and dojo names in embedded terminal (ttyd)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See Personalized Dojo Welcome (Priority: P1)

When a user starts an exam, the embedded terminal displays a welcome banner with the ASCII art logo and a personalized message showing the dojo name, making the exam experience more immersive and professional.

**Why this priority**: This is the core visual enhancement that creates the dojo atmosphere and provides immediate context about which exam the user is taking.

**Independent Test**: Start any exam via web interface and verify the terminal shows the ASCII banner with the correct dojo name and exam info.

**Acceptance Scenarios**:

1. **Given** user starts ckad-simulation1, **When** the terminal loads, **Then** the banner displays "Bienvenue au Dojo Seiryu" with dragon emoji and exam stats (22 questions, 113 points, 120 min).

2. **Given** user starts ckad-simulation2, **When** the terminal loads, **Then** the banner displays "Bienvenue au Dojo Suzaku" with phoenix emoji and correct exam stats.

3. **Given** user starts ckad-simulation3, **When** the terminal loads, **Then** the banner displays "Bienvenue au Dojo Byakko" with tiger emoji and correct exam stats.

4. **Given** user starts ckad-simulation4, **When** the terminal loads, **Then** the banner displays "Bienvenue au Dojo Genbu" with turtle emoji and correct exam stats.

---

### User Story 2 - Exam Configuration with Dojo Identity (Priority: P2)

Each exam has its own dojo identity defined in configuration, allowing easy customization and consistency across all interfaces.

**Why this priority**: Configuration-driven approach enables maintainability and potential future extensions (new exams, custom themes).

**Independent Test**: Check exam.conf files to verify DOJO_NAME and DOJO_EMOJI fields are present and correctly configured.

**Acceptance Scenarios**:

1. **Given** an exam.conf file, **When** opened, **Then** it contains DOJO_NAME with the guardian name and DOJO_EMOJI with the corresponding symbol.

2. **Given** a new exam is created, **When** the user adds DOJO_NAME and DOJO_EMOJI to exam.conf, **Then** the welcome banner displays the custom dojo identity.

---

### Edge Cases

- What happens if DOJO_NAME is not defined in exam.conf? Display default "CKAD Dojo" with generic emoji.
- What happens if DOJO_EMOJI contains invalid characters? Display without emoji, name only.
- What happens if terminal starts before exam config is loaded? Display generic banner until config available.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the existing ASCII art banner from the CLI at terminal startup
- **FR-002**: System MUST display a personalized welcome message with the dojo name below the banner
- **FR-003**: System MUST show exam statistics (questions count, total points, duration) in the welcome message
- **FR-004**: Each exam.conf MUST contain DOJO_NAME field with the guardian dojo name
- **FR-005**: Each exam.conf MUST contain DOJO_EMOJI field with the corresponding symbol
- **FR-006**: System MUST use default values if dojo configuration is missing (graceful fallback)

### Key Entities

- **Dojo Identity**: Name (Seiryu, Suzaku, Byakko, Genbu), emoji symbol, associated with exam
- **Welcome Banner**: ASCII art logo + dojo welcome message + exam statistics
- **Exam Configuration**: Extended with DOJO_NAME and DOJO_EMOJI fields

### Dojo Mapping (Shishin - Four Guardians)

| Exam ID | Dojo Name | Guardian | Emoji | Direction |
|---------|-----------|----------|-------|-----------|
| ckad-simulation1 | Dojo Seiryu | Dragon Azure | dragon | Est |
| ckad-simulation2 | Dojo Suzaku | Phoenix Vermillon | fire | Sud |
| ckad-simulation3 | Dojo Byakko | Tigre Blanc | tiger | Ouest |
| ckad-simulation4 | Dojo Genbu | Tortue Noire | turtle | Nord |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of exam terminals display the welcome banner with correct dojo name on startup
- **SC-002**: Users can identify which exam they are in within 2 seconds of terminal load
- **SC-003**: All 4 existing exams have unique dojo identities configured
- **SC-004**: Banner displays exam stats accurately matching exam.conf values

## Assumptions

- The ASCII art banner from ckad_dojo.py will be reused as-is
- Emojis are supported in the terminal environment (ttyd)
- The welcome message language is French ("Bienvenue au...")
- Terminal initialization script has access to exam configuration
