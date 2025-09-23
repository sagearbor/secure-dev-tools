# Dockerfile for Ollama-based development environment
# This provides a completely offline LLM for code assistance
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Install aider - a CLI tool that works well with Ollama
RUN pip3 install aider-chat

# Pre-download a code-optimized model during build
# DeepSeek-Coder is excellent for code tasks and relatively small
# This will be embedded in the image so no network needed at runtime
RUN ollama serve & \
    sleep 5 && \
    ollama pull deepseek-coder:6.7b && \
    pkill ollama

# Create working directory
WORKDIR /app

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["bash"]