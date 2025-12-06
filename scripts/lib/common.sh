#!/bin/bash
# common.sh - Shared utilities for CKAD Exam Simulator
# This file is sourced by all main scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get the directory where the scripts are located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMS_DIR="$PROJECT_DIR/exams"

# Default exam configuration
DEFAULT_EXAM_ID="ckad-simulation1"
CURRENT_EXAM_ID="${CURRENT_EXAM_ID:-$DEFAULT_EXAM_ID}"

# Legacy paths (for backward compatibility)
MANIFESTS_DIR="$PROJECT_DIR/manifests/setup"
TEMPLATES_DIR="$PROJECT_DIR/templates"
EXAM_DIR="$PROJECT_DIR/exam/course"

# ============================================================================
# EXAM CONFIGURATION FUNCTIONS
# ============================================================================

# Load exam configuration
# Usage: load_exam <exam_id>
load_exam() {
    local exam_id=${1:-$DEFAULT_EXAM_ID}
    local exam_conf="$EXAMS_DIR/$exam_id/exam.conf"

    if [ ! -f "$exam_conf" ]; then
        print_error "Exam configuration not found: $exam_conf"
        return 1
    fi

    # Source the exam configuration
    source "$exam_conf"

    # Set exam-specific paths
    CURRENT_EXAM_ID="$exam_id"
    CURRENT_EXAM_DIR="$EXAMS_DIR/$exam_id"
    CURRENT_MANIFESTS_DIR="$CURRENT_EXAM_DIR/manifests/setup"
    CURRENT_TEMPLATES_DIR="$CURRENT_EXAM_DIR/templates"
    CURRENT_QUESTIONS_FILE="$CURRENT_EXAM_DIR/${QUESTIONS_FILE:-questions.md}"
    CURRENT_SCORING_FILE="$CURRENT_EXAM_DIR/${SCORING_FUNCTIONS:-scoring-functions.sh}"

    # Update legacy paths to point to current exam (for backward compatibility)
    MANIFESTS_DIR="$CURRENT_MANIFESTS_DIR"
    TEMPLATES_DIR="$CURRENT_TEMPLATES_DIR"

    export CURRENT_EXAM_ID CURRENT_EXAM_DIR CURRENT_MANIFESTS_DIR
    export CURRENT_TEMPLATES_DIR CURRENT_QUESTIONS_FILE CURRENT_SCORING_FILE
    export MANIFESTS_DIR TEMPLATES_DIR

    return 0
}

# Get list of available exams
list_available_exams() {
    local exams=()
    for exam_dir in "$EXAMS_DIR"/*/; do
        if [ -d "$exam_dir" ] && [ -f "$exam_dir/exam.conf" ]; then
            exams+=("$(basename "$exam_dir")")
        fi
    done
    echo "${exams[@]}"
}

# Check if exam exists
exam_exists() {
    local exam_id=$1
    [ -d "$EXAMS_DIR/$exam_id" ] && [ -f "$EXAMS_DIR/$exam_id/exam.conf" ]
}

# Print functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                    $1"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
}

print_footer() {
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo -e "\n${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
}

print_skip() {
    echo -e "${YELLOW}○${NC} $1 (skipped)"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check prerequisites
check_prerequisites() {
    local missing=()

    if ! command_exists kubectl; then
        missing+=("kubectl")
    fi

    if ! command_exists helm; then
        missing+=("helm")
    fi

    # Check for docker OR podman (at least one is required)
    if ! command_exists docker && ! command_exists podman; then
        missing+=("docker or podman")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing[*]}"
        return 1
    fi

    # Check kubectl connection
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
        return 1
    fi

    return 0
}

# Check if namespace exists
namespace_exists() {
    kubectl get namespace "$1" &> /dev/null
}

# Check if resource exists
resource_exists() {
    local type="$1"
    local name="$2"
    local namespace="${3:-default}"
    kubectl get "$type" "$name" -n "$namespace" &> /dev/null
}

# Get resource field value
get_resource_field() {
    local type="$1"
    local name="$2"
    local namespace="$3"
    local jsonpath="$4"
    kubectl get "$type" "$name" -n "$namespace" -o jsonpath="$jsonpath" 2>/dev/null
}

# Check if file exists and is not empty
file_exists_and_not_empty() {
    [ -s "$1" ]
}

# Check if file contains string
file_contains() {
    local file="$1"
    local pattern="$2"
    grep -q "$pattern" "$file" 2>/dev/null
}

# Safe apply - creates if not exists, updates if exists
safe_apply() {
    local file="$1"
    if [ -f "$file" ]; then
        kubectl apply -f "$file" 2>/dev/null
        return $?
    else
        print_error "File not found: $file"
        return 1
    fi
}

# Check if Docker container is running
docker_container_running() {
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^$1$"
}

# Check if Podman container is running
podman_container_running() {
    podman ps --format '{{.Names}}' 2>/dev/null | grep -q "^$1$"
}

# Check if Docker image exists
docker_image_exists() {
    docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^$1$"
}

# Check if Podman image exists
podman_image_exists() {
    podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^$1$"
}

# ============================================================================
# TERMINAL FUNCTIONS
# ============================================================================

# Terminal emulators in priority order
TERMINAL_EMULATORS=("terminator" "gnome-terminal" "konsole" "xfce4-terminal" "xterm")

# Detect available terminal emulator
# Returns: terminal name or empty string
detect_terminal() {
    for terminal in "${TERMINAL_EMULATORS[@]}"; do
        if command_exists "$terminal"; then
            echo "$terminal"
            return 0
        fi
    done
    return 1
}

# Open a terminal in the specified directory
# Usage: open_terminal [directory]
open_terminal() {
    local dir="${1:-$PROJECT_DIR}"
    local terminal

    terminal=$(detect_terminal)
    if [ -z "$terminal" ]; then
        print_fail "No terminal emulator found"
        echo "  Checked: ${TERMINAL_EMULATORS[*]}"
        return 1
    fi

    print_success "Opening terminal ($terminal)..."

    case "$terminal" in
        terminator)
            terminator --working-directory="$dir" &
            ;;
        gnome-terminal)
            gnome-terminal --working-directory="$dir" &
            ;;
        konsole)
            konsole --workdir "$dir" &
            ;;
        xfce4-terminal)
            xfce4-terminal --working-directory="$dir" &
            ;;
        xterm)
            (cd "$dir" && xterm) &
            ;;
        *)
            print_fail "Unknown terminal: $terminal"
            return 1
            ;;
    esac

    # Disown the background process to prevent it from being killed
    disown 2>/dev/null || true
    return 0
}
