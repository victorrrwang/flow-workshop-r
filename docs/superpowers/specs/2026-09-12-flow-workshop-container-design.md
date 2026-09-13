# Flow Cytometry Workshop Container — Design

Date: 2026-09-12
Status: Draft for review

## Purpose

Give every workshop attendee an identical RStudio environment with the R/Bioconductor
packages needed for basic flow cytometry data manipulation, visualization, and
introductory high-dimensional analysis — without per-laptop R installation debugging.

## Success criteria

1. An attendee with Docker installed can go from nothing to a working RStudio at
   `http://localhost:8787` using one documented command (online) or one downloaded
   file plus one command (offline).
2. The image runs natively on Apple Silicon (arm64) and Intel/AMD (amd64) laptops.
3. A smoke test proves every workshop package loads and the example FCS file can be
   read, compensated, transformed, and plotted inside the container.
4. The starter R Markdown notebook knits to HTML without errors inside the container.
5. Adding a package later is a one-line change followed by a rebuild.

## Non-goals (for now)

- Python / reticulate environment
- Hosted multi-user server
- Bundling FCS data inside the image
- Automated CI builds (can be added later)

## Approach

Build on the official `bioconductor/bioconductor_docker` image, pinned to
`RELEASE_3_23-r-4.6.1` (Bioconductor 3.23, R 4.6.1; multi-arch amd64+arm64, verified on
Docker Hub 2026-09-12). This base ships RStudio Server and is configured to install
pre-built Bioconductor binaries, so builds are fast and reproducible on both
architectures. The floating `latest` tag is avoided (it is amd64-only and unpinned).

Rejected alternatives:
- `rocker/rstudio` + source installs — slow, fragile compiles on arm64.
- `renv.lock` without a container — reintroduces per-laptop setup problems.

## Repository layout

```
01-bioinformatics-analysis-in-r/
├── docker/
│   ├── Dockerfile          # FROM bioconductor/bioconductor_docker:RELEASE_3_23-r-4.6.1
│   └── install.R           # single package list; fails the build if any install fails
├── docker-compose.yml      # port 8787, password via env, volume mounts
├── data/                   # instructor FCS files — git-ignored, mounted read-only
├── workshop/               # attendee working folder — mounted read-write
│   └── 01-import-comp-transform-plot.Rmd
├── scripts/
│   ├── smoke-test.R        # verifies packages + FCS pipeline inside container
│   └── export-images.sh    # docker save → per-arch .tar.gz + SHA-256 checksums
├── docs/superpowers/specs/ # design documents (this file)
├── .gitignore              # data/*.fcs, *.tar.gz, knitted outputs
└── README.md               # attendee + instructor instructions
```

## Components

### 1. Image (`docker/Dockerfile`, `docker/install.R`)

- Base: `bioconductor/bioconductor_docker:RELEASE_3_23-r-4.6.1`.
- `install.R` holds one character vector of packages and installs them with
  `BiocManager::install(..., update = FALSE, ask = FALSE)`, then checks
  `requireNamespace()` for each and calls `quit(status = 1)` listing any failures, so a
  broken install fails the build instead of shipping silently.
- Package set:
  - Core flow: flowCore, flowWorkspace, openCyto, ggcyto, CytoML
  - QC: flowAI, PeacoQC
  - High-dimensional: CATALYST, FlowSOM, uwot
  - General: tidyverse, patchwork, rmarkdown, knitr
- Image published as `ghcr.io/victorrrwang/flow-workshop-r` with tags
  `2026.09` (workshop version) and `latest`.
- Labels: `org.opencontainers.image.source` pointing at the GitHub repo so GHCR links it.

**Adding packages later:** append the name to the vector in `install.R`, rebuild,
re-push with a new tag (e.g. `2026.10`). Attendees re-pull. Packages installed
interactively inside a running container are lost when the container is removed —
this is intentional so everyone stays on the same versions.

### 2. Runtime (`docker-compose.yml`)

- Maps `8787:8787`.
- `PASSWORD` read from environment with a documented default for local-only use
  (RStudio user: `rstudio`). Bound to `127.0.0.1` so it is not exposed on venue Wi-Fi.
- Mounts:
  - `./data` → `/home/rstudio/data` (read-only)
  - `./workshop` → `/home/rstudio/workshop` (read-write)
- Equivalent single `docker run` command documented in README for people without compose.

### 3. Starter notebook (`workshop/01-import-comp-transform-plot.Rmd`)

Uses the instructor's example file
`QC251006 PB NCC_C_tubeT_C12.fcs` (FACSDiva 9.6, FACSymphony A5 SE, FCS 3.0,
49,209 events, 55 parameters, 31 labelled markers, embedded `$SPILL` matrix).
The file path is a parameter at the top so other FCS files can be swapped in.

Sections:
1. **Setup** — load flowCore, flowWorkspace, ggcyto, tidyverse, patchwork.
2. **Import** — `read.FCS(path, transformation = FALSE, truncate_max_range = FALSE)`;
   print event and parameter counts.
3. **Metadata** — channel/marker table from `pData(parameters(ff))`
   (name, desc, range); selected keywords (`$CYT`, `$DATE`, `$TOT`, `CREATOR`, etc.)
   from `keyword(ff)`.
4. **Compensation** — extract `spillover(ff)$SPILL`, show it as a heatmap, apply with
   `compensate(ff, spill)`; before/after scatter of one known spillover pair.
5. **Transformation** — logicle via `estimateLogicle(ff_comp, channels = <fluorescence channels>)`
   applied to fluorescence channels only (scatter and Time left linear); before/after
   histograms of one marker.
6. **Plots** — ggcyto: FSC-A vs SSC-A, CD45 vs SSC-A, CD3 vs CD19, CD4 vs CD8
   (channels looked up by marker name, not hard-coded detector names).
7. **Session info** — `sessionInfo()` for reproducibility.

Knits to HTML. Output files are git-ignored.

### 4. Smoke test (`scripts/smoke-test.R`)

Run inside the built container:
- `library()` every package in the install list.
- If an FCS file exists in `/home/rstudio/data`, read → compensate → transform → save a
  ggcyto PNG; exit non-zero on any error.
- Render the starter Rmd via `rmarkdown::render()`.

### 5. Distribution

- **Online (primary):** `docker pull ghcr.io/victorrrwang/flow-workshop-r:2026.09`
  (package set to public in GHCR). Multi-arch manifest built with
  `docker buildx build --platform linux/amd64,linux/arm64 --push`.
  Requires `gh auth refresh -s write:packages` (or a PAT) for `docker login ghcr.io`.
- **Offline (cloud drive / USB):** `scripts/export-images.sh` pulls each platform and
  writes `flow-workshop-r-2026.09-arm64.tar.gz` and `…-amd64.tar.gz` plus
  `SHA256SUMS`. Instructor uploads to their cloud drive and shares the link; attendees
  run `docker load -i <file>`. README explains how to tell which architecture you have.
- **FCS data:** distributed separately by the instructor (not in the image, not in git).
  Note: the example file's header contains institution name, cytometer serial, and
  operator — acceptable for workshop sharing at instructor's discretion, but it is kept
  out of the public image and repo.

## Error handling

- Build fails loudly on any package install failure (install.R check).
- Smoke test exits non-zero on any failure; it is run before publishing.
- Notebook checks the FCS path exists at the top and stops with a clear message
  ("put your FCS file in ./data") if not.

## Testing / verification before workshop

1. Build locally on arm64 (instructor's Mac); run smoke test in container.
2. Knit the Rmd in RStudio in the browser.
3. Build/push the multi-arch image; run the smoke test on an amd64 machine or via
   `--platform linux/amd64` emulation.
4. Round-trip the offline tarball: `docker load` on a clean machine and open RStudio.

## Versioning

- Git repo tracks all build files, notebook, scripts, and this spec.
- Image tags are date-based (`YYYY.MM`); Bioconductor base pinned explicitly, so a
  rebuild months later yields the same Bioc release.
