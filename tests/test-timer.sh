#!/bin/bash
# test-timer.sh - Unit tests for scripts/lib/timer.sh

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Source test framework
source "$TESTS_DIR/test-framework.sh"

# Use isolated temp directory for timer state during tests
export TIMER_STATE_DIR=$(mktemp -d)

# Source the module under test
source "$PROJECT_DIR/scripts/lib/timer.sh"

# Cleanup function
cleanup_timer_tests() {
    # Kill any timer processes
    if [ -f "$TIMER_PID_FILE" ]; then
        _pid=$(cat "$TIMER_PID_FILE" 2>/dev/null)
        [ -n "$_pid" ] && kill "$_pid" 2>/dev/null
    fi
    rm -rf "$TIMER_STATE_DIR"
}
trap cleanup_timer_tests EXIT

# ============================================================================
# TEST SUITE: timer.sh
# ============================================================================

test_suite "timer.sh - Timer Functions"

# ----------------------------------------------------------------------------
# Test: Timer state variables
# ----------------------------------------------------------------------------
test_case "Timer state variables are set correctly"

assert_not_empty "$TIMER_STATE_DIR" "TIMER_STATE_DIR should be set"
assert_not_empty "$TIMER_PID_FILE" "TIMER_PID_FILE should be set"
assert_not_empty "$TIMER_STATE_FILE" "TIMER_STATE_FILE should be set"
assert_not_empty "$TIMER_LOG_FILE" "TIMER_LOG_FILE should be set"

# ----------------------------------------------------------------------------
# Test: Color variables
# ----------------------------------------------------------------------------
test_case "Timer color variables are defined"

assert_not_empty "$TIMER_RED" "TIMER_RED color should be defined"
assert_not_empty "$TIMER_GREEN" "TIMER_GREEN color should be defined"
assert_not_empty "$TIMER_YELLOW" "TIMER_YELLOW color should be defined"
assert_not_empty "$TIMER_BLUE" "TIMER_BLUE color should be defined"
assert_not_empty "$TIMER_CYAN" "TIMER_CYAN color should be defined"
assert_not_empty "$TIMER_NC" "TIMER_NC (no color) should be defined"
assert_not_empty "$TIMER_BOLD" "TIMER_BOLD should be defined"

# ----------------------------------------------------------------------------
# Test: Timer functions exist
# ----------------------------------------------------------------------------
test_case "Timer functions are defined"

assert_function_exists "timer_init" "timer_init function should exist"
assert_function_exists "format_time" "format_time function should exist"
assert_function_exists "get_time_color" "get_time_color function should exist"
assert_function_exists "timer_start" "timer_start function should exist"
assert_function_exists "timer_stop" "timer_stop function should exist"
assert_function_exists "timer_is_running" "timer_is_running function should exist"
assert_function_exists "timer_remaining" "timer_remaining function should exist"
assert_function_exists "timer_status" "timer_status function should exist"
assert_function_exists "timer_display" "timer_display function should exist"
assert_function_exists "timer_compact" "timer_compact function should exist"
assert_function_exists "timer_watch" "timer_watch function should exist"
assert_function_exists "timer_pause" "timer_pause function should exist"
assert_function_exists "timer_reset" "timer_reset function should exist"
assert_function_exists "timer_info" "timer_info function should exist"

# ----------------------------------------------------------------------------
# Test: timer_init function
# ----------------------------------------------------------------------------
test_case "timer_init creates state directory"

rm -rf "$TIMER_STATE_DIR"
timer_init
assert_dir_exists "$TIMER_STATE_DIR" "timer_init should create state directory"

# ----------------------------------------------------------------------------
# Test: format_time function
# ----------------------------------------------------------------------------
test_case "format_time formats seconds correctly"

assert_equals "00:00:00" "$(format_time 0)" "0 seconds = 00:00:00"
assert_equals "00:00:30" "$(format_time 30)" "30 seconds = 00:00:30"
assert_equals "00:01:00" "$(format_time 60)" "60 seconds = 00:01:00"
assert_equals "00:01:30" "$(format_time 90)" "90 seconds = 00:01:30"
assert_equals "00:10:00" "$(format_time 600)" "600 seconds = 00:10:00"
assert_equals "01:00:00" "$(format_time 3600)" "3600 seconds = 01:00:00"
assert_equals "01:30:00" "$(format_time 5400)" "5400 seconds = 01:30:00"
assert_equals "02:00:00" "$(format_time 7200)" "7200 seconds = 02:00:00"
assert_equals "01:23:45" "$(format_time 5025)" "5025 seconds = 01:23:45"

# ----------------------------------------------------------------------------
# Test: get_time_color function
# ----------------------------------------------------------------------------
test_case "get_time_color returns correct colors based on remaining time"

# Test with 15 minute warning (default)
_warning=15

# Normal time (more than warning threshold) - green
_color_normal=$(get_time_color 1800 $_warning)  # 30 min remaining
assert_contains "$_color_normal" "32m" "Should be green when time > warning"

# Warning time (less than warning but more than 1 min) - yellow
_color_warning=$(get_time_color 600 $_warning)  # 10 min remaining
assert_contains "$_color_warning" "33m" "Should be yellow during warning period"

# Critical time (1 min or less) - red with blink
_color_critical=$(get_time_color 45 $_warning)  # 45 sec remaining
assert_contains "$_color_critical" "31m" "Should be red in last minute"

# ----------------------------------------------------------------------------
# Test: timer_is_running when not running
# ----------------------------------------------------------------------------
test_case "timer_is_running returns false when no timer"

rm -f "$TIMER_PID_FILE"
assert_true '! timer_is_running' "Should return false when timer not running"

# ----------------------------------------------------------------------------
# Test: timer_status when not running
# ----------------------------------------------------------------------------
test_case "timer_status returns 'not_running' when no timer"

rm -f "$TIMER_PID_FILE"
_status=$(timer_status)
assert_equals "not_running" "$_status" "Status should be 'not_running'"

# ----------------------------------------------------------------------------
# Test: timer_remaining when no state
# ----------------------------------------------------------------------------
test_case "timer_remaining returns 0 when no timer state"

rm -f "$TIMER_STATE_FILE"
_remaining=$(timer_remaining)
assert_equals "0" "$_remaining" "Should return 0 when no state file"

# ----------------------------------------------------------------------------
# Test: timer_compact when not running
# ----------------------------------------------------------------------------
test_case "timer_compact shows 'NO TIMER' when not running"

rm -f "$TIMER_PID_FILE"
_output=$(timer_compact)
assert_equals "NO TIMER" "$_output" "Should show 'NO TIMER' when not running"

# ----------------------------------------------------------------------------
# Test: timer_pause shows not supported message
# ----------------------------------------------------------------------------
test_case "timer_pause shows not supported message"

_pause_output=$(timer_pause 2>&1)
assert_contains "$_pause_output" "not supported" "Should indicate pause not supported"

# ----------------------------------------------------------------------------
# Test: timer_info with no state
# ----------------------------------------------------------------------------
test_case "timer_info handles missing state"

rm -f "$TIMER_STATE_FILE"
_info_output=$(timer_info 2>&1)
assert_contains "$_info_output" "No timer state" "Should show no state message"

# ----------------------------------------------------------------------------
# Test: timer_display when not running
# ----------------------------------------------------------------------------
test_case "timer_display shows message when not running"

rm -f "$TIMER_PID_FILE"
_display_output=$(timer_display 2>&1)
assert_contains "$_display_output" "not running" "Should indicate timer not running"

# ----------------------------------------------------------------------------
# Test: timer_start creates state file
# Note: Background process tests are skipped due to subshell limitations
# ----------------------------------------------------------------------------
test_case "timer_start creates state file with correct content"

timer_init
# Start timer and immediately capture output
timer_start 60 10 "UnitTestExam" >/dev/null 2>&1 &
_timer_pid=$!
sleep 0.2

# Check files were created
assert_file_exists "$TIMER_STATE_FILE" "State file should exist after start"

# Check state file content using grep (avoid sourcing issues)
_duration=$(grep "^DURATION=" "$TIMER_STATE_FILE" 2>/dev/null | cut -d= -f2)
_warning=$(grep "^WARNING=" "$TIMER_STATE_FILE" 2>/dev/null | cut -d= -f2)
_exam_name=$(grep "^EXAM_NAME=" "$TIMER_STATE_FILE" 2>/dev/null | cut -d= -f2)
_start_time=$(grep "^START_TIME=" "$TIMER_STATE_FILE" 2>/dev/null | cut -d= -f2)
_end_time=$(grep "^END_TIME=" "$TIMER_STATE_FILE" 2>/dev/null | cut -d= -f2)

assert_equals "60" "$_duration" "DURATION should be 60"
assert_equals "10" "$_warning" "WARNING should be 10"
assert_equals "UnitTestExam" "$_exam_name" "EXAM_NAME should be set"
assert_not_empty "$_start_time" "START_TIME should be set"
assert_not_empty "$_end_time" "END_TIME should be set"

# Cleanup
kill $_timer_pid 2>/dev/null
timer_stop 2>/dev/null

# ----------------------------------------------------------------------------
# Test: timer_reset clears state
# ----------------------------------------------------------------------------
test_case "timer_reset removes state directory"

# Create state dir and file
timer_init
echo "TEST=value" > "$TIMER_STATE_FILE"

# Reset should remove everything
timer_reset >/dev/null 2>&1

assert_true '[ ! -d "$TIMER_STATE_DIR" ]' "State directory should be removed after reset"

# Recreate for cleanup trap
export TIMER_STATE_DIR=$(mktemp -d)

# ============================================================================
# SUMMARY
# ============================================================================

test_summary
exit $?
