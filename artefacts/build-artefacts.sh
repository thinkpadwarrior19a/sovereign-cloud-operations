#!/usr/bin/env bash
# build-artefacts.sh — Build derivative artefacts (ePub and PowerPoint)
# Usage: bash artefacts/build-artefacts.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTEFACTS_DIR="${REPO_ROOT}/artefacts"
CSS="${ARTEFACTS_DIR}/artefact.css"
RELEASES_DIR="${REPO_ROOT}/releases"
BUILD_DATE="$(date +%Y-%m-%d)"

mkdir -p "${RELEASES_DIR}"

echo "=== Building Sovereign Cloud Operations Artefacts ==="
echo ""

# --- Executive Abridged Edition ---
echo "Building: Executive Abridged Edition..."
pandoc \
  --metadata title="Sovereign Cloud Operations: Executive Abridged Edition" \
  --metadata subtitle="Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise" \
  --metadata author="Alan Hamilton" \
  --metadata rights="© 2026 Alan Hamilton. All rights reserved." \
  --metadata lang=en-GB \
  "${ARTEFACTS_DIR}/executive-abridged.md" \
  --to=epub3 \
  --split-level=1 \
  --css="${CSS}" \
  --toc \
  --toc-depth=2 \
  --output="${RELEASES_DIR}/executive-abridged-${BUILD_DATE}.epub"
echo "  Built: ${RELEASES_DIR}/executive-abridged-${BUILD_DATE}.epub"

# --- IBM Sales Play Guide ---
echo "Building: IBM Sales Play Guide..."
pandoc \
  --metadata title="Sovereign Cloud Operations: IBM Sales Play Guide" \
  --metadata subtitle="Positioning, Qualification, and Execution for IBM Sellers" \
  --metadata author="Alan Hamilton" \
  --metadata rights="© 2026 Alan Hamilton. IBM Internal Use Only." \
  --metadata lang=en-GB \
  "${ARTEFACTS_DIR}/sales-play-guide.md" \
  --to=epub3 \
  --split-level=1 \
  --css="${CSS}" \
  --toc \
  --toc-depth=2 \
  --output="${RELEASES_DIR}/sales-play-guide-${BUILD_DATE}.epub"
echo "  Built: ${RELEASES_DIR}/sales-play-guide-${BUILD_DATE}.epub"

# --- Internal Presentation (PowerPoint) ---
echo "Building: Internal Summary Presentation (PowerPoint)..."
pandoc \
  "${ARTEFACTS_DIR}/internal-presentation.md" \
  --to=pptx \
  --output="${RELEASES_DIR}/internal-presentation-${BUILD_DATE}.pptx"
echo "  Built: ${RELEASES_DIR}/internal-presentation-${BUILD_DATE}.pptx"

echo ""
echo "=== All artefacts built ==="
echo ""
ls -lh "${RELEASES_DIR}"/executive-abridged-*.epub "${RELEASES_DIR}"/sales-play-guide-*.epub "${RELEASES_DIR}"/internal-presentation-*.pptx 2>/dev/null
