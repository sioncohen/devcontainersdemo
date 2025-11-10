# Stage 1: build deps
FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm AS builder
WORKDIR /tmp/build
COPY requirements.txt .
RUN python -m pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir --target=/install -r requirements.txt

# Stage 2: final image (keep devcontainers tooling & 'vscode' user)
FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm

# Copy built deps (same Python version!) - install to system Python path for container-wide access
COPY --from=builder /install /usr/local/lib/python3.11/site-packages

# Clean up any temporary files and reduce image size for offline distribution
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set a reasonable workdir for VS Code
WORKDIR /workspaces/app

# Keep container running (VS Code will override this)
CMD ["sleep", "infinity"]