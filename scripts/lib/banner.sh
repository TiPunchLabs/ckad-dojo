#!/bin/bash
# banner.sh - Dojo welcome banner display functions
# Displays ASCII art and personalized welcome message for CKAD Dojo exams

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ASCII Art Banner (from ckad_dojo.py)
DOJO_BANNER='
 ██████╗██╗  ██╗ █████╗ ██████╗        ██████╗  ██████╗      ██╗ ██████╗
██╔════╝██║ ██╔╝██╔══██╗██╔══██╗       ██╔══██╗██╔═══██╗     ██║██╔═══██╗
██║     █████╔╝ ███████║██║  ██║ ████╗ ██║  ██║██║   ██║     ██║██║   ██║
██║     ██╔═██╗ ██╔══██║██║  ██║ ╚═══╝ ██║  ██║██║   ██║██   ██║██║   ██║
╚██████╗██║  ██╗██║  ██║██████╔╝       ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝
'

# Show dojo welcome banner
# Usage: show_dojo_banner [exam_id]
# Reads DOJO_NAME, DOJO_EMOJI, TOTAL_QUESTIONS, TOTAL_POINTS, EXAM_DURATION from exam.conf
show_dojo_banner() {
    local exam_id="${1:-}"
    local project_dir="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

    # Default values (fallback if config not found)
    local dojo_name="${DOJO_NAME:-CKAD Dojo}"
    local dojo_emoji="${DOJO_EMOJI:-🥋}"
    local total_questions="${TOTAL_QUESTIONS:-22}"
    local total_points="${TOTAL_POINTS:-113}"
    local exam_duration="${EXAM_DURATION:-120}"

    # Try to load exam configuration if exam_id provided
    if [ -n "$exam_id" ]; then
        local exam_conf="$project_dir/exams/$exam_id/exam.conf"
        if [ -f "$exam_conf" ]; then
            # Source the config to get values
            source "$exam_conf"
            dojo_name="${DOJO_NAME:-CKAD Dojo}"
            dojo_emoji="${DOJO_EMOJI:-🥋}"
            total_questions="${TOTAL_QUESTIONS:-22}"
            total_points="${TOTAL_POINTS:-113}"
            exam_duration="${EXAM_DURATION:-120}"
        fi
    fi

    # Display banner
    echo -e "${CYAN}${DOJO_BANNER}${NC}"
    echo ""
    echo -e "        ${dojo_emoji} ${GREEN}Bienvenue au ${dojo_name}${NC} ${dojo_emoji}"
    echo -e "           ${YELLOW}${total_questions} questions${NC} • ${YELLOW}${total_points} points${NC} • ${YELLOW}${exam_duration} min${NC}"
    echo ""
    echo "─────────────────────────────────────────────────────────────────────────"
    echo ""
}

# Export function for use in subshells
export -f show_dojo_banner 2>/dev/null || true
