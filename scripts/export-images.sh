#!/usr/bin/env bash
# Export the published image as per-architecture tarballs for offline sharing
# (cloud drive / USB). Attendees load with: docker load -i <file>.tar.gz
#
# Usage: scripts/export-images.sh [tag] [output_dir]
set -euo pipefail

IMAGE="ghcr.io/victorrrwang/flow-workshop-r"
TAG="${1:-2026.09}"
OUT="${2:-dist}"

mkdir -p "$OUT"
for arch in arm64 amd64; do
  file="$OUT/flow-workshop-r-$TAG-$arch.tar.gz"
  echo "==> $IMAGE:$TAG ($arch) -> $file"
  docker pull --platform "linux/$arch" "$IMAGE:$TAG"
  docker save --platform "linux/$arch" "$IMAGE:$TAG" | gzip -1 > "$file"
done

(cd "$OUT" && shasum -a 256 flow-workshop-r-"$TAG"-*.tar.gz > SHA256SUMS)
ls -lh "$OUT"
cat "$OUT/SHA256SUMS"
