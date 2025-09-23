#!/bin/bash
#
# Installer for Claude with MCPs (Model Context Protocol) Environment
#
# This script sets up Claude with network access restricted to:
# - Anthropic API endpoints
# - MCP servers like Context7
# - Other trusted API endpoints you configure
#
# This provides a middle ground between full isolation and full network access.

set -e # Exit immediately if a command fails.

echo "--- Setting up Claude with MCPs Environment ---"

# --- Configuration ---
# This URL points to this script's parent directory in the central repo.
GIT_REPO_RAW_BASE_URL="https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-withMCPs"

# --- Script Parameters ---
IMAGE_NAME="claude-withMCPs-env"
TOOLS_DIR="tools"
WRAPPER_SCRIPT_NAME="claude-withMCPs"

# --- Main Logic ---
mkdir -p "$TOOLS_DIR"
echo "✅ Created directory: $TOOLS_DIR"

echo "Downloading security profiles and scripts..."
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/Dockerfile" -o "$TOOLS_DIR/Dockerfile"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/entrypoint.sh" -o "$TOOLS_DIR/entrypoint.sh"
# Note: seccomp.json is downloaded but currently disabled in wrapper.sh due to Azure VM compatibility
# See wrapper.sh and claude-cli/wrapper.sh for details on the seccomp issue
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/seccomp.json" -o "$TOOLS_DIR/seccomp.json"
curl -fsSL "${GIT_REPO_RAW_BASE_URL}/allowed-domains.txt" -o "$TOOLS_DIR/allowed-domains.txt"
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
echo ""
echo "📋 Network access is restricted to:"
grep -v '^#' "$TOOLS_DIR/allowed-domains.txt" | grep -v '^$' | sed 's/^/    - /'
echo ""
echo "To add more allowed domains, edit: $TOOLS_DIR/allowed-domains.txt"
echo ""
echo "To use the tool, run from your project root:"
echo ""
echo "    ./$WRAPPER_SCRIPT_NAME --dangerously-skip-permissions [your prompts here]"
echo ""