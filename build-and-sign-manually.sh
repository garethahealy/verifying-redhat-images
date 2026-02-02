#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="ghcr.io/garethahealy/verifying-redhat-images/example:manaully-signed"

echo "1/4 Build image: ${IMAGE_TAG}"
podman build . -t "${IMAGE_TAG}" --platform linux/amd64

echo "2/4 Push image: ${IMAGE_TAG}"
podman push "${IMAGE_TAG}"

echo "3/4 Resolve image digest"
IMAGE_SHA="$(cosign triangulate --type='digest' "${IMAGE_TAG}")"

echo "4/4 Sign image digest: ${IMAGE_SHA}"
cosign sign -y "${IMAGE_SHA}"
