# Use a minimal, secure base image with Python pre-installed.
FROM python:3.11-slim-bullseye

# Set metadata labels
LABEL maintainer="Your Org <security@your-org.com>"
LABEL description="A secure, isolated environment for running the Claude AI CLI."

# Create a non-root user and group to run the application.
# This is a critical security measure to avoid running as root.
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid 1001 -m appuser

# Install claude-code CLI using npx
RUN apt-get update && \
    apt-get install -y curl nodejs npm && \
    npx -y claude-code@latest --version && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the container.
# This is where the project files will be mounted.
WORKDIR /app

# Switch to the non-root user.
# Any subsequent commands will be run as 'appuser'.
USER appuser

# The entrypoint is the command that will be run when the container starts.
# It's set to 'npx claude-code@latest' and will receive arguments from the docker run command.
ENTRYPOINT ["npx", "claude-code@latest"]
