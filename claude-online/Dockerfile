# Use a minimal, secure base image with Python pre-installed.
FROM python:3.11-slim-bullseye

# Set metadata labels
LABEL maintainer="Your Org <security@your-org.com>"
LABEL description="A secure, isolated environment for running the Claude AI CLI."

# Create a non-root user and group to run the application.
# This is a critical security measure to avoid running as root.
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid 1001 -m appuser

# Install Node.js 20 LTS and Claude CLI globally
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg procps && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @anthropic-ai/claude-code && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the container.
# This is where the project files will be mounted.
WORKDIR /app

# Switch to the non-root user.
# Any subsequent commands will be run as 'appuser'.
USER appuser

# Set permissive umask so files created by container are world-writable
# This allows both container user (UID 1001) and host user to modify files
RUN echo "umask 000" >> ~/.bashrc

# Create entrypoint script that sets umask before running claude
RUN echo '#!/bin/sh\numask 000\nexec claude "$@"' > /home/appuser/entrypoint.sh && \
    chmod +x /home/appuser/entrypoint.sh

# The entrypoint is the command that will be run when the container starts.
ENTRYPOINT ["/home/appuser/entrypoint.sh"]
