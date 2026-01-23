#!/bin/bash
# test-framework.sh - Simple bash testing framework for CKAD Exam Simulator
# Provides basic assertion functions and test running utilities

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_TEST=""

# ============================================================================
# ASSERTION FUNCTIONS
# ============================================================================

# Assert that a condition is true
# Usage: assert_true "condition" "message"
assert_true() {
	local condition="$1"
	local message="${2:-Assertion failed}"
	((TESTS_RUN++))

	if eval "$condition"; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Expected: true${NC}"
		echo -e "    ${RED}Condition: $condition${NC}"
		return 1
	fi
}

# Assert that two values are equal
# Usage: assert_equals "expected" "actual" "message"
assert_equals() {
	local expected="$1"
	local actual="$2"
	local message="${3:-Values should be equal}"
	((TESTS_RUN++))

	if [ "$expected" = "$actual" ]; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Expected: '$expected'${NC}"
		echo -e "    ${RED}Actual:   '$actual'${NC}"
		return 1
	fi
}

# Assert that a value is not empty
# Usage: assert_not_empty "$value" "message"
assert_not_empty() {
	local value="$1"
	local message="${2:-Value should not be empty}"
	((TESTS_RUN++))

	if [ -n "$value" ]; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Value is empty${NC}"
		return 1
	fi
}

# Assert that a file exists
# Usage: assert_file_exists "/path/to/file" "message"
assert_file_exists() {
	local file="$1"
	local message="${2:-File should exist: $file}"
	((TESTS_RUN++))

	if [ -f "$file" ]; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}File not found: $file${NC}"
		return 1
	fi
}

# Assert that a directory exists
# Usage: assert_dir_exists "/path/to/dir" "message"
assert_dir_exists() {
	local dir="$1"
	local message="${2:-Directory should exist: $dir}"
	((TESTS_RUN++))

	if [ -d "$dir" ]; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Directory not found: $dir${NC}"
		return 1
	fi
}

# Assert that a function exists
# Usage: assert_function_exists "function_name" "message"
assert_function_exists() {
	local func="$1"
	local message="${2:-Function should exist: $func}"
	((TESTS_RUN++))

	if declare -f "$func" >/dev/null; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Function not found: $func${NC}"
		return 1
	fi
}

# Assert that a command succeeds (exit code 0)
# Usage: assert_success "command" "message"
assert_success() {
	local cmd="$1"
	local message="${2:-Command should succeed}"
	((TESTS_RUN++))

	if eval "$cmd" >/dev/null 2>&1; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Command failed: $cmd${NC}"
		return 1
	fi
}

# Assert that a command fails (exit code != 0)
# Usage: assert_fails "command" "message"
assert_fails() {
	local cmd="$1"
	local message="${2:-Command should fail}"
	((TESTS_RUN++))

	if ! eval "$cmd" >/dev/null 2>&1; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Command succeeded but should have failed: $cmd${NC}"
		return 1
	fi
}

# Assert that output contains a string
# Usage: assert_contains "$(command)" "expected_substring" "message"
assert_contains() {
	local output="$1"
	local expected="$2"
	local message="${3:-Output should contain: $expected}"
	((TESTS_RUN++))

	if [[ "$output" == *"$expected"* ]]; then
		((TESTS_PASSED++))
		echo -e "  ${GREEN}✓${NC} $message"
		return 0
	else
		((TESTS_FAILED++))
		echo -e "  ${RED}✗${NC} $message"
		echo -e "    ${RED}Expected to contain: '$expected'${NC}"
		echo -e "    ${RED}Actual output: '$output'${NC}"
		return 1
	fi
}

# ============================================================================
# TEST RUNNING FUNCTIONS
# ============================================================================

# Start a test suite
# Usage: test_suite "Suite Name"
test_suite() {
	local name="$1"
	echo ""
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
	echo -e "${YELLOW}TEST SUITE: $name${NC}"
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
}

# Start a test case
# Usage: test_case "Test Name"
test_case() {
	CURRENT_TEST="$1"
	echo ""
	echo -e "▸ $CURRENT_TEST"
}

# Print test summary
# Usage: test_summary
test_summary() {
	echo ""
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
	echo -e "${YELLOW}TEST SUMMARY${NC}"
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
	echo ""
	echo "  Tests run:    $TESTS_RUN"
	echo -e "  ${GREEN}Passed:       $TESTS_PASSED${NC}"

	if [ $TESTS_FAILED -gt 0 ]; then
		echo -e "  ${RED}Failed:       $TESTS_FAILED${NC}"
		echo ""
		echo -e "${RED}TESTS FAILED${NC}"
		return 1
	else
		echo -e "  ${GREEN}Failed:       0${NC}"
		echo ""
		echo -e "${GREEN}ALL TESTS PASSED${NC}"
		return 0
	fi
}

# Reset test counters
# Usage: reset_tests
reset_tests() {
	TESTS_RUN=0
	TESTS_PASSED=0
	TESTS_FAILED=0
	CURRENT_TEST=""
}

# Skip a test
# Usage: skip_test "reason"
skip_test() {
	local reason="${1:-No reason given}"
	echo -e "  ${YELLOW}○${NC} SKIPPED: $reason"
}

# Check if an exam has all required files (not gitignored)
# Usage: exam_is_complete "exam_id" "$PROJECT_DIR"
# Returns 0 if complete, 1 if incomplete
exam_is_complete() {
	local exam_id="$1"
	local project_dir="$2"
	local exam_dir="$project_dir/exams/$exam_id"

	# Check for required files
	[ -f "$exam_dir/scoring-functions.sh" ] &&
		[ -f "$exam_dir/questions.md" ] &&
		[ -f "$exam_dir/solutions.md" ] &&
		[ -d "$exam_dir/manifests/setup" ]
}
