# Workshop setup

**Do this before the workshop, at home.** Ten minutes, plus a download you should not leave
until the last evening. Two things are involved: **the software** (a 2 GB download that
unpacks to about 13 GB — you need **20 GB free disk space**) and **your folder** (about
10 MB). Docker does not know your folder exists until you start it from inside that folder.

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

### 4. Get the software

**Good internet?** Skip this step — step 5 downloads it for you.

**From the USB stick:** your file is **`FOR-WINDOWS-AND-INTEL-MAC.tar.gz`** (on a
Snapdragon / ARM laptop, take `FOR-APPLE-SILICON-MAC.tar.gz` instead — same chip family).

Type `docker load -i ` — with a space after the `i` — then **drag the file from File
Explorer onto the PowerShell window**, which fills in the path for you. Press Enter. Do not
type the path by hand.

A few minutes pass with no progress bar, then it prints
`Loaded image: ghcr.io/victorrrwang/flow-workshop-r:2026.09`. To be sure, check Docker
Desktop → **Images** — see the last page.

### 5. Start the container

```
docker compose up -d
```

**The first time takes a while.** When the prompt comes back it is running; later starts
take seconds.

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

### 4. Get the software

**Good internet?** Skip this step — step 5 downloads it for you.

**From the USB stick:** which file depends on your Mac. Apple menu → **About This Mac** —
"Chip: Apple M1/M2/M3/M4" takes **`FOR-APPLE-SILICON-MAC.tar.gz`**, "Processor: Intel"
takes **`FOR-WINDOWS-AND-INTEL-MAC.tar.gz`**.

Type `docker load -i ` — with a space after the `i` — then **drag the file from Finder onto
the Terminal window**, which fills in the path for you. Press Enter. Do not type the path
by hand.

A few minutes pass with no progress bar, then it prints
`Loaded image: ghcr.io/victorrrwang/flow-workshop-r:2026.09`. To be sure, check Docker
Desktop → **Images** — see the last page.

### 5. Start the container

```
docker compose up -d
```

**The first time takes a while.** When the prompt comes back it is running; later starts
take seconds.

### 6. Check it works

As Windows step 6 — open **http://localhost:8787**, run `workshop/00-check-your-setup.Rmd`
from the **Files** pane — but the shortcuts are `Cmd+Shift+K` (Knit) and `Cmd+Option+R`
(Run All). **Reply to the workshop email with the `SETUP OK` line**, or the whole output if
it says anything else.

### 7. Stop it

`docker compose down` — your files stay. `docker compose up -d` starts it again anytime.

\newpage

# Did step 4 work?

Open Docker Desktop and click **Images** in the left sidebar. You are looking for one row
named `ghcr.io/victorrrwang/flow-workshop-r`, tag `2026.09`, about 12 GB:

![](docs/docker-images-check.png){width=100%}

If that row is there, the software is on your machine and you can go to step 5 — whatever
scrolled past in the terminal.

If the list is **empty**, the `docker load` did not finish. The usual reasons:

- **Not enough disk space.** The file unpacks to about 13 GB. Free up space and run it again.
- **The path was typed by hand.** Drag the file onto the terminal window instead.
- **Docker Desktop was not running.** Start it, wait for the whale icon to settle, retry.

Running it again is safe — it does not damage anything and does not use double the space.

---

*Stuck? Reply to the workshop email with a screenshot of what the terminal says. Please do
not leave it until the morning.*
