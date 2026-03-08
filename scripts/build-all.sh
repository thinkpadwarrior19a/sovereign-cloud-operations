#!/usr/bin/env bash
# build-all.sh — Build DOCX, ePub, and PDF from Sovereign Cloud Operations
# Usage: bash scripts/build-all.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/output"
mkdir -p "${OUT_DIR}"

# Add tools to PATH
export PATH="/c/Users/hamil/AppData/Local/Pandoc:/c/Users/hamil/AppData/Local/Programs/MiKTeX/miktex/bin/x64:${PATH}"

# Collect chapter files in order (skip backmatter for non-PDF builds)
mapfile -t ALL_CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | sort)
mapfile -t CHAPTERS_NO_BACKMATTER < <(ls "${REPO_ROOT}/book/"*.md | grep -v '99_backmatter' | sort)

echo "========================================="
echo "  Sovereign Cloud Operations — Full Build"
echo "========================================="
echo "Found ${#ALL_CHAPTERS[@]} source files"
echo ""

# ─────────────────────────────────────────────
# 1. DOCX Build
# ─────────────────────────────────────────────
echo "[1/3] Building DOCX..."
pandoc \
  "${CHAPTERS_NO_BACKMATTER[@]}" \
  --metadata-file="${REPO_ROOT}/config/metadata-docx.yaml" \
  --metadata title="Sovereign Cloud Operations" \
  --metadata subtitle="Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise" \
  --reference-doc="${REPO_ROOT}/config/reference.docx" \
  --lua-filter="${REPO_ROOT}/config/docx-enhancements.lua" \
  --from=markdown+autolink_bare_uris \
  --to=docx \
  --standalone \
  --resource-path="${REPO_ROOT}/book:${REPO_ROOT}" \
  --toc --toc-depth=2 \
  --output="${OUT_DIR}/Sovereign-Cloud-Operations.docx"
echo "  -> ${OUT_DIR}/Sovereign-Cloud-Operations.docx"

# ─────────────────────────────────────────────
# 2. ePub Build
# ─────────────────────────────────────────────
echo "[2/3] Building ePub..."
pandoc \
  "${CHAPTERS_NO_BACKMATTER[@]}" \
  --metadata-file="${REPO_ROOT}/config/metadata-epub.yaml" \
  --metadata title="Sovereign Cloud Operations" \
  --metadata subtitle="Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise" \
  --lua-filter="${REPO_ROOT}/config/epub-enhancements.lua" \
  --css="${REPO_ROOT}/config/epub-style.css" \
  --from=markdown+autolink_bare_uris \
  --to=epub3 \
  --standalone \
  --resource-path="${REPO_ROOT}/book:${REPO_ROOT}" \
  --toc --toc-depth=2 \
  --split-level=1 \
  --output="${OUT_DIR}/Sovereign-Cloud-Operations.epub"
echo "  -> ${OUT_DIR}/Sovereign-Cloud-Operations.epub"

# ─────────────────────────────────────────────
# 3. PDF Build (via XeLaTeX)
# ─────────────────────────────────────────────
echo "[3/3] Building PDF (this may take a few minutes)..."
pandoc \
  "${ALL_CHAPTERS[@]}" \
  --metadata-file="${REPO_ROOT}/config/metadata-pdf.yaml" \
  --metadata title="Sovereign Cloud Operations" \
  --metadata subtitle="Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise" \
  --lua-filter="${REPO_ROOT}/config/index-filter.lua" \
  --include-in-header="${REPO_ROOT}/config/pdf-preamble.tex" \
  --from=markdown+autolink_bare_uris \
  --to=latex \
  --standalone \
  --pdf-engine=xelatex \
  --resource-path="${REPO_ROOT}/book:${REPO_ROOT}" \
  --output="${OUT_DIR}/Sovereign-Cloud-Operations.pdf"
echo "  -> ${OUT_DIR}/Sovereign-Cloud-Operations.pdf"

echo ""
echo "========================================="
echo "  Build complete!"
echo "========================================="
echo "  DOCX: ${OUT_DIR}/Sovereign-Cloud-Operations.docx"
echo "  ePub: ${OUT_DIR}/Sovereign-Cloud-Operations.epub"
echo "  PDF:  ${OUT_DIR}/Sovereign-Cloud-Operations.pdf"
echo "========================================="
