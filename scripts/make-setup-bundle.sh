#!/usr/bin/env bash
#
# Build the bundle attendees receive at T-2 weeks.
#
# This is deliberately an ALLOWLIST, not an exclude-list. Anything not named here does not
# go out -- so adding a notebook or a patient file to the repo can never accidentally ship
# it. If you need something new in the bundle, add it below on purpose.
#
# What attendees get:   enough to start the container, prove it works, and open a real
#                       file. The QC normal control is fine to send in advance -- it is
#                       quality-control material, not a patient case.
# What they do NOT get: the lab notebooks, any patient case, the checkpoints.
#                       Those are handed out on the day.
#
# Usage:  scripts/make-setup-bundle.sh [outdir]

set -euo pipefail

OUT_DIR="${1:-dist}"

# The folder attendees end up with is called flow-workshop, so the instructions can say
# "you will have C:\Users\<you>\flow-workshop" and be literally true.
NAME="flow-workshop"
ZIP="flow-workshop-setup.zip"

# Stage and zip in a temporary directory, then copy the finished file into place.
#
# Not just tidiness: `zip` writes to a temp file and renames it over the target, and some
# mounted or synced filesystems (network shares, cloud-sync folders, container bind mounts)
# refuse renames and deletes. Building somewhere ordinary and copying the result in means
# the script works wherever you point it, and never leaves half-built junk in OUT_DIR.
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

STAGE="${WORK}/${NAME}"

# Files that go out. Nothing else does.
# Named one by one, deliberately. Do NOT change this to a glob like data/*.fcs -- the
# moment a patient case lands in data/, a glob would ship it and nobody would notice.
ALLOW=(
  "SETUP.md"
  "SETUP.pdf"
  "docker-compose.yml"
  "docker/rstudio-prefs.json"
  "workshop/00-check-your-setup.Rmd"
  "data/QC251006 PB NCC_C_tubeT_C12.fcs"
)

mkdir -p "${STAGE}"

# Keep SETUP.pdf in step with SETUP.md. pandoc ships inside RStudio rather than on the
# PATH, so this is best-effort: regenerate when we can, otherwise ship the committed PDF.
if command -v pandoc >/dev/null 2>&1; then
  echo "Regenerating SETUP.pdf from SETUP.md ..."
  pandoc SETUP.md -o SETUP.pdf \
    --pdf-engine=xelatex \
    -V geometry:margin=1.6cm \
    -V fontsize=9pt \
    -V colorlinks=true -V linkcolor=black -V urlcolor=blue \
    -V mainfont="DejaVu Sans" -V monofont="DejaVu Sans Mono" \
    || echo "WARNING: pandoc failed; shipping the existing SETUP.pdf" >&2
else
  echo "NOTE: pandoc not found; shipping the existing SETUP.pdf unchanged."
fi

for f in "${ALLOW[@]}"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: expected file is missing: $f" >&2
    exit 1
  fi
  mkdir -p "${STAGE}/$(dirname "$f")"
  cp "$f" "${STAGE}/$f"
done

mkdir -p "${STAGE}/data"
cat > "${STAGE}/data/README.txt" <<'TXT'
This folder holds the FCS files the workshop uses.

One quality-control file is here already, so you can check your setup on real data.
The rest of the files, and the lab notebooks, are handed out on the day.
Leave this folder where it is -- the container expects to find it.
TXT

# Sanity check: checkpoints are worked answers and must never ship early.
if find "${STAGE}" -name '*.rds' | grep -q .; then
  echo "ERROR: .rds checkpoints found in the bundle. Refusing to build." >&2
  exit 1
fi

# Sanity check: only the QC file may go out. Anything else in data/ is assumed to be a
# patient case until proven otherwise.
while IFS= read -r f; do
  case "$(basename "$f")" in
    QC*.fcs) ;;
    *) echo "ERROR: non-QC data file in the bundle: $f" >&2; exit 1 ;;
  esac
done < <(find "${STAGE}" -name '*.fcs')

if ls "${STAGE}/workshop/"*.Rmd 2>/dev/null | grep -v '00-check-your-setup.Rmd' | grep -q .; then
  echo "ERROR: lab notebooks found in the bundle. Refusing to build." >&2
  exit 1
fi

# The bundle gets the attendee half of the README only -- the instructor sections would
# just confuse people and reference scripts they do not have. Extracted rather than
# duplicated, so there is one source of truth.
awk '/^## For attendees/{p=1} /^## For the instructor/{p=0} p' README.md \
  > "${STAGE}/README.md"

if [ ! -s "${STAGE}/README.md" ]; then
  echo "ERROR: could not extract the attendee section from README.md" >&2
  exit 1
fi

( cd "${WORK}" && zip -rq "${ZIP}" "${NAME}" )

mkdir -p "${OUT_DIR}"

# cp, not mv: a plain overwrite works on filesystems where a rename would not.
cp "${WORK}/${ZIP}" "${OUT_DIR}/${ZIP}"

echo "Built ${OUT_DIR}/${ZIP}"
echo
echo "Contents:"
unzip -l "${OUT_DIR}/${ZIP}"
