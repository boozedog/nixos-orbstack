#!/usr/bin/env bash
set -euo pipefail

# Updates packages/sidecar.nix with the latest develop branch commit
# and a proper git-describe-style version string.
#
# Usage: ./scripts/update-sidecar.sh [COMMIT_SHA]
#   If no commit is given, uses the latest commit on boozedog/sidecar develop.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_FILE="$SCRIPT_DIR/../packages/sidecar.nix"

FORK_OWNER="boozedog"
FORK_REPO="sidecar"
UPSTREAM_OWNER="marcus"
UPSTREAM_REPO="sidecar"
BRANCH="develop"

# 1. Resolve target commit
if [[ ${1:-} ]]; then
  COMMIT="$1"
  echo "Using provided commit: $COMMIT"
else
  COMMIT=$(gh api "repos/$FORK_OWNER/$FORK_REPO/branches/$BRANCH" --jq '.commit.sha')
  echo "Latest $BRANCH commit: $COMMIT"
fi
SHORT_SHA=${COMMIT:0:7}

# 2. Find the latest upstream tag that's an ancestor of this commit.
#    Fetch tags sorted by version (newest first), then check ancestry.
echo "Finding latest ancestor tag from $UPSTREAM_OWNER/$UPSTREAM_REPO..."

TAGS=$(gh api "repos/$UPSTREAM_OWNER/$UPSTREAM_REPO/tags" --paginate --jq '.[].name' | sort -rV)

BEST_TAG=""
AHEAD_BY=0

for tag in $TAGS; do
  result=$(gh api "repos/$UPSTREAM_OWNER/$UPSTREAM_REPO/compare/$tag...$COMMIT" \
    --jq '{ahead_by, behind_by}' 2>/dev/null) || continue

  behind=$(echo "$result" | jq -r '.behind_by')
  ahead=$(echo "$result" | jq -r '.ahead_by')

  if [[ "$behind" == "0" ]]; then
    BEST_TAG="$tag"
    AHEAD_BY="$ahead"
    break
  fi
done

if [[ -z "$BEST_TAG" ]]; then
  echo "ERROR: Could not find an ancestor tag for $COMMIT"
  exit 1
fi

echo "Closest tag: $BEST_TAG ($AHEAD_BY commits ahead)"

# 3. Build version string matching git describe --tags --always
TAG_VERSION="${BEST_TAG#v}" # strip leading 'v'
if [[ "$AHEAD_BY" -eq 0 ]]; then
  VERSION="$TAG_VERSION"
else
  VERSION="${TAG_VERSION}-${AHEAD_BY}-g${SHORT_SHA}"
fi
echo "Version: $VERSION"

# 4. Prefetch source hash
echo "Prefetching source hash..."
SRC_HASH=$(nix-prefetch-url --unpack --type sha256 \
  "https://github.com/$FORK_OWNER/$FORK_REPO/archive/$COMMIT.tar.gz" 2>/dev/null)
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$SRC_HASH")
echo "Source hash: $SRI_HASH"

# 5. Update sidecar.nix
echo "Updating $NIX_FILE..."

# Update version
sed -i "s|version = \".*\";.*|version = \"$VERSION\"; # git describe --tags --always $SHORT_SHA|" "$NIX_FILE"

# Update rev
sed -i "s|rev = \".*\";.*|rev = \"$COMMIT\"; # $BRANCH branch|" "$NIX_FILE"

# Update source hash
sed -i "s|hash = \"sha256-.*\";|hash = \"$SRI_HASH\";|" "$NIX_FILE"

echo ""
echo "Updated sidecar.nix:"
echo "  version: $VERSION"
echo "  rev:     $COMMIT"
echo "  hash:    $SRI_HASH"
echo ""
echo "NOTE: If Go dependencies changed, vendorHash may need updating."
echo "      Build with 'nix build .#sidecar' — if it fails with a hash"
echo "      mismatch, replace vendorHash with the expected hash from the error."
