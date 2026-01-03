#!/bin/bash
# Hook som körs innan bash-kommandon
# Varnar för potentiellt farliga kommandon

COMMAND="$CLAUDE_BASH_COMMAND"

# Lista över farliga mönster
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  ":(){:|:&};:"
  "mkfs"
  "dd if="
  "> /dev/sd"
  "chmod -R 777 /"
  "curl.*| bash"
  "wget.*| bash"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "BLOCKED: Potentiellt farligt kommando detekterat: $pattern" >&2
    exit 2  # Exit code 2 blockerar operationen
  fi
done

exit 0
