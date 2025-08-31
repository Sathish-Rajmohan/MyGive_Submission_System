#!/bin/dash

echo "=== MyGive Test 1: mygive-submit functionality ==="

# Clean up
rm -rf .mygive
rm -f test.tests submission1.sh submission2.py large_submission.sh

# Create valid tar test file
mkdir -p test1
# Add minimal required files for a test
# (arguments/stdin/stdout are optional, but at least one file is needed)
echo "expected output" > test1/stdout
tar -cf test.tests test1/
rm -rf test1

# Create submission files
cat > submission1.sh << 'EOF'
#!/bin/dash
echo "Hello World"
EOF
chmod +x submission1.sh

cat > submission2.py << 'EOF'
#!/usr/bin/python3
print("Hello Python")
EOF
chmod +x submission2.py

# Setup assignment
./mygive-add testlab test.tests >/dev/null 2>&1

# Test 1: Valid submission
echo "Testing valid submission..."
output=$(./mygive-submit testlab z5000000 submission1.sh 2>&1)
if ! echo "$output" | grep -q "Submission accepted - submission 1:"; then
    echo "FAIL: Should accept valid submission"
    echo "Output: $output"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

if ! echo "$output" | grep -q "submission1.sh"; then
    echo "FAIL: Should show filename in submission message"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 2: Second submission from same student
echo "Testing second submission from same student..."
output=$(./mygive-submit testlab z5000000 submission2.py 2>&1)
if ! echo "$output" | grep -q "Submission accepted - submission 2:"; then
    echo "FAIL: Should accept second submission with incremented number"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 3: Submission from different student
echo "Testing submission from different student..."
output=$(./mygive-submit testlab z5111111 submission1.sh 2>&1)
if ! echo "$output" | grep -q "Submission accepted - submission 1:"; then
    echo "FAIL: Should accept submission from different student with submission 1"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 4: Invalid assignment name
echo "Testing invalid assignment name..."
if ./mygive-submit nonexistent z5000000 submission1.sh 2>/dev/null; then
    echo "FAIL: Should reject nonexistent assignment"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 5: Invalid zid format
echo "Testing invalid zid format..."
if ./mygive-submit testlab 5000000 submission1.sh 2>/dev/null; then
    echo "FAIL: Should reject zid without 'z' prefix"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

if ./mygive-submit testlab z500000 submission1.sh 2>/dev/null; then
    echo "FAIL: Should reject zid with wrong number of digits"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

if ./mygive-submit testlab z500000a submission1.sh 2>/dev/null; then
    echo "FAIL: Should reject zid with non-numeric characters"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 6: Invalid filename
echo "Testing invalid filename..."
if ./mygive-submit testlab z5000000 nonexistent.sh 2>/dev/null; then
    echo "FAIL: Should reject nonexistent file"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Test 7: File size reporting
echo "Testing file size reporting..."
echo "larger content for size testing" > large_submission.sh
output=$(./mygive-submit testlab z5000000 large_submission.sh 2>&1)
if ! echo "$output" | grep -q "bytes"; then
    echo "FAIL: Should report file size in bytes"
    rm -f test.tests submission1.sh submission2.py large_submission.sh
    exit 1
fi

# Clean up
rm -f test.tests submission1.sh submission2.py large_submission.sh

echo "PASS: All mygive-submit tests passed"