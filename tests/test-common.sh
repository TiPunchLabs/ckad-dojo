#!/bin/bash
# test-common.sh - Unit tests for scripts/lib/common.sh

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Source test framework
source "$TESTS_DIR/test-framework.sh"

# Source the module under test
source "$PROJECT_DIR/scripts/lib/common.sh"

# ============================================================================
# TEST SUITE: common.sh
# ============================================================================

test_suite "common.sh - Core Utilities"

# ----------------------------------------------------------------------------
# Test: Directory variables
# ----------------------------------------------------------------------------
test_case "Directory variables are set correctly"

assert_not_empty "$SCRIPT_DIR" "SCRIPT_DIR should be set"
assert_not_empty "$PROJECT_DIR" "PROJECT_DIR should be set"
assert_not_empty "$EXAMS_DIR" "EXAMS_DIR should be set"
assert_dir_exists "$EXAMS_DIR" "EXAMS_DIR should exist"

# ----------------------------------------------------------------------------
# Test: Color variables
# ----------------------------------------------------------------------------
test_case "Color variables are defined"

assert_not_empty "$RED" "RED color should be defined"
assert_not_empty "$GREEN" "GREEN color should be defined"
assert_not_empty "$YELLOW" "YELLOW color should be defined"
assert_not_empty "$BLUE" "BLUE color should be defined"
assert_not_empty "$NC" "NC (no color) should be defined"

# ----------------------------------------------------------------------------
# Test: Print functions exist
# ----------------------------------------------------------------------------
test_case "Print functions are defined"

assert_function_exists "print_header" "print_header function should exist"
assert_function_exists "print_footer" "print_footer function should exist"
assert_function_exists "print_section" "print_section function should exist"
assert_function_exists "print_success" "print_success function should exist"
assert_function_exists "print_fail" "print_fail function should exist"
assert_function_exists "print_skip" "print_skip function should exist"
assert_function_exists "print_error" "print_error function should exist"

# ----------------------------------------------------------------------------
# Test: Utility functions exist
# ----------------------------------------------------------------------------
test_case "Utility functions are defined"

assert_function_exists "command_exists" "command_exists function should exist"
assert_function_exists "check_prerequisites" "check_prerequisites function should exist"
assert_function_exists "namespace_exists" "namespace_exists function should exist"
assert_function_exists "resource_exists" "resource_exists function should exist"
assert_function_exists "file_exists_and_not_empty" "file_exists_and_not_empty function should exist"
assert_function_exists "file_contains" "file_contains function should exist"

# ----------------------------------------------------------------------------
# Test: Exam configuration functions exist
# ----------------------------------------------------------------------------
test_case "Exam configuration functions are defined"

assert_function_exists "load_exam" "load_exam function should exist"
assert_function_exists "list_available_exams" "list_available_exams function should exist"
assert_function_exists "exam_exists" "exam_exists function should exist"

# ----------------------------------------------------------------------------
# Test: command_exists function
# ----------------------------------------------------------------------------
test_case "command_exists function works correctly"

assert_true 'command_exists bash' "bash command should exist"
assert_true 'command_exists ls' "ls command should exist"
assert_true '! command_exists nonexistent_command_xyz' "nonexistent command should not exist"

# ----------------------------------------------------------------------------
# Test: file_exists_and_not_empty function
# ----------------------------------------------------------------------------
test_case "file_exists_and_not_empty function works correctly"

# Create temp file for testing
TEMP_FILE=$(mktemp)
echo "content" >"$TEMP_FILE"
EMPTY_FILE=$(mktemp)

assert_true "file_exists_and_not_empty '$TEMP_FILE'" "Non-empty file should return true"
assert_true '! file_exists_and_not_empty "$EMPTY_FILE"' "Empty file should return false"
assert_true '! file_exists_and_not_empty "/nonexistent/file"' "Nonexistent file should return false"

# Cleanup
rm -f "$TEMP_FILE" "$EMPTY_FILE"

# ----------------------------------------------------------------------------
# Test: file_contains function
# ----------------------------------------------------------------------------
test_case "file_contains function works correctly"

TEMP_FILE=$(mktemp)
echo "hello world" >"$TEMP_FILE"

assert_true "file_contains '$TEMP_FILE' 'hello'" "Should find 'hello' in file"
assert_true "file_contains '$TEMP_FILE' 'world'" "Should find 'world' in file"
assert_true '! file_contains "$TEMP_FILE" "notfound"' "Should not find 'notfound' in file"

rm -f "$TEMP_FILE"

# ----------------------------------------------------------------------------
# Test: exam_exists function
# ----------------------------------------------------------------------------
test_case "exam_exists function works correctly"

assert_true 'exam_exists "ckad-simulation1"' "ckad-simulation1 should exist"
assert_true 'exam_exists "ckad-simulation2"' "ckad-simulation2 should exist"
assert_true '! exam_exists "nonexistent-exam"' "nonexistent-exam should not exist"

# ----------------------------------------------------------------------------
# Test: list_available_exams function
# ----------------------------------------------------------------------------
test_case "list_available_exams function works correctly"

exams=$(list_available_exams)
assert_contains "$exams" "ckad-simulation1" "Should list ckad-simulation1"
assert_contains "$exams" "ckad-simulation2" "Should list ckad-simulation2"

# ----------------------------------------------------------------------------
# Test: load_exam function
# ----------------------------------------------------------------------------
test_case "load_exam function works correctly"

# Load simulation1
if load_exam "ckad-simulation1"; then
	assert_equals "ckad-simulation1" "$CURRENT_EXAM_ID" "CURRENT_EXAM_ID should be set"
	assert_not_empty "$EXAM_NAME" "EXAM_NAME should be set"
	assert_not_empty "$TOTAL_QUESTIONS" "TOTAL_QUESTIONS should be set"
	assert_not_empty "$TOTAL_POINTS" "TOTAL_POINTS should be set"
	assert_true '[ ${#EXAM_NAMESPACES[@]} -gt 0 ]' "EXAM_NAMESPACES should have elements"
else
	assert_true 'false' "load_exam should succeed for ckad-simulation1"
fi

# Load simulation2
if load_exam "ckad-simulation2"; then
	assert_equals "ckad-simulation2" "$CURRENT_EXAM_ID" "CURRENT_EXAM_ID should be set for simulation2"
	assert_contains "${EXAM_NAMESPACES[*]}" "blaze" "simulation2 should have blaze namespace"
else
	assert_true 'false' "load_exam should succeed for ckad-simulation2"
fi

# Try to load nonexistent exam
assert_true '! load_exam "nonexistent-exam" 2>/dev/null' "load_exam should fail for nonexistent exam"

# ----------------------------------------------------------------------------
# Test: Docker functions exist
# ----------------------------------------------------------------------------
test_case "Docker utility functions are defined"

assert_function_exists "docker_container_running" "docker_container_running function should exist"
assert_function_exists "docker_image_exists" "docker_image_exists function should exist"

# ----------------------------------------------------------------------------
# Test: ttyd functions exist
# ----------------------------------------------------------------------------
test_case "ttyd utility functions are defined"

assert_function_exists "check_ttyd" "check_ttyd function should exist"
assert_function_exists "start_ttyd" "start_ttyd function should exist"
assert_function_exists "stop_ttyd" "stop_ttyd function should exist"

# ----------------------------------------------------------------------------
# Test: ttyd variables are set
# ----------------------------------------------------------------------------
test_case "ttyd configuration variables are set"

assert_not_empty "$TTYD_PORT" "TTYD_PORT should be set"
assert_not_empty "$TTYD_PID_FILE" "TTYD_PID_FILE should be set"
assert_equals "7682" "$TTYD_PORT" "TTYD_PORT should default to 7682"

# ----------------------------------------------------------------------------
# Test: Print functions output behavior
# ----------------------------------------------------------------------------
test_case "Print functions produce correct output"

# Test print_success includes checkmark
_success_output=$(print_success "test message" 2>&1)
assert_contains "$_success_output" "✓" "print_success should include checkmark"
assert_contains "$_success_output" "test message" "print_success should include message"

# Test print_fail includes X mark
_fail_output=$(print_fail "error message" 2>&1)
assert_contains "$_fail_output" "✗" "print_fail should include X mark"
assert_contains "$_fail_output" "error message" "print_fail should include message"

# Test print_skip includes circle
_skip_output=$(print_skip "skipped" 2>&1)
assert_contains "$_skip_output" "○" "print_skip should include circle"
assert_contains "$_skip_output" "skipped" "print_skip should include reason"

# Test print_error outputs to stderr
_error_output=$(print_error "error" 2>&1)
assert_contains "$_error_output" "ERROR" "print_error should include ERROR tag"

# Test print_section includes INFO tag
_section_output=$(print_section "section" 2>&1)
assert_contains "$_section_output" "INFO" "print_section should include INFO tag"

# ----------------------------------------------------------------------------
# Test: Additional utility functions exist
# ----------------------------------------------------------------------------
test_case "Additional utility functions are defined"

assert_function_exists "safe_apply" "safe_apply function should exist"
assert_function_exists "get_resource_field" "get_resource_field function should exist"
assert_function_exists "open_browser_tab" "open_browser_tab function should exist"
assert_function_exists "open_docs_tabs" "open_docs_tabs function should exist"

# ----------------------------------------------------------------------------
# Test: Default exam configuration
# ----------------------------------------------------------------------------
test_case "Default exam configuration is set"

assert_not_empty "$DEFAULT_EXAM_ID" "DEFAULT_EXAM_ID should be set"
assert_equals "ckad-simulation1" "$DEFAULT_EXAM_ID" "DEFAULT_EXAM_ID should be ckad-simulation1"

# ----------------------------------------------------------------------------
# Test: Legacy path variables
# ----------------------------------------------------------------------------
test_case "Legacy path variables are defined"

assert_not_empty "$EXAM_DIR" "EXAM_DIR should be set"
assert_contains "$EXAM_DIR" "exam/course" "EXAM_DIR should contain exam/course"

# ----------------------------------------------------------------------------
# Test: Load exam sets all required paths
# ----------------------------------------------------------------------------
test_case "load_exam sets all required paths"

# Use a complete exam for this test (simulation1 may be gitignored)
_test_exam="ckad-simulation1"
if ! exam_is_complete "$_test_exam" "$PROJECT_DIR"; then
	_test_exam="ckad-simulation2"
fi

load_exam "$_test_exam" >/dev/null 2>&1
assert_not_empty "$CURRENT_EXAM_DIR" "CURRENT_EXAM_DIR should be set"
assert_not_empty "$CURRENT_MANIFESTS_DIR" "CURRENT_MANIFESTS_DIR should be set"
assert_not_empty "$CURRENT_TEMPLATES_DIR" "CURRENT_TEMPLATES_DIR should be set"
assert_not_empty "$CURRENT_QUESTIONS_FILE" "CURRENT_QUESTIONS_FILE should be set"
assert_not_empty "$CURRENT_SCORING_FILE" "CURRENT_SCORING_FILE should be set"
assert_dir_exists "$CURRENT_EXAM_DIR" "CURRENT_EXAM_DIR should exist"
assert_dir_exists "$CURRENT_MANIFESTS_DIR" "CURRENT_MANIFESTS_DIR should exist"

# ============================================================================
# SUMMARY
# ============================================================================

test_summary
exit $?
