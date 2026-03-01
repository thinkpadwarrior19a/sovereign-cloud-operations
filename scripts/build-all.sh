#!/usr/bin/env bash
# build-all.sh — Build all Sovereign Cloud Operations assets
# Usage: bash scripts/build-all.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

for build in pdf epub html; do
    echo "=== Building ${build} ==="
    if bash "${REPO_ROOT}/scripts/build-${build}.sh"; then
        echo "=== ${build} complete ==="
    else
        echo "=== ${build} FAILED ==="
        FAILED=1
    fi
    echo
done

echo "=== Building artefacts ==="
if bash "${REPO_ROOT}/artefacts/build-artefacts.sh"; then
    echo "=== artefacts complete ==="
else
    echo "=== artefacts FAILED ==="
    FAILED=1
fi
echo

if [ "${FAILED}" -eq 1 ]; then
    echo "Some builds failed — check output above."
    exit 1
fi

echo "All builds complete."
echo ""
echo "Releases:"
ls -lh "${REPO_ROOT}/releases/" 2>/dev/null
