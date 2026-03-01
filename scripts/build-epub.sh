#!/usr/bin/env bash
# build-epub.sh — Build the Sovereign Cloud Operations ePub
# Usage: bash scripts/build-epub.sh [output-file]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-sovereign-cloud-operations.epub}"

# Collect chapters in sorted order
mapfile -t CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | sort)

echo "Building ePub from ${#CHAPTERS[@]} chapters..."

pandoc \
  "${REPO_ROOT}/config/epub-metadata.yaml" \
  "${CHAPTERS[@]}" \
  --to=epub3 \
  --split-level=1 \
  --css="${REPO_ROOT}/config/epub.css" \
  --toc \
  --toc-depth=2 \
  --resource-path="${REPO_ROOT}" \
  --output="${REPO_ROOT}/${OUT}"

echo "Built: ${REPO_ROOT}/${OUT}"
