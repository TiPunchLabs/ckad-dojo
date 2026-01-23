#!/bin/bash
# test-scoring.sh - Integration tests for scoring-functions.sh across all exams

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Source test framework
source "$TESTS_DIR/test-framework.sh"

# Source common utilities
source "$PROJECT_DIR/scripts/lib/common.sh"

# ============================================================================
# TEST SUITE: Scoring Integration Tests
# ============================================================================

test_suite "Scoring Integration Tests"

# Get list of all exams
_exams=$(list_available_exams)

# Filter to only complete exams (some may be gitignored like simulation1)
_complete_exams=""
for _exam in $_exams; do
	if exam_is_complete "$_exam" "$PROJECT_DIR"; then
		_complete_exams="$_complete_exams $_exam"
	else
		echo -e "  ${YELLOW}○${NC} Skipping $_exam (incomplete - files may be gitignored)"
	fi
done
_exams=$(echo "$_complete_exams" | xargs)

# ----------------------------------------------------------------------------
# Test: Each exam has required scoring file
# ----------------------------------------------------------------------------
test_case "Each exam has a scoring-functions.sh file"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"
	assert_file_exists "$_scoring_file" "$_exam should have scoring-functions.sh"
done

# ----------------------------------------------------------------------------
# Test: Each exam has valid exam.conf
# ----------------------------------------------------------------------------
test_case "Each exam has valid exam.conf with TOTAL_QUESTIONS"

for _exam in $_exams; do
	_conf_file="$PROJECT_DIR/exams/$_exam/exam.conf"
	assert_file_exists "$_conf_file" "$_exam should have exam.conf"

	# Source config and check TOTAL_QUESTIONS
	source "$_conf_file"
	assert_not_empty "$TOTAL_QUESTIONS" "$_exam exam.conf should define TOTAL_QUESTIONS"
	assert_true '[ "$TOTAL_QUESTIONS" -gt 0 ]' "$_exam TOTAL_QUESTIONS should be positive"
done

# ----------------------------------------------------------------------------
# Test: Scoring files are valid bash syntax
# ----------------------------------------------------------------------------
test_case "Scoring files have valid bash syntax"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"
	_syntax_check=$(bash -n "$_scoring_file" 2>&1)
	assert_equals "" "$_syntax_check" "$_exam scoring file should have valid bash syntax"
done

# ----------------------------------------------------------------------------
# Test: Each exam has scoring function for each question
# ----------------------------------------------------------------------------
test_case "Each exam has score_qN functions for all questions"

for _exam in $_exams; do
	_conf_file="$PROJECT_DIR/exams/$_exam/exam.conf"
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	# Get total questions from config
	source "$_conf_file"
	_total=$TOTAL_QUESTIONS

	# Check each scoring function exists
	for _q in $(seq 1 $_total); do
		_func="score_q$_q"
		_found=$(grep -c "^score_q$_q()" "$_scoring_file" 2>/dev/null || echo "0")
		assert_true "[ $_found -ge 1 ]" "$_exam should have $_func function"
	done
done

# ----------------------------------------------------------------------------
# Test: Scoring functions return valid format
# ----------------------------------------------------------------------------
test_case "Scoring functions follow score/denominator format pattern"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	# Check that functions use echo "$score/$total" or echo "$score/$max_points" pattern
	_echo_total=$(grep -cE 'echo "\$score/\$total"' "$_scoring_file" 2>/dev/null || true)
	_echo_max=$(grep -cE 'echo "\$score/\$max_points"' "$_scoring_file" 2>/dev/null || true)
	_echo_pattern=$((${_echo_total:-0} + ${_echo_max:-0}))
	assert_true "[ $_echo_pattern -gt 0 ]" "$_exam scoring functions should use echo \"\$score/\$total\" or \"\$score/\$max_points\" pattern"
done

# ----------------------------------------------------------------------------
# Test: Each exam scoring file sources common utilities
# ----------------------------------------------------------------------------
test_case "Scoring files source common utilities"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	# Accept sourcing common.sh directly or via scoring-functions.sh (which sources common.sh)
	_sources_common=$(grep -c 'source.*common.sh' "$_scoring_file" 2>/dev/null || echo "0")
	_sources_scoring=$(grep -c 'source.*scoring-functions.sh' "$_scoring_file" 2>/dev/null || echo "0")
	_total_sources=$((_sources_common + _sources_scoring))
	assert_true "[ $_total_sources -ge 1 ]" "$_exam scoring file should source common utilities"
done

# ----------------------------------------------------------------------------
# Test: Question counts match across files
# ----------------------------------------------------------------------------
test_case "TOTAL_QUESTIONS matches actual scoring function count"

for _exam in $_exams; do
	_conf_file="$PROJECT_DIR/exams/$_exam/exam.conf"
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	source "$_conf_file"
	_expected=$TOTAL_QUESTIONS

	# Count actual score_qN functions (with or without space before parentheses)
	_actual=$(grep -cE "^score_q[0-9]+\s*\(\)" "$_scoring_file" 2>/dev/null || echo "0")

	assert_equals "$_expected" "$_actual" "$_exam should have $_expected scoring functions (found $_actual)"
done

# ----------------------------------------------------------------------------
# Test: Points defined in exam.conf match scoring
# ----------------------------------------------------------------------------
test_case "TOTAL_POINTS is defined and reasonable"

for _exam in $_exams; do
	_conf_file="$PROJECT_DIR/exams/$_exam/exam.conf"
	source "$_conf_file"

	assert_not_empty "$TOTAL_POINTS" "$_exam should have TOTAL_POINTS defined"
	assert_true '[ "$TOTAL_POINTS" -gt 50 ]' "$_exam TOTAL_POINTS should be > 50"
	assert_true '[ "$TOTAL_POINTS" -lt 200 ]' "$_exam TOTAL_POINTS should be < 200"
done

# ----------------------------------------------------------------------------
# Test: Check helper functions are defined
# ----------------------------------------------------------------------------
test_case "Common scoring helper functions are available"

assert_function_exists "namespace_exists" "namespace_exists helper should exist"
assert_function_exists "resource_exists" "resource_exists helper should exist"
assert_function_exists "file_exists_and_not_empty" "file_exists_and_not_empty helper should exist"
assert_function_exists "file_contains" "file_contains helper should exist"

# ----------------------------------------------------------------------------
# Test: Each exam has questions.md with matching question count
# ----------------------------------------------------------------------------
test_case "questions.md has matching question count"

for _exam in $_exams; do
	_conf_file="$PROJECT_DIR/exams/$_exam/exam.conf"
	_questions_file="$PROJECT_DIR/exams/$_exam/questions.md"

	source "$_conf_file"
	_expected=$TOTAL_QUESTIONS

	# Count questions (## Question N pattern)
	_actual=$(grep -c "^## Question [0-9]" "$_questions_file" 2>/dev/null || echo "0")

	assert_equals "$_expected" "$_actual" "$_exam questions.md should have $_expected questions (found $_actual)"
done

# ----------------------------------------------------------------------------
# Test: Each exam has solutions.md
# ----------------------------------------------------------------------------
test_case "Each exam has solutions.md"

for _exam in $_exams; do
	_solutions_file="$PROJECT_DIR/exams/$_exam/solutions.md"
	assert_file_exists "$_solutions_file" "$_exam should have solutions.md"
done

# ----------------------------------------------------------------------------
# Test: Scoring functions define points variable (total or max_points)
# ----------------------------------------------------------------------------
test_case "Scoring functions define points variable"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	# Count total or max_points definitions (exams use one or the other)
	_total_count=$(grep -c 'local total=' "$_scoring_file" 2>/dev/null || true)
	_max_count=$(grep -c 'local max_points=' "$_scoring_file" 2>/dev/null || true)
	_points_count=$((${_total_count:-0} + ${_max_count:-0}))

	source "$PROJECT_DIR/exams/$_exam/exam.conf"
	_expected=$TOTAL_QUESTIONS

	# At least one per scoring function, possibly more for helpers
	assert_true "[ $_points_count -ge $_expected ]" "$_exam should have at least $_expected points variable definitions (found $_points_count)"
done

# ----------------------------------------------------------------------------
# Test: Scoring functions initialize score to 0
# ----------------------------------------------------------------------------
test_case "Scoring functions initialize score variable"

for _exam in $_exams; do
	_scoring_file="$PROJECT_DIR/exams/$_exam/scoring-functions.sh"

	# Count score=0 initializations (may have extra in helper functions)
	_score_init_count=$(grep -c 'local score=0' "$_scoring_file" 2>/dev/null || echo "0")

	source "$PROJECT_DIR/exams/$_exam/exam.conf"
	_expected=$TOTAL_QUESTIONS

	# At least one per scoring function, possibly more for helpers
	assert_true "[ $_score_init_count -ge $_expected ]" "$_exam should have at least $_expected score=0 initializations (found $_score_init_count)"
done

# ============================================================================
# SUMMARY
# ============================================================================

test_summary
exit $?
