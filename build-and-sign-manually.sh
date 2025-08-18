#!/usr/bin/env bash

podman build . -t ghcr.io/garethahealy/verifying-redhat-images/example:manaully-signed --platform linux/amd64
podman push ghcr.io/garethahealy/verifying-redhat-images/example:manaully-signed

IMAGE_SHA=$(cosign triangulate --type='digest' ghcr.io/garethahealy/verifying-redhat-images/example:manaully-signed)

cosign sign -y ${IMAGE_SHA}
