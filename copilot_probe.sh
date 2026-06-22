#!/usr/bin/env bash
# Read-only probe of VS Code Copilot chat sessions.
# Prints STRUCTURE only (file counts + a histogram of response "kind" tags) so it
# is safe to share — it never prints your message text. Nothing is written or sent.
set -uo pipefail
bases=(
  "$HOME/Library/Application Support/Code/User/workspaceStorage"
  "$HOME/Library/Application Support/Code - Insiders/User/workspaceStorage"
  "$HOME/.config/Code/User/workspaceStorage"
  "$HOME/.config/Code - Insiders/User/workspaceStorage"
  "$APPDATA/Code/User/workspaceStorage"
  "$APPDATA/Code - Insiders/User/workspaceStorage"
)
found=0
session_files=()
for base in "${bases[@]}"; do
  [ -d "$base" ] || continue
  found=1
  echo "## $base"
  cs=$(find "$base" -type d -name chatSessions 2>/dev/null | wc -l | tr -d ' ')
  es=$(find "$base" -type d -name chatEditingSessions 2>/dev/null | wc -l | tr -d ' ')
  echo "  workspaces with chatSessions:        $cs"
  echo "  workspaces with chatEditingSessions: $es   (>0 means agent/edit mode was used — the signal we want)"
  while IFS= read -r f; do [ -n "$f" ] && session_files+=("$f"); done \
    < <(find "$base" -path '*/chatSessions/*.json' 2>/dev/null)
done
if [ "$found" = 0 ]; then
  echo "No VS Code workspaceStorage found (looked for Code + Code - Insiders, macOS/Linux/Windows-APPDATA)."
  exit 0
fi
echo
echo "total session files: ${#session_files[@]}"
[ "${#session_files[@]}" -eq 0 ] && { echo "(no chat session JSON files — nothing to parse)"; exit 0; }
echo
echo "### response 'kind' histogram (across all sessions)"
echo "# toolInvocationSerialized / textEditGroup / prepareToolInvocation = tool & file-edit signal."
echo "# markdownContent / strings only = prose-only (low signal for scoring)."
grep -hoE '"kind"[[:space:]]*:[[:space:]]*"[^"]*"' "${session_files[@]}" 2>/dev/null \
  | sed -E 's/.*"([^"]*)"$/\1/' | sort | uniq -c | sort -rn
if command -v jq >/dev/null 2>&1; then
  echo
  echo "### per-session summary (jq)"
  for f in "${session_files[@]}"; do
    jq -r '"requests=\(.requests|length)  top_keys=[\(keys|join(","))]"' "$f" 2>/dev/null
  done | sort | uniq -c | sort -rn | head -20
fi
echo
echo "Largest session (best fixture candidate — contains real text, redact before sharing):"
for f in "${session_files[@]}"; do printf '%s\t%s\n' "$(wc -c <"$f" 2>/dev/null)" "$f"; done \
  | sort -rn | head -1