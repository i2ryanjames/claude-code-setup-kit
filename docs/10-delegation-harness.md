# The delegation harness (GLM + Ollama)

## What you'll accomplish

By the end of this page you will understand how to stretch a Claude subscription by routing routine typing and drafting work to cheaper or free models. You will install the local and cloud models the kit uses, learn how to run the `glm-do` harness safely, and know what each exit code means and how to protect sensitive repositories.

## Why delegate at all?

A Claude subscription comes with usage limits. Every routine question, rough draft, or simple analysis that you can hand to a local or low-cost model is a request you do not have to spend on the main plan. The kit installs a small ladder of helpers so Claude can push work downward automatically and keep the expensive reasoning for the problems that actually need it.

## What the kit installs

- `ask-gemma` — free local Gemma via Ollama, good for trivial questions and quick lookups.
- `ask-glm` — GLM-5.2 via Ollama Cloud, good for raw drafts and analysis. Use `-m kimi` when you need the stronger Kimi model.
- `glm-do` — the star of the harness. It is a single-file Python script. You give it a task file and a verify command, and it asks the model for complete file edits in a safe sentinel format. The script applies those edits mechanically, then runs your verify command. If the verify command fails, it loops back and asks the model to repair the problem. The model never gets shell access, so it cannot accidentally run destructive commands or wreck your working tree.
- `gemma-helper`, `glm-helper`, and `glm-coder` — small subagents that let Claude dispatch work down the ladder automatically.
- `glm-review.sh` — a Stop hook that gives you a free second-opinion code review of every uncommitted diff and logs the result to `~/.claude/logs/`.

## Setup

First, install Ollama. On macOS with Homebrew you can run:

```bash
brew install --cask ollama
```

On Linux, the Ollama install script is the easiest path:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

After Ollama is installed, pull the free local model that `ask-gemma` uses. The `gemma4:e4b` variant is about ten gigabytes.

```bash
ollama pull gemma4:e4b
```

If your machine has the memory and speed, the larger local model is optional:

```bash
ollama pull gemma4:26b
```

For the cloud models used by `ask-glm` and `glm-do`, sign in to Ollama Cloud. This lets you access `glm-5.2:cloud` and `kimi-k2.7-code:cloud`.

```bash
ollama signin
```

## Running `glm-do`

The harness needs four pieces of information: the repository root, a prompt file that describes the task, a context file it should read, and a verify command that proves the result is correct.

Here is a typical invocation:

```bash
glm-do -C ./my-project \
  --prompt-file task.txt \
  --context src/file.ts \
  --verify "npx tsc --noEmit"
```

The `-C ./my-project` flag tells `glm-do` which repository to edit. The `--prompt-file task.txt` is a plain-text description of the change you want. The `--context src/file.ts` file is read into the model's view so it knows the existing code. The `--verify` string is the command `glm-do` will run after applying edits. If the command fails, `glm-do` sends the error back to the model and asks it to fix the files. It stops only when the verify command passes or it hits a safety limit.

## Exit codes

`glm-do` uses the following exit codes so scripts and hooks can react correctly.

| Code | Meaning | What to do |
|------|---------|------------|
| `0` | Success. | Nothing — the edits were applied and verified. |
| `1` | Usage error. | Check the command line flags and the help text with `glm-do --help`. |
| `2` | Ollama is unreachable. | Start the local server with `ollama serve`, or open the Ollama desktop app. |
| `3` | Model error or truncation. | Try again, reduce the context size, or switch to a larger model. |
| `4` | No edits were parsed. | Rewrite the prompt to be more specific about which files to change. |
| `5` | Verify still failing after retries. | Read the diff manually; the model may need stronger instructions or more context. |
| `6` | Safety refusal. | Rephrase the prompt, or handle this file directly with Claude instead. |

## Protecting sensitive repositories

You can tell `glm-do` to refuse to touch specific repositories by setting the `GLM_DO_FORBIDDEN_PATHS` environment variable. It is a colon-separated list of repository roots. This is useful for repos that contain sensitive data, credentials, or anything you do not want an automated harness to edit.

```bash
export GLM_DO_FORBIDDEN_PATHS="/path/to/sensitive-repo:/another/repo"
```

Add that line to your shell profile if you want it to apply to every terminal session.

## Next →

Continue to [11-troubleshooting.md](11-troubleshooting.md) for a quick fix list when any part of this setup misbehaves.
