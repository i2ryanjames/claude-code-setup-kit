# Memory: what Claude remembers and where

## What you'll accomplish

By the end of this page you will know exactly where to write things down so Claude Code keeps helpful context without turning your project into a pile of duplicated notes. You will learn a simple three-tier habit for deciding what deserves a memory entry, a project fact file, or a wiki page, and you will understand how the kit's built-in hook decides when to remind you to capture durable knowledge.

## The three tiers

### Tier 1 — Routine fixes: rely on git

If you just fixed a typo, refactored one function, or resolved a one-off bug, you usually do not need a memory note. The commit message and the code diff already tell the whole story, and Claude can read them the next time it works with you. Before you add a note, ask the decision test below.

### Tier 2 — Active multi-session work: keep a lean index

When you are working on something that spans several sessions and you want Claude to pick up where you left off, add **one short line** to the per-project `MEMORY.md` index that Claude Code loads automatically. The line should name the topic and point to a detail file. Do not dump the full context into the index — that makes it noisy and harder to read.

Detail files live next to the index and follow these naming conventions:

- `project_<topic>.md` for facts about this repository.
- `feedback_<topic>.md` for preferences about how you like things done.
- `reference_<topic>.md` for external knowledge you keep coming back to.

Each detail file should start with YAML frontmatter so it is easy to find and sort later. Here is an example file:

```markdown
---
kind: project-api
created: 2026-01-10
last_used: 2026-01-10
---

## Notes on the public API

- Always return JSON with a `status` field.
- Rate limiting lives in `src/middleware/rate-limit.ts`.
```

Claude Code manages this memory directory itself — it lives under `~/.claude/projects/<project>/memory/`, and Claude creates `MEMORY.md` plus the detail files as you work. You normally never edit these by hand. The kit ships `kit/templates/MEMORY-starter.md` as a reference showing the shape a healthy index should have: one lean line per topic, grouped by theme, with detail in the linked files. If Claude's index starts getting bloated, point it at that template and ask it to tidy up.

### Tier 3 — Durable reusable knowledge: write a wiki page

Some lessons are worth keeping for months or reusing across projects: architecture decisions, team conventions, library gotchas, deployment runbooks, and so on. That kind of knowledge belongs in your "second brain" wiki, not in a per-project memory file. The kit expects your wiki to be a separate notes repository or folder that you choose.

## The decision test

Before you write anything, ask:

> "Would I re-read this months later to make a decision, and is it not already in git?"

- If the answer is **yes** and it is specific to this project, put it in a per-project fact file.
- If the answer is **yes** and it applies more broadly, write a wiki page.
- If the answer is **no**, let the git commit be the record and move on.

## The wiki-doc nudge hook

The kit includes `kit/hooks/wiki-doc-nudge.sh`, a Stop hook that fires when Claude finishes a turn. It reminds *Claude* (not you) to check whether the turn produced durable, reusable knowledge — and to write a wiki page or a memory line only if it did. The repo's `setup.sh` installs and wires this hook for you as part of Layer 4; if you skipped the installer, copy it to `~/.claude/hooks/`, make it executable with `chmod +x`, and add it to the `Stop` hooks in `~/.claude/settings.json` (see `kit/templates/settings-hooks.json` for the exact block).

### How the nudge decides to skip

The hook is intentionally quiet most of the time. The script itself only fires at most once per 45 minutes per session (and never re-fires while Claude is already responding to a nudge). The nudge text then instructs Claude to skip silently for anything routine: plain Q&A, work that is still mid-task, or a change whose commit message and diff already tell the whole story. The bar it applies is the same decision test you read above — most turns produce nothing worth writing down, and that is by design.

## Next →

Continue to [10-delegation-harness.md](10-delegation-harness.md) to learn how to route routine work to cheaper models and make your main plan go much further.
