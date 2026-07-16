# Double-click installers

For people who'd rather not touch a terminal. Each file below runs the same
automatic setup as the one-liner — it just wraps it in a double-click.

| Your computer | File to send them | What they do |
|---|---|---|
| **Mac** | `install-mac.command` | Double-click it. If macOS blocks it once, right-click → **Open** → **Open**. |
| **Windows** | `install-windows.bat` | Double-click it. Approve the admin prompt, restart when asked, then double-click it again to finish. |

## What each one does

- **`install-mac.command`** — opens Terminal, downloads the public bootstrap
  (`install.sh`), and runs the full auto-install. No typing.
- **`install-windows.bat`** — checks for WSL (the Linux layer Windows needs). If
  it's missing, it installs WSL + Ubuntu (one admin prompt + one restart). On the
  second run it drives the install *inside* Ubuntu automatically, so the user
  never opens PowerShell or Ubuntu themselves.

## The one unavoidable Windows step

Installing WSL the first time requires **administrator approval and one restart** —
that's a Windows requirement no installer can skip. After that first-time setup,
everything is automatic.

## Distributing these files

- Send them **inside a `.zip`** (e.g. the whole `installers/` folder). Downloading
  a raw `.command`/`.bat` from a browser can strip permissions or trip security
  warnings.
- On Mac, the executable bit must be preserved. If the `.command` won't
  double-click, the user can run once in Terminal:
  `chmod +x install-mac.command` — or just right-click → Open.
- These wrappers fetch from the **public** `main` branch of the kit repo. While
  the repo is private, they will fail to download; make it public (or point them
  at a public tarball) for testing.
