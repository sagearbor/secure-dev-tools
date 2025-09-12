#!/bin/bash
# Wrapper script to run Ollama in a completely offline Docker container
set -e

IMAGE_NAME="ollama-secure-env"

# Check if Docker image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "❌ Docker image '$IMAGE_NAME' not found. Please run the installer first."
    echo "   Run: bash <(curl -sSL https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-ollama/install.sh)"
    exit 1
fi

# Run the container with NO NETWORK ACCESS
docker run \
    --rm \
    --interactive --tty \
    --network none \
    -v "$(pwd)":/app \
    --workdir /app \
    --user "$(id -u):$(id -g)" \
    "$IMAGE_NAME" \
    "$@"

# --------------------------- SECURITY EXPLANATION ---------------------------
# The `docker run` command above creates a completely OFFLINE environment
# for running a local LLM. Here's what each security flag does:
#
# --rm: Ephemeral. The container is completely destroyed upon exit,
#   preventing any state or data from persisting between sessions.
#
# --interactive --tty: Allows you to interact with the AI assistant.
#
# --network none: COMPLETE ISOLATION. The container has absolutely NO
#   network access - cannot reach the internet or any network services.
#   This ensures your code and conversations never leave your machine.
#
# -v "$(pwd)":/app: Controlled File Access. Maps ONLY the current project
#   directory into the container. The tool CANNOT see or access any other
#   files or folders on your system (e.g., ~/.ssh, /etc, other projects).
#
# --user ...: Runs as non-root user to match your file permissions and
#   prevent privilege escalation within the container.
#
# This provides the maximum possible security and privacy:
# - Your code never leaves your machine
# - No telemetry or data collection possible
# - No API keys or authentication needed
# - Complete air-gap isolation from the internet
# ----------------------------------------------------------------------------