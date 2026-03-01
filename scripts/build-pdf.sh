#!/usr/bin/env bash
# build-pdf.sh — Build the Sovereign Cloud Operations PDF
# Usage: bash scripts/build-pdf.sh [output-file]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-sovereign-cloud-operations.pdf}"
TEX_DIR="${REPO_ROOT}/.build"
TEX_FILE="${TEX_DIR}/book.tex"

# Collect chapters in sorted order
mapfile -t CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | sort)

echo "Building PDF from ${#CHAPTERS[@]} chapters..."

# Create build directory
mkdir -p "${TEX_DIR}"

# Step 1: Pandoc generates .tex with the Lua index filter
pandoc \
  "${REPO_ROOT}/config/metadata.yaml" \
  "${CHAPTERS[@]}" \
  --pdf-engine=xelatex \
  --include-in-header="${REPO_ROOT}/config/latex-preamble.tex" \
  --include-before-body="${REPO_ROOT}/config/after-toc.tex" \
  --lua-filter="${REPO_ROOT}/config/index-filter.lua" \
  --highlight-style=tango \
  --toc \
  --toc-depth=2 \
  --output="${TEX_FILE}"

# Step 2: latexmk handles multi-pass compilation (xelatex + makeindex)
latexmk \
  -xelatex \
  -interaction=nonstopmode \
  -output-directory="${TEX_DIR}" \
  "${TEX_FILE}"

# Copy the final PDF to the repo root
cp "${TEX_DIR}/book.pdf" "${REPO_ROOT}/${OUT}"

echo "Built: ${REPO_ROOT}/${OUT}"
