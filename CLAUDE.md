# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository provides centrally managed, security-audited configurations for running powerful development tools in sandboxed Docker environments. It contains two main tools that help developers run Claude CLI in secure containerized environments.

## Project Structure

The repository has a simple, modular structure:

```
secure-dev-tools/
├── claude-cli/          # API-only network access version
│   ├── Dockerfile       # Container definition with Claude Code and iptables
│   ├── entrypoint.sh    # Script that configures network filtering on startup
│   ├── wrapper.sh       # Bash script that runs Docker with security constraints
│   ├── seccomp.json     # Security profile for system call filtering
│   └── install.sh       # Downloads components and builds container locally
│
└── claude-online/       # Full network access version
    ├── Dockerfile       # Same container definition without network restrictions
    ├── wrapper.sh       # Modified wrapper without network filtering
    ├── seccomp.json     # Security profile (not used in online version)
    └── install.sh       # Downloads and builds online version container
```

## Architecture & Design Patterns

### Security Architecture
- **Containerization**: Both tools run inside Docker containers for isolation
- **File System Isolation**: Only current working directory is mounted into container
- **Network Filtering**: The restricted version (`claude-cli`) uses iptables to allow ONLY connections to Anthropic's API endpoints
- **System Call Filtering**: The restricted version uses seccomp profiles to restrict kernel access
- **Ephemeral Containers**: Containers are destroyed after each use, preventing persistence

### Installation Pattern
Each tool follows a consistent installation pattern:
1. User runs installer script from their project directory
2. Installer creates a `tools/` subdirectory with Docker configs
3. Installer builds a local Docker image
4. Installer creates an executable wrapper script in project root

### Wrapper Script Pattern
Both tools use wrapper scripts that:
- Check for required security profiles (offline version only)
- Run Docker with appropriate security flags
- Mount only the current directory as `/app` in container
- Pass through all command-line arguments to the claude CLI

## Common Development Tasks

### Building Docker Images
```bash
# For offline version (from project using the tool)
docker build -t claude-secure-env -f tools/Dockerfile .

# For online version (from project using the tool)
docker build -t claude-secure-env-online -f tools/Dockerfile.online .
```

### Testing Installation Scripts
```bash
# Test offline installer
bash ./claude-cli/install.sh

# Test online installer
bash ./claude-online/install.sh
```

### Running the Tools After Installation
```bash
# Offline version
./claude --dangerously-skip-permissions [prompts]

# Online version
./claude-online --dangerously-skip-permissions [prompts]
```

## Key Implementation Details

### Docker Security Flags
The restricted version (`claude-cli`) uses these critical security flags:
- `--cap-add NET_ADMIN`: Allows iptables to configure network filtering
- `--env APPLY_NETWORK_RESTRICTIONS=true`: Triggers network filtering to Anthropic only
- `--security-opt seccomp=<profile>`: Applies syscall whitelist
- `--rm`: Container is ephemeral, destroyed on exit
- `-v "$(pwd)":/app`: Maps only current directory

The full access version (`claude-online`) removes network filtering and seccomp restrictions for tasks requiring broader internet access.

### Repository URLs
The installers fetch components from:
- Base URL: `https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/`
- Offline tool: `${BASE_URL}/claude-cli/`
- Online tool: `${BASE_URL}/claude-online/`

### File Permissions
- Wrapper scripts are made executable (`chmod +x`) during installation
- Container processes run with host user's UID/GID to maintain proper file ownership