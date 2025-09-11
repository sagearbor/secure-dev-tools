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
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/seccomp.json" -o "$TOOLS_DIR/seccomp.json"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/wrapper.sh" -o "$WRAPPER_SCRIPT_NAME"
echo "✅ Downloaded configuration files."

echo "Building Docker image ('$IMAGE_NAME')..."
if docker build -t "$IMAGE_NAME" -f "$TOOLS_DIR/Dockerfile" . ; then
    echo "✅ Docker image built successfully."
else
    echo "❌ Docker image build failed. Please check for errors."
    exit 1
fi

chmod +x "$WRAPPER_SCRIPT_NAME"
echo "✅ Made '$WRAPPER_SCRIPT_NAME' script executable."

echo ""
echo "--- 🎉 Setup Complete! ---"
echo "To use the tool, run from your project root:"
echo ""
echo "    ./$WRAPPER_SCRIPT_NAME --dangerously-skip-permissions [your prompts here]"
echo ""
