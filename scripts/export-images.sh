#!/usr/bin/env bash
# Export the published image as offline tarballs for a USB stick.
#
# There is no single file that runs natively on both chip families, so this
# writes two, named after what the attendee can tell about their own laptop
# ("do I have a Windows PC?") rather than after the CPU architecture ("is my
# chip arm64?"), which is the question people get wrong.
#
#   FOR-WINDOWS-AND-INTEL-MAC.tar.gz   linux/amd64
#   FOR-APPLE-SILICON-MAC.tar.gz       linux/arm64   (M1/M2/M3/M4)
#
# Both carry the SAME image name and tag inside, so after `docker load` the
# one docker-compose.yml works unchanged either way.
#
# WHY SKOPEO AND NOT `docker save`
#   `docker pull --platform` followed by `docker save` fails on a machine
#   whose native architecture differs from the one being exported:
#       unable to create manifests file: NotFound: content digest ... not found
#   The local image store ends up holding the foreign manifest without every
#   blob that `save` wants to write, and the two Docker image-store backends
#   (classic and containerd) disagree about whether `save` may take a
#   --platform flag at all. skopeo sidesteps all of it by streaming from the
#   registry straight into a docker-archive, never touching local Docker.
#
#   Install once:  brew install skopeo
#
# Usage: scripts/export-images.sh [tag] [output_dir]
set -euo pipefail

IMAGE="ghcr.io/victorrrwang/flow-workshop-r"
TAG="${1:-2026.09}"
OUT="${2:-dist/usb}"

if ! command -v skopeo >/dev/null 2>&1; then
  echo "skopeo not found. Install it with:" >&2
  echo "    brew install skopeo" >&2
  exit 1
fi

mkdir -p "$OUT"

emit() {
  local arch="$1" label="$2"
  local tar="$OUT/$label.tar"

  echo "==> $IMAGE:$TAG (linux/$arch) -> $label.tar.gz"
  rm -f "$tar" "$tar.gz"

  # --override-arch selects one platform out of the multi-arch manifest.
  # The ":name:tag" suffix is what `docker load` will register the image as,
  # so it must match what docker-compose.yml references.
  skopeo copy \
    --override-os linux \
    --override-arch "$arch" \
    "docker://$IMAGE:$TAG" \
    "docker-archive:$tar:$IMAGE:$TAG"

  gzip -1 "$tar"
}

emit amd64 "FOR-WINDOWS-AND-INTEL-MAC"
emit arm64 "FOR-APPLE-SILICON-MAC"

(cd "$OUT" && shasum -a 256 FOR-*.tar.gz > SHA256SUMS)

cat > "$OUT/READ-ME-FIRST.txt" <<EOF
FLOW CYTOMETRY WORKSHOP - offline image
=======================================

Copy ONE of these two files, whichever matches your laptop:

  FOR-WINDOWS-AND-INTEL-MAC.tar.gz
      Any Windows PC. Also a Mac from 2020 or earlier
      (Apple menu > About This Mac says "Intel").

  FOR-APPLE-SILICON-MAC.tar.gz
      A Mac from 2020 or later
      (Apple menu > About This Mac says "Apple M1" / "M2" / "M3" / "M4").

Then, with Docker Desktop running, open Terminal (Mac) or
PowerShell (Windows), cd to wherever you copied the file, and run:

  docker load -i FOR-APPLE-SILICON-MAC.tar.gz         <- or the other name

That takes a few minutes and prints a line ending in
"$IMAGE:$TAG".

After that, follow SETUP.pdf from step 3 onwards. You can skip any
step that downloads the image - you already have it.

If you loaded the wrong file, nothing breaks: load the right one and
carry on. The wrong one would merely have run very slowly.
EOF

echo
ls -lh "$OUT"
echo
cat "$OUT/SHA256SUMS"
