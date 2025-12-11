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
        # Check if it's a preview question
        if [[ "$SPECIFIC_QUESTION" =~ ^[pP][0-9]+$ ]]; then
            local p_num="${SPECIFIC_QUESTION//[pP]/}"
            if declare -f "score_preview_q$p_num" > /dev/null; then
                echo ""
                "score_preview_q$p_num"
            else
                print_error "Preview question $SPECIFIC_QUESTION not found"
                exit 1
            fi
        # Check if it's a regular question
        elif [[ "$SPECIFIC_QUESTION" =~ ^[0-9]+$ ]]; then
            if [ "$SPECIFIC_QUESTION" -ge 1 ] && [ "$SPECIFIC_QUESTION" -le "$TOTAL_QUESTIONS" ]; then
                if declare -f "score_q$SPECIFIC_QUESTION" > /dev/null; then
                    echo ""
                    "score_q$SPECIFIC_QUESTION"
                else
                    print_error "Scoring function for question $SPECIFIC_QUESTION not found"
                    exit 1
                fi
            else
                print_error "Question $SPECIFIC_QUESTION out of range (1-$TOTAL_QUESTIONS)"
                exit 1
            fi
        else
            print_error "Invalid question format: $SPECIFIC_QUESTION"
            exit 1
        fi
        exit 0
    fi

    # Score all questions
    echo ""
    echo "Scoring all questions..."
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"

    # Dynamic question scoring - discover available score functions
    local total_qs="${TOTAL_QUESTIONS:-22}"

    for qnum in $(seq 1 "$total_qs"); do
        if declare -f "score_q$qnum" > /dev/null; then
            echo ""
            score_result=$("score_q$qnum" 2>/dev/null || echo "0/0")
            echo "$score_result"
            scored=$(echo "$score_result" | tail -1 | cut -d'/' -f1)
            max_points=$(echo "$score_result" | tail -1 | cut -d'/' -f2)

            # Handle cases where scoring fails
            if [ -z "$scored" ] || ! [[ "$scored" =~ ^[0-9]+$ ]]; then
                scored=0
            fi
            if [ -z "$max_points" ] || ! [[ "$max_points" =~ ^[0-9]+$ ]]; then
                max_points=0
            fi

            total_score=$((total_score + scored))
            total_possible=$((total_possible + max_points))

            results+=("Q$qnum|$scored/$max_points|Question $qnum")

            echo "───────────────────────────────────────────────────────────────────"
        else
            print_fail "No scoring function for question $qnum"
        fi
    done

    # Preview questions
    local preview_qs="${PREVIEW_QUESTIONS:-1}"
    if [ "$preview_qs" -gt 0 ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "PREVIEW QUESTIONS"
        echo "═══════════════════════════════════════════════════════════════════"

        for pnum in $(seq 1 "$preview_qs"); do
            if declare -f "score_preview_q$pnum" > /dev/null; then
                echo ""
                preview_result=$("score_preview_q$pnum" 2>/dev/null || echo "0/0")
                echo "$preview_result"
                preview_scored=$(echo "$preview_result" | tail -1 | cut -d'/' -f1)
                preview_max=$(echo "$preview_result" | tail -1 | cut -d'/' -f2)
                if [ -z "$preview_scored" ] || ! [[ "$preview_scored" =~ ^[0-9]+$ ]]; then
                    preview_scored=0
                fi
                if [ -z "$preview_max" ] || ! [[ "$preview_max" =~ ^[0-9]+$ ]]; then
                    preview_max=0
                fi
                # Preview questions don't count towards total
                results+=("P$pnum|$preview_scored/$preview_max|Preview Question $pnum")
            fi
        done
    fi

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
