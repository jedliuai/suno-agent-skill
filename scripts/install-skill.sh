#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${HOME}/.claude/skills/suno"
mkdir -p "$TARGET_DIR"
cp "$ROOT/skills/suno/SKILL.md" "$TARGET_DIR/SKILL.md"

echo "Installed Suno Claude Skill to: $TARGET_DIR/SKILL.md"
echo "Restart Claude Code / your Claude agent session if the skill list does not refresh automatically."
