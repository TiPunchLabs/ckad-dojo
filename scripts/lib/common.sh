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
	command -v "$1" &>/dev/null
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

	# Check for docker (required)
	if ! command_exists docker; then
		missing+=("docker")
	fi

	if [ ${#missing[@]} -gt 0 ]; then
		print_error "Missing required tools: ${missing[*]}"
		return 1
	fi

	# Check kubectl connection
	if ! kubectl cluster-info &>/dev/null; then
		print_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
		return 1
	fi

	return 0
}

# Check if namespace exists
namespace_exists() {
	kubectl get namespace "$1" &>/dev/null
}

# Check if resource exists
resource_exists() {
	local type="$1"
	local name="$2"
	local namespace="${3:-default}"
	kubectl get "$type" "$name" -n "$namespace" &>/dev/null
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

# Check if Docker image exists
docker_image_exists() {
	docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^$1$"
}

# ============================================================================
# TTYD WEB TERMINAL FUNCTIONS
# ============================================================================

# ttyd configuration
TTYD_PORT="${TTYD_PORT:-7682}"
TTYD_PID_FILE="/tmp/ckad-dojo-ttyd.pid"

# Check if ttyd is installed
# Returns: 0 if installed, 1 if not
check_ttyd() {
	if ! command_exists ttyd; then
		print_error "ttyd is not installed"
		echo ""
		echo "Install ttyd using one of the following methods:"
		echo ""
		echo "  Ubuntu/Debian:"
		echo "    sudo apt install ttyd"
		echo ""
		echo "  macOS:"
		echo "    brew install ttyd"
		echo ""
		echo "  From binary:"
		echo "    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o ttyd"
		echo "    chmod +x ttyd"
		echo "    sudo mv ttyd /usr/local/bin/"
		echo ""
		return 1
	fi
	return 0
}

# Start ttyd web terminal
# Usage: start_ttyd [port] [working_directory] [exam_id]
start_ttyd() {
	local port="${1:-$TTYD_PORT}"
	local workdir="${2:-$PROJECT_DIR}"
	local exam_id="${3:-}"

	# Check if ttyd is already running
	if [ -f "$TTYD_PID_FILE" ]; then
		local pid
		pid=$(cat "$TTYD_PID_FILE")
		if kill -0 "$pid" 2>/dev/null; then
			print_success "ttyd already running (PID: $pid)"
			return 0
		fi
		rm -f "$TTYD_PID_FILE"
	fi

	# Check if port is in use
	if lsof -i ":$port" &>/dev/null; then
		print_error "Port $port is already in use"
		return 1
	fi

	# Start ttyd with dojo welcome banner
	if [ -n "$exam_id" ] && [ -f "$workdir/scripts/lib/banner.sh" ]; then
		# Show dojo banner before launching interactive shell
		ttyd --port "$port" --writable --cwd "$workdir" \
			bash -c "source scripts/lib/banner.sh && show_dojo_banner '$exam_id'; exec bash" &
	else
		# Fallback: plain bash without banner
		ttyd --port "$port" --writable --cwd "$workdir" bash &
	fi
	local pid=$!
	echo "$pid" >"$TTYD_PID_FILE"

	# Wait for ttyd to start
	sleep 1
	if kill -0 "$pid" 2>/dev/null; then
		print_success "ttyd started on port $port (PID: $pid)"
		return 0
	else
		print_error "Failed to start ttyd"
		rm -f "$TTYD_PID_FILE"
		return 1
	fi
}

# Stop ttyd web terminal
stop_ttyd() {
	if [ -f "$TTYD_PID_FILE" ]; then
		local pid
		pid=$(cat "$TTYD_PID_FILE")
		if kill -0 "$pid" 2>/dev/null; then
			kill "$pid" 2>/dev/null
			print_success "ttyd stopped (PID: $pid)"
		fi
		rm -f "$TTYD_PID_FILE"
	fi

	# Also try to kill any stray ttyd processes on our port
	pkill -f "ttyd.*--port.*$TTYD_PORT" 2>/dev/null || true
}

# ============================================================================
# BROWSER HELPER FUNCTIONS
# ============================================================================

# Open a URL in the default browser
# Usage: open_browser_tab <url>
open_browser_tab() {
	local url="$1"

	if command_exists xdg-open; then
		xdg-open "$url" 2>/dev/null &
	elif command_exists open; then
		open "$url" 2>/dev/null &
	elif command_exists wslview; then
		wslview "$url" 2>/dev/null &
	else
		return 1
	fi
	return 0
}

# Open documentation tabs (Kubernetes and Helm)
# Usage: open_docs_tabs
open_docs_tabs() {
	local k8s_docs="https://kubernetes.io/docs/home/"
	local helm_docs="https://helm.sh/docs"

	print_section "Opening documentation tabs..."

	if open_browser_tab "$k8s_docs"; then
		print_success "Kubernetes docs: $k8s_docs"
	else
		print_fail "Could not open Kubernetes docs"
	fi

	# Small delay between tabs
	sleep 0.3

	if open_browser_tab "$helm_docs"; then
		print_success "Helm docs: $helm_docs"
	else
		print_fail "Could not open Helm docs"
	fi
}
