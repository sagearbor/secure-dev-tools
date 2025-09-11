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
```

---

### **Creating Level 1 (`claude-online`) via Command Line**

You are correct, creating the network-enabled version is very straightforward. Here are the commands you can run from the root of your `secure-dev-tools` git repository to create the new tool and update the `README` automatically.

**Just copy and paste this entire block into your terminal:**

```bash
# Step 1: Create the new 'claude-online' tool by copying the offline version.
echo "--> Creating 'claude-online' directory..."
cp -r claude-cli/ claude-online/

# Step 2: Make the new tool network-enabled by removing the two security flags
# from its wrapper script using the 'sed' command.
echo "--> Modifying wrapper to enable networking..."
sed -i.bak '/--network none/d' ./claude-online/wrapper.sh
sed -i.bak '/--security-opt seccomp/d' ./claude-online/wrapper.sh
rm ./claude-online/wrapper.sh.bak # Clean up backup files created by sed

# Step 3: Append the instructions for the new tool to the main README.md.
echo "--> Updating main README.md..."
echo '
### 2. Claude CLI (Online Version)

**Warning:** This version can access the internet. Use it for tasks that require network access, like installing dependencies or researching APIs. Do not use it on highly sensitive codebases.

**To Install in Your Project:**

**A. Download the installer:**
```bash
curl -sSL "[https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online/install.sh](https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online/install.sh)" -o setup_claude_online.sh
```

**B. Run the installer:**
```bash
bash setup_claude_online.sh
```
' >> README.md

echo "✅ Done! The 'claude-online' tool has been created and the README is updated."
echo "Please review the changes with 'git status' and 'git diff' before committing."

