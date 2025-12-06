# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a CKAD (Certified Kubernetes Application Developer) exam preparation repository containing practice questions and solutions. It is designed for studying Kubernetes concepts and practicing for the CKAD certification exam.

## Structure

- `simulation1.md` - Contains 22 practice questions with detailed answers covering CKAD exam topics
- `scorring.md` - Scoring criteria for all questions (113 total points)
- `scripts/` - Automation scripts for the exam simulator
  - `ckad-setup.sh` - Sets up the exam environment
  - `ckad-score.sh` - Scores your answers against all criteria
  - `ckad-cleanup.sh` - Resets the environment for a fresh attempt
  - `lib/` - Shared library functions
- `manifests/setup/` - Kubernetes manifests for pre-existing exam resources
- `templates/` - Template files copied to exam directories during setup
- `web/` - Python web server for exam interface
- `pyproject.toml` - Python project configuration (uses `uv` for execution)

## Usage

```bash
# 1. Setup the exam environment
./scripts/ckad-setup.sh

# 2. Practice exam questions from simulation1.md
#    Save files to ./exam/course/N/ directories

# 3. Check your score
./scripts/ckad-score.sh

# 4. Reset and retry
./scripts/ckad-cleanup.sh
./scripts/ckad-setup.sh
```

### Path Mappings
- Exam `/opt/course/N/` → Use `./exam/course/N/`
- Use local registry at `localhost:5000`

## Topics Covered

The questions cover core CKAD exam domains:
- Namespaces, Pods, Jobs, Deployments
- Helm management
- ServiceAccounts and Secrets
- Probes (Readiness/Liveness)
- Rollouts and rollbacks
- Services (ClusterIP, NodePort)
- Storage (PV, PVC, StorageClass)
- ConfigMaps and Secrets (volume mounts, environment variables)
- Logging sidecars
- InitContainers
- NetworkPolicies
- Resource requests and limits
- Labels and Annotations

## Exam Environment Notes

**Original exam setup:**
- Each question is solved on a specific SSH instance (e.g., `ssh ckad5601`)
- Always `exit` back to main terminal before connecting to a different instance

**Local simulator setup:**
- All questions solved on a single kubeadm cluster (no SSH needed)
- Files saved to `./exam/course/N/` instead of `/opt/course/N/`
- Local registry at `localhost:5000`

**Python environment:**
- Uses `uv` for Python execution (`uv run python ...`)
- No external dependencies (standard library only)
- Install uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Common tips:**
- Use alias: `alias k=kubectl`
- Generate YAML with `kubectl ... --dry-run=client -o yaml`
- Check kubernetes.io/docs for reference (allowed in real exam)

## Active Technologies
- Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend) + kubectl, helm, docker/podman, uv (Python runner) (002-002-ckad-simulation2)
- File-based (YAML manifests, markdown files) (002-002-ckad-simulation2)

## Recent Changes
- 002-002-ckad-simulation2: Added Bash 4.0+ (scripts), Python 3.8+ (web server), JavaScript ES6+ (frontend) + kubectl, helm, docker/podman, uv (Python runner)
