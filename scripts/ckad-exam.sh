#!/bin/bash
# ckad-exam.sh - CKAD Exam Launcher
# Verifies configuration, starts timer, and manages exam session

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/timer.sh"

# Default exam
DEFAULT_EXAM="ckad-simulation1"
EXAMS_DIR="$PROJECT_DIR/exams"

# Web server settings
WEB_PORT=9090

# Show ASCII banner
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
 ██████╗██╗  ██╗ █████╗ ██████╗       ██████╗  ██████╗      ██╗ ██████╗
██╔════╝██║ ██╔╝██╔══██╗██╔══██╗      ██╔══██╗██╔═══██╗     ██║██╔═══██╗
██║     █████╔╝ ███████║██║  ██║█████╗██║  ██║██║   ██║     ██║██║   ██║
██║     ██╔═██╗ ██╔══██║██║  ██║╚════╝██║  ██║██║   ██║██   ██║██║   ██║
╚██████╗██║  ██╗██║  ██║██████╔╝      ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝       ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝
EOF
    echo -e "${NC}"
    echo -e "                    ${GREEN}CKAD Exam Simulator${NC}"
    echo ""
}

# Show help
show_help() {
    echo "Usage: $(basename "$0") [COMMAND] [OPTIONS]"
    echo ""
    echo "CKAD Exam Launcher - Start and manage exam sessions"
    echo ""
    echo "COMMANDS:"
    echo "  start [EXAM]     Start an exam session (default: interactive selection)"
    echo "  web [EXAM]       Start exam with web interface (recommended)"
    echo "  stop             Stop current exam session and timer"
    echo "  status           Show current exam status and timer"
    echo "  list             List available exams"
    echo "  timer            Show/watch the timer (terminal mode)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help       Show this help message"
    echo "  -e, --exam EXAM  Specify exam to use"
    echo "  -q, --question N Start at question number N"
    echo "  -y, --yes        Skip confirmation prompt"
    echo "  --no-timer       Start exam without timer"
    echo "  --port PORT      Web interface port (default: $WEB_PORT)"
    echo ""
    echo "EXAMPLES:"
    echo "  $(basename "$0")                          # Interactive exam selection"
    echo "  $(basename "$0") web                      # Web interface with selection"
    echo "  $(basename "$0") web -e ckad-simulation1  # Start specific exam"
    echo "  $(basename "$0") web -q 5                 # Start at question 5"
    echo "  $(basename "$0") list                     # Show available exams"
}

# List available exams
list_exams() {
    echo ""
    echo -e "${BLUE}Available Exams:${NC}"
    echo "───────────────────────────────────────────────────────────────────"

    for exam_dir in "$EXAMS_DIR"/*/; do
        if [ -d "$exam_dir" ] && [ -f "$exam_dir/exam.conf" ]; then
            source "$exam_dir/exam.conf"
            local exam_id=$(basename "$exam_dir")
            printf "  %-25s %s\n" "$exam_id" "$EXAM_NAME"
            printf "    Duration: %d min | Questions: %d | Points: %d | Pass: %d%%\n" \
                "$EXAM_DURATION" "$TOTAL_QUESTIONS" "$TOTAL_POINTS" "$PASSING_PERCENTAGE"
            echo ""
        fi
    done
}

# Get array of available exams
get_available_exams() {
    local exams=()
    for exam_dir in "$EXAMS_DIR"/*/; do
        if [ -d "$exam_dir" ] && [ -f "$exam_dir/exam.conf" ]; then
            exams+=("$(basename "$exam_dir")")
        fi
    done
    echo "${exams[@]}"
}

# Interactive exam selection
select_exam_interactive() {
    local exams=($(get_available_exams))
    local num_exams=${#exams[@]}

    if [ $num_exams -eq 0 ]; then
        print_error "No exams found in $EXAMS_DIR"
        exit 1
    fi

    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                     SELECT AN EXAM TO START                       ${BLUE}║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}"

    local i=1
    for exam_id in "${exams[@]}"; do
        source "$EXAMS_DIR/$exam_id/exam.conf"
        printf "${BLUE}║${NC}  ${CYAN}%d)${NC} %-20s - %s\n" $i "$exam_id" "$EXAM_NAME"
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
            SELECTED_EXAM="${exams[$((selection-1))]}"
            break
        else
            echo -e "${RED}Invalid selection. Please enter a valid exam number.${NC}"
        fi
    done

    echo ""
    echo -e "${GREEN}Selected:${NC} $SELECTED_EXAM"
}

# Detect if another exam's resources exist in the cluster
detect_existing_exam_resources() {
    local target_exam=$1
    local found_namespaces=()
    local found_exam=""

    # Check all available exams
    for exam_dir in "$EXAMS_DIR"/*/; do
        if [ -d "$exam_dir" ] && [ -f "$exam_dir/exam.conf" ]; then
            local exam_id=$(basename "$exam_dir")

            # Source exam config to get namespaces
            source "$exam_dir/exam.conf"

            # Check if any namespaces from this exam exist
            local ns_count=0
            for ns in "${EXAM_NAMESPACES[@]}"; do
                if namespace_exists "$ns"; then
                    ((++ns_count))
                    found_namespaces+=("$ns")
                fi
            done

            # If we found namespaces and it's a different exam, record it
            if [ $ns_count -gt 0 ]; then
                found_exam="$exam_id"
                break
            fi
        fi
    done

    if [ -n "$found_exam" ]; then
        echo "$found_exam"
        return 0
    fi

    return 1
}

# Offer cleanup if resources from another exam exist
check_and_offer_cleanup() {
    local target_exam=$1

    echo ""
    print_section "Checking for existing exam resources..."

    local existing_exam
    existing_exam=$(detect_existing_exam_resources "$target_exam") || true

    if [ -n "$existing_exam" ]; then
        echo ""
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${NC}                    EXISTING EXAM DETECTED                         ${YELLOW}║${NC}"
        echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║${NC}"
        echo -e "${YELLOW}║${NC}  Found resources from: ${CYAN}$existing_exam${NC}"
        echo -e "${YELLOW}║${NC}"
        if [ "$existing_exam" = "$target_exam" ]; then
            echo -e "${YELLOW}║${NC}  This is the same exam you want to start."
            echo -e "${YELLOW}║${NC}  You can continue with existing setup or cleanup first."
        else
            echo -e "${YELLOW}║${NC}  This is a different exam than you want to start."
            echo -e "${YELLOW}║${NC}  ${RED}Cleanup is recommended before proceeding.${NC}"
        fi
        echo -e "${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        echo "What would you like to do?"
        echo "  1) Cleanup existing resources and start fresh"
        echo "  2) Continue with existing setup (may cause conflicts)"
        echo "  3) Cancel"
        echo ""

        local choice
        while true; do
            read -r -p "Enter your choice: " choice
            case $choice in
                1)
                    echo ""
                    echo -e "${CYAN}Running cleanup for $existing_exam...${NC}"
                    "$SCRIPT_DIR/ckad-cleanup.sh" -e "$existing_exam" -y
                    echo ""
                    print_success "Cleanup completed!"
                    return 0
                    ;;
                2)
                    echo ""
                    echo -e "${YELLOW}Continuing with existing setup...${NC}"
                    return 0
                    ;;
                3)
                    echo ""
                    echo "Cancelled."
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Please enter a valid option.${NC}"
                    ;;
            esac
        done
    else
        print_success "No existing exam resources found"
    fi

    return 0
}

# Select starting question
select_starting_question() {
    local exam_id=$1
    local max_questions=$2

    echo ""
    echo -e "${BLUE}Starting Question:${NC}"
    echo "  Enter a question number to start at (1-$max_questions)"
    echo "  Or press Enter to start at question 1"
    echo ""

    local question
    read -r -p "Start at question [1]: " question

    if [ -z "$question" ]; then
        START_QUESTION=1
    elif [[ "$question" =~ ^[0-9]+$ ]] && [ "$question" -ge 1 ] && [ "$question" -le "$max_questions" ]; then
        START_QUESTION=$question
    else
        echo -e "${YELLOW}Invalid question number. Starting at question 1.${NC}"
        START_QUESTION=1
    fi

    echo -e "${GREEN}Starting at question:${NC} $START_QUESTION"
}

# Load exam configuration
load_exam_config() {
    local exam_id=$1
    local exam_conf="$EXAMS_DIR/$exam_id/exam.conf"

    if [ ! -f "$exam_conf" ]; then
        print_error "Exam '$exam_id' not found. Use 'list' to see available exams."
        exit 1
    fi

    source "$exam_conf"

    # Set exam-specific paths
    CURRENT_EXAM_ID="$exam_id"
    CURRENT_EXAM_DIR="$EXAMS_DIR/$exam_id"
    CURRENT_MANIFESTS_DIR="$CURRENT_EXAM_DIR/manifests/setup"
    CURRENT_TEMPLATES_DIR="$CURRENT_EXAM_DIR/templates"
    CURRENT_QUESTIONS_FILE="$CURRENT_EXAM_DIR/$QUESTIONS_FILE"
    CURRENT_SCORING_FILE="$CURRENT_EXAM_DIR/$SCORING_FUNCTIONS"

    export CURRENT_EXAM_ID CURRENT_EXAM_DIR CURRENT_MANIFESTS_DIR
    export CURRENT_TEMPLATES_DIR CURRENT_QUESTIONS_FILE CURRENT_SCORING_FILE
}

# Verify exam prerequisites
verify_prerequisites() {
    local errors=0

    echo ""
    print_section "Verifying prerequisites..."

    # Check kubectl
    if command_exists kubectl; then
        print_success "kubectl found"
    else
        print_fail "kubectl not found"
        ((errors++))
    fi

    # Check cluster connection
    if kubectl cluster-info &> /dev/null; then
        print_success "Kubernetes cluster accessible"
    else
        print_fail "Cannot connect to Kubernetes cluster"
        ((errors++))
    fi

    # Check helm
    if command_exists helm; then
        print_success "helm found"
    else
        print_fail "helm not found"
        ((errors++))
    fi

    # Check docker
    if command_exists docker; then
        print_success "docker found"
    else
        print_fail "docker not found"
        ((errors++))
    fi

    return $errors
}

# Verify exam environment is set up
verify_exam_setup() {
    local errors=0

    echo ""
    print_section "Verifying exam environment..."

    # Check namespaces
    local ns_count=0
    local ns_total=${#EXAM_NAMESPACES[@]}
    for ns in "${EXAM_NAMESPACES[@]}"; do
        if namespace_exists "$ns"; then
            ((++ns_count))
        fi
    done

    if [ $ns_count -eq $ns_total ]; then
        print_success "All $ns_total namespaces exist"
    elif [ $ns_count -gt 0 ]; then
        print_fail "Only $ns_count/$ns_total namespaces exist"
        ((errors++))
    else
        print_fail "No exam namespaces found"
        ((errors++))
    fi

    # Check exam directories
    if [ -d "$EXAM_DIR" ]; then
        print_success "Exam directory exists ($EXAM_DIR)"
    else
        print_fail "Exam directory not found"
        ((errors++))
    fi

    # Check registry (if needed)
    local registry_name="${REGISTRY_NAME:-registry}"
    local registry_host="${REGISTRY_HOST:-localhost}"
    local registry_port="${REGISTRY_PORT:-5000}"
    if docker_container_running "$registry_name"; then
        print_success "Docker registry running on $registry_host:$registry_port"
    else
        print_fail "Docker registry not running"
        ((errors++))
    fi

    # Check questions file
    if [ -f "$CURRENT_QUESTIONS_FILE" ]; then
        print_success "Questions file found"
    else
        print_fail "Questions file not found"
        ((errors++))
    fi

    return $errors
}

# Display exam info before starting
display_exam_info() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                         EXAM INFORMATION                          ${BLUE}║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  Exam:        $EXAM_NAME"
    echo -e "${BLUE}║${NC}  Duration:    $EXAM_DURATION minutes"
    echo -e "${BLUE}║${NC}  Questions:   $TOTAL_QUESTIONS (+ $PREVIEW_QUESTIONS preview)"
    echo -e "${BLUE}║${NC}  Total:       $TOTAL_POINTS points"
    echo -e "${BLUE}║${NC}  Pass Score:  $PASSING_PERCENTAGE%"
    echo -e "${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Questions:   $CURRENT_QUESTIONS_FILE"
    echo -e "${BLUE}║${NC}  Answers in:  $EXAM_DIR"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Start web interface
start_web() {
    local exam_id=${1:-$DEFAULT_EXAM}
    local skip_confirm=$2
    local start_question=${3:-1}

    # Load exam configuration (may already be loaded)
    load_exam_config "$exam_id"

    # Display header
    print_header "CKAD Exam Launcher - Web Interface"
    echo ""

    # Verify prerequisites
    if ! verify_prerequisites; then
        echo ""
        print_error "Prerequisites check failed. Please install missing tools."
        exit 1
    fi

    # Check uv (Python package manager)
    if ! command_exists uv; then
        print_error "uv is required for the web interface"
        echo "  Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    print_success "uv found"

    # Check if setup has been run
    if ! verify_exam_setup; then
        echo ""
        echo -e "${YELLOW}Exam environment is not fully configured.${NC}"
        echo ""
        read -p "Would you like to run setup now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/ckad-setup.sh" -e "$exam_id"
            echo ""
            # Re-verify after setup
            if ! verify_exam_setup; then
                print_error "Setup completed with errors. Please check and try again."
                exit 1
            fi
        else
            print_error "Cannot start exam without proper environment setup."
            exit 1
        fi
    fi

    print_success "Environment ready!"

    # Display exam info
    display_exam_info

    # Confirm start
    if [ "$skip_confirm" != "true" ]; then
        echo ""
        echo -e "${YELLOW}Ready to launch the exam interface.${NC}"
        echo -e "${YELLOW}The browser will open and the timer will start.${NC}"
        echo ""
        read -p "Start exam now? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exam cancelled."
            exit 0
        fi
    fi

    # Stop any existing timer
    timer_stop 2>/dev/null || true

    # Check if port is available
    if lsof -Pi :$WEB_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo ""
        echo -e "${YELLOW}Port $WEB_PORT is already in use.${NC}"
        echo "Attempting to use it (may be a previous exam session)..."
    fi

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                    LAUNCHING WEB INTERFACE                        ${GREEN}║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  Opening: ${CYAN}http://localhost:$WEB_PORT${NC}"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  The exam will start when you select it in the browser."
    echo -e "${GREEN}║${NC}  Press Ctrl+C in this terminal to stop the server."
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  Save your answers in: $EXAM_DIR"
    echo -e "${GREEN}║${NC}  Score with: ./scripts/ckad-score.sh"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Try to open browser
    if command_exists xdg-open; then
        (sleep 1 && xdg-open "http://localhost:$WEB_PORT" 2>/dev/null) &
    elif command_exists open; then
        (sleep 1 && open "http://localhost:$WEB_PORT" 2>/dev/null) &
    fi

    # Start the web server (blocks until Ctrl+C)
    cd "$PROJECT_DIR"
    uv run python web/server.py "$WEB_PORT" "$exam_id" "$start_question"
}

# Start exam session (terminal mode)
start_exam() {
    local exam_id=${1:-$DEFAULT_EXAM}
    local skip_confirm=$2
    local no_timer=$3
    local start_question=${4:-1}

    # Load exam configuration (may already be loaded)
    load_exam_config "$exam_id"

    # Display header
    print_header "CKAD Exam Launcher"
    echo ""

    # Verify prerequisites
    if ! verify_prerequisites; then
        echo ""
        print_error "Prerequisites check failed. Please install missing tools."
        exit 1
    fi

    # Check if setup has been run
    if ! verify_exam_setup; then
        echo ""
        echo -e "${YELLOW}Exam environment is not fully configured.${NC}"
        echo ""
        read -p "Would you like to run setup now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/ckad-setup.sh" -e "$exam_id"
            echo ""
            # Re-verify after setup
            if ! verify_exam_setup; then
                print_error "Setup completed with errors. Please check and try again."
                exit 1
            fi
        else
            print_error "Cannot start exam without proper environment setup."
            exit 1
        fi
    fi

    print_success "Environment ready!"

    # Display exam info
    display_exam_info

    # Confirm start
    if [ "$skip_confirm" != "true" ]; then
        echo ""
        echo -e "${YELLOW}Are you ready to start the exam?${NC}"
        echo -e "${YELLOW}The timer will start immediately.${NC}"
        echo ""
        echo -e "${CYAN}Tip: Use './scripts/ckad-exam.sh web' for a better interface${NC}"
        echo ""
        read -p "Start exam now? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exam cancelled."
            exit 0
        fi
    fi

    # Stop any existing timer
    timer_stop 2>/dev/null

    # Start timer (unless disabled)
    if [ "$no_timer" != "true" ]; then
        echo ""
        timer_start "$EXAM_DURATION" "$EXAM_WARNING_TIME" "$EXAM_NAME"
        echo ""
    fi

    # Display start message
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                       EXAM STARTED!                               ${GREEN}║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  Good luck! You have $EXAM_DURATION minutes to complete the exam."
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  Commands:"
    echo -e "${GREEN}║${NC}    ./scripts/ckad-exam.sh timer    - Watch the countdown"
    echo -e "${GREEN}║${NC}    ./scripts/ckad-exam.sh status   - Check exam status"
    echo -e "${GREEN}║${NC}    ./scripts/ckad-score.sh         - Check your score"
    echo -e "${GREEN}║${NC}    ./scripts/ckad-exam.sh stop     - End exam early"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  Questions file: $CURRENT_QUESTIONS_FILE"
    echo -e "${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Show current timer status
    if [ "$no_timer" != "true" ]; then
        timer_display
        echo ""
        echo -e "${CYAN}Tip: Run './scripts/ckad-exam.sh timer' in another terminal to watch the countdown${NC}"
    fi
}

# Stop exam session
stop_exam() {
    echo ""
    print_header "Stopping Exam"
    echo ""

    if timer_is_running; then
        timer_stop
        print_success "Timer stopped"
    else
        print_skip "No timer running"
    fi

    echo ""
    echo "Would you like to see your score? Run:"
    echo "  ./scripts/ckad-score.sh"
    echo ""
}

# Show exam status
show_status() {
    echo ""
    print_header "Exam Status"

    # Timer info
    timer_info

    # Check if exam is set up
    echo ""
    print_section "Environment Status"

    # Quick namespace check using first 3 namespaces from config
    local ns_found=0
    local ns_to_check=3
    local ns_checked=0
    for ns in "${EXAM_NAMESPACES[@]}"; do
        if [ $ns_checked -ge $ns_to_check ]; then
            break
        fi
        if namespace_exists "$ns"; then
            ((++ns_found))
        fi
        ((++ns_checked))
    done

    if [ $ns_found -gt 0 ]; then
        print_success "Exam namespaces found ($ns_found/$ns_checked checked)"
    else
        print_fail "Exam namespaces not found - run setup first"
    fi

    # Check registry
    local registry_name="${REGISTRY_NAME:-registry}"
    if docker_container_running "$registry_name"; then
        print_success "Docker registry running"
    else
        print_fail "Docker registry not running"
    fi

    # Check exam directory
    if [ -d "$EXAM_DIR" ]; then
        print_success "Exam directory exists"
    else
        print_fail "Exam directory not found"
    fi

    echo ""
}

# Watch timer
watch_timer() {
    timer_watch
}

# Parse arguments
COMMAND=""
EXAM_ID=""
START_QUESTION=""
SKIP_CONFIRM=false
NO_TIMER=false
INTERACTIVE_EXAM=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        -e|--exam)
            EXAM_ID=$2
            INTERACTIVE_EXAM=false
            shift 2
            ;;
        -q|--question)
            START_QUESTION=$2
            shift 2
            ;;
        --no-timer)
            NO_TIMER=true
            shift
            ;;
        --port)
            WEB_PORT=$2
            shift 2
            ;;
        start|stop|status|list|timer|web)
            COMMAND=$1
            shift
            # Check if next arg is exam ID (not a flag)
            if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
                EXAM_ID=$1
                INTERACTIVE_EXAM=false
                shift
            fi
            ;;
        *)
            if [ -z "$COMMAND" ]; then
                # Assume it's an exam ID for web (default command)
                COMMAND="web"
                EXAM_ID=$1
                INTERACTIVE_EXAM=false
            else
                print_error "Unknown option: $1"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Default command is web
if [ -z "$COMMAND" ]; then
    COMMAND="web"
fi

# Show banner for main commands
case $COMMAND in
    web|start|list)
        show_banner
        ;;
esac

# Interactive exam selection for web and start commands
if [[ "$COMMAND" == "web" || "$COMMAND" == "start" ]]; then
    # If no exam specified, show interactive selection
    if [ "$INTERACTIVE_EXAM" = true ] || [ -z "$EXAM_ID" ]; then
        select_exam_interactive
        EXAM_ID="$SELECTED_EXAM"
    fi

    # Check for existing exam resources and offer cleanup
    check_and_offer_cleanup "$EXAM_ID"

    # Load exam config to get total questions
    load_exam_config "$EXAM_ID"

    # Calculate total questions including preview
    TOTAL_WITH_PREVIEW=$((TOTAL_QUESTIONS + PREVIEW_QUESTIONS))

    # Interactive question selection if not specified via -q
    if [ -z "$START_QUESTION" ]; then
        select_starting_question "$EXAM_ID" "$TOTAL_WITH_PREVIEW"
    else
        # Validate the provided question number
        if [[ "$START_QUESTION" =~ ^[0-9]+$ ]] && [ "$START_QUESTION" -ge 1 ] && [ "$START_QUESTION" -le "$TOTAL_WITH_PREVIEW" ]; then
            echo ""
            echo -e "${GREEN}Starting at question:${NC} $START_QUESTION"
        else
            echo -e "${YELLOW}Invalid question number $START_QUESTION. Starting at question 1.${NC}"
            START_QUESTION=1
        fi
    fi
fi

# Execute command
case $COMMAND in
    web)
        start_web "$EXAM_ID" "$SKIP_CONFIRM" "$START_QUESTION"
        ;;
    start)
        start_exam "$EXAM_ID" "$SKIP_CONFIRM" "$NO_TIMER" "$START_QUESTION"
        ;;
    stop)
        stop_exam
        ;;
    status)
        show_status
        ;;
    list)
        list_exams
        ;;
    timer)
        watch_timer
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
