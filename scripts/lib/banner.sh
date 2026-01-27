#!/bin/bash
# banner.sh - Dojo welcome banner display functions
# Displays ASCII art and personalized welcome message for CKAD Dojo exams

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
DIM='\033[2m'
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
	local dojo_title="${DOJO_TITLE:-}"
	local dojo_quote="${DOJO_QUOTE:-}"
	local dojo_credit_text="${DOJO_CREDIT_TEXT:-}"
	local dojo_credit_url="${DOJO_CREDIT_URL:-}"
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
			dojo_title="${DOJO_TITLE:-}"
			dojo_quote="${DOJO_QUOTE:-}"
			dojo_credit_text="${DOJO_CREDIT_TEXT:-}"
			dojo_credit_url="${DOJO_CREDIT_URL:-}"
			total_questions="${TOTAL_QUESTIONS:-22}"
			total_points="${TOTAL_POINTS:-113}"
			exam_duration="${EXAM_DURATION:-120}"
		fi
	fi

	# Banner width (ASCII art is ~74 chars)
	local banner_width=74

	# Helper function to get display width using wcswidth via printf
	# Emojis and wide characters are handled correctly
	get_display_width() {
		local text="$1"
		# Use printf to measure actual display width
		# This handles emojis and unicode properly
		local width
		width=$(printf '%s' "$text" | wc -L 2>/dev/null || echo ${#text})
		echo "$width"
	}

	# Helper function to center text (returns padding spaces)
	get_padding() {
		local plain_text="$1"
		local width="$2"
		local text_len
		text_len=$(get_display_width "$plain_text")
		local padding=$(((width - text_len) / 2))
		[ $padding -lt 0 ] && padding=0
		printf "%*s" $padding ""
	}

	# Display banner
	echo -e "${CYAN}${DOJO_BANNER}${NC}"
	echo ""

	# Line 1: Welcome message
	local line1_plain="Bienvenue au ${dojo_name}"
	local pad1
	pad1=$(get_padding "$line1_plain" $banner_width)
	echo -e "${pad1}${GREEN}Bienvenue au ${dojo_name}${NC}"

	# Line 2: Dojo title
	if [ -n "$dojo_title" ]; then
		local pad2
		pad2=$(get_padding "$dojo_title" $banner_width)
		echo -e "${pad2}${WHITE}${dojo_title}${NC}"
	fi

	# Line 3: Stats
	local line3_plain="${total_questions} questions • ${total_points} points • ${exam_duration} min"
	local pad3
	pad3=$(get_padding "$line3_plain" $banner_width)
	echo -e "${pad3}${YELLOW}${total_questions} questions${NC} • ${YELLOW}${total_points} points${NC} • ${YELLOW}${exam_duration} min${NC}"
	echo ""

	# Line 4: Quote
	if [ -n "$dojo_quote" ]; then
		local line4_plain="\"${dojo_quote}\""
		local pad4
		pad4=$(get_padding "$line4_plain" $banner_width)
		echo -e "${pad4}${DIM}\"${dojo_quote}\"${NC}"
		echo ""
	fi

	# Line 5: Credit with URL (if provided)
	if [ -n "$dojo_credit_text" ]; then
		local pad5
		pad5=$(get_padding "$dojo_credit_text" $banner_width)
		echo -e "${pad5}${DIM}${dojo_credit_text}${NC}"
		if [ -n "$dojo_credit_url" ]; then
			local pad_url
			pad_url=$(get_padding "$dojo_credit_url" $banner_width)
			echo -e "${pad_url}${DIM}${dojo_credit_url}${NC}"
		fi
		echo ""
	fi
	echo "─────────────────────────────────────────────────────────────────────────"
	echo ""
}

# Export function for use in subshells
export -f show_dojo_banner 2>/dev/null || true
