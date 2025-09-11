# Secure Development Environment Tools

This repository provides centrally managed, security-audited configurations for running powerful development tools in sandboxed environments.

Each tool is self-contained in its own directory.

## Available Tools

### 1. Claude CLI

A secure, network-disabled, containerized environment for running the `claude-cli` Python tool. The tool can only read and write files within the project directory it is run from.

**To Install in Your Project:**

Navigate to your project's root directory and run the following two commands:

**A. Download the installer:**

```
curl -sSL "[https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli/install.sh](https://raw.githubusercontent.com/sagearbor/secure-dev-tools/main/claude-cli/install.sh)" -o setup_claude.sh
```

**B. Run the installer:**

```
bash setup_claude.sh
```

This will create a `./claude` command in your project for you to use. You can safely delete the `setup_claude.sh` script after it has run.

*(When you add more tools in the future, you will add a new section for them here.)*
