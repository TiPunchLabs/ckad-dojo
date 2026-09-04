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

# Current exam (set by load_exam or interactive selection)
CURRENT_EXAM_ID="${CURRENT_EXAM_ID:-}"

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
	local exam_id=$1
	local exam_conf="$EXAMS_DIR/$exam_id/exam.conf"

	if [ ! -f "$exam_conf" ]; then
		print_error "Exam configuration not found: $exam_conf"
		return 1
	fi

	# Source the exam configuration
	source "$exam_conf"

	# Initialize USER_NAMESPACES if not defined (for backward compatibility)
	if [ -z "${USER_NAMESPACES+x}" ]; then
		USER_NAMESPACES=()
	fi

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

# Interactive exam selection menu
# Sets the global SELECTED_EXAM variable
select_exam_interactive() {
	local exams
	IFS=' ' read -r -a exams <<<"$(list_available_exams)"
	local num_exams=${#exams[@]}

	if [ "$num_exams" -eq 0 ]; then
		print_error "No exams found in $EXAMS_DIR"
		exit 1
	fi

	echo ""
	echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
	echo -e "${BLUE}║${NC}                     SELECT AN EXAM                                ${BLUE}║${NC}"
	echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
	echo -e "${BLUE}║${NC}"

	local i=1
	for exam_id in "${exams[@]}"; do
		source "$EXAMS_DIR/$exam_id/exam.conf"
		printf "${BLUE}║${NC}  ${CYAN}%d)${NC} %-20s - %s\n" "$i" "$exam_id" "$EXAM_NAME"
		printf "${BLUE}║${NC}     Duration: %d min | Questions: %d | Points: %d\n" \
			"$EXAM_DURATION" "$TOTAL_QUESTIONS" "$TOTAL_POINTS"
		echo -e "${BLUE}║${NC}"
		((i++))
	done

	echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
	echo ""

	local selection
	while true; do
		read -r -p "Select an exam: " selection
		if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "$num_exams" ]; then
			SELECTED_EXAM="${exams[$((selection - 1))]}"
			break
		else
			echo -e "${RED}Invalid selection. Please enter a valid exam number.${NC}"
		fi
	done

	echo ""
	echo -e "${GREEN}Selected:${NC} $SELECTED_EXAM"
}

# ============================================================================
# ACTIVE EXAM STATE MANAGEMENT
# ============================================================================

# State file for tracking the currently active exam
EXAM_STATE_DIR="${EXAM_STATE_DIR:-/tmp/ckad-dojo}"
EXAM_STATE_FILE="$EXAM_STATE_DIR/active-exam.state"

# Save the active exam ID to state file
# Usage: save_active_exam <exam_id>
save_active_exam() {
	local exam_id=$1
	mkdir -p "$EXAM_STATE_DIR"
	echo "ACTIVE_EXAM_ID=$exam_id" >"$EXAM_STATE_FILE"
	echo "ACTIVE_SINCE=$(date +%s)" >>"$EXAM_STATE_FILE"
}

# Get the active exam ID from state file
# Returns: exam_id if found, empty string otherwise
get_active_exam() {
	if [ -f "$EXAM_STATE_FILE" ]; then
		local exam_id
		exam_id=$(grep "^ACTIVE_EXAM_ID=" "$EXAM_STATE_FILE" 2>/dev/null | cut -d= -f2)
		if [ -n "$exam_id" ] && exam_exists "$exam_id"; then
			echo "$exam_id"
			return 0
		fi
	fi
	echo ""
	return 1
}

# Clear the active exam state
clear_active_exam() {
	rm -f "$EXAM_STATE_FILE"
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

# Attempt to enable metrics-server if the cluster does not already expose the
# metrics.k8s.io API. This is intentionally best-effort and non-fatal.
ensure_metrics_server() {
	if ! command_exists kubectl; then
		echo -e "${YELLOW}[WARN]${NC} kubectl is required to enable metrics-server."
		return 1
	fi

	if ! kubectl cluster-info &>/dev/null; then
		echo -e "${YELLOW}[WARN]${NC} Kubernetes cluster is not reachable, so metrics-server could not be enabled."
		return 1
	fi

	if kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes &>/dev/null; then
		return 0
	fi

	if command_exists minikube && minikube status &>/dev/null; then
		echo -e "${YELLOW}[INFO]${NC} Enabling metrics-server for minikube..."
		minikube addons enable metrics-server >/dev/null 2>&1 || true
	else
		echo -e "${YELLOW}[INFO]${NC} Installing metrics-server from the upstream manifest..."
		kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null 2>&1 || true
	fi

	local retry_count="${CKAD_METRICS_SERVER_RETRY_SECONDS:-30}"
	local retry_interval="${CKAD_METRICS_SERVER_RETRY_INTERVAL:-2}"

	for _ in $(seq 1 "$retry_count"); do
		if kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes &>/dev/null; then
			print_success "metrics-server is available"
			return 0
		fi
		if [ "$retry_interval" -gt 0 ]; then
			sleep "$retry_interval"
		fi
	done

	echo -e "${YELLOW}[WARN]${NC} metrics-server could not be enabled on this cluster; some metric-based questions may show errors or <unknown>."
	return 1
}

# Check prerequisites
# Usage: check_prerequisites [--verbose]
# --verbose: show each check result (success/fail) instead of failing at first error
check_prerequisites() {
	local verbose=false
	if [ "${1:-}" = "--verbose" ]; then
		verbose=true
	fi

	local errors=0

	# Check kubectl
	if command_exists kubectl; then
		if $verbose; then print_success "kubectl found"; fi
	else
		if $verbose; then print_fail "kubectl not found"; else print_error "kubectl is not installed"; fi
		((errors++))
	fi

	# Check cluster connection (only if kubectl exists)
	if [ $errors -eq 0 ] || $verbose; then
		if kubectl cluster-info &>/dev/null; then
			if $verbose; then print_success "Kubernetes cluster accessible"; fi
		else
			if $verbose; then print_fail "Cannot connect to Kubernetes cluster"; else print_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."; fi
			((errors++))
		fi
	fi

	# Check helm
	if command_exists helm; then
		if $verbose; then print_success "helm found"; fi
	else
		if $verbose; then print_fail "helm not found"; else print_error "helm is not installed"; fi
		((errors++))
	fi

	# Check docker
	if command_exists docker; then
		if $verbose; then print_success "docker found"; fi
	else
		if $verbose; then print_fail "docker not found"; else print_error "docker is not installed"; fi
		((errors++))
	fi

	# Check Docker daemon is running (only if docker exists)
	if command_exists docker; then
		if docker info &>/dev/null; then
			if $verbose; then print_success "Docker daemon is running"; fi
		else
			if $verbose; then print_fail "Docker daemon is not running"; else print_error "Docker daemon is not running. Start it with: sudo systemctl start docker"; fi
			((errors++))
		fi
	fi

	if ! $verbose && [ $errors -gt 0 ]; then
		return 1
	fi

	return $errors
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

# Supported browsers (in order of preference for auto-detection)
SUPPORTED_BROWSERS="firefox chrome chromium brave chromium-browser google-chrome google-chrome-stable"

# Open a URL with a specific browser or system default
# Usage: open_url_with_browser <url> [browser]
# browser can be: firefox, chrome, chromium, brave, or "default" (uses system default)
# If browser is not specified, uses CKAD_BROWSER env var or "default"
open_url_with_browser() {
	local url="$1"
	local browser="${2:-${CKAD_BROWSER:-default}}"

	# Normalize browser name
	case "$browser" in
	chrome | google-chrome | google-chrome-stable)
		browser="google-chrome"
		;;
	chromium | chromium-browser)
		browser="chromium"
		;;
	firefox | firefox-esr)
		browser="firefox"
		;;
	brave | brave-browser)
		browser="brave-browser"
		;;
	default | "")
		browser="default"
		;;
	esac

	# Open with specific browser or default
	if [ "$browser" = "default" ]; then
		if command_exists xdg-open; then
			xdg-open "$url" 2>/dev/null &
		elif command_exists open; then
			open "$url" 2>/dev/null &
		elif command_exists wslview; then
			wslview "$url" 2>/dev/null &
		else
			return 1
		fi
	else
		# Try the specific browser
		local browser_cmd=""
		case "$browser" in
		firefox)
			for cmd in firefox firefox-esr; do
				if command_exists "$cmd"; then
					browser_cmd="$cmd"
					break
				fi
			done
			;;
		google-chrome)
			for cmd in google-chrome google-chrome-stable chrome; do
				if command_exists "$cmd"; then
					browser_cmd="$cmd"
					break
				fi
			done
			;;
		chromium)
			for cmd in chromium chromium-browser; do
				if command_exists "$cmd"; then
					browser_cmd="$cmd"
					break
				fi
			done
			;;
		brave-browser)
			for cmd in brave-browser brave; do
				if command_exists "$cmd"; then
					browser_cmd="$cmd"
					break
				fi
			done
			;;
		*)
			# Try the browser name directly
			if command_exists "$browser"; then
				browser_cmd="$browser"
			fi
			;;
		esac

		if [ -n "$browser_cmd" ]; then
			"$browser_cmd" "$url" 2>/dev/null &
		else
			print_fail "Browser '$browser' not found. Falling back to system default."
			open_url_with_browser "$url" "default"
			return $?
		fi
	fi
	return 0
}

# Open a URL in the default browser (legacy function for compatibility)
# Usage: open_browser_tab <url>
open_browser_tab() {
	local url="$1"
	open_url_with_browser "$url" "default"
	return $?
}

# Open documentation tabs (Kubernetes and Helm)
# Usage: open_docs_tabs [browser]
open_docs_tabs() {
	local browser="${1:-${CKAD_BROWSER:-default}}"
	local k8s_docs="https://kubernetes.io/docs/home/"
	local helm_docs="https://helm.sh/docs"

	print_section "Opening documentation tabs..."

	if open_url_with_browser "$k8s_docs" "$browser"; then
		print_success "Kubernetes docs: $k8s_docs"
	else
		print_fail "Could not open Kubernetes docs"
	fi

	# Small delay between tabs
	sleep 0.3

	if open_url_with_browser "$helm_docs" "$browser"; then
		print_success "Helm docs: $helm_docs"
	else
		print_fail "Could not open Helm docs"
	fi
}
