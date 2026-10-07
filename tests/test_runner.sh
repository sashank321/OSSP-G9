#!/usr/bin/env bash

# ==============================================================================
# LabRunner Automated Test Suite
# Tests LabRunner Weeks 1-6 functionality
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN="${ROOT_DIR}/bin/labrunner"

PASSED=0
FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# ------------------------------------------------------------------------------
# Build LabRunner
# ------------------------------------------------------------------------------

log_info "Building LabRunner using Makefile..."

make -C "${ROOT_DIR}" clean > /dev/null 2>&1 || true
make -C "${ROOT_DIR}" all

if [[ ! -x "${BIN}" ]]; then
    echo -e "${RED}Error: Executable ${BIN} was not generated.${NC}"
    exit 1
fi

log_info "Running test suite against ${BIN}..."
echo "--------------------------------------------------------"

# ------------------------------------------------------------------------------
# Test 1: Clean exit
# ------------------------------------------------------------------------------

TEST_NAME="Test 1: Clean exit command"

OUTPUT=$(printf "exit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "Goodbye!"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected 'Goodbye!' in output"
fi

# ------------------------------------------------------------------------------
# Test 2: Version and banner
# ------------------------------------------------------------------------------

TEST_NAME="Test 2: Banner and version verification"

OUTPUT=$(printf "exit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "LabRunner Version 6.0"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected 'LabRunner Version 6.0' in output"
fi

# ------------------------------------------------------------------------------
# Test 3: External command execution
# ------------------------------------------------------------------------------

TEST_NAME="Test 3: External command execution"

OUTPUT=$(printf "echo hello\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "hello"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected external echo command to execute"
fi

# ------------------------------------------------------------------------------
# Test 4: Multi-argument command execution
# ------------------------------------------------------------------------------

TEST_NAME="Test 4: Multi-argument command execution"

OUTPUT=$(printf "echo arg1 arg2 arg3\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "arg1 arg2 arg3"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected all command arguments to be passed to execvp()"
fi

# ------------------------------------------------------------------------------
# Test 5: Whitespace and tab handling
# ------------------------------------------------------------------------------

TEST_NAME="Test 5: Whitespace/tab delimiter handling"

OUTPUT=$(printf "\t  echo \t\t hello   world   \t\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "hello world"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to handle spaces and tabs correctly"
fi

# ------------------------------------------------------------------------------
# Test 6: Dynamic input buffer expansion
# ------------------------------------------------------------------------------

TEST_NAME="Test 6: Dynamic line buffer expansion (>64 chars)"

LONG_TEXT="this_is_a_very_long_input_string_designed_to_exceed_the_initial_sixty_four_byte_buffer_limit_and_verify_realloc_expansion"

OUTPUT=$(printf "echo %s\nexit\n" "${LONG_TEXT}" | "${BIN}")

if echo "${OUTPUT}" | grep -q "${LONG_TEXT}"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to handle input exceeding the initial buffer capacity"
fi

# ------------------------------------------------------------------------------
# Test 7: Dynamic token vector expansion
# ------------------------------------------------------------------------------

TEST_NAME="Test 7: Dynamic token vector expansion (>64 tokens)"

MANY_TOKENS=""

for i in $(seq 1 70); do
    MANY_TOKENS="${MANY_TOKENS} arg${i}"
done

OUTPUT=$(printf "echo%s\nexit\n" "${MANY_TOKENS}" | "${BIN}")

if echo "${OUTPUT}" | grep -q "arg70"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Failed to process more than 64 command tokens"
fi

# ------------------------------------------------------------------------------
# Test 8: pwd built-in
# ------------------------------------------------------------------------------

TEST_NAME="Test 8: pwd built-in"

OUTPUT=$(printf "pwd\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "${ROOT_DIR}"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "pwd did not report the LabRunner working directory"
fi

# ------------------------------------------------------------------------------
# Test 9: cd built-in
# ------------------------------------------------------------------------------

TEST_NAME="Test 9: cd built-in"

OUTPUT=$(printf "cd /tmp\npwd\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "/tmp"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "cd did not change the LabRunner working directory"
fi

# ------------------------------------------------------------------------------
# Test 10: help built-in
# ------------------------------------------------------------------------------

TEST_NAME="Test 10: help built-in"

OUTPUT=$(printf "help\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "LabRunner Built-in Commands:" && \
   echo "${OUTPUT}" | grep -q "cd <directory>" && \
   echo "${OUTPUT}" | grep -q "pwd" && \
   echo "${OUTPUT}" | grep -q "help" && \
   echo "${OUTPUT}" | grep -q "clear" && \
   echo "${OUTPUT}" | grep -q "exit"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Help output is incomplete"
fi

# ------------------------------------------------------------------------------
# Test 11: Environment variables
# ------------------------------------------------------------------------------

TEST_NAME="Test 11: Environment variable support"

OUTPUT=$(printf "env\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "^HOME="; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected HOME environment variable in env output"
fi

# ------------------------------------------------------------------------------
# Test 12: Invalid command handling
# ------------------------------------------------------------------------------

TEST_NAME="Test 12: Invalid command error handling"

OUTPUT=$(printf "labrunner_invalid_command_xyz\nexit\n" | "${BIN}" 2>&1)

if echo "${OUTPUT}" | grep -q "LabRunner:"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Expected LabRunner error message for invalid command"
fi

# ------------------------------------------------------------------------------
# Test 13: Child process synchronization
# ------------------------------------------------------------------------------

TEST_NAME="Test 13: Child process synchronization"

OUTPUT=$(printf "echo child_process_test\nexit\n" | "${BIN}")

if echo "${OUTPUT}" | grep -q "child_process_test" && \
   echo "${OUTPUT}" | grep -q "Goodbye!"; then
    log_pass "${TEST_NAME}"
else
    log_fail "${TEST_NAME}" "Child command did not complete before LabRunner continued"
fi

echo "--------------------------------------------------------"
echo -e "Test Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}"

if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi

echo -e "${GREEN}All tests passed!${NC}"
