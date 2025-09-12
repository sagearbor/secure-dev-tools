#!/bin/bash
# Wrapper script to run the claude tool inside a secure, locked-down Docker container.
set -e

IMAGE_NAME="claude-secure-env"
SECCOMP_PROFILE_PATH="./tools/seccomp.json"

if [ ! -f "$SECCOMP_PROFILE_PATH" ]; then
    echo "❌ Security profile not found at $SECCOMP_PROFILE_PATH. Please run the installer again."
    exit 1
fi

docker run \
    --rm \
    --interactive --tty \
    --cap-add NET_ADMIN \
    --env APPLY_NETWORK_RESTRICTIONS=true \
    --security-opt seccomp="$SECCOMP_PROFILE_PATH" \
    -v "$(pwd)":/app \
    --workdir /app \
    "$IMAGE_NAME" \
    "$@"

# --------------------------- SECURITY EXPLANATION ---------------------------
# The `docker run` command above constructs a temporary, locked-down "prison"
# for the claude tool to run in. Here is what each flag does:
#
# --rm: Ephemeral. The container is completely destroyed upon exit. This
#   prevents any state, malware, or hidden files from persisting.
#
# --interactive --tty: Allows you to interact with the command-line tool.
#
# --cap-add NET_ADMIN: Allows iptables to configure network filtering rules.
#   The entrypoint script uses this to restrict network access to ONLY
#   Anthropic's API endpoints (api.anthropic.com and claude.ai).
#
# --env APPLY_NETWORK_RESTRICTIONS=true: Triggers the network filtering.
#   Only HTTPS connections to Anthropic's servers are allowed.
#
# --security-opt seccomp=...: CRITICAL. Applies a strict whitelist of
#   allowed kernel-level actions (system calls). This prevents advanced,
#   low-level attacks even if the tool itself were compromised.
#
# -v "$(pwd)":/app: Controlled File Access. Maps ONLY the current project
#   directory into the container. The tool CANNOT see or access any other
#   files or folders on your system (e.g., ~/.ssh, /etc).
# ----------------------------------------------------------------------------
