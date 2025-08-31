#!/bin/dash

# Test 6: mygive-mark functionality
# Tests running marking tests on student submissions

echo "=== MyGive Test 6: mygive-mark functionality ==="

# Clean up
rm -rf .mygive

# Create test files with marking tests
cat > marking.tests << 'EOF'
test1/
test1/stdout
test1/stdin
test1/arguments
marking1/
marking1/stdout
marking1/stdin
marking1/arguments
marking1/marks
marking2/
marking2/stdout
marking2/stdin
marking2/arguments
marking2/marks
EOF

# Create test directories and files
mkdir -p test1 marking1 marking2

# Non-marking test
echo "Expected output" > test1/stdout
echo "input data" > test1/stdin
echo "arg1 arg2" > test1/arguments

# Marking tests
echo "Correct answer" > marking1/stdout
echo "test input" > marking1/stdin
echo "param1" > marking1/arguments
echo "10" > marking1/marks

echo "Another correct answer" > marking2/stdout
echo "another input" > marking2/stdin
echo "param2 param3" > marking2/arguments
echo "25" > marking2/marks

# Create tar file
tar -cf marking.tests test1/ marking1/ marking2/

# Create test program that will pass all tests
cat > correct_program.py << 'EOF'
#!/usr/bin/python3
import sys

if len(sys.argv) > 1:
    if sys.argv[1] == "param1":
        print("Correct answer")
    elif sys.argv[1] == "param2":
        print("Another correct answer")
    else:
        print("Expected output")
else:
    print("Expected output")
EOF

chmod +x correct_program.py

# Create test program that will fail some tests
cat > failing_program.py << 'EOF'
#!/usr/bin/python3
import sys

if len(sys.argv) > 1:
    if sys.argv[1] == "param1":
        print("Correct answer")
    elif sys.argv[1] == "param2":
        print("Wrong answer")  # This will fail
    else:
        print("Expected output")
else:
    print("Expected output")
EOF

chmod +x failing_program.py

# Test mygive-mark functionality
echo "--- Testing mygive-mark on assignment with no submissions ---"
if ./mygive-add lab1 marking.tests 2>&1; then
    echo " Assignment created successfully"
else
    echo " Failed to create assignment"
    exit 1
fi

# Try marking with no submissions
echo "--- Testing marking with no submissions ---"
./mygive-mark lab1 2>&1

# Add some submissions
echo "--- Adding submissions ---"
./mygive-submit lab1 z5000001 correct_program.py 2>&1
./mygive-submit lab1 z5000002 failing_program.py 2>&1
./mygive-submit lab1 z5000001 failing_program.py 2>&1  # Second submission, should be the one marked

echo "--- Testing mygive-mark on assignments with submissions ---"
./mygive-mark lab1 2>&1

# Test error cases
echo "--- Testing error cases ---"
echo "Testing non-existent assignment:"
./mygive-mark nonexistent 2>&1

echo "Testing assignment without marking tests:"
cat > simple.tests << 'EOF'
test1/
test1/stdout
EOF
mkdir -p simple_test
echo "output" > simple_test/stdout
tar -cf simple.tests simple_test/
./mygive-add lab2 simple.tests 2>&1
./mygive-submit lab2 z5000001 correct_program.py 2>&1
./mygive-mark lab2 2>&1

# Clean up test files
rm -f marking.tests simple.tests correct_program.py failing_program.py
rm -rf test1 marking1 marking2 simple_test

echo "=== Test 6 completed ==="