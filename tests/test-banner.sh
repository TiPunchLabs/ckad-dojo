#!/bin/bash
# test-banner.sh - Unit tests for scripts/lib/banner.sh

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

# Source test framework
source "$TESTS_DIR/test-framework.sh"

# Source the module under test
source "$PROJECT_DIR/scripts/lib/banner.sh"

# ============================================================================
# TEST SUITE: banner.sh
# ============================================================================

test_suite "banner.sh - Dojo Welcome Banner"

# ----------------------------------------------------------------------------
# Test: Color variables
# ----------------------------------------------------------------------------
test_case "Color variables are defined"

assert_not_empty "$CYAN" "CYAN color should be defined"
assert_not_empty "$GREEN" "GREEN color should be defined"
assert_not_empty "$YELLOW" "YELLOW color should be defined"
assert_not_empty "$WHITE" "WHITE color should be defined"
assert_not_empty "$DIM" "DIM style should be defined"
assert_not_empty "$NC" "NC (no color) should be defined"

# ----------------------------------------------------------------------------
# Test: Banner constant
# ----------------------------------------------------------------------------
test_case "DOJO_BANNER constant is defined"

assert_not_empty "$DOJO_BANNER" "DOJO_BANNER should be defined"
# Banner is ASCII art using Unicode box characters
assert_contains "$DOJO_BANNER" "██" "Banner should contain ASCII art blocks"
assert_contains "$DOJO_BANNER" "╔" "Banner should contain box drawing characters"

# ----------------------------------------------------------------------------
# Test: show_dojo_banner function exists
# ----------------------------------------------------------------------------
test_case "show_dojo_banner function is defined"

assert_function_exists "show_dojo_banner" "show_dojo_banner function should exist"

# ----------------------------------------------------------------------------
# Test: show_dojo_banner output without exam_id
# ----------------------------------------------------------------------------
test_case "show_dojo_banner displays default content"

_banner_output=$(show_dojo_banner 2>&1)

assert_contains "$_banner_output" "CKAD" "Output should contain CKAD"
assert_contains "$_banner_output" "Bienvenue" "Output should contain welcome message"
assert_contains "$_banner_output" "questions" "Output should mention questions"
assert_contains "$_banner_output" "points" "Output should mention points"
assert_contains "$_banner_output" "min" "Output should mention duration"

# ----------------------------------------------------------------------------
# Test: show_dojo_banner with valid exam_id
# ----------------------------------------------------------------------------
test_case "show_dojo_banner loads exam configuration"

# Test with simulation1
_banner_sim1=$(show_dojo_banner "ckad-simulation1" 2>&1)
assert_contains "$_banner_sim1" "Seiryu" "Simulation1 should show Seiryu dojo name"

# Test with simulation2
_banner_sim2=$(show_dojo_banner "ckad-simulation2" 2>&1)
assert_contains "$_banner_sim2" "Suzaku" "Simulation2 should show Suzaku dojo name"

# ----------------------------------------------------------------------------
# Test: show_dojo_banner with invalid exam_id uses defaults
# ----------------------------------------------------------------------------
test_case "show_dojo_banner handles invalid exam_id gracefully"

_banner_invalid=$(show_dojo_banner "nonexistent-exam" 2>&1)

# Should still display something (fallback to defaults)
assert_contains "$_banner_invalid" "CKAD" "Should fallback to displaying CKAD"
assert_contains "$_banner_invalid" "Bienvenue" "Should still show welcome message"

# ----------------------------------------------------------------------------
# Test: Banner separator line
# ----------------------------------------------------------------------------
test_case "show_dojo_banner includes separator line"

_banner_output=$(show_dojo_banner 2>&1)
assert_contains "$_banner_output" "─" "Output should contain separator line"

# ============================================================================
# SUMMARY
# ============================================================================

test_summary
exit $?
