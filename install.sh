#!/bin/bash
#
# Claude Code Setup Installer
# Installerar agents, skills, commands och hooks
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "╔════════════════════════════════════════╗"
echo "║   Claude Code Setup Installer          ║"
echo "║   10 Agents │ 20 Skills │ 14 Commands  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Skapa ~/.claude om den inte finns
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "📁 Skapar $CLAUDE_DIR..."
    mkdir -p "$CLAUDE_DIR"
fi

# Backup befintliga filer
if [ -d "$CLAUDE_DIR/agents" ] || [ -d "$CLAUDE_DIR/skills" ] || [ -d "$CLAUDE_DIR/commands" ]; then
    BACKUP_DIR="$CLAUDE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backup av befintliga filer till $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    [ -d "$CLAUDE_DIR/agents" ] && cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/"
    [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/"
    [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/"
    [ -d "$CLAUDE_DIR/hooks" ] && cp -r "$CLAUDE_DIR/hooks" "$BACKUP_DIR/"
    [ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/"
fi

# Kopiera filer
echo "📋 Kopierar agents..."
cp -r "$SCRIPT_DIR/agents" "$CLAUDE_DIR/"

echo "📋 Kopierar skills..."
cp -r "$SCRIPT_DIR/skills" "$CLAUDE_DIR/"

echo "📋 Kopierar commands..."
cp -r "$SCRIPT_DIR/commands" "$CLAUDE_DIR/"

echo "📋 Kopierar hooks..."
cp -r "$SCRIPT_DIR/hooks" "$CLAUDE_DIR/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh

echo "📋 Kopierar CLAUDE.md..."
cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/"

echo "📋 Kopierar README.md..."
cp "$SCRIPT_DIR/README.md" "$CLAUDE_DIR/"

# Settings - fråga om överskrivning
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    echo ""
    read -p "⚠️  settings.json finns redan. Vill du ersätta den? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/"
        echo "✓ settings.json ersatt"
    else
        echo "→ Behåller befintlig settings.json"
    fi
else
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/"
fi

echo ""
echo "════════════════════════════════════════"
echo "✅ Installation klar!"
echo ""
echo "Installerat:"
echo "  • 10 Agents (architect, debugger, migrator...)"
echo "  • 20 Skills (llm-apps, edge, event-driven...)"
echo "  • 14 Commands (/new, /architect, /debug...)"
echo "  • 2 Hooks (auto-format, security check)"
echo ""
echo "📖 Läs dokumentationen:"
echo "   cat ~/.claude/README.md"
echo ""
echo "⚡ Starta om Claude Code för att aktivera!"
echo "════════════════════════════════════════"
