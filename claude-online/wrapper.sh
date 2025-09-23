#!/bin/bash
# Wrapper script to run the claude tool inside a secure, locked-down Docker container.
set -e

IMAGE_NAME="claude-secure-env-online"
SECCOMP_PROFILE_PATH="./tools/seccomp.json"

# SECCOMP TEMPORARILY DISABLED - Azure VM Compatibility Issue
# See claude-cli/wrapper.sh for detailed explanation
# TO RE-ENABLE: Uncomment the check below and the --security-opt line in docker run

# if [ ! -f "$SECCOMP_PROFILE_PATH" ]; then
#     echo "❌ Security profile not found at $SECCOMP_PROFILE_PATH. Please run the installer again."
#     exit 1
# fi

docker run \
    --rm \
    --interactive --tty \
    -v "$(pwd)":/app:rw \
    --workdir /app \
    "$IMAGE_NAME" \
    "$@"
    # --security-opt seccomp="$SECCOMP_PROFILE_PATH" \  # DISABLED - Azure VM issue

# --------------------------- SECURITY EXPLANATION ---------------------------
# The `docker run` command above constructs a temporary, locked-down "prison"
# for the claude tool to run in. Here is what each flag does:
#
# --rm: Ephemeral. The container is completely destroyed upon exit. This
#   prevents any state, malware, or hidden files from persisting.
#
# --interactive --tty: Allows you to interact with the command-line tool.
#
# -v "$(pwd)":/app:rw: Controlled File Access. Maps ONLY the current project
#   directory into the container. The tool CANNOT see or access any other
#   files or folders on your system (e.g., ~/.ssh, /etc).
#
# USER appuser: The Dockerfile sets the container to run as a non-root user
#   (appuser with UID 1001) for security. This user has minimal permissions.
#
# Note: This version has UNRESTRICTED network access for tasks requiring
#   internet connectivity (package installation, API research, etc.)
# ----------------------------------------------------------------------------

