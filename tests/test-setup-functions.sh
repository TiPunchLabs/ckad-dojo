#!/bin/bash
# test-setup-functions.sh - Unit tests for scripts/lib/setup-functions.sh

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Source test framework
source "$TESTS_DIR/test-framework.sh"

# Source the module under test
source "$PROJECT_DIR/scripts/lib/setup-functions.sh"

# ============================================================================
# TEST SUITE: setup-functions.sh
# ============================================================================

test_suite "setup-functions.sh - Setup and Cleanup Functions"

# ----------------------------------------------------------------------------
# Test: Setup functions exist
# ----------------------------------------------------------------------------
test_case "Setup functions are defined"

assert_function_exists "setup_namespaces" "setup_namespaces function should exist"
assert_function_exists "setup_resources" "setup_resources function should exist"
assert_function_exists "setup_directories" "setup_directories function should exist"
assert_function_exists "setup_templates" "setup_templates function should exist"
assert_function_exists "setup_registry" "setup_registry function should exist"
assert_function_exists "setup_helm" "setup_helm function should exist"

# ----------------------------------------------------------------------------
# Test: Cleanup functions exist
# ----------------------------------------------------------------------------
test_case "Cleanup functions are defined"

assert_function_exists "cleanup_namespaces" "cleanup_namespaces function should exist"
assert_function_exists "cleanup_helm" "cleanup_helm function should exist"
assert_function_exists "cleanup_directories" "cleanup_directories function should exist"
assert_function_exists "cleanup_registry" "cleanup_registry function should exist"
assert_function_exists "wait_for_namespace_deletion" "wait_for_namespace_deletion function should exist"

# ----------------------------------------------------------------------------
# Test: Exam configuration variables with load_exam
# ----------------------------------------------------------------------------
test_case "Setup functions use dynamic exam configuration"

# Load simulation1 if complete, otherwise use simulation2 for first test
if exam_is_complete "ckad-simulation1" "$PROJECT_DIR"; then
	load_exam "ckad-simulation1"

	assert_not_empty "$CURRENT_MANIFESTS_DIR" "CURRENT_MANIFESTS_DIR should be set after load_exam"
	assert_not_empty "$CURRENT_TEMPLATES_DIR" "CURRENT_TEMPLATES_DIR should be set after load_exam"
	assert_contains "$CURRENT_MANIFESTS_DIR" "ckad-simulation1" "Manifests dir should contain exam id"
	assert_contains "$CURRENT_TEMPLATES_DIR" "ckad-simulation1" "Templates dir should contain exam id"

	# Verify namespaces are from config
	assert_true '[ ${#EXAM_NAMESPACES[@]} -gt 0 ]' "EXAM_NAMESPACES should have elements"
	assert_contains "${EXAM_NAMESPACES[*]}" "neptune" "simulation1 should have neptune namespace"
else
	skip_test "simulation1 files are gitignored - testing with simulation2 only"
fi

# Load simulation2 and verify different namespaces
load_exam "ckad-simulation2"

assert_not_empty "$CURRENT_MANIFESTS_DIR" "CURRENT_MANIFESTS_DIR should be set after load_exam"
assert_contains "$CURRENT_MANIFESTS_DIR" "ckad-simulation2" "Manifests dir should contain exam id"
assert_contains "${EXAM_NAMESPACES[*]}" "blaze" "simulation2 should have blaze namespace"

# ----------------------------------------------------------------------------
# Test: Exam directory structure
# ----------------------------------------------------------------------------
test_case "Exam directory structures exist"

# Check simulation1 structure (may be gitignored)
assert_dir_exists "$PROJECT_DIR/exams/ckad-simulation1" "simulation1 exam dir should exist"
assert_file_exists "$PROJECT_DIR/exams/ckad-simulation1/exam.conf" "simulation1 exam.conf should exist"
if exam_is_complete "ckad-simulation1" "$PROJECT_DIR"; then
	assert_file_exists "$PROJECT_DIR/exams/ckad-simulation1/questions.md" "simulation1 questions.md should exist"
	assert_file_exists "$PROJECT_DIR/exams/ckad-simulation1/scoring-functions.sh" "simulation1 scoring-functions.sh should exist"
	assert_dir_exists "$PROJECT_DIR/exams/ckad-simulation1/manifests/setup" "simulation1 manifests/setup should exist"
	assert_dir_exists "$PROJECT_DIR/exams/ckad-simulation1/templates" "simulation1 templates should exist"
else
	skip_test "simulation1 files are gitignored"
fi

# Check simulation2 structure
assert_dir_exists "$PROJECT_DIR/exams/ckad-simulation2" "simulation2 exam dir should exist"
assert_file_exists "$PROJECT_DIR/exams/ckad-simulation2/exam.conf" "simulation2 exam.conf should exist"
assert_file_exists "$PROJECT_DIR/exams/ckad-simulation2/questions.md" "simulation2 questions.md should exist"
assert_file_exists "$PROJECT_DIR/exams/ckad-simulation2/scoring-functions.sh" "simulation2 scoring-functions.sh should exist"

# ----------------------------------------------------------------------------
# Test: Manifest files exist
# ----------------------------------------------------------------------------
test_case "Manifest files exist for both exams"

if exam_is_complete "ckad-simulation1" "$PROJECT_DIR"; then
	assert_file_exists "$PROJECT_DIR/exams/ckad-simulation1/manifests/setup/namespaces.yaml" "simulation1 namespaces.yaml should exist"
else
	skip_test "simulation1 manifests are gitignored"
fi
assert_file_exists "$PROJECT_DIR/exams/ckad-simulation2/manifests/setup/namespaces.yaml" "simulation2 namespaces.yaml should exist"

# ----------------------------------------------------------------------------
# Test: HELM configuration
# ----------------------------------------------------------------------------
test_case "Helm configuration is set in exam configs"

if exam_is_complete "ckad-simulation1" "$PROJECT_DIR"; then
	load_exam "ckad-simulation1"
	assert_not_empty "$HELM_NAMESPACE" "HELM_NAMESPACE should be set for simulation1"
	assert_true '[ ${#HELM_RELEASES[@]} -gt 0 ]' "HELM_RELEASES should have elements for simulation1"
else
	skip_test "simulation1 files are gitignored"
fi

load_exam "ckad-simulation2"
assert_not_empty "$HELM_NAMESPACE" "HELM_NAMESPACE should be set for simulation2"
assert_true '[ ${#HELM_RELEASES[@]} -gt 0 ]' "HELM_RELEASES should have elements for simulation2"

# ============================================================================
# SUMMARY
# ============================================================================

test_summary
exit $?
