#!/bin/bash
# ckad-setup.sh - CKAD Exam Simulator Setup Script
# Sets up the Kubernetes cluster with all pre-requisites for exam questions

set -e

# Source library functions
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$SCRIPT_LIB_DIR/common.sh"
source "$SCRIPT_LIB_DIR/setup-functions.sh"

# Show help
show_help() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Set up the CKAD Exam Simulator environment."
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help         Show this help message"
    echo "  -e, --exam EXAM    Select exam to set up (default: $DEFAULT_EXAM_ID)"
    echo "  -q, --quiet        Suppress non-essential output"
    echo "  --skip-registry    Skip local Docker registry setup"
    echo "  --list             List available exams"
    echo ""
    echo "This script will:"
    echo "  1. Create exam namespaces"
    echo "  2. Deploy pre-existing resources for exam questions"
    echo "  3. Create exam directory structure at ./exam/course/"
    echo "  4. Copy template files to exam directories"
    echo "  5. Start local Docker registry at localhost:5000"
    echo "  6. Configure Helm releases"
    echo ""
    echo "The script is idempotent - safe to run multiple times."
    echo ""
    echo "EXAMPLES:"
    echo "  $(basename "$0")                          # Setup default exam"
    echo "  $(basename "$0") -e ckad-simulation1      # Setup specific exam"
    echo "  $(basename "$0") --list                   # List available exams"
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
            printf "    Duration: %d min | Questions: %d | Points: %d\n" \
                "$EXAM_DURATION" "$TOTAL_QUESTIONS" "$TOTAL_POINTS"
        fi
    done
    echo ""
}

# Parse arguments
QUIET=false
SKIP_REGISTRY=false
SELECTED_EXAM="$DEFAULT_EXAM_ID"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -e|--exam)
            SELECTED_EXAM="$2"
            shift 2
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --skip-registry)
            SKIP_REGISTRY=true
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

# Main setup function
main() {
    local errors=0
    local start_time=$(date +%s)

    # Load exam configuration
    if ! load_exam "$SELECTED_EXAM"; then
        print_error "Failed to load exam: $SELECTED_EXAM"
        echo "Use --list to see available exams."
        exit 1
    fi

    print_header "CKAD Exam Simulator - Setup"
    echo ""
    echo -e "Exam:        ${CYAN}$EXAM_NAME${NC}"
    echo -e "Exam ID:     ${CYAN}$CURRENT_EXAM_ID${NC}"
    echo "Exam directory: $EXAM_DIR"
    echo "Manifests: $CURRENT_MANIFESTS_DIR"
    echo ""

    # Check prerequisites
    print_section "Checking prerequisites..."
    if ! check_prerequisites; then
        print_error "Prerequisites check failed. Please install missing tools."
        exit 1
    fi
    print_success "All prerequisites satisfied"

    # Step 1: Create namespaces
    if ! setup_namespaces; then
        ((errors++))
    fi

    # Step 2: Deploy pre-existing resources
    setup_resources
    local resource_errors=$?
    if [ $resource_errors -gt 0 ]; then
        print_fail "$resource_errors resource(s) failed to deploy"
        ((errors += resource_errors))
    fi

    # Step 3: Create exam directories
    setup_directories

    # Step 4: Copy template files
    setup_templates

    # Step 5: Start local registry (unless skipped)
    if [ "$SKIP_REGISTRY" = false ]; then
        if ! setup_registry; then
            ((errors++))
        fi
    else
        print_section "Skipping local registry setup (--skip-registry)"
    fi

    # Step 6: Setup Helm environment for Q4
    if ! setup_helm; then
        print_fail "Helm setup encountered errors (non-critical)"
    fi

    # Wait for resources to be ready
    print_section "Waiting for resources to be ready..."
    sleep 3

    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    print_footer
    echo ""

    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}Setup completed successfully in ${duration}s${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Start the exam:  ./scripts/ckad-exam.sh start $CURRENT_EXAM_ID"
        echo "  2. Or practice:     See questions in exams/$CURRENT_EXAM_ID/questions.md"
        echo "  3. Check score:     ./scripts/ckad-score.sh -e $CURRENT_EXAM_ID"
        echo "  4. Reset:           ./scripts/ckad-cleanup.sh -e $CURRENT_EXAM_ID"
    else
        echo -e "${YELLOW}Setup completed with $errors error(s) in ${duration}s${NC}"
        echo "Some resources may not have been created correctly."
        echo "Check the errors above and try running the script again."
    fi

    echo ""

    return $errors
}

# Run main
main
exit $?
