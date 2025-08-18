#!/usr/bin/env bash

IMAGE_SHA=$(cosign triangulate --type='digest' ghcr.io/garethahealy/verifying-redhat-images/signed:v1)

cosign sign -y ${IMAGE_SHA}
