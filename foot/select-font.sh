#!/usr/bin/env bash
set -euo pipefail

config=${1:-/home/lain/.config/foot/foot.ini}

for cmd in fc-list fzf awk; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$config" ]]; then
  echo "Error: config not found: $config" >&2
  exit 1
fi

family=$(fc-list -f '%{family[0]}\n' | sort -u | fzf --prompt='Font family> ')
if [[ -z "${family:-}" ]]; then
  echo "No selection made; leaving config unchanged." >&2
  exit 1
fi

awk -v fam="$family" '
function update(line) {
  # Preserve leading whitespace if present.
  match(line, /^[[:space:]]*/)
  lead = substr(line, RSTART, RLENGTH)
  line2 = substr(line, RLENGTH + 1)

  eq = index(line2, "=")
  if (eq == 0) return line
  key = substr(line2, 1, eq - 1)
  rest = substr(line2, eq + 1)

  colon = index(rest, ":")
  if (colon == 0) {
    return lead key "=" fam
  }
  return lead key "=" fam substr(rest, colon)
}

/^[[:space:]]*font(\-italic|\-bold|\-bold\-italic)?=/ {
  print update($0)
  next
}
{ print }
' "$config" > "${config}.tmp"

mv "${config}.tmp" "$config"

echo "Updated $config to use: $family"
