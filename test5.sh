#!/bin/dash

# Test script for mygive-test functionality

echo "=== MyGive Test 5: Testing mygive-test functionality ==="

# Clean up any existing .mygive directory
if [ -d ".mygive" ]; then
    rm -rf .mygive
fi

# Create test files needed for testing
cat > simple_test.sh << 'EOF'
#!/bin/dash
echo "Hello World"
EOF

cat > multiply.py << 'EOF'
#!/usr/bin/python3
import sys
a = int(sys.argv[1])
b = int(input())
print(a * b)
EOF

cat > args_test.sh << 'EOF'
#!/bin/dash
echo "$@"
EOF

cat > failing_test.sh << 'EOF'
#!/bin/dash
echo "Wrong output"
exit 1
EOF

cat > exit_test.sh << 'EOF'
#!/bin/dash
exit 1
EOF

# Make all test scripts executable
chmod +x simple_test.sh multiply.py args_test.sh failing_test.sh exit_test.sh

# Create a simple test archive
mkdir -p test_archive/simple_test
echo "Hello World" > test_archive/simple_test/stdout
echo "0" > test_archive/simple_test/exit_status

mkdir -p test_archive/args_test
echo "-e arg1 arg2 arg3" > test_archive/args_test/arguments
echo "arg1 arg2 arg3" > test_archive/args_test/stdout

mkdir -p test_archive/multiply_test
echo "3" > test_archive/multiply_test/arguments
echo "5" > test_archive/multiply_test/stdin
echo "15" > test_archive/multiply_test/stdout

mkdir -p test_archive/exit_test
echo "test" > test_archive/exit_test/arguments
echo "" > test_archive/exit_test/stdout
echo "1" > test_archive/exit_test/exit_status

mkdir -p test_archive/marking_test
echo "Hello World" > test_archive/marking_test/stdout
echo "10" > test_archive/marking_test/marks

cd test_archive && tar -cf ../test_basic.tar * && cd ..
rm -rf test_archive

echo "Test 1: Basic mygive-test functionality"
./mygive-add test_basic test_basic.tar > /dev/null
if [ $? -eq 0 ]; then
    echo " Assignment created successfully"
else
    echo " Failed to create assignment"
fi

echo "Test 1a: Running tests on simple program"
output=$(./mygive-test test_basic simple_test.sh 2>&1)
if echo "$output" | grep -q "simple_test passed"; then
    echo " Simple test passed as expected"
else
    echo " Simple test failed unexpectedly"
    echo "Output: $output"
fi

echo "Test 2: Testing program with arguments"
output=$(./mygive-test test_basic args_test.sh 2>&1)
if echo "$output" | grep -q "args_test passed" && echo "$output" | grep -q "exit_test passed" && echo "$output" | grep -q "multiply_test passed" && echo "$output" | grep -q "simple_test passed"; then
    echo " Arguments test passed"
else
    echo " Arguments test failed"
    echo "Output: $output"
fi

echo "Test 3: Testing program with stdin"
output=$(./mygive-test test_basic multiply.py 2>&1)
if echo "$output" | grep -q "multiply_test passed"; then
    echo " Multiply test passed"
else
    echo " Multiply test failed"
    echo "Output: $output"
fi

echo "Test 4: Testing program that should fail"
output=$(./mygive-test test_basic failing_test.sh 2>&1)
if echo "$output" | grep -q "tests failed"; then
    echo " Failing test detected correctly"
else
    echo " Failing test not detected"
    echo "Output: $output"
fi

echo "Test 5: Verify marking tests are ignored"
output=$(./mygive-test test_basic simple_test.sh 2>&1)
if echo "$output" | grep -q "marking_test"; then
    echo " Marking tests not ignored"
else
    echo " Marking tests correctly ignored"
fi

echo "Test 6: Testing error conditions"
output=$(./mygive-test Invalid123 simple_test.sh 2>&1)
if echo "$output" | grep -q "invalid assignment"; then
    echo " Invalid assignment name rejected"
else
    echo " Invalid assignment name not rejected"
fi

output=$(./mygive-test nonexistent simple_test.sh 2>&1)
if echo "$output" | grep -q "not found"; then
    echo " Non-existent assignment detected"
else
    echo " Non-existent assignment not detected"
fi

output=$(./mygive-test test_basic nonexistent.sh 2>&1)
if echo "$output" | grep -q "No such file"; then
    echo " Non-existent file detected"
else
    echo " Non-existent file not detected"
fi

echo "Test 7: Testing summary output format"
output=$(./mygive-test test_basic simple_test.sh 2>&1)
if echo "$output" | grep -q "\\*\\* .* tests passed, .* tests failed"; then
    echo " Summary format correct"
else
    echo " Summary format incorrect"
fi

echo "Test 8: Testing argument validation"
output=$(./mygive-test 2>&1)
if echo "$output" | grep -q "usage:"; then
    echo " Usage message shown for no arguments"
else
    echo " Usage message not shown for no arguments"
fi

output=$(./mygive-test test_basic 2>&1)
if echo "$output" | grep -q "usage:"; then
    echo " Usage message shown for insufficient arguments"
else
    echo " Usage message not shown for insufficient arguments"
fi

# Clean up
rm -f simple_test.sh multiply.py args_test.sh failing_test.sh exit_test.sh test_basic.tar
rm -rf .mygive

echo "=== mygive-test testing completed ==="