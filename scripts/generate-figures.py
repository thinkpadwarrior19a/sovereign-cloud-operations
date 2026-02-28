#!/usr/bin/env python3
"""
generate-figures.py — Generate all book figures via napkin.ai API

Usage:
    python3 scripts/generate-figures.py              # Generate all missing figures
    python3 scripts/generate-figures.py --dry-run    # List figures without generating
    python3 scripts/generate-figures.py --status     # Check status of pending requests
    python3 scripts/generate-figures.py --replace    # Replace placeholders in markdown files
"""

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    import requests
except ImportError:
    print("Installing requests...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    import requests

# Configuration
API_BASE = "https://api.napkin.ai/v1/visual"
API_KEY = os.environ.get("NAPKIN_API_KEY", "sk-d809787ffd9812d4c155fdb406cfaeb1dca2dc731f6d23b7c0ffe471154182ad")
REPO_ROOT = Path(__file__).resolve().parent.parent
BOOK_DIR = REPO_ROOT / "book"
IMAGES_DIR = REPO_ROOT / "images"
STATE_FILE = REPO_ROOT / ".build" / "figure-state.json"

HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json",
}

# Standard style prompt prefix for consistent look
STYLE_PREFIX = (
    "Create a clean, professional technical diagram with a formal, muted colour palette "
    "(navy, slate grey, teal, white backgrounds). Use clear labels, straight connecting lines, "
    "and a structured layout suitable for a professional technical book. "
    "The diagram should illustrate: "
)

# Regex to match figure placeholders
FIGURE_RE = re.compile(
    r'> \*\*\[FIGURE (\d+)\.(\d+)\s*[—–-]\s*(.+?)\]\*\*'
)


def scan_figures():
    """Scan all chapter files for figure placeholders."""
    figures = []
    for md_file in sorted(BOOK_DIR.glob("*.md")):
        with open(md_file, "r") as f:
            for line_num, line in enumerate(f, 1):
                m = FIGURE_RE.search(line)
                if m:
                    chapter = int(m.group(1))
                    fig_num = int(m.group(2))
                    description = m.group(3).rstrip()
                    fig_id = f"figure-{chapter}-{fig_num}"
                    figures.append({
                        "id": fig_id,
                        "chapter": chapter,
                        "figure": fig_num,
                        "description": description,
                        "file": str(md_file.relative_to(REPO_ROOT)),
                        "line": line_num,
                        "image_path": f"images/{fig_id}.png",
                    })
    return figures


def load_state():
    """Load generation state from disk."""
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            return json.load(f)
    return {}


def save_state(state):
    """Save generation state to disk."""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)


def submit_figure(fig, state):
    """Submit a figure generation request to napkin.ai."""
    fig_id = fig["id"]

    # Skip if already completed
    if fig_id in state and state[fig_id].get("status") == "completed":
        img_path = IMAGES_DIR / f"{fig_id}.png"
        if img_path.exists():
            return fig_id, "already_done"

    # Skip if pending (already submitted)
    if fig_id in state and state[fig_id].get("status") == "pending":
        return fig_id, "already_pending"

    content = STYLE_PREFIX + fig["description"]

    try:
        resp = requests.post(
            API_BASE,
            headers=HEADERS,
            json={"format": "png", "content": content},
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()
        state[fig_id] = {
            "request_id": data["id"],
            "status": "pending",
            "description": fig["description"],
            "submitted_at": time.time(),
        }
        save_state(state)
        return fig_id, "submitted"
    except Exception as e:
        return fig_id, f"error: {e}"


def check_status(request_id):
    """Check the status of a napkin.ai request."""
    try:
        resp = requests.get(
            f"{API_BASE}/{request_id}/status",
            headers=HEADERS,
            timeout=30,
        )
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        return {"status": "error", "error": str(e)}


def download_figure(fig_id, url):
    """Download a generated figure."""
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    img_path = IMAGES_DIR / f"{fig_id}.png"
    try:
        resp = requests.get(url, headers=HEADERS, timeout=60)
        resp.raise_for_status()
        with open(img_path, "wb") as f:
            f.write(resp.content)
        return True, img_path
    except Exception as e:
        return False, str(e)


def poll_and_download(state, max_wait=600):
    """Poll pending requests and download completed figures."""
    pending = {
        fig_id: info for fig_id, info in state.items()
        if info.get("status") == "pending"
    }

    if not pending:
        print("No pending requests to poll.")
        return

    print(f"Polling {len(pending)} pending requests...")
    start_time = time.time()

    while pending and (time.time() - start_time) < max_wait:
        for fig_id, info in list(pending.items()):
            result = check_status(info["request_id"])

            if result.get("status") == "completed":
                files = result.get("generated_files", [])
                if files:
                    url = files[0]["url"]
                    ok, path = download_figure(fig_id, url)
                    if ok:
                        state[fig_id]["status"] = "completed"
                        state[fig_id]["image_path"] = str(path)
                        print(f"  Downloaded: {fig_id}")
                    else:
                        state[fig_id]["status"] = "download_error"
                        state[fig_id]["error"] = str(path)
                        print(f"  Download failed: {fig_id}: {path}")
                else:
                    state[fig_id]["status"] = "no_files"
                    print(f"  No files: {fig_id}")
                del pending[fig_id]
                save_state(state)

            elif result.get("status") == "error":
                state[fig_id]["status"] = "error"
                state[fig_id]["error"] = result.get("error", "unknown")
                del pending[fig_id]
                save_state(state)
                print(f"  Error: {fig_id}: {result.get('error')}")

        if pending:
            remaining = len(pending)
            elapsed = int(time.time() - start_time)
            print(f"  Waiting... {remaining} pending, {elapsed}s elapsed")
            time.sleep(5)

    if pending:
        print(f"\nTimed out with {len(pending)} requests still pending.")


def replace_placeholders(figures, state):
    """Replace figure placeholders in markdown files with image references."""
    replacements = {}
    for fig in figures:
        fig_id = fig["id"]
        if fig_id in state and state[fig_id].get("status") == "completed":
            img_path = IMAGES_DIR / f"{fig_id}.png"
            if img_path.exists():
                if fig["file"] not in replacements:
                    replacements[fig["file"]] = []
                replacements[fig["file"]].append(fig)

    if not replacements:
        print("No completed figures to replace.")
        return

    for filepath, figs in replacements.items():
        full_path = REPO_ROOT / filepath
        with open(full_path, "r") as f:
            content = f.read()

        for fig in figs:
            fig_id = fig["id"]
            old_pattern = re.compile(
                r'> \*\*\[FIGURE ' + re.escape(f"{fig['chapter']}.{fig['figure']}") +
                r'\s*[—–-]\s*' + re.escape(fig["description"]) + r'\]\*\*'
            )
            caption = f"Figure {fig['chapter']}.{fig['figure']} — {fig['description']}"
            new_text = f"![{caption}]({fig['image_path']})"
            content, count = old_pattern.subn(new_text, content)
            if count > 0:
                print(f"  Replaced: {fig_id} in {filepath}")

        with open(full_path, "w") as f:
            f.write(content)


def main():
    parser = argparse.ArgumentParser(description="Generate book figures via napkin.ai")
    parser.add_argument("--dry-run", action="store_true", help="List figures without generating")
    parser.add_argument("--status", action="store_true", help="Check status of pending requests")
    parser.add_argument("--replace", action="store_true", help="Replace placeholders with images")
    parser.add_argument("--batch-size", type=int, default=10, help="Figures per batch (default: 10)")
    parser.add_argument("--batch-delay", type=float, default=2.0, help="Seconds between batches")
    parser.add_argument("--poll-timeout", type=int, default=600, help="Max seconds to poll (default: 600)")
    args = parser.parse_args()

    figures = scan_figures()
    print(f"Found {len(figures)} figure placeholders across {len(set(f['file'] for f in figures))} files.")

    if args.dry_run:
        for fig in figures:
            img = IMAGES_DIR / f"{fig['id']}.png"
            status = "EXISTS" if img.exists() else "MISSING"
            print(f"  [{status}] {fig['id']}: {fig['description'][:80]}...")
        return

    state = load_state()

    if args.status:
        pending = sum(1 for v in state.values() if v.get("status") == "pending")
        completed = sum(1 for v in state.values() if v.get("status") == "completed")
        errors = sum(1 for v in state.values() if "error" in v.get("status", ""))
        print(f"  Pending: {pending}, Completed: {completed}, Errors: {errors}")
        if pending > 0:
            poll_and_download(state, args.poll_timeout)
        return

    if args.replace:
        replace_placeholders(figures, state)
        return

    # Determine which figures need generating
    to_generate = []
    for fig in figures:
        fig_id = fig["id"]
        img_path = IMAGES_DIR / f"{fig_id}.png"
        if img_path.exists():
            continue
        if fig_id in state and state[fig_id].get("status") in ("completed", "pending"):
            continue
        to_generate.append(fig)

    if not to_generate:
        print("All figures already generated or pending.")
        # Poll any remaining pending
        poll_and_download(state, args.poll_timeout)
        return

    print(f"\nGenerating {len(to_generate)} figures in batches of {args.batch_size}...")
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)

    # Submit in batches
    for batch_start in range(0, len(to_generate), args.batch_size):
        batch = to_generate[batch_start:batch_start + args.batch_size]
        batch_num = batch_start // args.batch_size + 1
        total_batches = (len(to_generate) + args.batch_size - 1) // args.batch_size
        print(f"\nBatch {batch_num}/{total_batches} ({len(batch)} figures):")

        for fig in batch:
            fig_id, result = submit_figure(fig, state)
            print(f"  {fig_id}: {result}")
            time.sleep(0.5)  # Small delay between individual requests

        # Wait between batches
        if batch_start + args.batch_size < len(to_generate):
            print(f"  Waiting {args.batch_delay}s before next batch...")
            time.sleep(args.batch_delay)

    save_state(state)

    # Now poll for all pending and download
    print(f"\nAll requests submitted. Polling for completion...")
    poll_and_download(state, args.poll_timeout)

    # Summary
    completed = sum(1 for v in state.values() if v.get("status") == "completed")
    pending = sum(1 for v in state.values() if v.get("status") == "pending")
    errors = sum(1 for v in state.values() if "error" in v.get("status", ""))
    print(f"\nSummary: {completed} completed, {pending} pending, {errors} errors")


if __name__ == "__main__":
    main()
