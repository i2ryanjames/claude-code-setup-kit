# Claude Code Setup Kit

Turn a bare Mac or Windows PC into a fully-loaded **Claude Code** workstation —
not just the CLI, but the whole operating pattern around it:

- 🧠 **Claude as the lead engineer** — it plans, delegates, and reviews
- 🤝 **A "junior team" of cheap/free local models** (Gemma + GLM via Ollama)
  that types the routine code, so your Claude subscription goes 5–10× further
- 📚 **A second brain** — an Obsidian-compatible markdown vault Claude reads
  and writes, so knowledge survives between sessions
- 🛠 **An MCP tool stack** — browser automation, live library docs, and
  UI-component intelligence available in every project
- 🔍 **A free automatic code review** of every uncommitted diff, running in
  the background after each Claude turn

## Quick start

```bash
# requires access — accept your repo invitation first, then:
git clone https://github.com/i2ryanjames/claude-code-setup-kit
cd claude-code-setup-kit
bash setup.sh
```

The installer is **interactive and layered** — it asks before each layer,
never overwrites your existing config without a timestamped backup, and is
safe to re-run any time.

Completely new to the terminal? Start with the docs instead:

| Read | If you want |
|---|---|
| [docs/00-overview.md](docs/00-overview.md) | How all the pieces fit together (start here) |
| [docs/01-accounts.md](docs/01-accounts.md) | Which accounts you need (and which are optional) |
| [docs/02-install-mac.md](docs/02-install-mac.md) | Mac setup from zero |
| [docs/03-install-windows.md](docs/03-install-windows.md) | Windows setup from zero (WSL) |
| [docs/04-first-session.md](docs/04-first-session.md) | Your first Claude Code session |
| [docs/05-claude-md.md](docs/05-claude-md.md) | Standing instructions (CLAUDE.md) |
| [docs/06-skills-plugins.md](docs/06-skills-plugins.md) | Skills and plugins |
| [docs/07-mcp-stack.md](docs/07-mcp-stack.md) | The MCP tool stack |
| [docs/08-second-brain.md](docs/08-second-brain.md) | The knowledge vault |
| [docs/09-memory-system.md](docs/09-memory-system.md) | What Claude remembers, and where |
| [docs/10-delegation-harness.md](docs/10-delegation-harness.md) | The delegation harness (the star of the kit) |
| [docs/11-troubleshooting.md](docs/11-troubleshooting.md) | When something breaks |

## What's in the box

```
setup.sh                 # interactive layered installer
docs/                    # step-by-step guide, beginner-friendly
kit/
├── bin/                 # → ~/.local/bin
│   ├── ask-gemma        #   free local generation (Gemma via Ollama)
│   ├── ask-glm          #   cheap cloud generation (GLM-5.2 / Kimi via Ollama Cloud)
│   └── glm-do           #   autonomous coding harness — the model returns whole
│                        #   files, the script applies them; the model NEVER
│                        #   gets shell access
├── agents/              # → ~/.claude/agents — subagents so Claude can dispatch
│   │                    #   work down the ladder by itself
│   ├── gemma-helper.md  glm-helper.md  glm-coder.md
├── hooks/               # → ~/.claude/hooks
│   ├── session-start-hotcache.sh   # injects your vault's hot.md each session
│   ├── glm-review.sh               # free background review of every diff
│   └── wiki-doc-nudge.sh           # nudges Claude to capture durable knowledge
└── templates/
    ├── CLAUDE.md.template          # the delegation-ladder standing instructions
    ├── settings-hooks.json         # the hooks block setup.sh merges for you
    ├── hot-starter.md  MEMORY-starter.md
```

## The delegation ladder (the core idea)

```
cost ▲   Tier 4  Claude lead (Opus-class) — plans, specs, reviews every diff
     │   Tier 3  Claude Sonnet subagent  — delicate execution, escalations
     │   Tier 2  GLM via glm-do          — DEFAULT executor: edits files safely
     │   Tier 1  GLM raw (ask-glm)       — drafts, analysis, explanations
     ▼   Tier 0  Gemma local (ask-gemma) — free: boilerplate, naming, summaries
```

Claude stays the architect and reviewer; the cheap tiers do the typing.
Escalation only happens on a stall. Your subscription budget gets spent where
it matters — judgment — not on keystrokes.

## Safety notes

- `glm-do` gives the model **zero shell access** — it can only propose file
  contents, which the harness writes mechanically and verifies with a command
  you control. It refuses paths that escape the repo, anything touching
  `.git`, and any repo you list in `GLM_DO_FORBIDDEN_PATHS`.
- `setup.sh` backs up any file it would change (`*.bak-<timestamp>`) and
  merges hook config additively — your existing hooks are preserved.
- Never put secrets or private data in prompts sent to the delegate models.

## Requirements

macOS or Windows 10/11 (via WSL2) · an Anthropic account with Claude Pro or
Max · ~15 GB free disk if you want the local Gemma model. Full detail in
[docs/01-accounts.md](docs/01-accounts.md).

## License

Proprietary — personal-use license for authorized purchasers. See [LICENSE](LICENSE).
Please don't redistribute; it's a small independent product.
