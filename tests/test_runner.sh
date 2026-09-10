#!/usr/bin/env bash
# ==============================================================================
# LabRunner Automated Test Suite
# Tests parser, memory reallocation, and REPL lifecycle
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN="${ROOT_DIR}/bin/labrunner"

PASSED=0
FAILED=0

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1: $2"
    FAILED=$((FAILED + 1))
}

# Ensure binary is built
log_info "Building LabRunner using Makefile..."
make -C "${ROOT_DIR}" clean > /dev/null 2>&1 || true
make -C "${ROOT_DIR}" all

if [[ ! -x "${BIN}" ]]; then
    echo -e "${RED}Error: Executable ${BIN} was not generated.${NC}"
    exit 1
fi

log_info "Running test suite against ${BIN}..."
echo "--------------------------------------------------------"

# Test 1: Clean exit command
TEST_NAME="Test 1: Clean exit command"
OUTPUT=$(printf "exit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "Goodbye!"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected 'Goodbye!' in output"
fi

# Test 2: Version and banner display
TEST_NAME="Test 2: Banner and version verification"
OUTPUT=$(printf "exit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "LabRunner Version 3.0"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected 'LabRunner Version 3.0' in output"
fi

# Test 3: Single token command parsing
TEST_NAME="Test 3: Single token command parsing"
OUTPUT=$(printf "ls\nexit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "argv\[0\] = ls"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected 'argv[0] = ls'"
fi

# Test 4: Multi-argument command tokenization
TEST_NAME="Test 4: Multi-argument command tokenization"
OUTPUT=$(printf "gcc -Wall -Wextra main.c -o test\nexit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "argv\[0\] = gcc" && \
   echo "${OUTPUT}" | grep -q "argv\[1\] = -Wall" && \
   echo "${OUTPUT}" | grep -q "argv\[2\] = -Wextra" && \
   echo "${OUTPUT}" | grep -q "argv\[3\] = main.c" && \
   echo "${OUTPUT}" | grep -q "argv\[4\] = -o" && \
   echo "${OUTPUT}" | grep -q "argv\[5\] = test"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to tokenize all arguments correctly"
fi

# Test 5: Whitespace and tab delimiter handling
TEST_NAME="Test 5: Complex whitespace/tab delimiter handling"
OUTPUT=$(printf "\t  cat \t\t file.txt   \t\nexit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "argv\[0\] = cat" && \
   echo "${OUTPUT}" | grep -q "argv\[1\] = file.txt"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to parse tokens separated by tabs/spaces"
fi

# Test 6: Buffer expansion test (input > 64 chars)
TEST_NAME="Test 6: Dynamic line buffer expansion (>64 chars)"
LONG_INPUT="echo this_is_a_very_long_input_string_designed_specifically_to_exceed_the_initial_sixty_four_byte_buffer_limit_and_verify_realloc_expansion\nexit\n"
OUTPUT=$(printf "${LONG_INPUT}" | "${BIN}")
if echo "${OUTPUT}" | grep -q "argv\[0\] = echo" && \
   echo "${OUTPUT}" | grep -q "argv\[1\] = this_is_a_very_long_input_string_designed_specifically_to_exceed_the_initial_sixty_four_byte_buffer_limit_and_verify_realloc_expansion"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to handle input exceeding initial buffer capacity"
fi

# Test 7: Multi-token buffer expansion (>64 tokens)
TEST_NAME="Test 7: Dynamic token vector expansion (>64 tokens)"
MANY_TOKENS="cmd"
for i in $(seq 1 70); do
    MANY_TOKENS="${MANY_TOKENS} arg${i}"
done
OUTPUT=$(printf "${MANY_TOKENS}\nexit\n" | "${BIN}")
if echo "${OUTPUT}" | grep -q "argv\[0\] = cmd" && \
   echo "${OUTPUT}" | grep -q "argv\[70\] = arg70"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to expand token buffer past 64 tokens"
fi

echo "--------------------------------------------------------"
echo -e "Test Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}"

if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi

exit 0
