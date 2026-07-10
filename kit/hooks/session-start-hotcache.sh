#!/usr/bin/env bash
# SessionStart hook: inject the "hot cache" — a deliberately tiny page of
# pointers from your knowledge vault — into every new Claude Code session.
# hot.md should hold POINTERS (where to look), never content dumps.
cat "$HOME/claude-obsidian/wiki/hot.md" 2>/dev/null || true
