#!/usr/bin/env bash
# build-artefacts.sh — Build ePub versions of derivative artefacts
# Usage: bash artefacts/build-artefacts.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTEFACTS_DIR="${REPO_ROOT}/artefacts"
CSS="${ARTEFACTS_DIR}/artefact.css"
BUILD_DIR="${REPO_ROOT}/.build/artefacts"

mkdir -p "${BUILD_DIR}"

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
  --output="${BUILD_DIR}/executive-abridged.epub"
echo "  Built: ${BUILD_DIR}/executive-abridged.epub"

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
  --output="${BUILD_DIR}/sales-play-guide.epub"
echo "  Built: ${BUILD_DIR}/sales-play-guide.epub"

echo ""
echo "=== All artefacts built ==="
echo ""
ls -lh "${BUILD_DIR}"/*.epub
