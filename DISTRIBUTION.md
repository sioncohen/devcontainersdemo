# Offline Docker Dev Container Distribution Guide

This guide explains how to build, save, and distribute the Docker dev container to disconnected/air-gapped stations.

## Overview

The Docker dev container is pre-configured with:
- Python 3.11 (Debian Bookworm)
- All dependencies from `requirements.txt` pre-installed
- VS Code Dev Container support
- No internet connection required at runtime

## Prerequisites

### On the Build Machine (with internet)
- Docker installed and running
- Access to the project repository
- Internet connection to download base images and Python packages

### On the Target Machine (offline)
- Docker installed and running
- No internet connection required

## Building and Saving the Container

### Option 1: Using the Provided Script (Recommended)

**On Linux/macOS:**
```bash
./save-container.sh
```

**On Windows (PowerShell):**
```powershell
.\save-container.ps1
```

**On Windows (Command Prompt):**
```cmd
save-container.bat
```

These scripts will:
1. Build the Docker image from the Dockerfile
2. Save it as `devcontainer-offline.tar`
3. Display the file size and next steps

### Option 2: Manual Build and Save

**On Linux/macOS/Windows:**
```bash
# Build the image
docker build -t devcontainer-offline:latest -f .devcontainer/Dockerfile .

# Save the image to a tar file
docker save devcontainer-offline:latest -o devcontainer-offline.tar
```

## Distributing to Offline Stations

1. **Copy the tar file** to the target machine using:
   - USB drive
   - Network file share (if available)
   - Any other offline transfer method

2. **Transfer the entire project directory** (or at least the `.devcontainer` folder) to maintain devcontainer configuration

## Loading on Offline Stations

### Step 1: Load the Docker Image

**On Linux/macOS/Windows:**
```bash
docker load -i devcontainer-offline.tar
```

**Verify the image was loaded:**

On Linux/macOS:
```bash
docker images | grep devcontainer-offline
```

On Windows (PowerShell):
```powershell
docker images | Select-String devcontainer-offline
```

On Windows (Command Prompt):
```cmd
docker images | findstr devcontainer-offline
```

### Step 2: Configure Dev Container (if using VS Code)

The `.devcontainer/devcontainer.json` is already configured to build from the Dockerfile. However, if you want to use the pre-loaded image directly, you can modify `devcontainer.json`:

```json
{
  "name": "Python 3 (Offline)",
  "image": "devcontainer-offline:latest",
  "remoteUser": "vscode"
}
```

### Step 3: Use the Container

#### Using VS Code Dev Containers

1. Open the project folder in VS Code
2. Press `F1` and select "Dev Containers: Reopen in Container"
3. VS Code will build/use the container with all dependencies pre-installed

#### Using Docker Directly

**On Linux/macOS:**
```bash
# Run the container interactively
docker run -it --rm -v $(pwd):/workspaces/app devcontainer-offline:latest /bin/bash

# Or run a Python script
docker run --rm -v $(pwd):/workspaces/app devcontainer-offline:latest python main.py
```

**On Windows (PowerShell):**
```powershell
# Run the container interactively
docker run -it --rm -v ${PWD}:/workspaces/app devcontainer-offline:latest /bin/bash

# Or run a Python script
docker run --rm -v ${PWD}:/workspaces/app devcontainer-offline:latest python main.py
```

**On Windows (Command Prompt):**
```cmd
REM Run the container interactively
docker run -it --rm -v %CD%:/workspaces/app devcontainer-offline:latest /bin/bash

REM Or run a Python script
docker run --rm -v %CD%:/workspaces/app devcontainer-offline:latest python main.py
```

## Verifying Installation

Once inside the container, verify all packages are installed (works on all platforms):

```bash
python -c "import pandas, numpy, duckdb, dlt, oracledb, pymongo, requests, openpyxl, pyarrow, sklearn, matplotlib, sqlalchemy, pyodbc; print('All packages imported successfully!')"
```

## Troubleshooting

### Image Not Found After Loading

If the image doesn't appear after loading:

**On Linux/macOS/Windows:**
```bash
# Check if the image was loaded
docker images

# If needed, tag the image
docker tag <image-id> devcontainer-offline:latest
```

### Container Can't Find Python Packages

If packages aren't found:
- Ensure the image was built correctly with all dependencies
- Check that you're using the correct Python version (3.11)
- Verify the packages are in `/usr/local/lib/python3.11/site-packages`

### VS Code Dev Container Issues

If VS Code can't connect:
- Ensure Docker is running
- Check that the devcontainer.json is correctly configured
- Try rebuilding the container: `F1` → "Dev Containers: Rebuild Container"

## Updating the Container

To update dependencies:

1. **On build machine (with internet):**
   - Update `requirements.txt`
   - Rebuild and save:
     - Linux/macOS: `./save-container.sh`
     - Windows PowerShell: `.\save-container.ps1`
     - Windows CMD: `save-container.bat`
   - Distribute the new `devcontainer-offline.tar`

2. **On offline stations:**
   - Load the new image: `docker load -i devcontainer-offline.tar`
   - Rebuild the dev container in VS Code

## File Sizes

The saved tar file will typically be:
- **Base image**: ~500MB-1GB
- **With dependencies**: ~1-2GB (depending on packages)
- **Compressed**: Can be compressed further with `gzip` or `xz` for transfer

**Example compression:**

On Linux/macOS:
```bash
gzip devcontainer-offline.tar
# Results in devcontainer-offline.tar.gz (smaller file)
# Load with: gunzip -c devcontainer-offline.tar.gz | docker load
```

On Windows (PowerShell):
```powershell
# Use 7-Zip or similar compression tool
Compress-Archive -Path devcontainer-offline.tar -DestinationPath devcontainer-offline.tar.zip
# Load: Extract first, then docker load -i devcontainer-offline.tar
```

Note: Docker `save` and `load` commands work the same on all platforms (Linux, macOS, Windows).

## Security Notes

- The container includes all dependencies pre-installed
- No internet connection is required at runtime
- All packages are installed from PyPI during the build process
- Review `requirements.txt` to ensure all packages are trusted

