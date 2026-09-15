# Workshop setup — Windows

**Do this before the workshop, at home.** Takes 10 minutes plus a download.

### 1. Install Docker Desktop

[docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) →
install → restart when asked → launch it. Wait until the whale icon in the system tray
stops animating.

### 2. Download your workshop folder

Download **`flow-workshop-setup.zip`** from the link in the workshop email. It is about
11 MB and holds the settings, one data file and one notebook. (It is not the software —
that comes in step 4.)

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

**The first time takes a while** — it is downloading or unpacking 5 GB. When the prompt
comes back, it is running. Every time after that it starts in seconds.

### 6. Check it works

Open **http://localhost:8787** — no password needed.

In the **Files** pane (bottom right), click `workshop`, then click
`00-check-your-setup.Rmd`. It opens in the editor, top left.

Now run it, either way:

- Click **Knit** in the toolbar above the file (`Ctrl+Shift+K`) — builds a report in a new
  pane, and the result is the last line of it. **Try this one first**, because it is what
  you will use all morning.
- Or **Run ▸ Run All** (`Ctrl+Alt+R`) — runs everything straight down the notebook, with
  the output appearing under each block of code.

Either way it ends with one line starting `SETUP OK`.
**Reply to the workshop email with that line.** If it says anything else, send the whole
output instead.

### 7. Stop it

`docker compose down` — your files stay. `docker compose up -d` starts it again anytime.

---

*Stuck? Reply to the email with a screenshot of what PowerShell says. Do not leave it until
the morning.*
