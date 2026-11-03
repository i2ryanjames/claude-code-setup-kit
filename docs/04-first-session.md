# Your first session

## What you'll accomplish

In this guide you will start Claude Code inside a real project folder, learn how its permission prompts keep you in control before anything runs, pick up the handful of slash commands you will use every day, and understand how to phrase requests so Claude gives you useful results the first time. By the end you will be comfortable launching a session, approving actions, and steering Claude toward a clear goal.

## Step 1: Open a project folder and start Claude

Claude Code always works inside a folder, so first open a terminal and move into the project you want help with. The `cd` command means "change directory."

```bash
cd ~/projects/my-app
```

Replace `~/projects/my-app` with the path to your own project. If you do not have a project yet, any folder will do for practice.

Now start Claude Code:

```bash
claude
```

This launches an interactive session. Claude reads the files around it, waits for your message, and then begins helping you.

## Step 2: Understand the permission prompt system

Claude never silently runs dangerous things. Before it executes a shell command, edits a file, or takes any action with side effects, it shows you a prompt describing exactly what it wants to do and asks for your approval. You always have the chance to say yes, no, or ask for changes first.

There are three interaction modes you can cycle through by pressing **Shift+Tab** at the prompt:

- **Default ask mode** (the current UI labels this one "Manual") — Claude proposes every action and waits for you to approve. This is the safest mode and is where you will start.
- **Auto-accept edits mode** — Claude may edit files and run common filesystem commands (like `mkdir` or `mv`) without asking, but still prompts before other shell commands. Great once you trust a task.
- **Plan mode** — Claude only reads and plans; it will not edit or run anything until you tell it to proceed. Useful for exploring an unfamiliar codebase.

The current mode is always shown, so you always know what Claude is allowed to do. (A few more advanced modes, including a "bypass permissions" mode meant for unattended/CI-style runs, exist outside this default Shift+Tab cycle — not something you need as a beginner, but good to know the cycle above isn't the full list.)

## Step 3: Learn the core slash commands

While a session is running, you can type commands that start with a slash. These are the ones you will use most often.

```bash
/help
```

The `/help` command lists every available command and gives a short description of each. When in doubt, start here.

```bash
/init
```

The `/init` command asks Claude to read your codebase and generate a `CLAUDE.md` file that describes the project's conventions, build commands, and structure. It is the fastest way to give Claude long-term context about a repo.

```bash
/clear
```

The `/clear` command wipes the current conversation so you can start a fresh task without old context bleeding in. Use it whenever you switch to an unrelated job in the same project.

```bash
/config
```

The `/config` command opens Claude's settings, where you can adjust behavior, permissions, and other preferences.

## Step 4: Phrase good requests

The single biggest skill in using Claude Code well is writing clear requests. A strong request has three parts:

1. **Goal** — what you want to end up with.
2. **Constraints** — any rules Claude must respect (style, files to avoid, tests that must pass).
3. **How to verify** — how you and Claude will know the task is done.

For example, instead of "fix the bug," you might say:

> "Fix the login function so it rejects empty emails. Keep the existing error message style, don't touch the database layer, and run `npm test` at the end to confirm everything passes."

That request gives Claude a goal (reject empty emails), a constraint (leave the database layer alone), and a verification step (`npm test`). Claude will work through the task and run the verification command itself, showing you the result.

## Step 5: Remember what Claude can do

Inside a session Claude is not limited to chat. It can:

- Run shell commands (with your approval).
- Edit files directly in your project.
- Search the web to look things up when it needs fresh information.

Knowing these abilities helps you ask for things that actually take advantage of Claude Code instead of treating it like a plain chat box.

---

Next → [CLAUDE.md — your standing instructions](05-claude-md.md)
