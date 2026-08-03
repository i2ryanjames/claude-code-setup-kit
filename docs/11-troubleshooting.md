# Troubleshooting

## What you'll accomplish

By the end of this page you will be able to diagnose and fix the most common problems with the kit's models, hooks, and integrations. You will know which commands to run when something fails, where to look for logs, and how to get Claude Code back into a working state without guessing.

## Ollama is unreachable

If a local model command fails or `glm-do` exits with code `2`, the Ollama server is probably not running. Start it from the terminal:

```bash
ollama serve
```

On macOS you can also open the Ollama app from your Applications folder. To confirm the server is listening, ask it for its version:

```bash
curl http://localhost:11434/api/version
```

A successful response means the local server is ready.

## Cloud model errors

If `ask-glm` or `glm-do` complains that a cloud model is unavailable, you are usually not signed in. Run:

```bash
ollama signin
```

Then try the command again. Cloud models require an active Ollama Cloud session.

## `glm-do` exit codes and fixes

| Code | Meaning | Fix |
|------|---------|-----|
| `0` | Success. | No action needed. |
| `1` | Bad command line. | Run `glm-do --help` and check your flags. |
| `2` | Ollama unreachable. | Start `ollama serve` or open the Ollama app. |
| `3` | Model error or truncation. | Retry with a shorter context or a stronger model. |
| `4` | No edits parsed. | Make the prompt explicitly name the files to change. |
| `5` | Verify still failing. | Inspect the diff and improve the prompt or context. |
| `6` | Safety refusal. | Rephrase the request, or handle that file manually. |

## Hooks are not firing

Claude Code loads hooks from your settings file. First, check that the settings file is valid JSON:

```bash
jq . ~/.claude/settings.json
```

If `jq` prints an error, fix the JSON syntax and restart Claude Code. Next, make sure the hook script itself is executable:

```bash
chmod +x ~/.claude/hooks/wiki-doc-nudge.sh
chmod +x ~/.claude/hooks/glm-review.sh
```

Claude Code will silently ignore a hook that does not have execute permission.

## An MCP server is not loading

List the currently registered servers to see which one is failing:

```bash
claude mcp list
```

Check that Node.js is installed and reasonably up to date:

```bash
node --version
```

If one server is stuck, remove it and add it back fresh:

```bash
claude mcp remove my-server
claude mcp add --transport stdio my-server -- npx -y my-mcp-server
```

## Permission prompts are too frequent

If Claude Code keeps asking for permission to run the same command, add it to your allowlist in `~/.claude/settings.json`, or use the `/permissions` slash command inside Claude Code to manage allowed tools in bulk.

## Claude Code login loops

If you keep being asked to log in even though you already did, sign out and back in cleanly from inside a Claude Code session using the slash commands:

```
/logout
/login
```

## Where the logs live

The kit's `glm-review.sh` hook saves its free second-opinion code reviews to `~/.claude/logs/` (one timestamped file per review). If you're wondering what the background reviewer thought of your last diff, that directory is where to look.

```bash
ls -la ~/.claude/logs/
```

**End of guide**
