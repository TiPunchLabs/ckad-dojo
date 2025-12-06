#!/bin/bash
# run-tests.sh - Run all unit tests for CKAD Exam Simulator

# Don't exit on error - we want to run all tests

# Get script directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          CKAD Exam Simulator - Test Runner                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track overall results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
FAILED_TESTS=()

# Find and run all test files
for test_file in "$TESTS_DIR"/test-*.sh; do
    if [ -f "$test_file" ] && [ "$(basename "$test_file")" != "test-framework.sh" ]; then
        ((TOTAL_SUITES++))
        test_name=$(basename "$test_file" .sh)

        echo -e "${YELLOW}Running: $test_name${NC}"
        echo ""

        if bash "$test_file"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
            FAILED_TESTS+=("$test_name")
        fi

        echo ""
    fi
done

# Overall summary
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}                    OVERALL RESULTS${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Test suites run:    $TOTAL_SUITES"
echo -e "  ${GREEN}Suites passed:      $PASSED_SUITES${NC}"

if [ $FAILED_SUITES -gt 0 ]; then
    echo -e "  ${RED}Suites failed:      $FAILED_SUITES${NC}"
    echo ""
    echo -e "${RED}Failed test suites:${NC}"
    for failed in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}• $failed${NC}"
    done
    echo ""
    echo -e "${RED}SOME TESTS FAILED${NC}"
    exit 1
else
    echo -e "  ${GREEN}Suites failed:      0${NC}"
    echo ""
    echo -e "${GREEN}ALL TEST SUITES PASSED${NC}"
    exit 0
fi
