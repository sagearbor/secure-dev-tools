#!/bin/bash
#
# Secure Wrapper for Claude CLI
#
# This script executes the Claude CLI tool inside a heavily restricted, ephemeral
# Docker container. It handles all the complex security flags so you don't have to.

set -e

# --- Parameters ---
# The name of the Docker image built by the setup script.
IMAGE_NAME="claude-secure-env"
# The directory inside the container where the code will be mounted.
CONTAINER_WORKDIR="/app"

# --- Security Checks ---
# Ensure the seccomp profile exists before trying to run the container.
if [ ! -f "tools/seccomp.json" ]; then
    echo "Error: Security profile not found at 'tools/seccomp.json'"
    echo "Please run the 'tools/setup_secure_env.sh' script first."
    exit 1
fi

# --- Docker Execution ---
# This is the core of the security model.
# Each flag adds a layer of protection.
echo "Running claude in secure container..."
docker run \
  --rm \
  -it \
  -v "$(pwd):${CONTAINER_WORKDIR}" \
  -w "${CONTAINER_WORKDIR}" \
  --user="$(id -u):$(id -g)" \
  --network none \
  --cap-drop=ALL \
  --security-opt seccomp="$(pwd)/tools/seccomp.json" \
  "${IMAGE_NAME}" \
  "$@"
