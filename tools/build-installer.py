#!/usr/bin/env python3
"""Northsaga — build the self-extracting installer.

    cd tools && python3 build-installer.py

Writes setup-northsaga.sh in the repo root: a single shell script that recreates
the whole site in a directory of your choosing. One quoted heredoc per text
file, then the binary assets base64-encoded in a footer.

Run it last, after build-work-pages.py and build-journal.py, or the installer
ships an older copy of the generated pages than the tree does.

Verify it with:

    ./setup-northsaga.sh /tmp/check && diff -r . /tmp/check

Python 3 standard library only.
"""

import base64
import os
import stat

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "setup-northsaga.sh")

DELIM = "NSEOF"

# Directories never shipped.
SKIP_DIRS = {".git", "__pycache__", ".vercel", ".claude", ".DS_Store"}

# Files never shipped: the installer itself, and the paste-in block, which is
# generated output about generated output and belongs to whoever is editing.
SKIP_FILES = {"setup-northsaga.sh", ".DS_Store"}
SKIP_PATHS = {"tools/_homepage-list.html"}

BINARY_EXT = {".png"}


def collect():
    """Every shipped file, as (relative path, is_binary), in a stable order."""
    out = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for name in sorted(filenames):
            if name in SKIP_FILES:
                continue
            rel = os.path.relpath(os.path.join(dirpath, name), ROOT)
            if rel in SKIP_PATHS:
                continue
            ext = os.path.splitext(name)[1].lower()
            out.append((rel, ext in BINARY_EXT))
    return out


def main():
    files = collect()
    dirs = sorted({os.path.dirname(rel) for rel, _ in files if os.path.dirname(rel)})
    mkdirs = " ".join(f"'{d}'" for d in dirs)

    parts = [f"""#!/bin/sh
# =============================================================================
# NORTHSAGA — self-extracting installer
#
# GENERATED FILE — do not hand-edit. Source: the working tree.
# Rebuild it with: cd tools && python3 build-installer.py
#
#   ./setup-northsaga.sh [directory]     default: northsaga.ai
#
# Recreates the site exactly. No dependencies beyond a shell, openssl and
# python3 (python3 only if you want to regenerate the built pages afterwards).
# =============================================================================
set -e

DEST="${{1:-northsaga.ai}}"
mkdir -p "$DEST"
cd "$DEST"

nsbin() {{ openssl base64 -d -A > "$1"; }}

mkdir -p {mkdirs}
"""]

    text_files = [(r, b) for r, b in files if not b]
    bin_files = [(r, b) for r, b in files if b]

    for rel, _ in text_files:
        with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
            body = fh.read()
        if any(line.strip() == DELIM for line in body.splitlines()):
            raise SystemExit(
                f"{rel} contains a line equal to the heredoc delimiter {DELIM}. "
                f"Change the delimiter in tools/build-installer.py.")
        if not body.endswith("\n"):
            body += "\n"
        parts.append(f"\ncat > '{rel}' <<'{DELIM}'\n{body}{DELIM}\n")

    if bin_files:
        parts.append("\n# ---- binary assets: icons and the share card ----\n")
        for rel, _ in bin_files:
            with open(os.path.join(ROOT, rel), "rb") as fh:
                blob = base64.b64encode(fh.read()).decode("ascii")
            wrapped = "\n".join(blob[i:i + 76] for i in range(0, len(blob), 76))
            parts.append(f"\nnsbin '{rel}' <<'{DELIM}'\n{wrapped}\n{DELIM}\n")

    parts.append(f"""
chmod +x tools/*.py 2>/dev/null || true

echo "Northsaga installed into $DEST"
echo "  {len(text_files)} text files, {len(bin_files)} binary assets"
echo
echo "  cd $DEST && python3 -m http.server 8000"
""")

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("".join(parts))
    os.chmod(OUT, os.stat(OUT).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    size = os.path.getsize(OUT)
    print(f"wrote setup-northsaga.sh  "
          f"({len(text_files)} text, {len(bin_files)} binary, {size // 1024} KB)")
    print("verify with: ./setup-northsaga.sh /tmp/check && diff -r . /tmp/check")


if __name__ == "__main__":
    main()
