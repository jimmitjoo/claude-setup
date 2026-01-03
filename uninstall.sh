#!/bin/bash
#
# Claude Code Setup Uninstaller
# Tar bort installerade agents, skills, commands och hooks
#

set -e

CLAUDE_DIR="$HOME/.claude"

echo "╔════════════════════════════════════════╗"
echo "║   Claude Code Setup Uninstaller        ║"
echo "╚════════════════════════════════════════╝"
echo ""

read -p "⚠️  Detta tar bort alla agents, skills, commands och hooks. Fortsätt? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Avbrutet."
    exit 0
fi

# Backup först
BACKUP_DIR="$CLAUDE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
echo "📦 Skapar backup i $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
[ -d "$CLAUDE_DIR/agents" ] && cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/"
[ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/"
[ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/"
[ -d "$CLAUDE_DIR/hooks" ] && cp -r "$CLAUDE_DIR/hooks" "$BACKUP_DIR/"

# Ta bort
echo "🗑️  Tar bort agents..."
rm -rf "$CLAUDE_DIR/agents"

echo "🗑️  Tar bort skills..."
rm -rf "$CLAUDE_DIR/skills"

echo "🗑️  Tar bort commands..."
rm -rf "$CLAUDE_DIR/commands"

echo "🗑️  Tar bort hooks..."
rm -rf "$CLAUDE_DIR/hooks"

echo "🗑️  Tar bort CLAUDE.md..."
rm -f "$CLAUDE_DIR/CLAUDE.md"

echo "🗑️  Tar bort README.md..."
rm -f "$CLAUDE_DIR/README.md"

echo ""
echo "✅ Avinstallation klar!"
echo "   Backup sparad i: $BACKUP_DIR"
echo ""
echo "⚡ Starta om Claude Code för att tillämpa!"
