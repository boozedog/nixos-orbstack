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
  run      Load image and run claude-code in Docker (run on macOS)
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
  echo "How do you want to run claude-code?"
  echo ""
  echo "  1) Dangerously skip permissions (default)"
  echo "  2) Normal run"
  echo "  3) Login (first time setup)"
  echo ""
  read -rp "Choice [1]: " choice
  choice="${choice:-1}"

  case "$choice" in
    1)
      docker run -it --rm --name "claude-code-danger-$(basename "$(pwd)")" \
        -v claude-code-home:/home/claude \
        -v "$(pwd):/work" \
        -w /work \
        "${IMAGE_NAME}:${IMAGE_TAG}" --dangerously-skip-permissions
      ;;
    2)
      docker run -it --rm --name "claude-code-$(basename "$(pwd)")" \
        -v claude-code-home:/home/claude \
        -v "$(pwd):/work" \
        -w /work \
        "${IMAGE_NAME}:${IMAGE_TAG}"
      ;;
    3)
      docker run -it --rm --name "claude-code-$(basename "$(pwd)")" \
        -v claude-code-home:/home/claude \
        -v "$(pwd):/work" \
        -w /work \
        "${IMAGE_NAME}:${IMAGE_TAG}" login
      ;;
    *)
      echo "Invalid choice."
      exit 1
      ;;
  esac
}

case "${1:-}" in
  build) cmd_build ;;
  run)   cmd_run ;;
  *)     usage ;;
esac
