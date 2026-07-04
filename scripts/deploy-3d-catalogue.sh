#!/usr/bin/env bash
#
# Deploy the 3D Asset Catalogue from its git-ignored draft source into public/.
#
# The draft (drafts/mushishi-3d-catalogue/catalogue.html) references thumbnails as
# `thumbs/…` so it previews locally; in public/ they live under the namespaced
# `3d-thumbs/…`. That path repoint used to be a manual, forgettable sed — and
# forgetting it shipped broken images (OPS-61). This bakes it in and verifies the
# result, so the deploy is one reproducible command.
#
# Usage:  scripts/deploy-3d-catalogue.sh
# Then:   git add public/3d-catalogue.html public/3d-thumbs && git commit && git push
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SRC_DIR="drafts/mushishi-3d-catalogue"
SRC_HTML="$SRC_DIR/catalogue.html"
SRC_THUMBS="$SRC_DIR/thumbs"
DST_HTML="public/3d-catalogue.html"
DST_THUMBS="public/3d-thumbs"

[[ -f "$SRC_HTML"   ]] || { echo "ERROR: source HTML not found: $SRC_HTML" >&2; exit 1; }
[[ -d "$SRC_THUMBS" ]] || { echo "ERROR: thumbs dir not found: $SRC_THUMBS" >&2; exit 1; }

# 1) HTML: copy + repoint thumb paths (thumbs/ -> 3d-thumbs/). The (^|[^-]) guard
#    means it never double-applies to an already-namespaced 3d-thumbs/.
sed -E 's#(^|[^-])thumbs/#\13d-thumbs/#g' "$SRC_HTML" > "$DST_HTML"

# 2) Thumbnails: mirror the image files into the namespaced public dir.
#    Copy *.png only — never the *.png.bak-* backup cruft the draft dir accumulates.
mkdir -p "$DST_THUMBS"
cp "$SRC_THUMBS"/*.png "$DST_THUMBS"/

# 3) Guardrails — fail loudly rather than ship broken images (the OPS-61 failure mode).
if grep -qE '(^|[^-])thumbs/' "$DST_HTML"; then
  echo "ERROR: un-repointed 'thumbs/' still in $DST_HTML" >&2; exit 1
fi
missing=0
while IFS= read -r img; do
  [[ -f "public/$img" ]] || { echo "  MISSING: public/$img" >&2; missing=1; }
done < <(grep -oE '3d-thumbs/[A-Za-z0-9_.-]+\.png' "$DST_HTML" | sort -u)
[[ $missing -eq 0 ]] || { echo "ERROR: referenced thumbnails missing — would ship broken images." >&2; exit 1; }

echo "✓ 3D catalogue deployed → $DST_HTML  (+$(find "$DST_THUMBS" -type f | wc -l | tr -d ' ') thumbs, paths repointed & verified)"
echo "  next: git add $DST_HTML $DST_THUMBS && git commit -m 'chore: refresh 3D catalogue' && git push"
