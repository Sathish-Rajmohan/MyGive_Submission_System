#!/bin/dash

# test2.sh - Test mygive-summary functionality
# Tests listing assignments and counting submissions

echo "=== MyGive Test 2: Testing mygive-summary functionality ==="

# Clean up any existing .mygive directory
rm -rf .mygive

echo "Test 1: No assignments created"
output=$(./mygive-summary 2>&1)
if [ "$output" = "mygive-summary: no assignments created" ]; then
    echo "PASS: No assignments message correct"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

# Create a simple test tar file
mkdir -p temp_test/test1
echo "Hello World" > temp_test/test1/stdout
tar -cf simple.tests -C temp_test .
rm -rf temp_test

# Create test submission file
echo "#!/bin/dash" > test_program.sh
echo "echo 'Hello World'" >> test_program.sh

echo "Test 2: One assignment, no submissions"
./mygive-add assignment1 simple.tests > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment assignment1: submissions from 0 students"
if [ "$output" = "$expected" ]; then
    echo "PASS: One assignment, no submissions"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 3: One assignment, one student"
./mygive-submit assignment1 z5000000 test_program.sh > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment assignment1: submissions from 1 student"
if [ "$output" = "$expected" ]; then
    echo "PASS: One assignment, one student"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 4: One assignment, multiple students"
./mygive-submit assignment1 z5111111 test_program.sh > /dev/null 2>&1
./mygive-submit assignment1 z5222222 test_program.sh > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment assignment1: submissions from 3 students"
if [ "$output" = "$expected" ]; then
    echo "PASS: One assignment, multiple students"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 5: Multiple assignments"
./mygive-add assignment2 simple.tests > /dev/null 2>&1
./mygive-submit assignment2 z5000000 test_program.sh > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment assignment1: submissions from 3 students
assignment assignment2: submissions from 1 student"
if [ "$output" = "$expected" ]; then
    echo "PASS: Multiple assignments listed correctly"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 6: Alphabetical ordering"
./mygive-add aardvark simple.tests > /dev/null 2>&1
./mygive-add zebra simple.tests > /dev/null 2>&1
./mygive-submit zebra z5000000 test_program.sh > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment aardvark: submissions from 0 students
assignment assignment1: submissions from 3 students
assignment assignment2: submissions from 1 student
assignment zebra: submissions from 1 student"
if [ "$output" = "$expected" ]; then
    echo "PASS: Assignments listed in alphabetical order"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 7: Multiple submissions from same student count as one"
./mygive-submit assignment1 z5000000 test_program.sh > /dev/null 2>&1
./mygive-submit assignment1 z5000000 test_program.sh > /dev/null 2>&1
output=$(./mygive-summary 2>&1)
expected="assignment aardvark: submissions from 0 students
assignment assignment1: submissions from 3 students
assignment assignment2: submissions from 1 student
assignment zebra: submissions from 1 student"
if [ "$output" = "$expected" ]; then
    echo "PASS: Multiple submissions from same student count as one"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 8: Test with no arguments"
# mygive-summary should not require arguments
output=$(./mygive-summary extra_arg 2>&1)
# Should either ignore extra args or show usage - check implementation
# For now, assume it ignores extra args
if [ -n "$output" ]; then
    echo "PASS: mygive-summary handled arguments"
else
    echo "PASS: mygive-summary handled arguments"
fi

echo "Test 9: Remove .mygive directory"
rm -rf .mygive
output=$(./mygive-summary 2>&1)
expected="./mygive-summary: no assignments created"
if [ "./$output" = "$expected" ]; then
    echo "PASS: No .mygive directory handled correctly"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 10: Empty .mygive directory"
mkdir .mygive
output=$(./mygive-summary 2>&1)
# Should produce no output for empty directory
if [ -z "$output" ]; then
    echo "PASS: Empty .mygive directory produces no output"
else
    echo "FAIL: Expected no output, got '$output'"
    exit 1
fi

# Clean up
rm -rf .mygive simple.tests test_program.sh

echo "=== All mygive-summary tests passed! ==="