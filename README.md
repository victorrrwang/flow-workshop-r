# Bioinformatics and Analysis of Flow Cytometry Data in R

A ready-to-use RStudio environment for the workshop, packaged as a Docker image with
the R/Bioconductor packages for flow cytometry data manipulation and visualization.

| Included | Packages |
|---|---|
| Core flow | flowCore, flowWorkspace, openCyto, ggcyto, CytoML |
| Quality control | flowAI, PeacoQC |
| High-dimensional | CATALYST, FlowSOM, uwot |
| General | tidyverse, patchwork, rmarkdown, knitr |

R 4.6.1 · Bioconductor 3.23 · works on Apple Silicon and Intel/AMD machines.

---

## For attendees

### 1. Install Docker (before the workshop)

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and start it.
Give it at least **4 GB of memory** (Docker Desktop → Settings → Resources).

### 2. Get the workshop image (~5 GB, do this before the workshop)

**Option A — online:**

```bash
docker pull ghcr.io/victorrrwang/flow-workshop-r:2026.09
```

**Option B — offline file** (from the instructor's shared drive link or USB stick).
Pick the file matching your computer:

| Your computer | File |
|---|---|
| Mac with Apple chip (M1/M2/M3/M4…) | `flow-workshop-r-2026.09-arm64.tar.gz` |
| Intel Mac, most Windows and Linux PCs | `flow-workshop-r-2026.09-amd64.tar.gz` |

Not sure? Mac: Apple menu → About This Mac → "Chip: Apple …" means arm64.
Windows: Settings → System → About → "x64-based processor" means amd64.

```bash
docker load -i flow-workshop-r-2026.09-arm64.tar.gz
```

### 3. Get the workshop folder

Download this repository (or the folder shared by the instructor). Put the FCS files
you were given into its `data/` folder.

### 4. Start RStudio

From inside the workshop folder:

```bash
docker compose up -d
```

Open <http://localhost:8787> and log in with user **`rstudio`**, password **`workshop`**.

Without compose, the equivalent is (macOS/Linux):

```bash
docker run -d --name flow-workshop -p 127.0.0.1:8787:8787 -e PASSWORD=workshop -v "$PWD/data:/home/rstudio/data:ro" -v "$PWD/workshop:/home/rstudio/workshop" ghcr.io/victorrrwang/flow-workshop-r:2026.09
```

In RStudio:
- `data/` — the FCS files (read-only, so you can't accidentally modify them)
- `workshop/` — notebooks; anything you save here stays on your laptop

Open `workshop/01-import-comp-transform-plot.Rmd` and click **Knit**.

### 5. Stop

```bash
docker compose down
```

Your files in `workshop/` are kept.

### Troubleshooting

- **Port 8787 already in use** — change `127.0.0.1:8787:8787` to `127.0.0.1:8788:8787` in
  `docker-compose.yml` and open <http://localhost:8788>.
- **Linux: "permission denied" reading FCS files or saving in `workshop/`** — the
  container user has UID 1000. Run `chmod -R a+r data` and `chmod a+rwx workshop`.
- **RStudio is very slow / R session crashes** — increase Docker Desktop memory.

---

## For the instructor

### Layout

```
docker/Dockerfile        image definition (pinned Bioconductor base)
docker/install.R         THE package list — edit this to add packages
docker-compose.yml       runtime: port, password, mounts
scripts/smoke-test.R     verifies packages, FCS pipeline, notebook knit
scripts/export-images.sh per-architecture tarballs for offline sharing
workshop/                attendee notebooks
data/                    FCS files (git-ignored, never baked into the image)
docs/superpowers/        design spec and implementation plan
```

### Build and test locally

```bash
docker compose build
```

```bash
docker compose up -d
```

```bash
docker compose exec -u rstudio rstudio Rscript /opt/workshop/smoke-test.R
```

Expect `SMOKE TEST PASSED`.

### Add a package

1. Append it to `pkgs` in `docker/install.R`.
2. Bump the tag (e.g. `2026.09` → `2026.10`) in `docker-compose.yml`, this README and
   `scripts/export-images.sh`.
3. Rebuild, run the smoke test, publish.

The build fails if any package does not install. Packages installed interactively in a
running container are lost when it is removed — intentional, so everyone matches.

### Publish to GHCR (multi-architecture)

```bash
gh auth refresh -s write:packages
```

```bash
gh auth token | docker login ghcr.io -u victorrrwang --password-stdin
```

```bash
docker buildx create --use --name multiarch
```

```bash
docker buildx build --platform linux/amd64,linux/arm64 -f docker/Dockerfile -t ghcr.io/victorrrwang/flow-workshop-r:2026.09 -t ghcr.io/victorrrwang/flow-workshop-r:latest --push .
```

Then on GitHub → your profile → Packages → `flow-workshop-r` → Package settings →
change visibility to **Public**.

### Offline tarballs for a cloud drive

```bash
scripts/export-images.sh 2026.09 dist
```

Upload `dist/*.tar.gz` and `dist/SHA256SUMS` to the drive and share the link.
