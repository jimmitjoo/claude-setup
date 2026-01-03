#!/bin/bash
# Hook som körs efter att Claude skriver/redigerar filer
# Formaterar koden automatiskt baserat på filtyp

FILE_PATH="$CLAUDE_FILE_PATH"

# Avbryt om ingen fil angiven
[ -z "$FILE_PATH" ] && exit 0

# Hämta filändelse
EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|json)
    # Försök formatera med prettier om det finns
    if command -v npx &> /dev/null && [ -f "package.json" ]; then
      npx prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  go)
    # Go formattering
    if command -v gofmt &> /dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    # Rust formattering
    if command -v rustfmt &> /dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    # Python formattering
    if command -v black &> /dev/null; then
      black "$FILE_PATH" 2>/dev/null || true
    elif command -v ruff &> /dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
