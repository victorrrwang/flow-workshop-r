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
  "SETUP.pdf"
  "SETUP-zh.pdf"
  "docker-compose.yml"
  "docker/rstudio-prefs.json"
  "workshop/00-check-your-setup.Rmd"
  "data/QC251006 PB NCC_C_tubeT_C12.fcs"
)

mkdir -p "${STAGE}"

# Keep the PDFs in step with their .md sources. pandoc ships inside RStudio rather than
# on the PATH, so this is best-effort: regenerate when we can, otherwise ship the
# committed PDFs.
#
# -f markdown-implicit_figures keeps the Docker Desktop screenshot inline instead of
# turning it into a LaTeX float, which LaTeX would happily defer to its own page.
if command -v pandoc >/dev/null 2>&1; then
  echo "Regenerating SETUP.pdf from SETUP.md ..."
  pandoc SETUP.md -f markdown-implicit_figures -o SETUP.pdf \
    --pdf-engine=xelatex \
    -V geometry:margin=1.6cm \
    -V fontsize=9pt \
    -V colorlinks=true -V linkcolor=black -V urlcolor=blue \
    -V mainfont="DejaVu Sans" -V monofont="DejaVu Sans Mono" \
    || echo "WARNING: pandoc failed; shipping the existing SETUP.pdf" >&2

  # The Chinese build needs a CJK font, and line breaking between Han characters, which
  # LaTeX does not do by default. The usual route is the xeCJK package, but that pulls in
  # ctexhook.sty from the ctex bundle, which is not part of a basic TeX Live install.
  # These two XeTeX primitives give the same line breaking with no extra packages.
  echo "Regenerating SETUP-zh.pdf from SETUP-zh.md ..."
  # Portable: BSD mktemp -t takes a prefix, GNU mktemp -t needs XXXXXX.
  # Plain mktemp behaves the same on both, and -H does not care about the extension.
  ZH_HEADER="$(mktemp)"
  cat > "${ZH_HEADER}" <<'TEX'
\XeTeXlinebreaklocale "zh"
\XeTeXlinebreakskip = 0pt plus 1pt minus 0.1pt
TEX
  pandoc SETUP-zh.md -f markdown-implicit_figures -o SETUP-zh.pdf \
    --pdf-engine=xelatex \
    -H "${ZH_HEADER}" \
    -V geometry:margin=1.6cm \
    -V fontsize=10pt \
    -V colorlinks=true -V linkcolor=black -V urlcolor=blue \
    -V mainfont="Noto Sans CJK SC" -V monofont="Noto Sans Mono CJK SC" \
    || echo "WARNING: pandoc failed; shipping the existing SETUP-zh.pdf" >&2
  rm -f "${ZH_HEADER}"
else
  echo "NOTE: pandoc not found; shipping the existing PDFs unchanged."
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

# Attendees get the PDF, not markdown. A stray .md means someone added one to the
# allowlist without thinking about who reads it.
if find "${STAGE}" -name '*.md' | grep -q .; then
  echo "ERROR: markdown files found in the bundle. Attendees get SETUP.pdf only." >&2
  find "${STAGE}" -name '*.md' >&2
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
