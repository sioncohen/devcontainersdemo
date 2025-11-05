# Stage 1: Build stage for downloading all dependencies
FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm as builder

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install dependencies into a dedicated directory. The --no-cache-dir flag is crucial for
# avoiding a build cache that would increase the final image size.
RUN python -m pip install --no-cache-dir --upgrade pip
RUN python -m pip install --no-cache-dir --target=/install -r requirements.txt

# Stage 2: Final image with and the pre-installed dependencies
# Start with a clean base image
FROM python:3.13-slim

# Set up a dedicated non-root user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -ms /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME -p TESTTESSSS \
    && usermod -p S0MEV3RYS3KretPw $USERNAME

RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY sshd_config /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd

# Set the working directory
WORKDIR /home/$USERNAME

# Copy the installed packages from the builder stage
COPY --from=builder /install /usr/local/lib/python3.13/site-packages

# Install JupyterLab and notebook extensions
RUN python -m pip install --no-cache-dir jupyterlab notebook jupyter_http_over_ws jupyterlab-git

# Expose the JupyterLab and SSH ports
EXPOSE 8888
EXPOSE 22

# Set up SSH and generate keys
RUN mkdir -p /home/$USERNAME/.ssh
RUN if [ ! -f /home/$USERNAME/.ssh/key ] ; then ssh-keygen -t ed25519 -C "" -N "" -f /home/$USERNAME/.ssh/key ; fi
RUN if [ ! -f /home/$USERNAME/.ssh/key2048 ] ; then ssh-keygen -t rsa -b 2048 -C "" -N "" -f /home/$USERNAME/.ssh/key2048 ; fi	
COPY ./authorized_keys /home/$USERNAME/.ssh/authorized_keys

RUN chown -R $USERNAME:$USERNAME /home/$USERNAME
COPY start.sh /home/$USERNAME/start_jupyter.sh
RUN chmod +x /home/$USERNAME/start_jupyter.sh


# RUN service ssh start

# Set the entrypoint to the wrapper script
CMD ["service", "ssh", "start", "-D"]
