# Bioinformatics and Analysis of Flow Cytometry Data in R

A ready-to-use RStudio environment for the workshop, packaged as a Docker image with
the R/Bioconductor packages for flow cytometry data manipulation and visualization.

| Included | Packages |
|---|---|
| Core flow | flowCore, flowWorkspace, openCyto, ggcyto, CytoML |
| Quality control | flowAI, PeacoQC |
| High-dimensional | CATALYST, FlowSOM, uwot |
| Plotting | [speedyflowplot](https://github.com/victorrrwang/speedyflowplot) (fast density dot plots), ggcyto |
| General | tidyverse, patchwork, rmarkdown, knitr |

R 4.6.1 · Bioconductor 3.23 · works on Apple Silicon and Intel/AMD machines.

---

## For attendees

### What you are setting up

Two separate things, which is the part that confuses people:

| | What it is | Where it comes from |
|---|---|---|
| **The image** | The software — R, RStudio, and every package the workshop needs, about 5 GB | Docker downloads it for you |
| **The folder** | Your files — the config, the data, the notebooks | A zip you download and unzip yourself |

Docker does not know your folder exists until you tell it. That is the job of
`docker-compose.yml`, which sits in the folder and says *run this image, and connect these
two folders to it*. You never manage the image by hand — you never even see it as files.

---

### Step 1 · Install Docker Desktop

Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/),
then restart your computer when it asks. Start Docker Desktop and wait until the whale icon
in the system tray (Windows) or menu bar (macOS) stops animating. It has to be running
before anything below works.

**macOS only:** Docker Desktop → Settings → Resources → Memory, set **8 GB**. On Windows
memory is handled automatically and there is nothing to set.

### Step 2 · Download and unzip the workshop folder

This is **not** the container — Docker handles that in step 4. This is a small zip of
*your* files: the configuration that tells Docker what to run, one FCS file, and the check
notebook. About 11 MB.

Download `flow-workshop-setup.zip` from the link in the workshop email. Unzip it directly
into your user folder — **not** into a subfolder, because the zip already contains one.

| | Unzip into | You end up with |
|---|---|---|
| Windows | `C:\Users\<you>\` | `C:\Users\<you>\flow-workshop\` |
| macOS | `/Users/<you>/` | `/Users/<you>/flow-workshop/` |

> **Windows: not Documents, not Desktop, not OneDrive.** Those are usually synced to
> OneDrive, which will try to upload everything the container writes and can lock files
> while Docker is using them. Straight in `C:\Users\<you>\` avoids all of it.

Open the `flow-workshop` folder and check it looks like this:

```
flow-workshop/
├── docker-compose.yml          the instructions Docker follows
├── README.md                   this file
├── docker/
│   └── rstudio-prefs.json      RStudio's appearance settings
├── data/                       FCS files  →  becomes /home/rstudio/data
│   └── QC251006 PB NCC_C_tubeT_C12.fcs
└── workshop/                   notebooks  →  becomes /home/rstudio/workshop
    └── 00-check-your-setup.Rmd
```

If instead you see a single folder called `flow-workshop` *inside* another folder called
`flow-workshop`, you unzipped one level too deep. Move the inner one up and delete the
outer.

The lab notebooks arrive on the day and go into `workshop/`. The remaining FCS files go
into `data/`.

### Step 3 · Open a terminal in that folder

**Windows.** Open the folder in File Explorer, click the address bar, type `powershell`,
press Enter.

**macOS.** Open Terminal and type `cd ` (with a space), then drag the folder from Finder
onto the Terminal window and press Enter.

Either way you now have a prompt sitting in the workshop folder, which is the only place
the next command works.

### Step 4 · Start it

```bash
docker compose up -d
```

**The first time you run this it downloads the 5 GB image**, which takes a while on a good
connection and considerably longer on a bad one. Do this at home, not in the workshop room.
You will see progress bars; when the prompt comes back, it is running.

Every time after that, the same command starts in a couple of seconds, because the image is
already on your machine.

### Step 5 · Open RStudio

Go to **<http://localhost:8787>** in any browser. There is no login screen.

> **Why no password?** The server is published to `127.0.0.1`, which means your own
> computer and nothing else — it is not on the network, and nobody else can reach it. If
> you ever change that to share it with someone, put a password back first.

In the Files pane you will see `data` and `workshop` — the same folders from step 2. Open
`workshop/00-check-your-setup.Rmd` and click **Knit**. It should finish with a line
starting `SETUP OK`. **Reply to the workshop email with that line.** If it says anything
else, send me the whole output instead.

### Step 6 · Stop it when you are done

```bash
docker compose down
```

Your files stay where they are. Run `docker compose up -d` again whenever you want it back.

---

### On the day

You will be given the lab notebooks and the remaining FCS files on a USB stick. There is
nothing to install and nothing to rebuild.

1. Copy the `workshop` and `data` folders from the USB stick into your `flow-workshop`
   folder. Your computer will ask whether to merge — say yes. The new files sit alongside
   `00-check-your-setup.Rmd` and the QC file you already have.
2. Start the container if it is not already running: `docker compose up -d`.
3. Go to <http://localhost:8787> and open `workshop/01-file-handling-and-import.Rmd`.

If the container was already running, the new files are simply there — the two folders are
live windows onto your real folders, not copies. You may need to click the refresh arrow in
RStudio's Files pane to see them.

---

### If your internet is slow: the offline route

Instead of letting step 4 download the image, load it from a file you copy over beforehand.
Pick the one matching your computer:

| Your computer | File |
|---|---|
| Mac with Apple chip (M1/M2/M3/M4…) | `flow-workshop-r-2026.09-arm64.tar.gz` |
| Windows PCs, Intel Macs, most Linux | `flow-workshop-r-2026.09-amd64.tar.gz` |

Not sure? **Windows:** Settings → System → About → "System type". Almost all say x64, which
means amd64; an ARM-based processor means arm64. **Mac:** Apple menu → About This Mac —
"Chip: Apple …" means arm64.

```bash
docker load -i flow-workshop-r-2026.09-amd64.tar.gz
```

Then carry on from step 4 as normal. It will find the image already there and skip the
download.

---

### Troubleshooting

- **Port 8787 already in use** — change `127.0.0.1:8787:8787` to `127.0.0.1:8788:8787` in
  `docker-compose.yml` and open <http://localhost:8788>.
- **Linux: "permission denied" reading FCS files or saving in `workshop/`** — the
  container user has UID 1000. Run `chmod -R a+r data` and `chmod a+rwx workshop`.
- **RStudio is very slow / R session crashes** — it has run out of memory.

  *macOS:* Docker Desktop → Settings → Resources → Memory, raise it to 8 GB.

  *Windows:* memory is normally handled for you, but on a machine with 8 GB or less in
  total you can cap what WSL takes. Create `C:\Users\<you>\.wslconfig` containing:

  ```
  [wsl2]
  memory=6GB
  ```

  then run `wsl --shutdown` in PowerShell and restart Docker Desktop.

---

## For the instructor

### Layout

```
docker/Dockerfile        image definition (pinned Bioconductor base)
docker/install.R         THE package list — edit this to add packages
docker/rstudio-prefs.json RStudio defaults (pane layout, fonts, session behaviour).
                         Mounted by compose AND baked into the image — must be committed,
                         or Docker creates a directory in its place and prefs are ignored.
docker-compose.yml       runtime: port, auth, mounts
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

1. Append it to `pkgs` in `docker/install.R` (CRAN/Bioconductor), or to `github_pkgs`
   as `"owner/repo[/subdir]@<commit SHA>"`. To update speedyflowplot, change its SHA.
2. Bump the tag (e.g. `2026.09` → `2026.10`) in `docker-compose.yml`, this README and
   `scripts/export-images.sh`.
3. Rebuild, run the smoke test, publish.

The build fails if any package does not install. Packages installed interactively in a
running container are lost when it is removed — intentional, so everyone matches.

### Publish to GHCR (multi-architecture)

**Preferred: let GitHub build it.** `.github/workflows/build-image.yml` builds each
architecture on a runner of that architecture and merges them into one tag. Nothing is
emulated, so a rebuild is tens of minutes rather than an overnight job — which matters,
because the package list will change at least once more before the workshop.

1. Create the repository and push (it may stay **private** — container packages have their
   own visibility, so the image can be public while the notebooks are not):

   ```bash
   gh repo create flow-workshop-r --private --source=. --remote=origin --push
   ```

2. Actions tab -> **Build and publish image** -> **Run workflow**.

3. Once it succeeds, make the package public:
   `https://github.com/users/<you>/packages/container/flow-workshop-r/settings`
   -> Danger Zone -> Change visibility -> Public.

4. Verify it works for someone who is not you:

   ```bash
   docker logout ghcr.io
   docker pull ghcr.io/<you>/flow-workshop-r:2026.09
   ```

   The `logout` matters: with cached credentials a private package pulls fine for you and
   fails for everyone else.

*Note:* the `linux/arm64` runner (`ubuntu-24.04-arm`) is free on public repositories; on a
private repository it consumes Actions minutes. If that is a problem, make the repository
public with the notebooks kept out of git, or drop to the manual route below.

### Publish manually instead

Works, but the `linux/amd64` half runs under emulation on an Apple Silicon Mac and takes
hours. Start it overnight.

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

### Two-stage distribution

Course materials are **not** in the image and **not** in the setup bundle. The image holds
the environment only — `install.R`, `smoke-test.R`, `rstudio-prefs.json` and two empty
folders. Notebooks and data arrive on the day.

Build the bundle attendees get at T-2 weeks:

```bash
scripts/make-setup-bundle.sh dist
```

That produces `dist/flow-workshop-setup.zip` from an **allowlist** — `docker-compose.yml`,
`docker/rstudio-prefs.json`, `README.md`, `workshop/00-check-your-setup.Rmd` and an empty
`data/`. Anything not on that list cannot ship by accident, and the script refuses to build
if an `.fcs`, an `.rds` or a lab notebook turns up in the staging folder.

**Check the repository is private.** The image is public on GHCR, which is fine — it holds
no materials. The git repository is a different question: once the lab notebooks are
committed, a public repo publishes them. Keep it private until after the workshop, or keep
the notebooks out of it entirely.

On the day, hand out a folder containing `workshop/*.Rmd` and `data/` (FCS files plus the
shipped `.rds` checkpoints). Attendees copy both into the folder they already unzipped;
the running container picks them up immediately, because both are bind mounts.

### Offline tarballs for a cloud drive

```bash
scripts/export-images.sh 2026.09 dist
```

Upload `dist/*.tar.gz` and `dist/SHA256SUMS` to the drive and share the link.
