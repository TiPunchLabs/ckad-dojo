#!/bin/bash
# ckad-cleanup.sh - CKAD Exam Simulator Cleanup Script
# Resets the Kubernetes cluster to pre-exam state

set -e

# Source library functions
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$SCRIPT_LIB_DIR/common.sh"
source "$SCRIPT_LIB_DIR/setup-functions.sh"
source "$SCRIPT_LIB_DIR/timer.sh"

# Show help
show_help() {
	echo "Usage: $(basename "$0") [OPTIONS]"
	echo ""
	echo "Clean up the CKAD Exam Simulator environment."
	echo ""
	echo "OPTIONS:"
	echo "  -h, --help         Show this help message"
	echo "  -e, --exam EXAM    Select exam to clean up (default: $DEFAULT_EXAM_ID)"
	echo "  -y, --yes          Skip confirmation prompt"
	echo "  --keep-registry    Keep the local Docker registry running"
	echo "  --keep-dirs        Keep the exam directory structure"
	echo "  --list             List available exams"
	echo ""
	echo "This script will:"
	echo "  1. Stop any running exam timer"
	echo "  2. Uninstall Helm releases"
	echo "  3. Clean up resources in default namespace"
	echo "  4. Delete all exam namespaces"
	echo "  5. Remove ./exam/course/ directory"
	echo "  6. Stop and remove local Docker registry"
	echo ""
	echo "WARNING: This will delete all exam resources!"
}

# List available exams
list_exams() {
	echo ""
	echo "Available Exams:"
	echo "────────────────────────────────────────────────────────────────"
	for exam_dir in "$EXAMS_DIR"/*/; do
		if [ -d "$exam_dir" ] && [ -f "$exam_dir/exam.conf" ]; then
			source "$exam_dir/exam.conf"
			local exam_id=$(basename "$exam_dir")
			printf "  %-25s %s\n" "$exam_id" "$EXAM_NAME"
		fi
	done
	echo ""
}

# Parse arguments
SKIP_CONFIRM=false
KEEP_REGISTRY=false
KEEP_DIRS=false
SELECTED_EXAM="$DEFAULT_EXAM_ID"

while [[ $# -gt 0 ]]; do
	case $1 in
	-h | --help)
		show_help
		exit 0
		;;
	-e | --exam)
		SELECTED_EXAM="$2"
		shift 2
		;;
	-y | --yes)
		SKIP_CONFIRM=true
		shift
		;;
	--keep-registry)
		KEEP_REGISTRY=true
		shift
		;;
	--keep-dirs)
		KEEP_DIRS=true
		shift
		;;
	--list)
		list_exams
		exit 0
		;;
	*)
		print_error "Unknown option: $1"
		show_help
		exit 1
		;;
	esac
done

# Main cleanup function
main() {
	local start_time=$(date +%s)

	# Load exam configuration
	if ! load_exam "$SELECTED_EXAM"; then
		print_error "Failed to load exam: $SELECTED_EXAM"
		echo "Use --list to see available exams."
		exit 1
	fi

	print_header "CKAD Exam Simulator - Cleanup"
	echo ""
	echo -e "Exam:        ${CYAN}$EXAM_NAME${NC}"
	echo -e "Exam ID:     ${CYAN}$CURRENT_EXAM_ID${NC}"
	echo ""

	# Confirmation prompt
	if [ "$SKIP_CONFIRM" = false ]; then
		echo -e "${YELLOW}WARNING: This will delete all exam resources!${NC}"
		echo ""
		echo "The following will be deleted:"
		echo "  - Resources in default namespace (pods, deployments, services, secrets, configmaps)"
		echo "  - All exam namespaces (${EXAM_NAMESPACES[*]})"
		if [ ${#HELM_RELEASES[@]} -gt 0 ]; then
			echo "  - Helm releases: ${HELM_RELEASES[*]}"
		fi
		if [ "$KEEP_DIRS" = false ]; then
			echo "  - Directory: $EXAM_DIR"
		fi
		if [ "$KEEP_REGISTRY" = false ]; then
			echo "  - Local Docker registry container"
		fi
		echo ""
		read -p "Are you sure you want to continue? [y/N] " -n 1 -r
		echo ""
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			echo "Cleanup cancelled."
			exit 0
		fi
	fi

	# Check if kubectl is available
	if ! command_exists kubectl; then
		print_error "kubectl is not installed"
		exit 1
	fi

	# Step 0: Stop exam timer
	if timer_is_running; then
		print_section "Stopping exam timer..."
		timer_stop
		print_success "Timer stopped"
	fi

	# Step 1: Cleanup Helm releases (before namespace deletion)
	cleanup_helm

	# Step 2: Clean up resources in default namespace
	cleanup_default_namespace

	# Step 3: Delete namespaces
	cleanup_namespaces

	# Step 4: Clean up PersistentVolumes (cluster-scoped)
	cleanup_persistent_volumes

	# Step 5: Clean up custom StorageClasses (cluster-scoped)
	cleanup_storage_classes

	# Step 6: Remove exam directories
	if [ "$KEEP_DIRS" = false ]; then
		cleanup_directories
	else
		print_section "Keeping exam directories (--keep-dirs)"
	fi

	# Step 7: Stop registry
	if [ "$KEEP_REGISTRY" = false ]; then
		cleanup_registry
	else
		print_section "Keeping local registry (--keep-registry)"
	fi

	# Step 8: Clean up exam Docker containers
	cleanup_docker_containers

	# Step 9: Clean up exam Docker images (localhost:5000/*)
	cleanup_docker_images

	# Step 10: Reset timer state
	timer_reset 2>/dev/null || true

	# Wait for namespace deletion
	wait_for_namespace_deletion

	# Summary
	local end_time=$(date +%s)
	local duration=$((end_time - start_time))

	echo ""
	print_footer
	echo ""
	echo -e "${GREEN}Cleanup completed in ${duration}s${NC}"
	echo ""
	echo "To set up the exam environment again, run:"
	echo "  ./scripts/ckad-setup.sh -e $CURRENT_EXAM_ID"
	echo ""
	echo "Or start a new exam session:"
	echo "  ./scripts/ckad-exam.sh start $CURRENT_EXAM_ID"
	echo ""

	return 0
}

# Run main
main
exit $?
