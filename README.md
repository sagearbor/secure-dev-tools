Secure Development Environment Tools
This repository provides centrally managed, security-audited configurations for running powerful development tools in sandboxed environments.

Each tool is self-contained in its own directory. To set up a tool in your project, follow the installation instructions for that specific tool below.

Available Tools
1. Claude CLI (Offline / Max Security)
This is a secure, network-disabled, containerized environment for running the claude-cli Python tool. Use this for maximum security on sensitive codebases. The tool can only read and write files within the project directory it is run from.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli/install.sh")

This will download and run the installer in one step, creating a ./claude command for you to use.

2. Claude CLI (Online Version)
Warning: This version can access the internet. Use it for tasks that require network access, like installing dependencies or researching APIs. Do not use it on highly sensitive codebases.

To Install in Your Project:

Navigate to your project's root directory and run the following command:

bash <(curl -sSL "https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-online/install.sh")

This will create a ./claude-online command for you to use.

Troubleshooting
If you encounter TLS certificate errors during Docker image builds (e.g., "x509: certificate signed by unknown authority"), this is typically caused by corporate security tools like Zscaler. To resolve:

1. Temporarily disable Zscaler or your corporate VPN/proxy
2. Run the installation command
3. Re-enable your security tools after installation completes

The Docker build only needs to run once during initial setup, so this is a one-time requirement.
