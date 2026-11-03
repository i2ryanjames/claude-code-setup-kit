# Setting up your Mac

## What you'll accomplish

In this page you will turn a plain Mac into a machine that can run Claude Code and the rest of the kit. You will open the Terminal, install Homebrew as your package manager, install the core command-line tools, install Claude Code globally, log in to your Anthropic account, and verify everything works. After that, the repo's `setup.sh` installer will be ready to wire up the rest of the delegation ladder for you.

## Open Terminal

On a Mac, open Spotlight by pressing **Command (⌘) + Space**, then type **Terminal** and press **Enter**. A window with a plain text prompt will appear. Every command in this guide is typed into that window and confirmed with **Enter**.

## Automatic prerequisite bootstrap

As of the latest version, the `setup.sh` installer can detect and auto-install
Homebrew and the core tools for you, so the manual steps below are now a
**fallback reference** if you prefer to install by hand or if the auto-bootstrap
doesn't work. You can skip this entire page and run `bash setup.sh` (or the
one-liner in the README) directly — it will handle this layer for you.

## Install Homebrew

Homebrew is a package manager: it lets you install other developer tools by name, the same way an app store lets you install apps. On a Mac it is the standard way to install things like `git`, `node`, and `gh`. Run this single command, taken from the official Homebrew site at brew.sh, to install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow any instructions Homebrew prints at the end, including adding Homebrew to your shell profile if it asks. When it finishes, the `brew` command will be available.

## Install the core tools

Now install the command-line tools the kit depends on. The following command installs several programs at once: `git` for version control, `jq` for working with JSON, `node` for JavaScript tools (including Claude Code), `gh` for GitHub, and `python3` for Python-based scripts.

```bash
brew install git jq node gh python3
```

This may take a few minutes the first time. When it returns to the prompt without errors, all five tools are installed.

## Install Claude Code

Claude Code is the lead engineer of this whole setup. It is distributed as an npm package, and since you installed `node` above, you already have the `npm` command. Install Claude Code globally so it is available in any folder:

```bash
npm install -g @anthropic-ai/claude-code
```

The `-g` flag means "install for every project, not just this one." When the command finishes, the `claude` program will be on your machine.

Anthropic also now offers a native installer that auto-updates itself in the background: `curl -fsSL https://claude.ai/install.sh | bash`. Either method gives you the same `claude` command — this kit sticks with the npm method above since you already have `node`/`npm` installed for the MCP tooling later in this kit.

## Log in for the first time

Claude Code needs to connect to your Anthropic account. Pick any folder you can write to, move into it, and launch Claude Code:

```bash
cd ~/Documents
claude
```

On first run, Claude Code opens a browser window and asks you to log in to your Anthropic account. Approve the connection in the browser. When you return to the Terminal, Claude Code will be logged in and ready.

## Verify the install

Check that everything installed correctly by asking Claude Code for its version number:

```bash
claude --version
```

You should see a version string printed back. If you do, Claude Code is installed and working.

## What comes next

You now have the foundation: Homebrew, the core tools, and Claude Code logged in. The remaining layers of the delegation ladder — Ollama, the GLM harness, subagents, hooks, and templates — are wired up automatically by this repository. From the root of the `claude-code-setup-kit` repo, run the installer:

```bash
bash setup.sh
```

That script installs and configures the `kit/` directory for you. The following pages walk through what it sets up.

Next → [Setting up Windows (via WSL)](./03-install-windows.md) — or skip ahead to [Your first session](./04-first-session.md)
