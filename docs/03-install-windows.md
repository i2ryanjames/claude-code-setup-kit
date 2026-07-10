# Setting up Windows (via WSL)

## What you'll accomplish

In this guide you will turn your Windows computer into a friendly place for Claude Code by installing WSL2 Ubuntu, adding the handful of tools Claude needs (Git, jq, curl, Python, and Node.js), and then installing and logging in to Claude Code itself. When you finish, you will have a working Linux terminal inside Windows where Claude Code runs exactly like it does on Mac, so every later command in this kit will just work for you.

## Why WSL?

Claude Code is a terminal application that runs best in a real Linux environment. On Windows, the cleanest way to get that environment is WSL2, which installs a genuine Ubuntu Linux system that runs side by side with Windows. Once you are inside Ubuntu, the commands look and behave the same as the "Mac" commands used throughout the rest of this kit.

## Step 1: Install WSL2 from an admin PowerShell

Open PowerShell as Administrator. The easiest way is to press the Start menu, type "PowerShell", right-click it, and choose **Run as administrator**. When the window opens, run the command below. It installs WSL2 and the default Ubuntu distribution in one shot.

```powershell
wsl --install
```

This single command enables the Windows Subsystem for Linux feature, downloads a small virtual machine platform, and installs Ubuntu. When it finishes you will be asked to restart your computer, so go ahead and reboot.

## Step 2: Create your Linux username and password

After the reboot, Ubuntu will open automatically (or you can launch "Ubuntu" from the Start menu). The first time it starts, it asks you to create a Linux username and password. These are separate from your Windows login and only live inside Ubuntu, so pick anything you like and remember the password because you will use it for `sudo` commands.

## Step 3: Update packages and install the core tools

Now you are inside an Ubuntu terminal. First, refresh the list of available packages and apply any pending updates. The `sudo` prefix means "run this as an administrator," which is why Ubuntu asks for your password.

```bash
sudo apt update && sudo apt install -y git jq curl python3
```

Here is what each piece does:

- `sudo apt update` refreshes the package index so the next install step finds the newest versions.
- `sudo apt install -y git jq curl python3` installs four tools Claude Code commonly relies on: **git** for version control, **jq** for reading JSON files, **curl** for downloading files from the internet, and **python3** for running Python scripts. The `-y` flag answers "yes" to the confirmation prompt automatically.

## Step 4: Install Node.js with nvm

Claude Code is built on Node.js, and the safest way to install Node on Ubuntu is through a version manager called **nvm**. The command below downloads and runs the official nvm install script.

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

This downloads the nvm installer from its official GitHub repository and runs it in your shell. It does not need `sudo` because it installs only into your home folder.

After nvm is installed, close and reopen your Ubuntu terminal so the `nvm` command becomes available. Then install the latest long-term-support version of Node.js:

```bash
nvm install --lts
```

The `--lts` flag tells nvm to grab the most stable, officially supported Node version, which is exactly what Claude Code expects.

## Step 5: Install Claude Code

Now that Node and its package manager `npm` are available, install Claude Code globally so the `claude` command works from any folder.

```bash
npm install -g @anthropic-ai/claude-code
```

The `-g` flag means "install globally," so Claude Code is available everywhere in your Ubuntu system rather than only in one project.

## Step 6: Log in

Finally, start Claude Code for the first time so you can sign in.

```bash
claude
```

The first time you run this, Claude will walk you through a browser-based login. Follow the on-screen prompts, and once you are signed in you are ready to use Claude Code.

## From here on, treat WSL like a Mac terminal

Everything you do from this point onward happens inside Ubuntu. The terminal commands shown in the rest of this kit's documentation (the "Mac" commands) work identically inside WSL, so you never need to translate anything. Whenever a later guide says "open a terminal," just open Ubuntu.

---

Next → [Your first session](04-first-session.md)
