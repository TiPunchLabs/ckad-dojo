#!/bin/bash
# ckad-score.sh - CKAD Exam Simulator Scoring Script
# Evaluates all exam questions and displays results

set -e

# Source library functions
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$SCRIPT_LIB_DIR/common.sh"

# Show help
show_help() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Score your CKAD Exam Simulator answers."
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help         Show this help message"
    echo "  -e, --exam EXAM    Select exam to score (default: $DEFAULT_EXAM_ID)"
    echo "  -q, --question N   Score a specific question (1-22, p1, p2)"
    echo "  -s, --summary      Show summary only (no details)"
    echo "  --list             List available exams"
    echo ""
    echo "EXAMPLES:"
    echo "  $(basename "$0")                      # Score all questions (default exam)"
    echo "  $(basename "$0") -e ckad-simulation1  # Score specific exam"
    echo "  $(basename "$0") -q 5                 # Score only question 5"
    echo "  $(basename "$0") -s                   # Show summary only"
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
            printf "    Questions: %d | Points: %d | Pass: %d%%\n" \
                "$TOTAL_QUESTIONS" "$TOTAL_POINTS" "$PASSING_PERCENTAGE"
        fi
    done
    echo ""
}

# Parse arguments
SPECIFIC_QUESTION=""
SUMMARY_ONLY=false
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
        -q|--question)
            SPECIFIC_QUESTION="$2"
            shift 2
            ;;
        -s|--summary)
            SUMMARY_ONLY=true
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

# Main scoring function
main() {
    local total_score=0
    local total_possible=0
    local start_time=$(date +%s)

    # Load exam configuration
    if ! load_exam "$SELECTED_EXAM"; then
        print_error "Failed to load exam: $SELECTED_EXAM"
        echo "Use --list to see available exams."
        exit 1
    fi

    # Source exam-specific scoring functions
    if [ -f "$CURRENT_SCORING_FILE" ]; then
        source "$CURRENT_SCORING_FILE"
    else
        # Fallback to lib scoring functions
        source "$SCRIPT_LIB_DIR/scoring-functions.sh"
    fi

    print_header "CKAD Exam Simulator - Scoring"
    echo ""
    echo -e "Exam:        ${CYAN}$EXAM_NAME${NC}"
    echo -e "Exam ID:     ${CYAN}$CURRENT_EXAM_ID${NC}"
    echo ""

    # Check kubectl connection
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
        exit 1
    fi

    # Array to store results for table display
    declare -a results

    # Score specific question or all
    if [ -n "$SPECIFIC_QUESTION" ]; then
        case "$SPECIFIC_QUESTION" in
            1) echo ""; score_q1; ;;
            2) echo ""; score_q2; ;;
            3) echo ""; score_q3; ;;
            4) echo ""; score_q4; ;;
            5) echo ""; score_q5; ;;
            6) echo ""; score_q6; ;;
            7) echo ""; score_q7; ;;
            8) echo ""; score_q8; ;;
            9) echo ""; score_q9; ;;
            10) echo ""; score_q10; ;;
            11) echo ""; score_q11; ;;
            12) echo ""; score_q12; ;;
            13) echo ""; score_q13; ;;
            14) echo ""; score_q14; ;;
            15) echo ""; score_q15; ;;
            16) echo ""; score_q16; ;;
            17) echo ""; score_q17; ;;
            18) echo ""; score_q18; ;;
            19) echo ""; score_q19; ;;
            20) echo ""; score_q20; ;;
            21) echo ""; score_q21; ;;
            22) echo ""; score_q22; ;;
            p1|P1) echo ""; score_preview_q1; ;;
            *)
                print_error "Invalid question: $SPECIFIC_QUESTION"
                exit 1
                ;;
        esac
        exit 0
    fi

    # Score all questions
    echo ""
    echo "Scoring all questions..."
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"

    # Question scoring with point tracking
    # Format: question_number|max_points|description

    local questions=(
        "1|1|Namespaces"
        "2|5|Pods"
        "3|6|Job"
        "4|5|Helm Management"
        "5|1|ServiceAccount, Secret"
        "6|5|ReadinessProbe"
        "7|6|Pods, Namespaces"
        "8|4|Deployment, Rollouts"
        "9|10|Pod -> Deployment"
        "10|9|Service, Logs"
        "11|7|Working with Containers"
        "12|6|Storage, PV, PVC, Pod volume"
        "13|6|Storage, StorageClass, PVC"
        "14|8|Secret, Secret-Volume, Secret-Env"
        "15|3|ConfigMap, Configmap-Volume"
        "16|6|Logging sidecar"
        "17|5|InitContainer"
        "18|2|Service misconfiguration"
        "19|2|Service ClusterIP->NodePort"
        "20|5|NetworkPolicy"
        "21|8|Requests and Limits, ServiceAccount"
        "22|3|Labels, Annotations"
    )

    for q in "${questions[@]}"; do
        IFS='|' read -r qnum max_points desc <<< "$q"

        echo ""
        score_result=$(score_q$qnum 2>/dev/null || echo "0/0")
        scored=$(echo "$score_result" | tail -1 | cut -d'/' -f1)

        # Handle cases where scoring fails
        if [ -z "$scored" ] || ! [[ "$scored" =~ ^[0-9]+$ ]]; then
            scored=0
        fi

        total_score=$((total_score + scored))
        total_possible=$((total_possible + max_points))

        results+=("Q$qnum|$scored/$max_points|$desc")

        echo "───────────────────────────────────────────────────────────────────"
    done

    # Preview questions
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "PREVIEW QUESTIONS"
    echo "═══════════════════════════════════════════════════════════════════"

    echo ""
    preview_result=$(score_preview_q1 2>/dev/null || echo "0/0")
    preview_scored=$(echo "$preview_result" | tail -1 | cut -d'/' -f1)
    if [ -z "$preview_scored" ] || ! [[ "$preview_scored" =~ ^[0-9]+$ ]]; then
        preview_scored=0
    fi

    # Preview questions don't count towards total
    results+=("P1|$preview_scored/3|Liveness Probe (Preview)")

    # Calculate percentage
    local percentage=0
    if [ $total_possible -gt 0 ]; then
        percentage=$((total_score * 100 / total_possible))
    fi

    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo ""
    print_footer
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "                           SCORE SUMMARY"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    # Print results table
    printf "%-8s %-12s %s\n" "Question" "Score" "Topic"
    printf "%-8s %-12s %s\n" "--------" "--------" "-----------------------------"
    for result in "${results[@]}"; do
        IFS='|' read -r qnum score desc <<< "$result"
        printf "%-8s %-12s %s\n" "$qnum" "$score" "$desc"
    done

    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    # Color-coded final score based on exam passing percentage
    local pass_threshold=${PASSING_PERCENTAGE:-66}

    if [ $percentage -ge $pass_threshold ]; then
        echo -e "${GREEN}TOTAL SCORE: $total_score / $total_possible ($percentage%)${NC}"
        echo ""
        echo -e "${GREEN}PASS - Congratulations!${NC}"
    elif [ $percentage -ge $((pass_threshold - 16)) ]; then
        echo -e "${YELLOW}TOTAL SCORE: $total_score / $total_possible ($percentage%)${NC}"
        echo ""
        echo -e "${YELLOW}CLOSE - Keep practicing!${NC}"
    else
        echo -e "${RED}TOTAL SCORE: $total_score / $total_possible ($percentage%)${NC}"
        echo ""
        echo -e "${RED}NEEDS IMPROVEMENT - Review the topics above${NC}"
    fi

    echo ""
    echo "Scoring completed in ${duration}s"
    echo ""
    echo "Note: CKAD passing score is approximately ${pass_threshold}%"
    echo ""

    return 0
}

# Run main
main
exit $?
