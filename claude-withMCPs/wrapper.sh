#!/bin/bash
# Wrapper script to run claude with customizable network restrictions
set -e

IMAGE_NAME="claude-withMCPs-env"
SECCOMP_PROFILE_PATH="./tools/seccomp.json"
ALLOWED_DOMAINS_PATH="./tools/allowed-domains.txt"

# SECCOMP TEMPORARILY DISABLED - Azure VM Compatibility Issue
# See claude-cli/wrapper.sh for detailed explanation of the Azure VM issue
# TO RE-ENABLE: Uncomment the check below and the --security-opt line in docker run

# Check for required files
# if [ ! -f "$SECCOMP_PROFILE_PATH" ]; then
#     echo "❌ Security profile not found at $SECCOMP_PROFILE_PATH. Please run the installer again."
#     exit 1
# fi

if [ ! -f "$ALLOWED_DOMAINS_PATH" ]; then
    echo "⚠️  No allowed-domains.txt found. Creating default configuration..."
    cat > "$ALLOWED_DOMAINS_PATH" << 'EOF'
# Allowed domains for Claude MCP network access
# Add one domain per line (without https://)
# Lines starting with # are comments

# Anthropic API endpoints (always required)
api.anthropic.com
claude.ai

# MCP Context7 endpoint
context7.com

# Add your custom domains below:
# example.com
# api.yourdomain.com
EOF
    echo "✅ Created $ALLOWED_DOMAINS_PATH - Edit this file to add more allowed domains"
fi

echo "🔒 Starting Claude with MCP/trusted API network restrictions..."
echo "📋 Allowed domains:"
grep -v '^#' "$ALLOWED_DOMAINS_PATH" | grep -v '^$' | sed 's/^/    - /'
echo ""

docker run \
    --rm \
    --interactive --tty \
    --cap-add NET_ADMIN \
    --env APPLY_NETWORK_RESTRICTIONS=true \
    -v "$(pwd)":/app:rw \
    -v "$ALLOWED_DOMAINS_PATH":/etc/allowed-domains.txt:ro \
    --workdir /app \
    "$IMAGE_NAME" \
    "$@"
    # --security-opt seccomp="$SECCOMP_PROFILE_PATH" \  # DISABLED - Azure VM issue

# --------------------------- SECURITY EXPLANATION ---------------------------
# This configuration provides a middle ground between the fully restricted
# and fully open versions:
#
# --cap-add NET_ADMIN: Allows iptables to configure custom network filtering.
#
# --env APPLY_NETWORK_RESTRICTIONS=true: Triggers the network filtering
#   based on your allowed-domains.txt configuration file.
#
# Network Access: Limited to domains listed in tools/allowed-domains.txt
#   - Always includes api.anthropic.com and claude.ai
#   - You can add trusted domains like MCP servers, documentation sites, etc.
#   - Edit tools/allowed-domains.txt to customize
#
# --security-opt seccomp=...: Applies system call filtering for additional
#   security at the kernel level.
#
# -v "$(pwd)":/app: Maps ONLY the current project directory. Claude cannot
#   access files outside this directory (e.g., ~/.ssh, /etc).
#
# To add more allowed domains, edit: ./tools/allowed-domains.txt
# ----------------------------------------------------------------------------