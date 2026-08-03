#!/usr/bin/env python3
"""Generate the Northsaga QR as static SVG — carved/runic treatment.

STATUS: the output of this script DOES NOT CURRENTLY DECODE. See the warning at
the top of assets/qr/northsaga-ai.svg before using it for anything.

NOT part of any build. The site is static HTML/CSS/vanilla JS with no build step
and no dependencies (CLAUDE.md), and that is unchanged: this is a one-off
authoring tool, run by hand, whose output is committed as a static asset. Nothing
the site serves depends on Python or on segno.

    pip install segno --break-system-packages
    python3 tools/make-qr.py

To verify a change, also: pip install zxing-cpp cairosvg --break-system-packages
Render to PNG and decode at 1200/600/400/300/200/150/120/100px, in BOTH colour
orientations (bone-on-ink is an INVERTED code — not all scanners handle it) and
at 0/90/180/270 degrees. Real print size is ~17mm at 300dpi = 201px.

Why this is safe to stylise: a QR decoder samples the CENTRE of each module.
Anything that leaves the middle ~50% of a dark module dark, and adds nothing
to the middle of a light module, still decodes. So we chamfer corners (never
reshape or shrink past centre) and merge orthogonally adjacent modules into
continuous staves — which is what gives the carved, rune-stone reading.

Finder patterns are drawn as clean concentric squares: they are what the
decoder locks onto first, so they get no stylisation at all.
"""
import segno

URL = "https://northsaga.ai"
CHAMFER = 0.26        # of one module; keeps the central 48% untouched
QUIET = 4             # modules — QR spec minimum

qr = segno.make(URL, error="H")
m = [[bool(v) for v in row] for row in qr.matrix]
n = len(m)

# --- finder patterns: top-left, top-right, bottom-left ----------------------
finders = [(0, 0), (0, n - 7), (n - 7, 0)]

def in_finder(r, c):
    return any(fr <= r < fr + 7 and fc <= c < fc + 7 for fr, fc in finders)

def octagon(x0, y0, x1, y1, k):
    """Rect with all four corners chamfered — a chisel-ended stave."""
    return (f"M{x0 + k:.4g} {y0:.4g}"
            f"H{x1 - k:.4g}L{x1:.4g} {y0 + k:.4g}"
            f"V{y1 - k:.4g}L{x1 - k:.4g} {y1:.4g}"
            f"H{x0 + k:.4g}L{x0:.4g} {y1 - k:.4g}"
            f"V{y0 + k:.4g}Z")

def rect(x0, y0, x1, y1):
    return f"M{x0:.4g} {y0:.4g}H{x1:.4g}V{y1:.4g}H{x0:.4g}Z"

parts = []

# Finder patterns — exact squares, no chamfer. Outer 7x7 ring + 3x3 core.
for fr, fc in finders:
    # 7x7 dark ring, 5x5 light, 3x3 SOLID dark centre. Three subpaths under
    # evenodd: fill, cut, fill. A fourth would punch a hole in the centre and
    # the decoder would never lock on.
    parts.append(rect(fc, fr, fc + 7, fr + 7))
    parts.append(rect(fc + 1, fr + 1, fc + 6, fr + 6))
    parts.append(rect(fc + 2, fr + 2, fc + 5, fr + 5))

# --- data modules: merge runs both ways, chamfer the ends ------------------
# Horizontal runs
for r in range(n):
    c = 0
    while c < n:
        if m[r][c] and not in_finder(r, c):
            c0 = c
            while c < n and m[r][c] and not in_finder(r, c):
                c += 1
            parts.append(octagon(c0, r, c, r + 1, CHAMFER))
        else:
            c += 1

# Vertical runs (length >= 2 only — singles are already drawn above, and
# overlaying them again would just repaint the same octagon)
for c in range(n):
    r = 0
    while r < n:
        if m[r][c] and not in_finder(r, c):
            r0 = r
            while r < n and m[r][c] and not in_finder(r, c):
                r += 1
            if r - r0 >= 2:
                parts.append(octagon(c, r0, c + 1, r, CHAMFER))
        else:
            r += 1

d = "".join(parts)
size = n + 2 * QUIET
vb = f"{-QUIET} {-QUIET} {size} {size}"

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}"
     role="img" aria-label="northsaga.ai">
  <title>northsaga.ai</title>
  <path fill="currentColor" fill-rule="evenodd" d="{d}"/>
</svg>
'''

open("/home/user/northsaga.ai/assets/qr/northsaga-ai.svg", "w").write(svg)
print(f"modules {n}x{n} + {QUIET} quiet | viewBox {vb} | path {len(d)} chars")
print("written assets/qr/northsaga-ai.svg")
