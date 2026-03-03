#!/usr/bin/env bash
# build-html.sh — Build the Sovereign Cloud Operations HTML site
# Usage: bash scripts/build-html.sh [output-dir]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-${REPO_ROOT}/_site}"

# Collect chapters in sorted order
mapfile -t CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | sort)

echo "Building HTML site from ${#CHAPTERS[@]} chapters..."

# Create output directory
mkdir -p "${OUT_DIR}"

# Copy images if they exist
if [ -d "${REPO_ROOT}/images" ]; then
    cp -r "${REPO_ROOT}/images" "${OUT_DIR}/images"
fi

# Build single-page HTML (main reading experience)
pandoc \
  "${REPO_ROOT}/config/metadata.yaml" \
  "${CHAPTERS[@]}" \
  --to=html5 \
  --standalone \
  --toc \
  --toc-depth=2 \
  --metadata numbersections:false \
  --css=style.css \
  --template="${REPO_ROOT}/config/html-template.html" \
  --resource-path="${REPO_ROOT}" \
  --metadata=lang:en-GB \
  --output="${OUT_DIR}/index.html"

# Copy stylesheet
cp "${REPO_ROOT}/config/site-style.css" "${OUT_DIR}/style.css"

# Build individual chapter pages for deep-linking
mkdir -p "${OUT_DIR}/chapters"
for chapter in "${CHAPTERS[@]}"; do
    basename=$(basename "${chapter}" .md)
    pandoc \
      "${chapter}" \
      --to=html5 \
      --standalone \
      --css=../style.css \
      --template="${REPO_ROOT}/config/html-template.html" \
      --resource-path="${REPO_ROOT}" \
      --metadata=lang:en-GB \
      --metadata title-prefix="Sovereign Cloud Operations" \
      --output="${OUT_DIR}/chapters/${basename}.html"
done

echo "Built HTML site: ${OUT_DIR}/"
echo "  Single page: ${OUT_DIR}/index.html"
echo "  Chapters:    ${OUT_DIR}/chapters/"
