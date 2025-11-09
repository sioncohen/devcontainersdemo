# PowerShell script to build and save the offline Docker dev container
# This creates a tar file that can be distributed to disconnected stations

$ErrorActionPreference = "Stop"

$IMAGE_NAME = "devcontainer-offline"
$IMAGE_TAG = "latest"
$OUTPUT_FILE = "devcontainer-offline.tar"

Write-Host "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
Write-Host "Build context: .devcontainer directory"
Write-Host ""

# Build the Docker image from the Dockerfile
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f .devcontainer/Dockerfile --build-arg BUILDKIT_INLINE_CACHE=1 .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Image built successfully!"
Write-Host ""

# Save the image to a tar file
Write-Host "Saving image to ${OUTPUT_FILE}..."
docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o $OUTPUT_FILE

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker save failed!" -ForegroundColor Red
    exit 1
}

# Get the file size
$fileInfo = Get-Item $OUTPUT_FILE
$fileSize = "{0:N2} MB" -f ($fileInfo.Length / 1MB)

Write-Host ""
Write-Host "✓ Image saved successfully!" -ForegroundColor Green
Write-Host "  File: ${OUTPUT_FILE}"
Write-Host "  Size: ${fileSize}"
Write-Host ""
Write-Host "To distribute to offline stations:"
Write-Host "  1. Copy ${OUTPUT_FILE} to the target machine"
Write-Host "  2. On the target machine, run:"
Write-Host "     docker load -i ${OUTPUT_FILE}"
Write-Host "  3. Tag the image (optional):"
Write-Host "     docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:${IMAGE_TAG}"
Write-Host ""
Write-Host "To use with VS Code Dev Containers:"
Write-Host "  - The devcontainer.json is already configured to build from the Dockerfile"
Write-Host "  - Or you can modify devcontainer.json to use the loaded image:"
Write-Host "    `"image`": `"${IMAGE_NAME}:${IMAGE_TAG}`""
Write-Host ""

