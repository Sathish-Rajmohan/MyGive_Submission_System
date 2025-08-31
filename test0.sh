#!/bin/dash

# test0.sh - Test basic mygive-add functionality
# Tests assignment creation, directory structure, and error handling

echo "=== MyGive Test 0: Testing mygive-add basic functionality ==="

# Clean up any existing .mygive directory
rm -rf .mygive

# Create a simple test tar file
mkdir -p temp_test/test1
echo "Hello World" > temp_test/test1/stdout
echo "42" > temp_test/test1/arguments
tar -cf simple.tests -C temp_test .
rm -rf temp_test

echo "Test 1: Check .mygive doesn't exist initially"
if [ -d ".mygive" ]; then
    echo "FAIL: .mygive directory exists when it shouldn't"
    exit 1
fi
echo "PASS: .mygive directory doesn't exist initially"

echo "Test 2: Create first assignment"
output=$(./mygive-add assignment1 simple.tests 2>&1)
expected="directory .mygive created
assignment assignment1 created"
if [ "$output" = "$expected" ]; then
    echo "PASS: First assignment created with correct output"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 3: Check .mygive directory structure"
if [ ! -d ".mygive" ]; then
    echo "FAIL: .mygive directory not created"
    exit 1
fi
if [ ! -d ".mygive/assignment1" ]; then
    echo "FAIL: assignment1 directory not created"
    exit 1
fi
if [ ! -d ".mygive/assignment1/submissions" ]; then
    echo "FAIL: submissions directory not created"
    exit 1
fi
if [ ! -d ".mygive/assignment1/tests" ]; then
    echo "FAIL: tests directory not created"
    exit 1
fi
if [ ! -f ".mygive/assignment1/tests.tar" ]; then
    echo "FAIL: tests.tar not copied"
    exit 1
fi
echo "PASS: Directory structure created correctly"

echo "Test 4: Check tests were extracted"
if [ ! -d ".mygive/assignment1/tests/test1" ]; then
    echo "FAIL: test1 directory not extracted"
    exit 1
fi
if [ ! -f ".mygive/assignment1/tests/test1/stdout" ]; then
    echo "FAIL: test1/stdout not extracted"
    exit 1
fi
echo "PASS: Tests extracted correctly"

echo "Test 5: Try to create duplicate assignment"
output=$(./mygive-add assignment1 simple.tests 2>&1)
if [ "$output" = "mygive-add: assignment assignment1 already exists" ]; then
    echo "PASS: Duplicate assignment rejected correctly"
else
    echo "FAIL: Expected 'mygive-add: assignment assignment1 already exists', got '$output'"
    exit 1
fi

echo "Test 6: Create second assignment (no directory message)"
output=$(./mygive-add assignment2 simple.tests 2>&1)
expected="assignment assignment2 created"
if [ "$output" = "$expected" ]; then
    echo "PASS: Second assignment created without directory message"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 7: Test invalid assignment name"
output=$(./mygive-add 1invalid simple.tests 2>&1)
expected="mygive-add: invalid assignment: 1invalid"
if [ "$output" = "$expected" ]; then
    echo "PASS: Invalid assignment name rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 8: Test invalid assignment name with special chars"
output=$(./mygive-add "test-name" simple.tests 2>&1)
expected="mygive-add: invalid assignment: test-name"
if [ "$output" = "$expected" ]; then
    echo "PASS: Assignment name with dash rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 9: Test nonexistent tests file"
output=$(./mygive-add assignment3 nonexistent.tests 2>&1)
expected="mygive-add: nonexistent.tests: No such file or directory"
if [ "$output" = "$expected" ]; then
    echo "PASS: Nonexistent tests file rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 10: Test invalid tests file pathname"
output=$(./mygive-add assignment3 "invalid@file.tests" 2>&1)
expected="mygive-add: invalid pathname: invalid@file.tests"
if [ "$output" = "$expected" ]; then
    echo "PASS: Invalid pathname rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

# Clean up
rm -rf .mygive simple.tests

echo "=== All mygive-add tests passed! ==="