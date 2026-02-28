#!/usr/bin/env bash
# build-pdf.sh — Build the Sovereign Cloud Operations PDF
# Usage: bash scripts/build-pdf.sh [output-file]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-sovereign-cloud-operations.pdf}"

# Collect chapters in sorted order
mapfile -t CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | sort)

echo "Building PDF from ${#CHAPTERS[@]} chapters..."

pandoc \
  "${REPO_ROOT}/config/metadata.yaml" \
  "${CHAPTERS[@]}" \
  --pdf-engine=xelatex \
  --include-in-header="${REPO_ROOT}/config/latex-preamble.tex" \
  --highlight-style=tango \
  --output="${REPO_ROOT}/${OUT}"

echo "Built: ${REPO_ROOT}/${OUT}"
