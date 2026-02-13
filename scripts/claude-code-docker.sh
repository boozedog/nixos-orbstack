#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="claude-code"
IMAGE_TAG="latest"
FLAKE_ATTR=".#packages.aarch64-linux.claude-code-docker"
HOST_TMP="/mnt/mac/tmp/claude-code.tar.gz"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  build    Build the image and copy to macOS host (run in VM)
  run      Load image and run sidecar in Docker (run on macOS)
EOF
  exit 1
}

cmd_build() {
  echo "Building ${IMAGE_NAME} docker image..."
  nix build "${FLAKE_ATTR}"

  echo "Copying to macOS host at ${HOST_TMP}..."
  install -m 644 "$(readlink -f result)" "${HOST_TMP}"

  echo ""
  echo "Done! Now run 'docker:run' on macOS to load and start."
}

cmd_run() {
  echo "Loading image into Docker..."
  docker load < "/tmp/claude-code.tar.gz"
  echo ""

  docker run -it --rm --name "sidecar-$(basename "$(pwd)")" \
    -v claude-code-home:/home/claude \
    -v "$(pwd):/work" \
    -w /work \
    "${IMAGE_NAME}:${IMAGE_TAG}"
}

case "${1:-}" in
  build) cmd_build ;;
  run)   cmd_run ;;
  *)     usage ;;
esac
