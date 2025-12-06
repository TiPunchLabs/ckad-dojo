# Quickstart: CKAD Exam Simulator

## Prerequisites

Verify you have all required tools:

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Check kubectl
kubectl version --client

# Check Helm
helm version

# Check Docker
docker --version

# Check Podman
podman --version

# Check uv
uv --version

# Verify cluster connection
kubectl cluster-info
```

## Quick Start (Recommended)

The easiest way to start an exam session with the **web interface**:

```bash
# From the ckad-dojo directory
cd /path/to/ckad-dojo

# Start an exam session with web interface (default)
./scripts/ckad-exam.sh

# Or explicitly:
./scripts/ckad-exam.sh web
```

This will:
1. Verify all prerequisites
2. Set up the exam environment (if not already done)
3. Launch a local web server at `http://localhost:9090`
4. Open the exam interface in your browser
5. Display the exam selection screen

### Terminal-Only Mode

If you prefer a terminal-only experience without the web interface:

```bash
./scripts/ckad-exam.sh start
```

This will start a 120-minute countdown timer in the terminal.

## Manual Setup

If you prefer to set up manually without the timer:

```bash
# Run the setup script
./scripts/ckad-setup.sh

# Or for a specific exam
./scripts/ckad-setup.sh -e ckad-simulation1
```

The setup will:
1. Create 11 namespaces (neptune, saturn, earth, mars, pluto, jupiter, mercury, venus, moon, sun, shell-intern)
2. Deploy pre-existing resources for questions that require them
3. Install Helm releases in mercury namespace for Q4
4. Start a local Docker registry at `localhost:5000` for Q11
5. Create directory structure `./exam/course/1/` through `./exam/course/22/` plus `p1/`, `p2/`
6. Place template files in appropriate directories

## Take the Exam

### With Web Interface (Recommended)

```bash
# Launch web interface
./scripts/ckad-exam.sh web
```

The web interface provides:
- **120-minute countdown timer** - Visual timer with color warnings (yellow at 15 min, orange at 5 min, red at 1 min)
- **Question navigation** - Arrow keys, dropdown selector, or question dots
- **Flag for review** - Mark questions to revisit (keyboard: F)
- **Question metadata** - Points, namespace, resources, files displayed
- **Dark/Light theme** - Toggle with button in header
- **Time's up notification** - Interface blocks when timer reaches 0

#### Web Interface Keyboard Shortcuts

| Key | Action |
|-----|--------|
| ← / → | Previous / Next question |
| F | Flag/unflag current question |

#### Stop Exam and View Score

Click the **Stop Exam** button (red) in the footer to:
1. Confirm you want to end the exam
2. Stop the timer
3. Calculate your score automatically
4. View detailed results in a modal:
   - Overall percentage and points
   - Pass/fail status (66% threshold)
   - Elapsed time
   - Per-question breakdown with pass/fail indicators

### With Terminal Timer

```bash
# Start exam with terminal timer
./scripts/ckad-exam.sh start

# In another terminal, watch the countdown
./scripts/ckad-exam.sh timer

# Check exam status at any time
./scripts/ckad-exam.sh status
```

### Without Timer (Practice Mode)

1. Open `exams/ckad-simulation1/questions.md` to read the questions
2. Work through questions in order (or any order you prefer)
3. Save your answers:
   - Create Kubernetes resources with `kubectl`
   - Save files to `./exam/course/N/` directories as instructed

**Important paths mapping:**
- Exam says `/opt/course/1/` → Use `./exam/course/1/`
- Exam says `/opt/course/11/image/` → Use `./exam/course/11/image/`

**Q11 Registry mapping:**
- Use local registry at `localhost:5000`

Example for Q11:
```bash
# Build with Docker
docker build -t localhost:5000/sun-cipher:v1-docker ./exam/course/11/image/
docker push localhost:5000/sun-cipher:v1-docker

# Build with Podman
podman build -t localhost:5000/sun-cipher:v1-podman ./exam/course/11/image/
podman push localhost:5000/sun-cipher:v1-podman --tls-verify=false
```

## Exam Commands

```bash
# Launch web interface (default)
./scripts/ckad-exam.sh

# List available exams
./scripts/ckad-exam.sh list

# Start terminal-only mode
./scripts/ckad-exam.sh start

# Watch the countdown timer (terminal)
./scripts/ckad-exam.sh timer

# Check current status
./scripts/ckad-exam.sh status

# Stop the exam early
./scripts/ckad-exam.sh stop
```

## Check Your Score

```bash
# Score all questions
./scripts/ckad-score.sh

# Score a specific question
./scripts/ckad-score.sh -q 5
```

**Expected output:**
```
═══════════════════════════════════════════════════════════════════
                           SCORE SUMMARY
═══════════════════════════════════════════════════════════════════

Question Score        Topic
-------- --------     -----------------------------
Q1       1/1          Namespaces
Q2       5/5          Pods
Q3       6/6          Job
...

═══════════════════════════════════════════════════════════════════

TOTAL SCORE: 87 / 113 (77%)

PASS - Congratulations!
```

## Reset and Retry

To start fresh:

```bash
./scripts/ckad-cleanup.sh
./scripts/ckad-setup.sh
```

Or use the exam launcher:
```bash
./scripts/ckad-exam.sh stop
./scripts/ckad-cleanup.sh -y
./scripts/ckad-exam.sh start
```

The cleanup will:
1. Stop any running timer
2. Delete all exam namespaces
3. Uninstall Helm releases
4. Stop and remove local registry
5. Remove `./exam/course/` directory

## Multi-Exam Support

List available exams:
```bash
./scripts/ckad-exam.sh list
# Or
./scripts/ckad-setup.sh --list
```

Work with a specific exam:
```bash
# Setup specific exam
./scripts/ckad-setup.sh -e ckad-simulation1

# Start specific exam
./scripts/ckad-exam.sh start ckad-simulation1

# Score specific exam
./scripts/ckad-score.sh -e ckad-simulation1

# Cleanup specific exam
./scripts/ckad-cleanup.sh -e ckad-simulation1
```

## Project Structure

```
ckad-dojo/
├── scripts/
│   ├── ckad-exam.sh          # Exam launcher (web + terminal)
│   ├── ckad-setup.sh         # Environment setup
│   ├── ckad-score.sh         # Answer scoring
│   ├── ckad-cleanup.sh       # Environment cleanup
│   └── lib/
│       ├── common.sh         # Shared utilities
│       ├── setup-functions.sh
│       ├── scoring-functions.sh
│       └── timer.sh          # Timer functionality
├── web/                      # Web interface
│   ├── server.py             # Python web server with API
│   ├── index.html            # Main HTML interface
│   ├── css/
│   │   └── style.css         # Modern styles (dark/light themes)
│   └── js/
│       └── app.js            # JavaScript application logic
├── exams/
│   └── ckad-simulation1/     # Exam-specific files
│       ├── exam.conf         # Exam configuration
│       ├── questions.md      # Questions (no answers)
│       ├── scoring-functions.sh
│       ├── manifests/setup/  # Pre-existing resources
│       └── templates/        # Template files for questions
├── manifests/setup/          # Legacy location (symlinked)
├── templates/                # Legacy location (symlinked)
├── exam/course/              # Created by setup (answer files go here)
└── simulation1.md            # Original questions with answers
```

## Troubleshooting

### Setup fails with "namespace already exists"
This is normal if re-running. The script is idempotent - it will skip existing resources.

### Web interface not loading
Ensure uv is installed and port 9090 is available:
```bash
uv --version
lsof -i :9090  # Check if port is in use
```

Use `--port` to specify an alternative port:
```bash
./scripts/ckad-exam.sh web --port 8888
```

### Timer not showing (terminal mode)
Make sure the exam was started with `./scripts/ckad-exam.sh start`. Run `./scripts/ckad-exam.sh status` to check.

### Q4 Helm commands fail
Ensure the Helm repo is configured:
```bash
helm repo list
# Should show: bitnami https://charts.bitnami.com/bitnami
```

### Q11 push fails
Check registry is running:
```bash
docker ps | grep registry
# Should show registry:2 container on port 5000
```

For Podman, use `--tls-verify=false`:
```bash
podman push localhost:5000/sun-cipher:v1-podman --tls-verify=false
```

### Scoring shows 0 for completed questions
Verify:
1. Resources are in the correct namespace
2. File paths match exactly `./exam/course/N/filename`
3. Resource names match exam requirements

## Tips

1. **Use aliases** - Set `alias k=kubectl` like in the real exam
2. **Use dry-run** - Generate YAML with `kubectl ... --dry-run=client -o yaml`
3. **Check the docs** - kubernetes.io/docs is available in real exam
4. **Verify before moving on** - Run scoring after each question to verify
5. **Use the web interface** - The integrated timer with visual warnings helps manage time
6. **Flag difficult questions** - Use the flag feature to mark questions for later review
7. **Practice under time pressure** - The 120-minute timer simulates real exam conditions
8. **Toggle dark/light mode** - Use the theme that's most comfortable for you
9. **Use Stop Exam** - Click "Stop Exam" to end early and see your detailed score breakdown
