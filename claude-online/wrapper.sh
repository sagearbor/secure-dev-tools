#!/bin/bash
# Wrapper script to run the claude tool inside a secure, locked-down Docker container.
set -e

IMAGE_NAME="claude-secure-env"
SECCOMP_PROFILE_PATH="./tools/seccomp.json"

# Note: seccomp provides system call filtering for defense-in-depth security.
# It doesn't control network access - that's unrestricted in this version.
if [ ! -f "$SECCOMP_PROFILE_PATH" ]; then
    echo "❌ Security profile not found at $SECCOMP_PROFILE_PATH. Please run the installer again."
    exit 1
fi

docker run \
    --rm \
    --interactive --tty \
    --security-opt seccomp="$SECCOMP_PROFILE_PATH" \
    -v "$(pwd)":/app \
    --workdir /app \
    --user "$(id -u):$(id -g)" \
    "$IMAGE_NAME" \
    claude "$@"

# --------------------------- SECURITY EXPLANATION ---------------------------
# The `docker run` command above constructs a temporary, locked-down "prison"
# for the claude tool to run in. Here is what each flag does:
#
# --rm: Ephemeral. The container is completely destroyed upon exit. This
#   prevents any state, malware, or hidden files from persisting.
#
# --interactive --tty: Allows you to interact with the command-line tool.
#
# --security-opt seccomp=...: Defense-in-depth. Applies a strict whitelist of
#   allowed kernel-level actions (system calls). This prevents advanced,
#   low-level attacks even if the tool itself were compromised. Note: This
#   controls system calls, not network access (which is unrestricted here).
#
# -v "$(pwd)":/app: Controlled File Access. Maps ONLY the current project
#   directory into the container. The tool CANNOT see or access any other
#   files or folders on your system (e.g., ~/.ssh, /etc).
#
# --user ...: Principle of Least Privilege. Runs the process as a non-root
#   user inside the container. This prevents it from modifying its own
#   environment and ensures files it creates have the correct ownership.
# ----------------------------------------------------------------------------

