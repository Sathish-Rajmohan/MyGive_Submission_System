#!/bin/dash

# test3.sh - Test mygive-status functionality
# Tests listing student submissions across assignments

echo "=== MyGive Test 3: Testing mygive-status functionality ==="

# Clean up any existing .mygive directory
rm -rf .mygive

echo "Test 1: No assignments created"
output=$(./mygive-status z5000000 2>&1)
if [ "$output" = "mygive-status: no assignments created" ]; then
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

# Create test submission files
echo "#!/bin/dash" > test_program1.sh
echo "echo 'Hello World'" >> test_program1.sh

echo "#!/bin/dash" > test_program2.sh
echo "echo 'Goodbye World'" >> test_program2.sh

echo "Test 2: Student with no submissions"
./mygive-add assignment1 simple.tests > /dev/null 2>&1
output=$(./mygive-status z5000000 2>&1)
expected="no submissions for z5000000"
if [ "$output" = "$expected" ]; then
    echo "PASS: No submissions message correct"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 3: Student with one submission"
./mygive-submit assignment1 z5000000 test_program1.sh > /dev/null 2>&1
output=$(./mygive-status z5000000 2>&1)
if echo "$output" | grep -q "* 1 submissions for assignment1" && echo "$output" | grep -q "submission 1: test_program1.sh"; then
    echo "PASS: One submission listed correctly"
else
    echo "FAIL: One submission not listed correctly"
    echo "Got: $output"
    exit 1
fi

echo "Test 4: Student with multiple submissions to same assignment"
./mygive-submit assignment1 z5000000 test_program2.sh > /dev/null 2>&1
output=$(./mygive-status z5000000 2>&1)
if echo "$output" | grep -q "* 2 submissions for assignment1" && \
   echo "$output" | grep -q "submission 1: test_program1.sh" && \
   echo "$output" | grep -q "submission 2: test_program2.sh"; then
    echo "PASS: Multiple submissions to same assignment listed correctly"
else
    echo "FAIL: Multiple submissions not listed correctly"
    echo "Got: $output"
    exit 1
fi

echo "Test 5: Student with submissions to multiple assignments"
./mygive-add assignment2 simple.tests > /dev/null 2>&1
./mygive-submit assignment2 z5000000 test_program1.sh > /dev/null 2>&1
output=$(./mygive-status z5000000 2>&1)
if echo "$output" | grep -q "* 2 submissions for assignment1" && \
   echo "$output" | grep -q "* 1 submissions for assignment2"; then
    echo "PASS: Submissions to multiple assignments listed correctly"
else
    echo "FAIL: Submissions to multiple assignments not listed correctly"
    echo "Got: $output"
    exit 1
fi

echo "Test 6: Alphabetical ordering of assignments"
./mygive-add aardvark simple.tests > /dev/null 2>&1
./mygive-add zebra simple.tests > /dev/null 2>&1
./mygive-submit zebra z5000000 test_program1.sh > /dev/null 2>&1
./mygive-submit aardvark z5000000 test_program2.sh > /dev/null 2>&1
output=$(./mygive-status z5000000 2>&1)
# Should list aardvark before assignment1, assignment2, zebra
if echo "$output" | head -1 | grep -q "aardvark"; then
    echo "PASS: Assignments listed in alphabetical order"
else
    echo "FAIL: Assignments not in alphabetical order"
    echo "Got: $output"
    exit 1
fi

echo "Test 7: Different student"
./mygive-submit assignment1 z5111111 test_program1.sh > /dev/null 2>&1
output=$(./mygive-status z5111111 2>&1)
if echo "$output" | grep -q "* 1 submissions for assignment1" && \
   ! echo "$output" | grep -q "assignment2"; then
    echo "PASS: Different student shows only their submissions"
else
    echo "FAIL: Different student shows incorrect submissions"
    echo "Got: $output"
    exit 1
fi

echo "Test 8: Invalid zid"
output=$(./mygive-status z500000 2>&1)
expected="./mygive-status: invalid zid: z500000"
if [ "./$output" = "$expected" ]; then
    echo "PASS: Invalid zid rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 9: Invalid zid format"
output=$(./mygive-status student123 2>&1)
expected="./mygive-status: invalid zid: student123"
if [ "./$output" = "$expected" ]; then
    echo "PASS: Invalid zid format rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 10: Wrong number of arguments"
output=$(./mygive-status 2>&1)
expected="usage: mygive-status <zid>"
if [ "$output" = "$expected" ]; then
    echo "PASS: Wrong number of arguments rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

echo "Test 11: Too many arguments"
output=$(./mygive-status z5000000 extra 2>&1)
expected="usage: mygive-status <zid>"
if [ "$output" = "$expected" ]; then
    echo "PASS: Too many arguments rejected"
else
    echo "FAIL: Expected '$expected', got '$output'"
    exit 1
fi

# Clean up
rm -rf .mygive simple.tests test_program1.sh test_program2.sh

echo "=== All mygive-status tests passed! ==="