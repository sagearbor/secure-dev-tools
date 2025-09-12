#!/bin/bash
#
# Installer for the Secure Claude CLI Environment
#
# This script is designed to be downloaded and run in the root of a project
# directory. It fetches the necessary security components for the Claude AI tool
# and builds the local container.

set -e # Exit immediately if a command fails.

echo "--- Setting up Secure Claude CLI Environment ---"

# --- Configuration ---
# This URL points to this script's parent directory in the central repo.
GIT_REPO_RAW_BASE_URL="https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli"

# --- Script Parameters ---
IMAGE_NAME="claude-secure-env"
TOOLS_DIR="tools"
WRAPPER_SCRIPT_NAME="claude"

# --- Main Logic ---
mkdir -p "$TOOLS_DIR"
echo "✅ Created directory: $TOOLS_DIR"

echo "Downloading security profiles and scripts..."
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/Dockerfile" -o "$TOOLS_DIR/Dockerfile"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/entrypoint.sh" -o "$TOOLS_DIR/entrypoint.sh"
# Note: seccomp.json is downloaded but currently disabled in wrapper.sh due to Azure VM compatibility
# See wrapper.sh for details on the seccomp issue and how to re-enable it
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/seccomp.json" -o "$TOOLS_DIR/seccomp.json"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/wrapper.sh" -o "$WRAPPER_SCRIPT_NAME"
echo "✅ Downloaded configuration files."

echo "Building Docker image ('$IMAGE_NAME')..."
echo "This may take a minute on first install..."
if ! docker build -t "$IMAGE_NAME" -f "$TOOLS_DIR/Dockerfile" . 2>&1; then
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
