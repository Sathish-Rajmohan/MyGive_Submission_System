#!/bin/dash

# Test 4: mygive-fetch functionality
# Tests retrieving submissions

echo "=== MyGive Test 4: mygive-fetch functionality ==="

# Clean up
rm -rf .mygive

# Create test files
cat > test.tests << 'EOF'
test1/
test1/stdout
EOF

mkdir -p test1
echo "expected output" > test1/stdout
tar -cf test.tests test1/
rm -rf test1

# Create different submission files with distinct content
cat > submission1.sh << 'EOF'
#!/bin/dash
echo "This is submission 1"
EOF

cat > submission2.py << 'EOF'
#!/usr/bin/python3
print("This is submission 2")
EOF

cat > submission3.c << 'EOF'
#include <stdio.h>
int main() {
    printf("This is submission 3\n");
    return 0;
}
EOF

# Setup
./mygive-add testlab test.tests >/dev/null 2>&1

# Test 1: Fetch with no submissions
echo "Testing fetch with no submissions..."
if ./mygive-fetch testlab z5000000 2>/dev/null; then
    echo "FAIL: Should fail when no submissions exist"
    exit 1
fi

# Make submissions
./mygive-submit testlab z5000000 submission1.sh >/dev/null 2>&1
./mygive-submit testlab z5000000 submission2.py >/dev/null 2>&1
./mygive-submit testlab z5000000 submission3.c >/dev/null 2>&1

# Test 2: Fetch latest submission (no number specified)
echo "Testing fetch latest submission..."
output=$(./mygive-fetch testlab z5000000 2>&1)
if ! echo "$output" | grep -q "This is submission 3"; then
    echo "FAIL: Should fetch latest submission when no number specified"
    echo "Output: $output"
    exit 1
fi

# Test 3: Fetch specific submission by positive number
echo "Testing fetch specific submission by positive number..."
output=$(./mygive-fetch testlab z5000000 1 2>&1)
if ! echo "$output" | grep -q "This is submission 1"; then
    echo "FAIL: Should fetch submission 1"
    exit 1
fi

output=$(./mygive-fetch testlab z5000000 2 2>&1)
if ! echo "$output" | grep -q "This is submission 2"; then
    echo "FAIL: Should fetch submission 2"
    exit 1
fi

output=$(./mygive-fetch testlab z5000000 3 2>&1)
if ! echo "$output" | grep -q "This is submission 3"; then
    echo "FAIL: Should fetch submission 3"
    exit 1
fi

# Test 4: Fetch using zero (latest submission)
echo "Testing fetch using zero..."
output=$(./mygive-fetch testlab z5000000 0 2>&1)
if ! echo "$output" | grep -q "This is submission 3"; then
    echo "FAIL: Zero should fetch latest submission"
    exit 1
fi

# Test 5: Fetch using negative numbers (relative to latest)
echo "Testing fetch using negative numbers..."
output=$(./mygive-fetch testlab z5000000 -1 2>&1)
if ! echo "$output" | grep -q "This is submission 2"; then
    echo "FAIL: -1 should fetch second-last submission"
    exit 1
fi

output=$(./mygive-fetch testlab z5000000 -2 2>&1)
if ! echo "$output" | grep -q "This is submission 1"; then
    echo "FAIL: -2 should fetch third-last submission"
    exit 1
fi

# Test 6: Fetch non-existent submissions
echo "Testing fetch non-existent submissions..."
if ./mygive-fetch testlab z5000000 4 2>/dev/null; then
    echo "FAIL: Should fail when fetching non-existent submission 4"
    exit 1
fi

if ./mygive-fetch testlab z5000000 -3 2>/dev/null; then
    echo "FAIL: Should fail when fetching non-existent submission -3"
    exit 1
fi

# Test 7: Fetch from non-existent assignment
echo "Testing fetch from non-existent assignment..."
if ./mygive-fetch nonexistent z5000000 2>/dev/null; then
    echo "FAIL: Should fail when assignment doesn't exist"
    exit 1
fi

# Test 8: Fetch from non-existent student
echo "Testing fetch from non-existent student..."
if ./mygive-fetch testlab z5999999 2>/dev/null; then
    echo "FAIL: Should fail when student has no submissions"
    exit 1
fi

# Test 9: Fetch with invalid zid
echo "Testing fetch with invalid zid..."
if ./mygive-fetch testlab 5000000 2>/dev/null; then
    echo "FAIL: Should reject invalid zid format"
    exit 1
fi

# Test 10: Test with different student
echo "Testing fetch with different student..."
./mygive-submit testlab z5111111 submission2.py >/dev/null 2>&1

output=$(./mygive-fetch testlab z5111111 2>&1)
if ! echo "$output" | grep -q "This is submission 2"; then
    echo "FAIL: Should fetch correct submission for different student"
    exit 1
fi

output=$(./mygive-fetch testlab z5111111 1 2>&1)
if ! echo "$output" | grep -q "This is submission 2"; then
    echo "FAIL: Should fetch submission 1 for student with only 1 submission"
    exit 1
fi

# Test 11: Test exact content matching
echo "Testing exact content matching..."
output=$(./mygive-fetch testlab z5000000 1 2>&1)
expected_content=$(cat submission1.sh)
if [ "$output" != "$expected_content" ]; then
    echo "FAIL: Fetched content should exactly match original file"
    echo "Expected: $expected_content"
    echo "Got: $output"
    exit 1
fi

# Clean up
rm -f test.tests submission1.sh submission2.py submission3.c

echo "PASS: All mygive-fetch tests passed"