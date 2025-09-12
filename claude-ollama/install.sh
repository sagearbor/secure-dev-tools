#!/bin/bash
# Installer script for Ollama secure development environment
# This creates a completely offline AI assistant for your project

set -e

echo "🤖 Ollama Secure Environment Installer"
echo "======================================"
echo ""
echo "This will set up a completely OFFLINE AI coding assistant."
echo "The initial build will download ~4GB for the AI model."
echo "After installation, NO internet connection is needed!"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Configuration
TOOL_NAME="claude-ollama"
TOOLS_DIR="./tools"
IMAGE_NAME="ollama-secure-env"
BASE_URL="https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-ollama"

# Create tools directory
echo ""
echo "📁 Creating tools directory..."
mkdir -p "$TOOLS_DIR"

# Download required files
echo "📥 Downloading configuration files..."

# Download Dockerfile
echo "  - Downloading Dockerfile..."
curl -sSL "${BASE_URL}/Dockerfile" -o "${TOOLS_DIR}/Dockerfile"

# Download entrypoint script
echo "  - Downloading entrypoint script..."
curl -sSL "${BASE_URL}/entrypoint.sh" -o "${TOOLS_DIR}/entrypoint.sh"

# Download wrapper script
echo "  - Downloading wrapper script..."
curl -sSL "${BASE_URL}/wrapper.sh" -o "./${TOOL_NAME}"
chmod +x "./${TOOL_NAME}"

# Build Docker image
echo ""
echo "🔨 Building Docker image (this will take several minutes)..."
echo "   Downloading DeepSeek-Coder 6.7B model (~4GB)..."
docker build -t "$IMAGE_NAME" -f "${TOOLS_DIR}/Dockerfile" "$TOOLS_DIR"

# Verify installation
echo ""
echo "🔍 Verifying installation..."
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "✅ Docker image built successfully!"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi

# Success message
echo ""
echo "🎉 Installation complete!"
echo ""
echo "========================================="
echo "USAGE:"
echo "========================================="
echo ""
echo "Launch AI pair programming with Aider:"
echo "  ./${TOOL_NAME} aider main.py"
echo ""
echo "Direct chat with the AI model:"
echo "  ./${TOOL_NAME} ollama run deepseek-coder:6.7b"
echo ""
echo "Interactive bash shell:"
echo "  ./${TOOL_NAME} bash"
echo ""
echo "Show help:"
echo "  ./${TOOL_NAME} --help"
echo ""
echo "========================================="
echo "FEATURES:"
echo "========================================="
echo "✅ Completely offline - no internet needed"
echo "✅ Your code never leaves your machine"
echo "✅ No API keys or authentication required"
echo "✅ Zero telemetry or data collection"
echo "✅ DeepSeek-Coder 6.7B model (optimized for code)"
echo ""
echo "Note: This tool runs with --network none for complete isolation."
echo "========================================="