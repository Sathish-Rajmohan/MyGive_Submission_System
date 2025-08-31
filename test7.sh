#!/bin/dash

# Test 7: mygive-rm functionality
# Tests removing assignments and error handling

echo "=== MyGive Test 7: mygive-rm functionality ==="

# Clean up
rm -rf .mygive

# Create test files
cat > test.tests << 'EOF'
test1/
test1/stdout
EOF

mkdir -p test1
echo "output" > test1/stdout
tar -cf test.tests test1/

# Create test program
cat > test_prog.sh << 'EOF'
#!/bin/dash
echo "output"
EOF

chmod +x test_prog.sh

# Test removing non-existent assignment (should fail)
echo "--- Testing removal of non-existent assignment ---"
./mygive-rm nonexistent 2>&1
echo "Exit status: $?"

# Create assignments
echo "--- Creating assignments ---"
./mygive-add lab1 test.tests 2>&1
./mygive-add lab2 test.tests 2>&1
./mygive-add lab3 test.tests 2>&1

# Add some submissions
echo "--- Adding submissions ---"
./mygive-submit lab1 z5000001 test_prog.sh 2>&1
./mygive-submit lab1 z5000002 test_prog.sh 2>&1
./mygive-submit lab2 z5000001 test_prog.sh 2>&1

# Check current state
echo "--- Current assignments ---"
./mygive-summary 2>&1

# Remove assignment with submissions
echo "--- Removing assignment lab1 (has submissions) ---"
./mygive-rm lab1 2>&1
echo "Exit status: $?"

# Check that assignment is removed
echo "--- Checking assignments after removal ---"
./mygive-summary 2>&1

# Try to access removed assignment
echo "--- Trying to access removed assignment ---"
./mygive-status z5000001 2>&1
./mygive-fetch lab1 z5000001 2>&1

# Remove assignment without submissions
echo "--- Removing assignment lab3 (no submissions) ---"
./mygive-rm lab3 2>&1
echo "Exit status: $?"

# Try to remove already removed assignment
echo "--- Trying to remove already removed assignment ---"
./mygive-rm lab1 2>&1
echo "Exit status: $?"

# Remove last assignment
echo "--- Removing last assignment ---"
./mygive-rm lab2 2>&1
echo "Exit status: $?"

# Check final state
echo "--- Final state ---"
./mygive-summary 2>&1

# Test with invalid assignment name
echo "--- Testing with invalid assignment name ---"
./mygive-rm "invalid name" 2>&1
./mygive-rm "123invalid" 2>&1
./mygive-rm "" 2>&1

# Test argument validation
echo "--- Testing argument validation ---"
./mygive-rm 2>&1  # No arguments
./mygive-rm lab1 extra_arg 2>&1  # Too many arguments

# Test after complete removal - should be able to recreate
echo "--- Testing recreation after removal ---"
./mygive-add lab1 test.tests 2>&1
./mygive-summary 2>&1

# Clean up test files
rm -f test.tests test_prog.sh
rm -rf test1

echo "=== Test 7 completed ==="