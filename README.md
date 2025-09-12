Secure Development Environment Tools
This repository provides centrally managed, security-audited configurations for running powerful development tools in sandboxed environments.

Each tool is self-contained in its own directory. To set up a tool in your project, follow the installation instructions for that specific tool below.

Available Tools
1. Claude Ollama (Completely Offline)
This is a fully offline AI coding assistant using Ollama with the DeepSeek-Coder model. After initial installation, it requires NO internet connection. Your code never leaves your machine, providing maximum privacy and security. Perfect for air-gapped environments or sensitive codebases.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-ollama/install.sh")

This will download the AI model (~4GB) during installation. After that, you can work completely offline.

2. Claude CLI (API-Only Network Access)
This is a secure, network-restricted, containerized environment for running Claude Code. Network access is restricted to ONLY Anthropic's API endpoints (api.anthropic.com and claude.ai) - no other internet access is allowed. The tool can only read and write files within the project directory it is run from.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "[https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli/install.sh](https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli/install.sh)")

This will download and run the installer in one step, creating a ./claude command for you to use.  

3. Claude CLI with MCPs (Trusted APIs)
This version allows network access to Anthropic's API plus configurable trusted endpoints like MCP servers (e.g., Context7). Edit the allowed-domains.txt file after installation to add your trusted API endpoints.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-withMCPs/install.sh")

This will create a ./claude-withMCPs command and a ./tools/allowed-domains.txt file you can customize.

4. Claude CLI (Full Network Access)
Warning: This version has unrestricted internet access. Use it for tasks that require network access beyond the Anthropic API, like installing dependencies, fetching documentation, or researching APIs. Only use this version when the restricted version is insufficient.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "[https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online/install.sh](https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online/install.sh)")

This will create a ./claude-online command for you to use.
