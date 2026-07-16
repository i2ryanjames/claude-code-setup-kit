# Skills and plugins

## What you'll accomplish

In this guide you will learn two ways to extend Claude Code with reusable capabilities: skills and plugins. Skills are compact instruction packs that Claude can invoke as slash commands, while plugins are larger bundles distributed through marketplaces. By the end of this page you will know the difference between the two, understand how to browse and install plugins from a marketplace, and have a short list of recommended plugins and skills to get you started.

## What are skills?

Skills are reusable instruction packs that Claude invokes when you call them. In practical terms, a skill usually shows up as a slash command inside Claude Code (for example, `/design-review`). When you trigger the command, Claude loads the skill's instructions for that session and follows them. This is handy for workflows you repeat often, such as reviewing a UI, debugging a build error, or generating boilerplate. Skills live in `~/.claude/skills/` on your machine, or arrive bundled inside plugins.

## What are plugins?

Plugins are bundles distributed through marketplaces and installed inside Claude Code with the `/plugin` command. A plugin may contain one or more skills, prompts, or supporting files. Think of a plugin as a small package you add to Claude Code so that it gains new slash commands or behaviors without you having to copy files around by hand.

## Auto-installed plugins (via setup.sh)

As of the latest version, `setup.sh` (Layer 5 of the installer) automatically
installs a recommended set of plugins for you using the `claude plugin` CLI. This
includes **ui-ux-pro-max**, **vercel**, **supabase**, **figma**, and the
**anthropics/skills** marketplace by default — so you no longer need to install
these by hand after running the installer.

The walkthrough below is still useful as a **manual reference** if you want to
add other plugins later or if the auto-installation doesn't complete.

## Recommended plugins and skills

Below is a short, generic list you can pick from. You do not need all of them — choose based on the tools you actually use.

- **vercel** and **supabase** (official marketplace): install these if you deploy your projects on Vercel or Supabase. They give Claude handy commands and context for those platforms.
- **ui-ux-pro-max** (marketplace: `nextlevelbuilder/ui-ux-pro-max-skill`): a skill pack focused on design intelligence, useful when you want stronger guidance on layout, spacing, and visual polish.
- **figma** (official): install this if you use Figma and want Claude to be able to reference your Figma files.
- **Anthropic's open-source skills marketplace** (`anthropics/skills`): a community-friendly source of skills covering design and debugging tasks. Worth browsing for reusable patterns.

## How to install a plugin

Inside Claude Code, you first add a marketplace, then install a plugin from it. The commands below are run inside the Claude Code prompt (not your terminal), which is why they start with a slash.

This command tells Claude Code to remember a new marketplace so it can list and install plugins from it. Replace `org-name/marketplace-name` with the actual marketplace identifier.

```bash
/plugin marketplace add org-name/marketplace-name
```

After adding the marketplace, you can install a specific plugin. This command installs the named plugin and makes its slash commands available in your sessions.

```bash
/plugin install plugin-name
```

You can also list installed plugins and marketplaces with:

```bash
/plugin list
```

## A generic install walkthrough

Let's say you want to add the `ui-ux-pro-max` skill from the `nextlevelbuilder/ui-ux-pro-max-skill` marketplace. You would do it in two steps.

First, add the marketplace so Claude Code knows where to find the plugin:

```bash
/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
```

Then install the plugin from that marketplace:

```bash
/plugin install ui-ux-pro-max
```

After the second command finishes, the plugin's slash commands become available. You can call them the same way you call any other slash command inside Claude Code.

## Tips for beginners

- Start with one or two plugins. Too many installed plugins can make Claude Code's behavior harder to predict.
- If a plugin depends on an API key (for example, a design tool that needs a token), read its README before installing so you know what to configure.
- You can remove a plugin later if it is not useful. Run `/plugin list` to see what is installed and follow the prompts to uninstall.

## Next →

Continue to [07-mcp-stack.md](07-mcp-stack.md) to learn about the MCP tool stack — servers that give Claude extra tools like component libraries, live docs, and browser automation.
