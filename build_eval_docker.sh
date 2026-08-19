#!/usr/bin/env bash
set -e

IMAGE_NAME="${1:-rehabcert-eval}"
DOCKER_PLATFORM="${2:-linux/amd64}"

docker build --network host --platform "$DOCKER_PLATFORM" -f eval.Dockerfile -t "$IMAGE_NAME" .
docker run --rm --platform "$DOCKER_PLATFORM" "$IMAGE_NAME" go build ./...

echo "Built image: $IMAGE_NAME (platform: $DOCKER_PLATFORM)"
