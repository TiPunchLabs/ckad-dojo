#!/bin/bash
# timer.sh - Timer functions for CKAD Exam Simulator
# Provides countdown timer functionality with on-screen display

# Timer state file
TIMER_STATE_DIR="${TIMER_STATE_DIR:-/tmp/ckad-exam-timer}"
TIMER_PID_FILE="$TIMER_STATE_DIR/timer.pid"
TIMER_STATE_FILE="$TIMER_STATE_DIR/timer.state"
TIMER_LOG_FILE="$TIMER_STATE_DIR/timer.log"

# Colors
TIMER_RED='\033[0;31m'
TIMER_GREEN='\033[0;32m'
TIMER_YELLOW='\033[1;33m'
TIMER_BLUE='\033[0;34m'
TIMER_CYAN='\033[0;36m'
TIMER_NC='\033[0m'
TIMER_BOLD='\033[1m'
TIMER_BLINK='\033[5m'

# Initialize timer directory
timer_init() {
    mkdir -p "$TIMER_STATE_DIR"
}

# Format seconds to HH:MM:SS
format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

# Get color based on remaining time
get_time_color() {
    local remaining=$1
    local warning_time=$2

    if [ $remaining -le 60 ]; then
        # Last minute - red blinking
        echo -e "${TIMER_BLINK}${TIMER_RED}"
    elif [ $remaining -le $((warning_time * 60)) ]; then
        # Warning time - yellow
        echo -e "${TIMER_YELLOW}"
    else
        # Normal - green
        echo -e "${TIMER_GREEN}"
    fi
}

# Start the timer display (runs in background)
# Usage: timer_start <duration_minutes> <warning_minutes> <exam_name>
timer_start() {
    local duration_minutes=${1:-120}
    local warning_minutes=${2:-15}
    local exam_name=${3:-"CKAD Exam"}

    timer_init

    # Check if timer is already running
    if timer_is_running; then
        echo "Timer is already running. Use 'timer_stop' to stop it first."
        return 1
    fi

    local total_seconds=$((duration_minutes * 60))
    local warning_seconds=$((warning_minutes * 60))
    local start_time=$(date +%s)
    local end_time=$((start_time + total_seconds))

    # Save state
    echo "START_TIME=$start_time" > "$TIMER_STATE_FILE"
    echo "END_TIME=$end_time" >> "$TIMER_STATE_FILE"
    echo "DURATION=$duration_minutes" >> "$TIMER_STATE_FILE"
    echo "WARNING=$warning_minutes" >> "$TIMER_STATE_FILE"
    echo "EXAM_NAME=$exam_name" >> "$TIMER_STATE_FILE"
    echo "STATUS=running" >> "$TIMER_STATE_FILE"

    # Start background timer process
    (
        trap 'exit 0' TERM INT

        while true; do
            local current_time=$(date +%s)
            local remaining=$((end_time - current_time))

            if [ $remaining -le 0 ]; then
                # Time's up!
                echo "STATUS=expired" >> "$TIMER_STATE_FILE"
                _timer_display_expired "$exam_name"
                exit 0
            fi

            # Update state
            sed -i "s/^STATUS=.*/STATUS=running/" "$TIMER_STATE_FILE" 2>/dev/null
            echo "REMAINING=$remaining" >> "$TIMER_STATE_FILE"

            sleep 1
        done
    ) &

    local timer_pid=$!
    echo $timer_pid > "$TIMER_PID_FILE"

    echo "Timer started for $duration_minutes minutes"
    echo "PID: $timer_pid"

    return 0
}

# Display expired message
_timer_display_expired() {
    local exam_name=$1
    echo ""
    echo -e "${TIMER_RED}${TIMER_BOLD}╔═══════════════════════════════════════════════════════════════╗${TIMER_NC}"
    echo -e "${TIMER_RED}${TIMER_BOLD}║                      TIME'S UP!                               ║${TIMER_NC}"
    echo -e "${TIMER_RED}${TIMER_BOLD}║                                                               ║${TIMER_NC}"
    echo -e "${TIMER_RED}${TIMER_BOLD}║   $exam_name has ended.                             ║${TIMER_NC}"
    echo -e "${TIMER_RED}${TIMER_BOLD}║   Run ckad-score.sh to see your results.                      ║${TIMER_NC}"
    echo -e "${TIMER_RED}${TIMER_BOLD}╚═══════════════════════════════════════════════════════════════╝${TIMER_NC}"
    echo ""
}

# Stop the timer
timer_stop() {
    if [ -f "$TIMER_PID_FILE" ]; then
        local pid=$(cat "$TIMER_PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            kill $pid 2>/dev/null
            echo "Timer stopped"
        fi
        rm -f "$TIMER_PID_FILE"
    fi

    if [ -f "$TIMER_STATE_FILE" ]; then
        sed -i "s/^STATUS=.*/STATUS=stopped/" "$TIMER_STATE_FILE" 2>/dev/null
    fi
}

# Check if timer is running
timer_is_running() {
    if [ -f "$TIMER_PID_FILE" ]; then
        local pid=$(cat "$TIMER_PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Get remaining time in seconds
timer_remaining() {
    if [ -f "$TIMER_STATE_FILE" ]; then
        source "$TIMER_STATE_FILE"
        local current_time=$(date +%s)
        local remaining=$((END_TIME - current_time))
        if [ $remaining -lt 0 ]; then
            echo 0
        else
            echo $remaining
        fi
    else
        echo 0
    fi
}

# Get timer status string
timer_status() {
    if ! timer_is_running; then
        echo "not_running"
        return
    fi

    if [ -f "$TIMER_STATE_FILE" ]; then
        source "$TIMER_STATE_FILE"
        echo "${STATUS:-unknown}"
    else
        echo "unknown"
    fi
}

# Display current timer status (one-shot, for embedding in prompt or status bar)
timer_display() {
    if ! timer_is_running; then
        echo -e "${TIMER_YELLOW}[Timer not running]${TIMER_NC}"
        return
    fi

    source "$TIMER_STATE_FILE" 2>/dev/null

    local remaining=$(timer_remaining)
    local warning_seconds=$((WARNING * 60))
    local color=$(get_time_color $remaining $WARNING)
    local formatted=$(format_time $remaining)

    echo -e "${color}⏱  ${EXAM_NAME}: ${formatted} remaining${TIMER_NC}"
}

# Display compact timer (for status bar)
timer_compact() {
    if ! timer_is_running; then
        echo "NO TIMER"
        return
    fi

    local remaining=$(timer_remaining)
    local formatted=$(format_time $remaining)
    echo "$formatted"
}

# Interactive timer display (blocks and updates every second)
# Press Ctrl+C to exit back to prompt
timer_watch() {
    if ! timer_is_running; then
        echo "Timer is not running. Start it with 'timer_start'"
        return 1
    fi

    source "$TIMER_STATE_FILE" 2>/dev/null

    echo ""
    echo -e "${TIMER_CYAN}${TIMER_BOLD}Watching timer for: $EXAM_NAME${TIMER_NC}"
    echo -e "${TIMER_CYAN}Press Ctrl+C to return to prompt${TIMER_NC}"
    echo ""

    trap 'echo ""; return 0' INT

    while timer_is_running; do
        local remaining=$(timer_remaining)
        local warning_seconds=$((WARNING * 60))
        local color=$(get_time_color $remaining $WARNING)
        local formatted=$(format_time $remaining)

        # Move cursor up and clear line
        echo -ne "\r\033[K"

        # Display timer box
        echo -ne "${color}╔═══════════════════════════════════╗${TIMER_NC}\r"
        echo -ne "\n${color}║     ⏱  TIME REMAINING: ${formatted}     ║${TIMER_NC}\r"
        echo -ne "\n${color}╚═══════════════════════════════════╝${TIMER_NC}"
        echo -ne "\033[2A\r"  # Move cursor back up

        if [ $remaining -le 0 ]; then
            echo ""
            echo ""
            echo ""
            _timer_display_expired "$EXAM_NAME"
            break
        fi

        sleep 1
    done

    trap - INT
}

# Pause the timer (not implemented - just stops)
timer_pause() {
    echo "Pause not supported. Use timer_stop to stop the timer."
}

# Reset the timer (stop and clear state)
timer_reset() {
    timer_stop
    rm -rf "$TIMER_STATE_DIR"
    echo "Timer reset"
}

# Show timer info
timer_info() {
    if [ ! -f "$TIMER_STATE_FILE" ]; then
        echo "No timer state found"
        return 1
    fi

    source "$TIMER_STATE_FILE"

    echo ""
    echo -e "${TIMER_BLUE}╔═══════════════════════════════════════════════════════════════╗${TIMER_NC}"
    echo -e "${TIMER_BLUE}║                      TIMER INFO                               ║${TIMER_NC}"
    echo -e "${TIMER_BLUE}╠═══════════════════════════════════════════════════════════════╣${TIMER_NC}"
    echo -e "${TIMER_BLUE}║${TIMER_NC} Exam:       $EXAM_NAME"
    echo -e "${TIMER_BLUE}║${TIMER_NC} Duration:   $DURATION minutes"
    echo -e "${TIMER_BLUE}║${TIMER_NC} Warning at: $WARNING minutes remaining"
    echo -e "${TIMER_BLUE}║${TIMER_NC} Status:     $STATUS"

    if timer_is_running; then
        local remaining=$(timer_remaining)
        local formatted=$(format_time $remaining)
        local color=$(get_time_color $remaining $WARNING)
        echo -e "${TIMER_BLUE}║${TIMER_NC} Remaining:  ${color}${formatted}${TIMER_NC}"
    fi

    echo -e "${TIMER_BLUE}╚═══════════════════════════════════════════════════════════════╝${TIMER_NC}"
    echo ""
}

# Export functions
export -f timer_init timer_start timer_stop timer_is_running
export -f timer_remaining timer_status timer_display timer_compact
export -f timer_watch timer_reset timer_info format_time
