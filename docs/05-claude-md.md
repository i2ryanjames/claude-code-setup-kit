# CLAUDE.md — your standing instructions

## What you'll accomplish

In this guide you will understand the two kinds of `CLAUDE.md` files Claude Code loads automatically, learn why both must stay short, and get a guided tour of the ready-made template shipped in this kit at `kit/templates/CLAUDE.md.template`. By the end you will know how to drop that template into your home folder, fill in the bracketed placeholders, and give Claude a consistent set of standing rules that apply on every turn.

## Two scopes, one idea

Claude Code can load instructions from two special files named `CLAUDE.md`. They work the same way; they just apply at different scopes.

The first scope is the **user scope**, located at `~/.claude/CLAUDE.md` in your home folder. This file loads in *every* session, no matter which project you open, so it is the right place for machine-wide rules like "always run tests before saying you are done" or "never commit directly to main."

The second scope is the **project scope**, located at `<project>/CLAUDE.md` inside a project folder. This file is normally checked into the repository so the whole team shares it. It holds conventions specific to that one codebase, such as "we use tabs, not spaces" or "the test command is `npm run test:ci`."

Both files are loaded into Claude's context on every turn, which is exactly why they must stay short. Long files burn context and dilute the important rules, so aim for a few clear lines instead of a manual.

## The kit ships a ready-made user template

This repository includes a starter user-scope file at `kit/templates/CLAUDE.md.template`. It encodes a delegation ladder and a set of guardrails designed to keep Claude working carefully on your behalf. Instead of writing rules from scratch, you copy this template into `~/.claude/CLAUDE.md` and then edit the bracketed placeholders.

The rest of this page walks through the sections you will find inside the template.

### Section: delegate-first reflex

The template opens by telling Claude that any task which edits files or runs multi-step execution should be dispatched to a cheaper delegate model FIRST (via the `glm-coder` subagent), with Claude reviewing the result. Claude only types the code itself when the work genuinely needs frontier-model judgment — novel architecture, security-critical logic, or something the delegates already failed at.

### Section: the delegation ladder

The template includes a small table ranking the delegates from cheapest to most capable: free local Gemma, cheap cloud GLM (raw drafts), GLM through the `glm-do` file-editing harness (the default executor), a Claude Sonnet subagent, and finally the lead Claude model itself. Work starts at the cheapest rung that can plausibly do the job and escalates only on a stall. This is how the expensive model's budget gets spent on judgment instead of keystrokes.

### Section: guardrails

The guardrails section lists hard rules Claude must not break: confirm the target repo before writing, never send secrets or private data to the delegate models, and never point autonomous delegates at repos you mark as sensitive. That last rule pairs with the `GLM_DO_FORBIDDEN_PATHS` environment variable — a colon-separated list of repositories the `glm-do` harness refuses to write to, enforced in code, not just by instruction (see [docs/10-delegation-harness.md](10-delegation-harness.md)).

### Section: knowledge-base pointers

Finally, the template points Claude at your second-brain vault (`~/claude-obsidian/wiki`) and states the memory rules: active work gets one lean line in the memory index, durable knowledge gets a wiki page, and routine fixes get nothing because the git commit is the record.

## Make it your own

To use the template, copy it into your user-scope location and then open it in an editor.

```bash
mkdir -p ~/.claude
cp kit/templates/CLAUDE.md.template ~/.claude/CLAUDE.md
```

The first command makes sure the `~/.claude` folder exists (the `-p` flag creates parent folders as needed and does not error if it already exists). The second command copies the template into place.

Open the file with any text editor:

```bash
nano ~/.claude/CLAUDE.md
```

Now replace the bracketed placeholder in the guardrails section (`[LIST YOUR SENSITIVE REPOS HERE ...]`) with your own paths, delete the instruction paragraph at the top, and adjust any rule that doesn't fit how you work. Save the file, and from the next session onward Claude will load your rules automatically. (The repo's `setup.sh` offers to install this template for you if you don't already have a `~/.claude/CLAUDE.md`.)

---

Next → [Skills and plugins](06-skills-plugins.md)
