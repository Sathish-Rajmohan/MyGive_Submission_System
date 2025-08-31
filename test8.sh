#!/bin/dash

# Test script for testing options functionality in mygive-test and mygive-mark

echo "=== MyGive Test 8: Testing test options functionality ==="

# Clean up any existing .mygive directory
if [ -d ".mygive" ]; then
    rm -rf .mygive
fi

# Create test programs
cat > case_program.sh << 'EOF'
#!/bin/dash
echo "hello world"
EOF

cat > whitespace_program.sh << 'EOF'
#!/bin/dash
echo "hello   world"
EOF

cat > digits_program.sh << 'EOF'
#!/bin/dash
echo "abc123def456"
EOF

cat > blank_lines_program.sh << 'EOF'
#!/bin/dash
echo "line1"
echo ""
echo "line2"
EOF

cat > mixed_program.sh << 'EOF'
#!/bin/dash
echo "Hello   World"
echo ""
echo "ABC123DEF"
EOF

# Create test archive with various option tests
mkdir -p options_archive/case_test
echo "HELLO WORLD" > options_archive/case_test/stdout
echo "c" > options_archive/case_test/options

mkdir -p options_archive/whitespace_test
echo "hello\tworld" > options_archive/whitespace_test/stdout
echo "w" > options_archive/whitespace_test/options

mkdir -p options_archive/digits_test
echo "123456" > options_archive/digits_test/stdout
echo "d" > options_archive/digits_test/options

mkdir -p options_archive/blank_lines_test
echo "line1" > options_archive/blank_lines_test/stdout
echo "line2" >> options_archive/blank_lines_test/stdout
echo "b" > options_archive/blank_lines_test/options

mkdir -p options_archive/mixed_test
echo "hello\tworld" > options_archive/mixed_test/stdout
echo "" >> options_archive/mixed_test/stdout
echo "123" >> options_archive/mixed_test/stdout
echo "cwd" > options_archive/mixed_test/options

mkdir -p options_archive/no_options_test
echo "exact match" > options_archive/no_options_test/stdout

# Add marking versions
mkdir -p options_archive/case_marking
echo "HELLO WORLD" > options_archive/case_marking/stdout
echo "c" > options_archive/case_marking/options
echo "10" > options_archive/case_marking/marks

mkdir -p options_archive/whitespace_marking
echo "hello\tworld" > options_archive/whitespace_marking/stdout
echo "w" > options_archive/whitespace_marking/options
echo "20" > options_archive/whitespace_marking/marks

cd options_archive && tar -cf ../options_tests.tar * && cd ..
rm -rf options_archive

echo "Test 1: Create assignment with options tests"
./mygive-add options_test options_tests.tar > /dev/null
if [ $? -eq 0 ]; then
    echo " Assignment created successfully"
else
    echo " Failed to create assignment"
fi

echo "Test 2: Test case-insensitive option (c)"
chmod +x case_program.sh
output=$(./mygive-test options_test case_program.sh 2>&1)
if echo "$output" | grep -q "case_test passed"; then
    echo " Case-insensitive option works"
else
    echo " Case-insensitive option failed"
    echo "Output: $output"
fi

echo "Test 3: Test whitespace option (w)"
chmod +x whitespace_program.sh
output=$(./mygive-test options_test whitespace_program.sh 2>&1)
if echo "$output" | grep -q "whitespace_test passed"; then
    echo " Whitespace option works"
else
    echo " Whitespace option failed"
    echo "Output: $output"
fi

echo "Test 4: Test digits option (d)"
chmod +x digits_program.sh
output=$(./mygive-test options_test digits_program.sh 2>&1)
if echo "$output" | grep -q "digits_test passed"; then
    echo " Digits option works"
else
    echo " Digits option failed"
    echo "Output: $output"
fi

echo "Test 5: Test blank lines option (b)"
chmod +x blank_lines_program.sh
output=$(./mygive-test options_test blank_lines_program.sh 2>&1)
if echo "$output" | grep -q "blank_lines_test passed"; then
    echo " Blank lines option works"
else
    echo " Blank lines option failed"
    echo "Output: $output"
fi

echo "Test 6: Test mixed options (cwd)"
chmod +x mixed_program.sh
output=$(./mygive-test options_test mixed_program.sh 2>&1)
if echo "$output" | grep -q "mixed_test passed"; then
    echo " Mixed options work"
else
    echo " Mixed options failed"
    echo "Output: $output"
fi

echo "Test 7: Test exact match (no options)"
cat > exact_program.sh << 'EOF'
#!/bin/dash
echo "exact match"
EOF
chmod +x exact_program.sh
output=$(./mygive-test options_test exact_program.sh 2>&1)
if echo "$output" | grep -q "no_options_test passed"; then
    echo " Exact match works"
else
    echo " Exact match failed"
    echo "Output: $output"
fi

echo "Test 8: Test failure without options"
cat > strict_program.sh << 'EOF'
#!/bin/dash
echo "hello world"
EOF
chmod +x strict_program.sh
output=$(./mygive-test options_test strict_program.sh 2>&1)
if echo "$output" | grep -q "no_options_test failed"; then
    echo " Strict matching works when no options"
else
    echo " Strict matching failed"
    echo "Output: $output"
fi

echo "Test 9: Test case sensitivity without option"
output=$(./mygive-test options_test case_program.sh 2>&1)
if echo "$output" | grep -q "no_options_test failed"; then
    echo " Case sensitivity enforced without option"
else
    echo " Case sensitivity not enforced"
fi

echo "Test 10: Test whitespace sensitivity without option"
output=$(./mygive-test options_test whitespace_program.sh 2>&1)
if echo "$output" | grep -q "no_options_test failed"; then
    echo " Whitespace sensitivity enforced without option"
else
    echo " Whitespace sensitivity not enforced"
fi

echo "Test 11: Test multiple option characters"
# Create a test that uses multiple options
mkdir -p multi_archive/multi_test
echo "HELLO   WORLD" > multi_archive/multi_test/stdout
echo "cw" > multi_archive/multi_test/options
cd multi_archive && tar -cf ../multi_tests.tar * && cd ..
rm -rf multi_archive

./mygive-add multi_test multi_tests.tar > /dev/null
output=$(./mygive-test multi_test case_program.sh 2>&1)
if echo "$output" | grep -q "multi_test passed"; then
    echo " Multiple options work together"
else
    echo " Multiple options failed"
    echo "Output: $output"
fi

echo "Test 12: Test option order independence"
# Create tests with options in different orders
mkdir -p order_archive/order_test1
echo "HELLO   WORLD" > order_archive/order_test1/stdout
echo "cw" > order_archive/order_test1/options

mkdir -p order_archive/order_test2
echo "HELLO   WORLD" > order_archive/order_test2/stdout
echo "wc" > order_archive/order_test2/options

cd order_archive && tar -cf ../order_tests.tar * && cd ..
rm -rf order_archive

./mygive-add order_test order_tests.tar > /dev/null
output=$(./mygive-test order_test case_program.sh 2>&1)
if echo "$output" | grep -q "2 tests passed"; then
    echo " Option order independence works"
else
    echo " Option order independence failed"
    echo "Output: $output"
fi

# Clean up
rm -f case_program.sh whitespace_program.sh digits_program.sh blank_lines_program.sh mixed_program.sh
rm -f exact_program.sh strict_program.sh options_tests.tar multi_tests.tar order_tests.tar
rm -rf .mygive

echo "=== Test options functionality testing completed ==="