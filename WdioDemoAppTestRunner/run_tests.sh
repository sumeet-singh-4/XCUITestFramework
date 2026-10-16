#!/bin/bash

# Quick test runner for WdioDemoAppTestRunner
# Usage: ./run_tests.sh [test_class] [test_method]

PROJECT_DIR="/Users/sumesing/New_Softwares/XCUITestFramework/WdioDemoAppTestRunner"
SCHEME="WdioDemoAppTestRunner"
SIMULATOR_ID="1F09C945-1B90-4173-A744-992774EED514"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cd "$PROJECT_DIR"

echo -e "${YELLOW}🧪 Running XCUITests for wdiodemoapp${NC}\n"

# Determine what to test
if [ -z "$1" ]; then
    # No arguments - run all tests
    TEST_TARGET="WdioDemoAppUITests"
    echo -e "${GREEN}Running ALL UI tests${NC}\n"
elif [ -z "$2" ]; then
    # One argument - run specific test class
    TEST_TARGET="WdioDemoAppUITests/$1"
    echo -e "${GREEN}Running test class: $1${NC}\n"
else
    # Two arguments - run specific test method
    TEST_TARGET="WdioDemoAppUITests/$1/$2"
    echo -e "${GREEN}Running test: $1.$2${NC}\n"
fi

# Run tests
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -only-testing:"$TEST_TARGET" \
  | grep -E "(Test Case|Test Suite|passed|failed|^\*\*)" || true

# Check exit status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "\n${GREEN}✅ Tests Passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Tests Failed!${NC}"
    exit 1
fi
