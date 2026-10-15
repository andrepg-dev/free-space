#!/usr/bin/env bash
# free-space.sh — reclaim disk space on macOS by clearing regenerable caches.
#
# Dry run by default: shows what would be freed. Pass --yes to delete.
# Only touches caches that tools rebuild on demand. Never touches
# Downloads, Documents, Docker volumes, or downloaded ML models.

set -uo pipefail

APPLY=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes) APPLY=1 ;;
    -h|--help)
      sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

TOTAL_KB=0

kb_of() { du -sk "$@" 2>/dev/null | awk '{s+=$1} END {print s+0}'; }
human() { awk -v k="$1" 'BEGIN { split("K M G T", u); i=1; while (k>=1024 && i<4) {k/=1024; i++} printf "%.1f%s", k, u[i] }'; }
free_space() { df -k / | awk 'NR==2 {print $4}'; }

# clean_path LABEL PATH... — remove the contents of each path
clean_path() {
  local label=$1; shift
  local paths=() p
  for p in "$@"; do [ -e "$p" ] && paths+=("$p"); done
  [ ${#paths[@]} -eq 0 ] && return
  local kb; kb=$(kb_of "${paths[@]}")
  [ "$kb" -eq 0 ] && return
  TOTAL_KB=$((TOTAL_KB + kb))
  printf "  %8s  %s\n" "$(human "$kb")" "$label"
  if [ $APPLY -eq 1 ]; then
    for p in "${paths[@]}"; do
      if [ -d "$p" ]; then
        find "$p" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
      else
        rm -f "$p"
      fi
    done
  fi
}

# clean_cmd LABEL MEASURE_PATH CMD... — measure a path, then run a tool's own cleaner
clean_cmd() {
  local label=$1 measure=$2; shift 2
  command -v "$1" >/dev/null 2>&1 || return
  [ -e "$measure" ] || return
  local kb; kb=$(kb_of "$measure")
  [ "$kb" -eq 0 ] && return
  TOTAL_KB=$((TOTAL_KB + kb))
  printf "  %8s  %s (via %s)\n" "$(human "$kb")" "$label" "$1"
  [ $APPLY -eq 1 ] && "$@" >/dev/null 2>&1
}

BEFORE=$(free_space)
[ $APPLY -eq 1 ] && echo "Cleaning caches..." || echo "Dry run — pass --yes to delete:"

echo "JavaScript"
clean_path "npm cache" "$HOME/.npm/_cacache" "$HOME/.npm/_npx" "$HOME/.npm/_logs"
clean_cmd  "pnpm store (unreferenced)" "$HOME/Library/pnpm/store" pnpm store prune
clean_path "pnpm metadata cache" "$HOME/Library/Caches/pnpm"
clean_path "bun cache" "$HOME/.bun/install/cache"
clean_path "yarn cache" "$HOME/Library/Caches/Yarn"
