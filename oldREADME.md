# Secure Development Environment Tools

This repository holds the centrally managed, security-audited configurations for running powerful development tools, such as AI assistants, in a sandboxed environment.

The goal is to allow developers to use these tools safely, without granting them unnecessary permissions on their host machine or the network.

### 1. One-Time Setup (Per Developer)

Before you begin, you must have Docker installed and running on your machine.

- [Install Docker Desktop](https://www.docker.com/products/docker-desktop/ "null")

### 2. Project Setup (For each project you work on)

Follow these steps inside the root directory of a project where you want to use the secure Claude tool.

**A. Create a `tools` directory and the setup script:**

```
mkdir -p tools
```

Now, create a new file named `tools/setup_secure_env.sh` and paste the following content into it:

```
#!/bin/bash## This script sets up a secure, containerized environment for the Claude AI tool.set -e # Exit immediately if a command fails.# --- Configuration ---# IMPORTANT: Replace the placeholder URL with the raw URL from YOUR organization's# central tools repository.## How to find the raw URL on GitHub:# 1. Navigate to the file in the repository (e.g., the Dockerfile).# 2. Click the "Raw" button on the file's page.# 3. Copy the URL from your browser's address bar.GIT_REPO_RAW_BASE_URL="<YOUR_ORG_GITHUB_RAW_URL>/claude-secure-env" # EDIT THIS LINE# --- Script Parameters -- -IMAGE_NAME="claude-secure-env"TOOLS_DIR="tools"WRAPPER_SCRIPT_NAME="claude"# --- Main Logic ---echo "--- Setting up secure development environment ---"mkdir -p "$TOOLS_DIR"# Download configuration filesecho "Downloading configuration files..."curl -sSL "${GIT_REPO_RAW_BASE_URL}/Dockerfile" -o "$TOOLS_DIR/Dockerfile"curl -sSL "${GIT_REPO_RAW_BASE_URL}/seccomp.json" -o "$TOOLS_DIR/seccomp.json"curl -sSL "${GIT_REPO_RAW_BASE_URL}/wrapper.sh" -o "$WRAPPER_SCRIPT_NAME"echo "✅ Downloaded configuration files."# Build the Docker imageecho "Building Docker image ('$IMAGE_NAME')..."docker build -t "$IMAGE_NAME" -f "$TOOLS_DIR/Dockerfile" . > /dev/nullecho "✅ Docker image built successfully."# Make the wrapper script executablechmod +x "$WRAPPER_SCRIPT_NAME"echo "✅ Made '$WRAPPER_SCRIPT_NAME' script executable."echo ""echo "--- 🎉 Setup Complete! ---"echo "To use the tool, run from your project root:"echo ""echo "    ./$WRAPPER_SCRIPT_NAME --dangerously-skip-permissions [your prompts here]"echo ""
```

**B. Configure the URL:**

Once you create your central Git repository and upload these files, edit the `GIT_REPO_RAW_BASE_URL` variable in the `setup_secure_env.sh` script to point to your new repo.

**C. Run the Setup Script:**

```
bash tools/setup_secure_env.sh
```

This will download the security profiles, build the container, and create a `./claude` executable script in your project's root directory.

### 3. Daily Usage

After the one-time setup for your project, simply run the tool using the wrapper script from your project's root directory:

```
./claude --dangerously-skip-permissions your prompt about the codebase here
```
