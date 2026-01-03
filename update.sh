#!/bin/bash
#
# Claude Code Setup Updater
# Uppdaterar från git repo och installerar om
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════╗"
echo "║   Claude Code Setup Updater            ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Kolla om vi är i ett git repo
if [ -d "$SCRIPT_DIR/.git" ]; then
    echo "📥 Hämtar senaste versionen..."
    cd "$SCRIPT_DIR"
    git pull
    echo ""
fi

# Kör install
echo "🔄 Installerar uppdateringar..."
"$SCRIPT_DIR/install.sh"
