# Accounts you'll need

## What you'll accomplish

On this page you will collect every account and login you need before installing anything. You will understand which accounts are required, which are recommended, and which are strictly optional, so you can sign up for the right things in one sitting and not be surprised later. By the end you will have a clear checklist of accounts and a firm rule about where API keys are allowed to live.

## Account table

| Account | Status | Why you need it |
|---|---|---|
| Anthropic (Claude Pro or Max) | Required | This is what powers Claude Code, the lead model. |
| GitHub (free) | Recommended | Stores your code and gives you the `gh` command-line tool. |
| Ollama (free download + free account) | Recommended | Lets you run free local models and use cheap cloud models like GLM/Kimi. |
| 21st.dev API key | Optional | Powers the "magic" UI component MCP. |
| context7 API key | Optional | Raises rate limits for live documentation lookups. |
| Vercel / Supabase / Figma | Optional | Only if your projects use those platforms. |

## Required: Anthropic

You must have an Anthropic account with either a **Claude Pro** or **Claude Max** subscription. Pro is the standard consumer plan and is enough for most people. **Max** gives you higher usage limits, which matters when you are delegating a lot and running many subagents in a day. If you find yourself hitting limits often, upgrading from Pro to Max is the single change that gives you more room. Either plan works with this kit; Max simply lets you go further before things slow down.

## Recommended: GitHub

A free GitHub account is strongly recommended. It is where you keep your code, and it unlocks the `gh` command-line tool that this kit uses for cloning, pushing, and opening issues from the terminal. You do not pay anything to sign up.

## Recommended: Ollama

Install the **Ollama** app, which is a free download. Then create a free Ollama account as well, because some models — including **GLM** and **Kimi** — run on Ollama's cloud servers for a very small fee. Those cloud models are cheaper than almost anything else and are a core part of the delegation ladder. You sign into your Ollama account from the terminal with this command:

```bash
ollama signin
```

That single command opens a browser flow where you log in to Ollama. After that, your terminal can pull and use both local and cloud models.

## Optional accounts

- **21st.dev API key** — only if you want the "magic" UI component MCP that generates polished component code.
- **context7 API key** — only if you want higher rate limits for live documentation lookups; the kit works without it.
- **Vercel, Supabase, Figma** — only sign up if your specific projects deploy on Vercel, use a Supabase database, or pull design tokens from Figma. This kit does not require any of them.

## The one rule about API keys

Never paste an API key into a chat prompt. Keys belong in configuration files, environment variables, or the installer's prompts — never in a message to any model. Pasting a key into chat can leak it and is also pointless, because the tools read keys from config, not from your conversation. Treat every key as a secret that lives in a file, not in your typing.

Next → [Setting up your Mac](./02-install-mac.md)
