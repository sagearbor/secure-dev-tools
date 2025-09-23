#!/bin/bash
# Test script to verify the permission fix works correctly

set -e

echo "=== Permission Fix Test ==="
echo "Testing that files created in Docker container have correct ownership"
echo ""

# Create a test directory
TEST_DIR="test-permissions-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "1. Created test directory: $(pwd)"
echo "2. Your user ID: $(id -u):$(id -g) ($(whoami))"
echo ""

# Copy the updated wrapper script here
echo "3. Setting up claude-cli with updated wrapper..."
cp -r ../claude-cli/Dockerfile ../claude-cli/entrypoint.sh ../claude-cli/seccomp.json .
cp ../claude-cli/wrapper.sh ./claude

# Make wrapper executable
chmod +x ./claude

echo "4. Running claude to create a test file..."
echo ""
echo "The following command will:"
echo "  - Run claude in the container with your user ID"
echo "  - Create a simple test file"
echo "  - Exit immediately"
echo ""

# Run claude to create a test file
./claude --dangerously-skip-permissions "Create a file called test.txt with the content 'Permission test successful'. Then exit immediately."

echo ""
echo "5. Checking file ownership..."
ls -la test.txt 2>/dev/null || echo "❌ File not created"

if [ -f test.txt ]; then
    OWNER_UID=$(stat -c %u test.txt)
    OWNER_GID=$(stat -c %g test.txt)
    MY_UID=$(id -u)
    MY_GID=$(id -g)

    if [ "$OWNER_UID" = "$MY_UID" ] && [ "$OWNER_GID" = "$MY_GID" ]; then
        echo "✅ SUCCESS: File owned by you ($MY_UID:$MY_GID)"
        echo "✅ The permission fix is working correctly!"
    else
        echo "❌ FAILED: File owned by $OWNER_UID:$OWNER_GID instead of $MY_UID:$MY_GID"
        echo "❌ The permission fix is not working"
    fi
else
    echo "⚠️  Test file was not created - claude may need to be rebuilt"
fi

echo ""
echo "6. Cleaning up test directory..."
cd ..
rm -rf "$TEST_DIR"
echo "✅ Test complete"