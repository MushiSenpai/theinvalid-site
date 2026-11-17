#!/bin/bash
# snapshot-classic.sh — freeze the pre-redesign (2026-11) site design under public/classic/.
# Builds REF in a temporary worktree, then copies its generated pages + CSS into
# public/classic/ with links re-pointed (scripts/classic_rewrite.py). Re-run only if the
# classic snapshot itself needs regenerating; new posts are NOT expected to appear there.
set -euo pipefail
REF="${1:-499b6d3}"
LABEL="${2:-on 17 Nov 2026}"
cd "$(dirname "$0")/.."
ROOT="$PWD"
WT="$(mktemp -d)"
git worktree add --detach "$WT" "$REF" >/dev/null
cleanup() { git -C "$ROOT" worktree remove --force "$WT" 2>/dev/null || true; }
trap cleanup EXIT
ln -s "$ROOT/node_modules" "$WT/node_modules"
(cd "$WT" && npx astro build >/dev/null)
python3 scripts/classic_rewrite.py "$WT/dist" "$WT/public" "$ROOT/public/classic" "$LABEL"
du -sh "$ROOT/public/classic"
