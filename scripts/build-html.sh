#!/usr/bin/env bash
# build-html.sh — Build the Sovereign Cloud Operations HTML site
# Usage: bash scripts/build-html.sh [output-dir]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-${REPO_ROOT}/_site}"

# Collect chapters in sorted order (skip backmatter which is LaTeX-only)
mapfile -t CHAPTERS < <(ls "${REPO_ROOT}/book/"*.md | grep -v '99_backmatter' | sort)

echo "Building HTML site from ${#CHAPTERS[@]} chapters..."

# Create output directories
mkdir -p "${OUT_DIR}/chapters"

# Copy images if they exist
if [ -d "${REPO_ROOT}/images" ]; then
    cp -r "${REPO_ROOT}/images" "${OUT_DIR}/images"
fi

# Copy stylesheet
cp "${REPO_ROOT}/config/site-style.css" "${OUT_DIR}/style.css"

# Build individual chapter pages
for chapter in "${CHAPTERS[@]}"; do
    basename=$(basename "${chapter}" .md)
    # Pre-process: rewrite image paths for chapters/ subdirectory
    sed 's|(images/|(../images/|g' "${chapter}" > "${OUT_DIR}/chapters/_tmp_${basename}.md"
    pandoc \
      "${OUT_DIR}/chapters/_tmp_${basename}.md" \
      --to=html5 \
      --standalone \
      --css=../style.css \
      --template="${REPO_ROOT}/config/html-template.html" \
      --resource-path="${REPO_ROOT}" \
      --metadata=lang:en-GB \
      --metadata title-prefix="Sovereign Cloud Operations" \
      --output="${OUT_DIR}/chapters/${basename}.html"
    rm -f "${OUT_DIR}/chapters/_tmp_${basename}.md"
done

# Extract chapter titles and build the index page
INDEX_BODY=""
INDEX_BODY+="<section class=\"book-hero\">"
INDEX_BODY+="<h1>Sovereign Cloud Operations</h1>"
INDEX_BODY+="<p class=\"subtitle\">Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise</p>"
INDEX_BODY+="<p class=\"author\">Alan Hamilton</p>"
INDEX_BODY+="</section>"
INDEX_BODY+="<nav class=\"chapter-list\"><h2>Contents</h2><ol>"

for chapter in "${CHAPTERS[@]}"; do
    basename=$(basename "${chapter}" .md)
    # Extract the first H1 heading as the chapter title
    title=$(grep -m1 '^# ' "${chapter}" | sed 's/^# //' || true)
    if [ -z "${title}" ]; then
        title="${basename}"
    fi
    INDEX_BODY+="<li><a href=\"chapters/${basename}.html\">${title}</a></li>"
done

INDEX_BODY+="</ol></nav>"

# Write index.html
cat > "${OUT_DIR}/index.html" <<HTMLEOF
<!DOCTYPE html>
<html lang="en-GB">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="author" content="Alan Hamilton">
  <meta name="description" content="Agentic AI, Observability, and Automation for the Fully Sovereign, Multi-Cloud Enterprise">
  <title>Sovereign Cloud Operations</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header id="site-header">
    <div class="header-inner">
      <a href="./" class="site-title">Sovereign Cloud Operations</a>
      <nav>
        <a href="./">Home</a>
      </nav>
    </div>
  </header>

  <main>
    <article>
${INDEX_BODY}
    </article>
  </main>

  <footer>
    <p>&copy; 2026 Alan Hamilton. Licensed under
    <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/">CC BY-NC-SA 4.0</a>.</p>
  </footer>
</body>
</html>
HTMLEOF

echo "Built HTML site: ${OUT_DIR}/"
echo "  Index:    ${OUT_DIR}/index.html"
echo "  Chapters: ${OUT_DIR}/chapters/"
