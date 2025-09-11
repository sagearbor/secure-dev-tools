#!/bin/bash
# Installer for the Claude CLI Environment (ONLINE)
set -e
echo "--- Setting up Claude CLI (Online)..."

GIT_REPO_RAW_BASE_URL="https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online"
IMAGE_NAME="claude-secure-env-online"
TOOLS_DIR="tools"
WRAPPER_SCRIPT_NAME="claude-online" # The command will be ./claude-online

mkdir -p "$TOOLS_DIR"
echo "✅ Created directory: $TOOLS_DIR"

echo "Downloading scripts..."
# Note: Does not download seccomp.json as it's not used
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/Dockerfile" -o "$TOOLS_DIR/Dockerfile.online"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/wrapper.sh" -o "$WRAPPER_SCRIPT_NAME"
echo "✅ Downloaded configuration files."

echo "Building Docker image ('$IMAGE_NAME')..."
echo "This may take a minute on first install..."
if ! docker build -t "$IMAGE_NAME" -f "$TOOLS_DIR/Dockerfile.online" . 2>&1; then
    echo ""
    echo "❌ Docker image build failed."
    echo "Common issues:"
    echo "  - Docker daemon not running: Start Docker Desktop or 'sudo systemctl start docker'"
    echo "  - Permission denied: Add your user to docker group with 'sudo usermod -aG docker $USER'"
    echo "  - Network issues: Check your internet connection for downloading Python image"
    exit 1
fi
echo "✅ Docker image built successfully."

chmod +x "$WRAPPER_SCRIPT_NAME"
if [ ! -x "$WRAPPER_SCRIPT_NAME" ]; then
    echo "❌ Failed to make '$WRAPPER_SCRIPT_NAME' executable."
    exit 1
fi
echo "✅ Made '$WRAPPER_SCRIPT_NAME' script executable."

echo ""
echo "--- 🎉 Setup Complete! ---"
echo "To use the tool, run from your project root:"
echo ""
echo "    ./$WRAPPER_SCRIPT_NAME --dangerously-skip-permissions [your prompts here]"
echo ""
