#!/bin/dash

# test9.sh - Complex test scenarios for MyGive system
# Tests edge cases, error handling, and complex workflows

export PATH=".:$PATH"
echo "=== MyGive Test 9: Complex Scenarios and Edge Cases ==="

# Clean up any existing .mygive directory
rm -rf .mygive

# Test 1: Multiple assignments with complex submission patterns
echo "Test 1: Complex multi-assignment workflow"

# Create test files for assignments
echo '#!/bin/dash
echo "Hello World"' > hello.sh
chmod +x hello.sh

echo '#!/bin/dash
echo "Goodbye World"' > goodbye.sh
chmod +x goodbye.sh

echo '#!/bin/dash
echo "Test Output"' > test_prog.sh
chmod +x test_prog.sh

# Create multiple tar files (assuming they exist in the environment)
# For this test, we'll assume hello.tests and answer.tests exist
if [ -f "hello.tests" ] && [ -f "answer.tests" ]; then
    # Create multiple assignments
    echo "Creating multiple assignments..."
    mygive-add assignment1 hello.tests
    mygive-add assignment2 answer.tests
    
    # Multiple submissions from same student
    echo "Testing multiple submissions from same student..."
    mygive-submit assignment1 z1234567 hello.sh
    mygive-submit assignment1 z1234567 goodbye.sh
    mygive-submit assignment1 z1234567 test_prog.sh
    
    # Check status shows all submissions
    echo "Checking submission history..."
    mygive-status z1234567
    
    # Test fetching different submission numbers
    echo "Testing fetch with different submission numbers..."
    echo "Fetching submission 1:"
    mygive-fetch assignment1 z1234567 1
    echo "Fetching submission 2:"
    mygive-fetch assignment1 z1234567 2
    echo "Fetching last submission (default):"
    mygive-fetch assignment1 z1234567
    
    # Test negative indexing
    echo "Testing negative submission indexing..."
    echo "Fetching submission 0 (last):"
    mygive-fetch assignment1 z1234567 0
    echo "Fetching submission -1 (second last):"
    mygive-fetch assignment1 z1234567 -1
    echo "Fetching submission -2 (third last):"
    mygive-fetch assignment1 z1234567 -2
else
    echo "Skipping Test 1: Required test files not found"
fi

# Test 2: Edge case error handling
echo -e "\nTest 2: Error handling and edge cases"

# Test invalid assignment names
echo "Testing invalid assignment names..."
mygive-add "1invalid" hello.tests 2>&1 | grep -q "invalid assignment" && echo " Caught invalid assignment name starting with digit"
mygive-add "invalid-name" hello.tests 2>&1 | grep -q "invalid assignment" && echo " Caught invalid assignment name with dash"
mygive-add "invalid@name" hello.tests 2>&1 | grep -q "invalid assignment" && echo " Caught invalid assignment name with special char"

# Test invalid ZIDs
echo "Testing invalid ZIDs..."
mygive-submit assignment1 "z123456" hello.sh 2>&1 | grep -q "invalid zid" && echo " Caught ZID with insufficient digits"
mygive-submit assignment1 "z12345678" hello.sh 2>&1 | grep -q "invalid zid" && echo " Caught ZID with too many digits"
mygive-submit assignment1 "x1234567" hello.sh 2>&1 | grep -q "invalid zid" && echo " Caught ZID not starting with z"
mygive-submit assignment1 "z123456a" hello.sh 2>&1 | grep -q "invalid zid" && echo " Caught ZID with non-digit characters"

# Test invalid submission numbers
echo "Testing invalid submission numbers..."
mygive-fetch assignment1 z1234567 "abc" 2>&1 | grep -q "invalid submission number" && echo " Caught non-numeric submission number"
mygive-fetch assignment1 z1234567 "1.5" 2>&1 | grep -q "invalid submission number" && echo " Caught decimal submission number"

# Test 3: Multiple students and complex status queries
echo -e "\nTest 3: Multiple students and status management"

if [ -f "hello.tests" ]; then
    # Create submissions from multiple students
    echo "Creating submissions from multiple students..."
    mygive-submit assignment1 z2345678 hello.sh
    mygive-submit assignment1 z3456789 goodbye.sh
    mygive-submit assignment1 z4567890 test_prog.sh
    
    # Submit to different assignments
    if [ -f "answer.tests" ]; then
        mygive-submit assignment2 z2345678 hello.sh
        mygive-submit assignment2 z3456789 goodbye.sh
    fi
    
    # Check summary
    echo "Checking assignment summary..."
    mygive-summary
    
    # Check individual student statuses
    echo "Checking individual student statuses..."
    mygive-status z2345678
    mygive-status z3456789
    mygive-status z4567890
    
    # Test status for student with no submissions
    echo "Testing status for student with no submissions..."
    mygive-status z9999999
fi

# Test 4: Edge cases with fetch operations
echo -e "\nTest 4: Fetch operation edge cases"

if [ -f "hello.tests" ]; then
    # Test fetching out-of-range submissions
    echo "Testing out-of-range fetch operations..."
    mygive-fetch assignment1 z1234567 10 2>&1 | grep -q "not found" && echo " Handled out-of-range positive submission number"
    mygive-fetch assignment1 z1234567 -10 2>&1 | grep -q "not found" && echo " Handled out-of-range negative submission number"
    
    # Test fetching from non-existent student
    echo "Testing fetch from non-existent student..."
    mygive-fetch assignment1 z9999999 1 2>&1 | grep -q "no submissions" && echo " Handled fetch from student with no submissions"
    
    # Test fetching from non-existent assignment
    echo "Testing fetch from non-existent assignment..."
    mygive-fetch nonexistent z1234567 1 2>&1 | grep -q "not found" && echo " Handled fetch from non-existent assignment"
fi

# Test 5: Assignment removal and cleanup
echo -e "\nTest 5: Assignment removal and cleanup"

if [ -f "hello.tests" ]; then
    # Create a temporary assignment for removal testing
    mygive-add temp_assignment hello.tests
    mygive-submit temp_assignment z1111111 hello.sh
    
    echo "Assignment created and has submissions:"
    mygive-summary | grep temp_assignment
    
    # Remove the assignment
    echo "Removing assignment..."
    mygive-rm temp_assignment
    
    # Verify removal
    echo "Verifying assignment removal..."
    mygive-summary | grep -q temp_assignment || echo " Assignment successfully removed"
    
    # Test operations on removed assignment
    echo "Testing operations on removed assignment..."
    mygive-submit temp_assignment z1111111 hello.sh 2>&1 | grep -q "not found" && echo " Submit to removed assignment properly handled"
    mygive-fetch temp_assignment z1111111 1 2>&1 | grep -q "not found" && echo " Fetch from removed assignment properly handled"
fi

# Test 6: Complex filename and pathname handling
echo -e "\nTest 6: Complex filename and pathname handling"

# Create files with various valid characters in names
echo '#!/bin/dash
echo "Test with underscore"' > test_underscore.sh
chmod +x test_underscore.sh

echo '#!/bin/dash
echo "Test with dash"' > test-dash.sh
chmod +x test-dash.sh

echo '#!/bin/dash
echo "Test with dots"' > test.dots.sh
chmod +x test.dots.sh

if [ -f "hello.tests" ]; then
    # Test submissions with various filename patterns
    echo "Testing submissions with various filename patterns..."
    mygive-submit assignment1 z5555555 test_underscore.sh
    mygive-submit assignment1 z5555555 test-dash.sh
    mygive-submit assignment1 z5555555 test.dots.sh
    
    # Verify all submissions were accepted
    echo "Verifying all submissions were accepted..."
    mygive-status z5555555 | grep -c "submission" && echo " All filename patterns accepted"
fi

# Test 7: Testing with no .mygive directory
echo -e "\nTest 7: Operations without .mygive directory"

# Remove .mygive directory
rm -rf .mygive

# Test operations that should fail gracefully
echo "Testing operations without .mygive directory..."
mygive-summary 2>&1 | grep -q "no assignments created" && echo " Summary handles missing .mygive directory"
mygive-status z1234567 2>&1 | grep -q "no assignments created" && echo " Status handles missing .mygive directory"
mygive-fetch assignment1 z1234567 1 2>&1 | grep -q "not found" && echo " Fetch handles missing .mygive directory"

# Test 8: Boundary conditions and stress testing
echo -e "\nTest 8: Boundary conditions"

if [ -f "hello.tests" ]; then
    # Recreate environment
    mygive-add assignment1 hello.tests
    
    # Test with minimum valid ZID (z0000000)
    echo "Testing minimum valid ZID..."
    mygive-submit assignment1 z0000000 hello.sh
    mygive-status z0000000 | grep -q "submission" && echo " Minimum valid ZID accepted"
    
    # Test with maximum valid ZID (z9999999)
    echo "Testing maximum valid ZID..."
    mygive-submit assignment1 z9999999 hello.sh
    mygive-status z9999999 | grep -q "submission" && echo " Maximum valid ZID accepted"
    
    # Test assignment names with various valid patterns
    echo "Testing assignment name patterns..."
    mygive-add a hello.tests && echo " Single character assignment name"
    mygive-add test123 hello.tests && echo " Assignment name with numbers"
    mygive-add test_underscore hello.tests && echo " Assignment name with underscores"
fi

# Cleanup
echo -e "\nCleaning up test files..."
rm -f hello.sh goodbye.sh test_prog.sh test_underscore.sh test-dash.sh test.dots.sh
rm -rf .mygive

echo "\n=== Test 9 Complete ==="