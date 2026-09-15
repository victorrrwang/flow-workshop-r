# Workshop setup

**Do this before the workshop, at home.** Ten minutes, plus a download you should not leave
until the last evening.

Two things are involved: **the software** (about 5 GB — Docker fetches it) and **your
folder** (about 10 MB — you download and unzip it). Docker does not know your folder exists
until you start it from inside that folder.

# Windows

### 1. Install Docker Desktop

[docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) →
install → restart when asked → launch it. Wait until the whale icon in the system tray
stops animating.

### 2. Download your workshop folder

Download **`flow-workshop-setup.zip`** from the link in the workshop email.
Right-click it → **Extract All** → extract to `C:\Users\<you>\`

You should end up with a folder at `C:\Users\<you>\flow-workshop\`.
**Not** Documents, Desktop or OneDrive — those sync to the cloud, which breaks things.

### 3. Open a terminal there

Open the `flow-workshop` folder in File Explorer → click the address bar → type
`powershell` → Enter.

### 4. Get the software (~5 GB) — pick one

| You have | Run this |
|---|---|
| **Good internet** | Nothing. Step 5 will download it for you. |
| **The USB stick** | `docker load -i D:\flow-workshop-r-2026.09-amd64.tar.gz` |
| **Downloaded the file** | `docker load -i $HOME\Downloads\flow-workshop-r-2026.09-amd64.tar.gz` |

*Snapdragon / ARM laptop? Use the `arm64` file instead. Check: Settings → System → About →
System type.*

### 5. Start the container

```
docker compose up -d
```

**The first time takes a while** — 5 GB to download or unpack. When the prompt comes back
it is running; later starts take seconds.

### 6. Check it works

Open **http://localhost:8787** — no password needed.

In the **Files** pane (bottom right): `workshop` → `00-check-your-setup.Rmd`.

Run it: click **Knit** above the file (`Ctrl+Shift+K`), or **Run ▸ Run All**
(`Ctrl+Alt+R`). Look for a line starting `SETUP OK` and **reply to the workshop email with
it.** If it says anything else, send the whole output.

### 7. Stop it

`docker compose down` — your files stay. `docker compose up -d` starts it again anytime.

\newpage

# macOS

### 1. Install Docker Desktop

[docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) →
install → launch it from Applications. Wait until the whale icon in the menu bar stops
animating.

Then: **Docker Desktop → Settings → Resources → Memory → 8 GB → Apply & Restart.**
The default is too small for this workshop.

### 2. Download your workshop folder

Download **`flow-workshop-setup.zip`** from the link in the workshop email. Safari usually
unzips it for you; otherwise double-click it.

Drag the resulting **`flow-workshop`** folder into your home folder, so you end up with
`/Users/<you>/flow-workshop/`. *(In Finder, that is the one with the house icon —
`Shift+Cmd+H` if you cannot see it.)*

### 3. Open a terminal there

Open **Terminal** (`Cmd+Space`, type `terminal`, Enter). Type `cd ` — with a space after it
— then drag the `flow-workshop` folder from Finder onto the Terminal window and press Enter.

### 4. Get the software (~5 GB) — pick one

| You have | Run this |
|---|---|
| **Good internet** | Nothing. Step 5 will download it for you. |
| **The USB stick** | `docker load -i /Volumes/<stick>/flow-workshop-r-2026.09-arm64.tar.gz` |
| **Downloaded the file** | `docker load -i ~/Downloads/flow-workshop-r-2026.09-arm64.tar.gz` |

*Apple Silicon (M1/M2/M3/M4) uses the `arm64` file; an older Intel Mac uses `amd64`.
Check: Apple menu → About This Mac — "Chip: Apple …" means Apple Silicon.*

### 5. Start the container

```
docker compose up -d
```

**The first time takes a while** — 5 GB to download or unpack. When the prompt comes back
it is running; later starts take seconds.

### 6. Check it works

Open **http://localhost:8787** — no password needed.

In the **Files** pane (bottom right): `workshop` → `00-check-your-setup.Rmd`.

Run it: click **Knit** above the file (`Cmd+Shift+K`), or **Run ▸ Run All**
(`Cmd+Option+R`). Look for a line starting `SETUP OK` and **reply to the workshop email
with it.** If it says anything else, send the whole output.

### 7. Stop it

`docker compose down` — your files stay. `docker compose up -d` starts it again anytime.

---

*Stuck? Reply to the workshop email with a screenshot of what the terminal says. Please do
not leave it until the morning.*
