"""Northsaga — the glyphs that sit in the corner of a schematic node.

Each entry is a list of (path data, kind) drawn on a 24 x 24 grid, in paint
order. Three kinds:

    'fill'  solid, in --bone-dim
    'cut'   solid, in --ink-raised, the box's own fill — punches a hole
    'line'  stroked, round caps, for things that are naturally a line

The renderer scales the grid to ICON_SIZE and translates it into place, so a
glyph never needs to know where it ends up.

**These are drawn here, not copied.** They are simplified marks that identify a
product by silhouette — a grid for a spreadsheet, a bubble and handset for
WhatsApp — rather than reproductions of anyone's trademarked artwork. They are
deliberately monochrome: BRAND.md allows one accent and brass is it, so a wall
of vendor colours would be a second palette arriving through the back door.
Keep them that way, and keep them simple: the drawing scrolls and zooms, and a
glyph has to survive being rendered at six pixels.

Python 3 standard library only.
"""

ICON_SIZE = 18          # rendered size in schematic units
ICON_GRID = 24          # the grid every path below is drawn on

ICONS = {
    # ---- telephony and messaging ----
    "phone": [
        ("M7.6 2.6 4.2 6a2 2 0 0 0-.4 2.3 26 26 0 0 0 11.9 11.9 2 2 0 0 0 "
         "2.3-.4l3.4-3.4a1 1 0 0 0 0-1.4l-3.6-3.6a1 1 0 0 0-1.4 0l-1.7 1.7a19 "
         "19 0 0 1-4.5-4.5l1.7-1.7a1 1 0 0 0 0-1.4L9 2.6a1 1 0 0 0-1.4 0Z",
         "fill"),
    ],

    "mobile": [
        ("M7 2h10a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4a2 2 0 0 1 "
         "2-2Z", "fill"),
        ("M6.8 5.6h10.4v11.8H6.8Z", "cut"),
    ],

    # Bubble with a tail, handset punched out of it.
    "whatsapp": [
        ("M12 2a10 10 0 0 0-8.7 15L2 22l5.2-1.3A10 10 0 1 0 12 2Z", "fill"),
        ("M8.9 7.5c-.2-.4-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.4-.3.3-.9.8-.9 2s.9 "
         "2.4 1 2.6c.1.2 1.7 2.7 4.2 3.7 2 .9 2.5.7 2.9.7.5 0 1.4-.6 1.6-1.2"
         ".2-.6.2-1.1.1-1.2 0-.1-.2-.2-.5-.3l-1.7-.8c-.2-.1-.4-.1-.6.1l-.7 1"
         "c-.1.2-.3.2-.5.1-.2-.1-1-.4-1.9-1.2-.7-.6-1.2-1.4-1.3-1.6-.1-.2 0-"
         ".4.1-.5l.4-.5c.1-.1.2-.3.2-.4 0-.2 0-.3-.1-.4l-.6-1.9Z", "cut"),
    ],

    "message": [
        ("M3 4h18v13H8l-5 4Z", "fill"),
        ("M7.6 9.3h2.2v2.2H7.6Z", "cut"),
        ("M10.9 9.3h2.2v2.2h-2.2Z", "cut"),
        ("M14.2 9.3h2.2v2.2h-2.2Z", "cut"),
    ],

    "mail": [
        ("M2 4.6h20v14.8H2Z", "fill"),
        ("M3.6 6.6 12 12.6l8.4-6v2L12 14.6 3.6 8.6Z", "cut"),
    ],

    "mic": [
        ("M12 2a3.2 3.2 0 0 0-3.2 3.2v6.4a3.2 3.2 0 0 0 6.4 0V5.2A3.2 3.2 0 0 "
         "0 12 2Z", "fill"),
        ("M5.4 10.4H3.6a8.4 8.4 0 0 0 7.4 8.3V22h2v-3.3a8.4 8.4 0 0 0 7.4-8.3"
         "h-1.8a6.6 6.6 0 0 1-13.2 0Z", "fill"),
    ],

    "bell": [
        ("M12 2a5.6 5.6 0 0 0-5.6 5.6v3.6L4 15.4v1.4h16v-1.4l-2.4-4.2V7.6A5.6 "
         "5.6 0 0 0 12 2Z", "fill"),
        ("M9.4 18.4a2.6 2.6 0 0 0 5.2 0Z", "fill"),
    ],

    "reply": [
        ("M10 5.4 2.4 12l7.6 6.6V14c5 0 8.4 1.6 10.6 5-.9-4.7-3.7-9.3-10.6-10Z",
         "fill"),
    ],

    # ---- documents and data ----
    "sheets": [
        ("M5 2h9l5 5v15H5Z", "fill"),
        ("M7.4 11h9.2v1.5H7.4Z", "cut"),
        ("M7.4 14.2h9.2v1.5H7.4Z", "cut"),
        ("M7.4 17.4h9.2v1.5H7.4Z", "cut"),
        ("M11.3 10.4h1.5v9.2h-1.5Z", "cut"),
    ],

    "doc": [
        ("M5 2h9l5 5v15H5Z", "fill"),
        ("M7.6 11h8.8v1.5H7.6Z", "cut"),
        ("M7.6 14.2h8.8v1.5H7.6Z", "cut"),
        ("M7.6 17.4h5.4v1.5H7.6Z", "cut"),
    ],

    "database": [
        ("M12 2c-4.4 0-8 1.3-8 3v14c0 1.7 3.6 3 8 3s8-1.3 8-3V5c0-1.7-3.6-3-8-3Z",
         "fill"),
        ("M4 8.2c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3"
         "-.6-8-1.6Z", "cut"),
        ("M4 13.4c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3"
         "-.6-8-1.6Z", "cut"),
    ],

    # ---- the box it all runs in ----
    "server": [
        ("M2.6 4h18.8v6.4H2.6Z", "fill"),
        ("M2.6 13.6h18.8V20H2.6Z", "fill"),
        ("M5.2 6.4h2v1.6h-2Z", "cut"),
        ("M5.2 16h2v1.6h-2Z", "cut"),
        ("M8.6 6.4h6v1.6h-6Z", "cut"),
        ("M8.6 16h6v1.6h-6Z", "cut"),
    ],

    "docker": [
        ("M3.2 10.6h3.4V14H3.2Z", "fill"),
        ("M7.3 10.6h3.4V14H7.3Z", "fill"),
        ("M11.4 10.6h3.4V14h-3.4Z", "fill"),
        ("M7.3 6.7h3.4v3.4H7.3Z", "fill"),
        ("M11.4 6.7h3.4v3.4h-3.4Z", "fill"),
        ("M11.4 2.8h3.4v3.4h-3.4Z", "fill"),
        ("M1.8 15.2h20.4c-.9 3.6-4.6 5.8-9.6 5.8-5.6 0-9.4-2-10.8-5.8Z", "fill"),
    ],

    "n8n": [
        ("M3.4 12a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z", "fill"),
        ("M15.2 6.6a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z", "fill"),
        ("M15.2 17.4a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z", "fill"),
        ("M6.1 12 17.9 6.6", "line"),
        ("M6.1 12 17.9 17.4", "line"),
    ],

    # Python's own mark is two interlocking bodies and does not survive being
    # drawn at six pixels. A pair of chevrons says "code" and stays honest.
    "code": [
        ("M9.2 4.6 3 12l6.2 7.4 1.7-1.4L5.8 12l5.1-6Z", "fill"),
        ("M14.8 4.6 21 12l-6.2 7.4-1.7-1.4L18.2 12l-5.1-6Z", "fill"),
    ],

    "clock": [
        ("M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z", "fill"),
        ("M12 4.4a7.6 7.6 0 1 1 0 15.2 7.6 7.6 0 0 1 0-15.2Z", "cut"),
        ("M11.2 6.4h1.6v6.4h-1.6Z", "fill"),
        ("M11.2 11.2h5v1.6h-5Z", "fill"),
    ],

    "wrench": [
        ("M20.7 4.6a5.6 5.6 0 0 1-7 7l-7.3 7.3a2.2 2.2 0 1 1-3.1-3.1l7.3-7.3a5.6 "
         "5.6 0 0 1 7-7l-3.3 3.3.9 3.2 3.2.9Z", "fill"),
    ],

    "pulse": [
        ("M2 12h4.6l2.4-5.8 3.5 11.6 2.4-6.4 1.5 2.6H22", "line"),
    ],
}


def render(name, x, y):
    """One glyph, translated to (x, y) and scaled to ICON_SIZE."""
    paths = ICONS.get(name)
    if paths is None:
        raise SystemExit(f"unknown schematic icon {name!r}. "
                         f"Add it to tools/icons.py or fix the node.")

    scale = ICON_SIZE / ICON_GRID
    out = [f'<g class="sch-icon-g" transform="translate({x} {y}) '
           f'scale({scale:.6g})">']
    for d, kind in paths:
        out.append(f'<path class="sch-icon--{kind}" d="{d}"/>')
    out.append("</g>")
    return "".join(out)
