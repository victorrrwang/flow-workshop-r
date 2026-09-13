# Flow Workshop Container Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A multi-arch RStudio + Bioconductor flow cytometry image, a starter Rmd, a smoke test, and distribution scripts.

**Architecture:** `bioconductor/bioconductor_docker` base + one `install.R` package list; runtime via docker compose with `data/` (ro) and `workshop/` (rw) mounts; verification by an in-container smoke test that also knits the Rmd.

**Tech Stack:** Docker/buildx, R 4.6.1, Bioconductor 3.23, flowCore/flowWorkspace/ggcyto, rmarkdown.

**Spec:** `docs/superpowers/specs/2026-09-12-flow-workshop-container-design.md`

## Global Constraints

- Base image: `bioconductor/bioconductor_docker:RELEASE_3_23-r-4.6.1`
- Platforms: `linux/amd64`, `linux/arm64`
- Image name: `ghcr.io/victorrrwang/flow-workshop-r`, tags `2026.09` and `latest`
- Mounts: `./data` → `/home/rstudio/data` (ro); `./workshop` → `/home/rstudio/workshop` (rw)
- Port bound to `127.0.0.1:8787`
- FCS files never committed to git nor baked into the image
- Publishing to GHCR requires explicit user confirmation at execution time

---

### Task 1: Image build files

**Files:** Create `docker/Dockerfile`, `docker/install.R`

- [ ] Write `install.R` with a `pkgs` vector (flowCore, flowWorkspace, openCyto, ggcyto, CytoML, flowAI, PeacoQC, CATALYST, FlowSOM, uwot, tidyverse, patchwork, rmarkdown, knitr); install via `BiocManager::install(pkgs, update = FALSE, ask = FALSE, Ncpus = parallel::detectCores())`; then `quit(status = 1)` if any `!requireNamespace(p, quietly = TRUE)`.
- [ ] Write `Dockerfile`: `FROM` pinned base, OCI source label, `COPY install.R`, `RUN Rscript /tmp/install.R`, copy `scripts/smoke-test.R` to `/opt/workshop/`.
- [ ] Verify: `docker build -f docker/Dockerfile -t flow-workshop-r:dev .` exits 0 (native arm64).
- [ ] Commit.

### Task 2: Runtime + smoke test

**Files:** Create `docker-compose.yml`, `scripts/smoke-test.R`, `data/.gitkeep`

- [ ] `smoke-test.R`: load every package from `/opt/workshop/install.R`'s list; find first `*.fcs` in `/home/rstudio/data`; `read.FCS` → `compensate(spillover SPILL)` → `estimateLogicle` on fluorescence channels → save ggcyto PNG to `tempdir()`; render `/home/rstudio/workshop/01-import-comp-transform-plot.Rmd` to `tempdir()` if it exists; any error → exit 1; print `SMOKE TEST PASSED`.
- [ ] Verify failure path: run smoke test with an empty data dir → reports "no FCS file" but still passes package checks (FCS step skipped with message).
- [ ] Copy example FCS into `data/`; `docker compose up -d`; `docker compose exec rstudio Rscript /opt/workshop/smoke-test.R` → `SMOKE TEST PASSED`; `curl -sI http://127.0.0.1:8787` → 200/302.
- [ ] Commit.

### Task 3: Starter Rmd

**Files:** Create `workshop/01-import-comp-transform-plot.Rmd`

- [ ] Sections: setup, import, metadata (parameters table + keywords), compensation (SPILL heatmap, before/after pair), transformation (logicle, before/after histogram), plots by marker name (FSC/SSC, CD45/SSC, CD3/CD19, CD4/CD8), sessionInfo. `fcs_path` param at top with `stopifnot(file.exists())`-style friendly error.
- [ ] Verify: re-run smoke test (it knits the Rmd) → PASS; inspect rendered HTML plots.
- [ ] Commit.

### Task 4: Distribution + docs

**Files:** Create `scripts/export-images.sh`, modify `README.md`

- [ ] `export-images.sh`: for arch in arm64 amd64 → `docker pull --platform linux/$arch $IMAGE:$TAG`, `docker save | gzip > flow-workshop-r-$TAG-$arch.tar.gz`; write `SHA256SUMS`.
- [ ] README: attendee quick start (online pull, offline load, compose/run command, login, where to put files, which arch am I), instructor section (build, smoke test, buildx push, export, adding packages).
- [ ] Verify: `bash -n scripts/export-images.sh`.
- [ ] Commit.

### Task 5: Publish (requires user confirmation)

- [ ] `gh auth refresh -s write:packages`; `gh auth token | docker login ghcr.io -u victorrrwang --password-stdin`
- [ ] `docker buildx build --platform linux/amd64,linux/arm64 -f docker/Dockerfile -t ghcr.io/victorrrwang/flow-workshop-r:2026.09 -t ghcr.io/victorrrwang/flow-workshop-r:latest --push .`
- [ ] Smoke test under `--platform linux/amd64`.
- [ ] Set GHCR package visibility to public (GitHub web UI).
