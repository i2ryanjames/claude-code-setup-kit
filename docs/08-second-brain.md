# The second brain (Obsidian vault)

## What you'll accomplish

In this guide you will learn how to set up a lightweight "second brain" — a folder of markdown files at `~/claude-obsidian` that serves two purposes at once. It is a vault you can open in the Obsidian app for reading and editing, and it is also a knowledge base Claude can read on demand. You will understand the three-file spine (`hot.md`, `index.md`, and individual wiki pages), how the kit auto-injects pointers at the start of every session, and why this keeps token cost low until you actually need detail.

## The pattern

The idea is simple: keep a folder of plain markdown files that both a human and Claude can read. The folder lives at `~/claude-obsidian` and contains a small set of wiki pages. You can open the same folder in Obsidian (a free note-taking app) to get a nice GUI over the files, but the GUI is optional — the files are plain text and work on their own.

## Getting started

You have two options for the initial structure.

The first option is to clone the open-source `claude-obsidian` project, which gives you a ready-made folder layout and starter templates. You can find it at `github.com/AgriciDaniel/claude-obsidian`.

The second option is to start bare. Create a folder named `~/claude-obsidian` containing a `wiki/` directory, and inside it two special files: `wiki/hot.md` and `wiki/index.md`, alongside your individual pages. The repo's `setup.sh` (Layer 3) scaffolds exactly this for you, including a starter `hot.md`.

## The three-file spine

The vault is organized around three layers of files. Understanding how they fit together is the key to keeping things cheap and fast.

**`hot.md`** is a tiny file containing only pointers. It lists a handful of important page names or one-line reminders. Because it is small, it can be injected at the start of every Claude session without costing many tokens. This file should stay short — pointers only, no long explanations.

**`index.md`** is a catalog of every page in the vault. It maps page titles to file paths so Claude (or you) can find any topic quickly. Think of it as the table of contents for the whole vault.

**Individual wiki pages** live inside `wiki/` and hold the actual detail. These are read on demand, meaning Claude only opens a page when a task requires that specific knowledge. This keeps token usage near zero until detail is truly needed.

## The read path

When a session starts, Claude reads `hot.md` first. If a pointer looks relevant, Claude checks `index.md` to find where the related page lives, then opens that individual wiki page. This `hot → index → page` flow means Claude only loads the small pointer file by default, and only pulls in heavier pages when a task actually needs them. The result is a knowledge base that stays inexpensive to use even as it grows.

## What the kit installs

The `claude-code-setup-kit` repo ships a couple of pieces to make this pattern easy. It installs a hook script at `kit/hooks/session-start-hotcache.sh` that runs at the start of every Claude session and injects the contents of `hot.md` into the session context. It also installs a starter template at `kit/templates/hot-starter.md` that you can copy into your vault to get a sensible starting `hot.md` without writing it from scratch.

When you run the repo's `setup.sh` installer, it wires up the hook so the hot cache loads automatically. After that, you only need to keep `hot.md`, `index.md`, and your `wiki/` pages updated as you learn new things.

## Is Obsidian required?

No. Obsidian is a free app that gives you a friendly graphical interface over the same markdown files, with features like links, search, and graph views. It is a nice-to-have, not a requirement. Claude reads the files directly, so the vault works perfectly well from the terminal or any text editor. If you like a visual note-taking experience, open the `~/claude-obsidian` folder in Obsidian. If not, plain files are enough.

## Next →

Continue to [09-memory-system.md](09-memory-system.md) to learn the rules for what gets written down where — memory index, fact files, or wiki pages.
