# How this setup works

## What you'll accomplish

In this short page you will understand the big picture behind the claude-code-setup-kit. You will learn who does what when you type code with Claude Code, why we use a "ladder" of models instead of one model for everything, and how that keeps your subscription tokens going much further. After reading this you will feel confident about the rest of the guide because the reasoning will already make sense to you.

## Meet your two teammates

When you use **Claude Code** in the terminal, you are really running a small engineering team. Claude Code is the **lead engineer**. It plans features, reads existing code, reviews work, and decides what the final result should look like. It rarely types large amounts of code itself, just like a busy lead engineer on a real team.

The actual typing of routine, repetitive code is done by a **junior team** of cheap or free models. Most of them run on **Ollama**, which lets you run models locally or in the cloud for very little money. These junior models are good enough for "write this function body" or "rename this variable everywhere" — the kind of work that does not need expensive reasoning.

## The delegation ladder

Work climbs a ladder. The cheapest model that can do the job is the one that gets the job. If it gets stuck, the work moves up one rung. The full ladder, from cheapest to most expensive, is:

```
          +-----------------------+
  TOP     |  Lead Claude model     |   plans, reviews, final decisions
          +-----------------------+
          |  Claude Sonnet        |   subagents for harder subtasks
          +-----------------------+
          |  glm-do harness        |   safe file-editing with GLM
          +-----------------------+
          |  GLM (cloud, cheap)    |   raw first drafts of routine code
          +-----------------------+
  BOTTOM  |  Gemma (local, free)   |   fastest free drafts, runs on your Mac
          +-----------------------+
```

- **Gemma** runs locally through Ollama. It is free because it uses your own machine. We send it the simplest, most mechanical tasks.
- **GLM** in the cloud is extremely cheap per token. It is great for producing a rough first draft of a file when Gemma is not enough.
- **glm-do** is a safe *file-editing harness* around GLM. Instead of letting a model say "here is some code, paste it yourself," glm-do actually applies edits to files under rules Claude controls. This keeps automation safe.
- **Claude Sonnet subagents** are smaller Claude sessions that Claude Code can spin up for a focused subtask. They are more capable but cost more.
- **The lead Claude model** is the one you talk to directly. It reviews the junior work and only writes code itself when the task truly needs its skill.

## Why do it this way

Your Claude Pro or Max subscription gives you a fixed amount of tokens. Those tokens are scarce. If the lead model writes every line, you run out fast. By delegating the boring parts to free or cheap models, the lead only spends tokens on thinking and reviewing — and reviewing is much cheaper than generating.

In practice this lets the same subscription cover five to ten times more real work. You get the quality of the expensive model where it matters, and you get free or nearly free labor everywhere else.

The rest of this kit, including the `setup.sh` installer and the `kit/` directory of scripts, agents, hooks, and templates, exists to wire this ladder together for you. You do not have to build the ladder yourself — you just need to understand it before you turn it on.

Next → [Accounts you'll need](./01-accounts.md)
