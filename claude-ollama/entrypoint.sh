#!/bin/bash
# Entrypoint script for Ollama container
# Starts Ollama server and provides interface options

set -e

# Function to display help
show_help() {
    echo "🤖 Ollama Local Development Environment"
    echo "========================================"
    echo ""
    echo "This is a completely offline AI coding assistant using Ollama."
    echo "No internet connection required after installation!"
    echo ""
    echo "Available commands:"
    echo "  aider [files]     - Launch Aider AI pair programming tool"
    echo "  ollama run model  - Run Ollama directly with a model"
    echo "  bash             - Drop into a bash shell"
    echo ""
    echo "Examples:"
    echo "  ./claude-ollama aider main.py         # Edit main.py with AI assistance"
    echo "  ./claude-ollama aider src/*.js        # Work on multiple JS files"
    echo "  ./claude-ollama ollama run deepseek-coder:6.7b  # Direct chat"
    echo "  ./claude-ollama bash                  # Interactive shell"
    echo ""
    echo "Available model: deepseek-coder:6.7b (optimized for code)"
}

# Start Ollama server in background
echo "🚀 Starting Ollama server..."
ollama serve > /dev/null 2>&1 &
OLLAMA_PID=$!

# Wait for server to be ready
sleep 2

# Check if server is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "❌ Failed to start Ollama server"
    exit 1
fi

echo "✅ Ollama server started (PID: $OLLAMA_PID)"

# Cleanup function
cleanup() {
    echo "🛑 Shutting down Ollama server..."
    kill $OLLAMA_PID 2>/dev/null || true
    wait $OLLAMA_PID 2>/dev/null || true
}

# Set up cleanup on exit
trap cleanup EXIT

# Handle command line arguments
if [ $# -eq 0 ]; then
    show_help
    exec bash
elif [ "$1" = "aider" ]; then
    shift
    echo "🎯 Launching Aider with Ollama backend..."
    echo "Using model: deepseek-coder:6.7b"
    echo ""
    # Configure aider to use local Ollama
    export OPENAI_API_BASE="http://localhost:11434/v1"
    export OPENAI_API_KEY="ollama"  # Ollama doesn't need a real key
    exec aider --model "deepseek-coder:6.7b" "$@"
elif [ "$1" = "ollama" ]; then
    shift
    exec ollama "$@"
elif [ "$1" = "bash" ]; then
    exec bash
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
else
    # Pass through any other commands
    exec "$@"
fi