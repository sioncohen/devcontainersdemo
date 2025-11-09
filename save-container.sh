#!/bin/bash
# Script to build and save the offline Docker dev container
# This creates a tar file that can be distributed to disconnected stations

set -e

IMAGE_NAME="devcontainer-offline"
IMAGE_TAG="latest"
OUTPUT_FILE="devcontainer-offline.tar"

echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Build context: .devcontainer directory"

# Build the Docker image from the Dockerfile
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f .devcontainer/Dockerfile --build-arg BUILDKIT_INLINE_CACHE=1 .

echo ""
echo "Image built successfully!"
echo ""

# Save the image to a tar file
echo "Saving image to ${OUTPUT_FILE}..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} -o ${OUTPUT_FILE}

# Get the file size
FILE_SIZE=$(du -h ${OUTPUT_FILE} | cut -f1)
echo ""
echo "✓ Image saved successfully!"
echo "  File: ${OUTPUT_FILE}"
echo "  Size: ${FILE_SIZE}"
echo ""
echo "To distribute to offline stations:"
echo "  1. Copy ${OUTPUT_FILE} to the target machine"
echo "  2. On the target machine, run:"
echo "     docker load -i ${OUTPUT_FILE}"
echo "  3. Tag the image (optional):"
echo "     docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To use with VS Code Dev Containers:"
echo "  - The devcontainer.json is already configured to build from the Dockerfile"
echo "  - Or you can modify devcontainer.json to use the loaded image:"
echo "    \"image\": \"${IMAGE_NAME}:${IMAGE_TAG}\""
echo ""

