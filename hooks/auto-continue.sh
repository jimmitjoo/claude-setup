#!/bin/bash
#
# Hook: Säg åt Claude att fortsätta om det finns arbete kvar
#
# Returnerar:
#   "continue" - fortsätt arbeta
#   "stop" - sluta
#

# Kolla om det finns todos kvar
# (Detta är en förenklad version - Claude skickar context via env vars)

echo '{"decision": "continue", "reason": "Arbete återstår"}'
