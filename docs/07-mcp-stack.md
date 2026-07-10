# The MCP tool stack

## What you'll accomplish

In this guide you will learn about the Model Context Protocol (MCP) and how it lets Claude Code call external servers that provide extra tools. You will understand the difference between user scope (available in every project) and project scope (saved to a project file), add several useful MCP servers with exact commands, and verify that they are registered. By the end you will have a working MCP stack for components, live docs, and browser automation.

## What is MCP?

MCP stands for Model Context Protocol. In plain terms, an MCP server is a small program that gives Claude extra tools. For example, one MCP server might let Claude browse component libraries, another might fetch live documentation for a library, and another might drive a browser. Claude loads these tools on demand, which means they only run when a task actually needs them.

## User scope vs project scope

MCP servers can be added at two scopes:

- **User scope (`-s user` or `--scope user`):** the server is available in every project on your machine. This is best for tools you want everywhere, such as a component library or live docs.
- **Project scope:** the server configuration is saved to a `.mcp.json` file in your project. This is best for tools that only make sense for one project, and the file can be committed so teammates get the same setup.

The commands below all use user scope, since these tools are useful across projects. If you ever want a project-scoped server, simply omit the `--scope user` flag and Claude Code will write the config to `.mcp.json`.

## Adding component library servers

This command adds a server named `shadcn` that lets Claude browse and use shadcn components. It runs the latest shadcn MCP server through `npx`, which downloads and runs the package on demand.

```bash
claude mcp add --scope user shadcn -- npx -y shadcn@latest mcp
```

This command adds a server named `magic-ui` for Magic UI animated components. It works the same way as the shadcn command but points at the Magic UI package.

```bash
claude mcp add --scope user magic-ui -- npx -y @magicuidesign/mcp
```

## Adding the 21st.dev component builder (optional)

This command adds a server named `magic` that uses the 21st.dev AI component builder. It requires an API key from 21st.dev, which you must place where `<your-21st-dev-key>` is shown. If you do not have a key, skip this one — it is optional.

```bash
claude mcp add --scope user magic -- env API_KEY=<your-21st-dev-key> npx -y @21st-dev/magic@latest
```

## Adding live docs and browser automation

This command adds a server named `context7` that fetches live, up-to-date documentation for libraries. This helps Claude avoid relying on stale knowledge about packages that change often.

```bash
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp
```

This command adds a server named `playwright` that lets Claude automate a browser using Playwright. It is useful for tasks like clicking through a page or taking screenshots during testing.

```bash
claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest
```

For Chrome DevTools, you have two options. You can install the official plugin from the `ChromeDevTools/chrome-devtools-mcp` repository (using the plugin flow from the previous page), or you can add it directly as an MCP server with this command:

```bash
claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest
```

## Verifying your MCP servers

After adding the servers, run this command to list every MCP server Claude Code knows about. It confirms each server is registered and shows whether it is user-scoped or project-scoped.

```bash
claude mcp list
```

If a server shows up in the list without errors, it is ready to use. Claude will call it automatically when a task needs its tools.

## A note on loading

MCP servers load their tools on demand. This means adding several servers does not slow down every session — Claude only reaches for a server's tools when your task actually requires them. You can safely keep a broad set of servers registered and trust that only the relevant ones activate.

## Next →

Continue to [08-second-brain.md](08-second-brain.md) to learn how to set up a "second brain" — a markdown vault that doubles as an Obsidian vault and a knowledge base Claude can read on demand.
