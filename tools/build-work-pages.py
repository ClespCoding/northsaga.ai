#!/usr/bin/env python3
"""Northsaga — workflow page generator.

    cd tools && python3 build-work-pages.py

Every workflow page's copy, stages, parts list, build order, prices and
schematic lives in the PAGES list below. work/*.html is generated output — do
not hand-edit it; edit the dictionary and re-run.

Also writes tools/_homepage-list.html, the block to paste into .install-list in
index.html if the list of workflows changes.

Python 3 standard library only. No dependencies, no build step.
"""

import html
import os

import chrome

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


# ==========================================================================
# THE SCHEMATIC RENDERER
#
# Boxes in brand colours, orthogonal brass connectors. Columns run left to
# right and each column is centred vertically against the tallest one.
#
#   'nodes': {
#     'a': (0, 0, 'Trigger', 'Inbound call|to your number'),
#     'b': (1, 0, 'Routing', 'Rings your mobile|for twenty seconds', 'webhook'),
#   }
#   'edges': [('a','b'), ('b','c'), ('c','a','dash')]
#
# A node is (column, row, ROLE, 'line 1|line 2') or the same with a fifth
# element, 'cron' or 'webhook', printed as a small brass label in the box's
# top-right corner. Both lengths are accepted so older four-element nodes keep
# working. Two label lines maximum, roughly 26 characters a line.
#
# 'dash' marks a feedback loop. An edge that runs right to left is routed in a
# lane underneath the drawing rather than back through the boxes.
#
# No colours, icons, gradients or rounded corners. Every fill and stroke is a
# CSS class styled in css/work.css, so no value is hard-coded here.
# ==========================================================================

BOX_W, BOX_H = 196, 88
COL_GAP, ROW_GAP = 66, 30
MARGIN = 10
LOOP_LANE = 40
ARROW = 7


def _arrow(x, y, direction):
    """A small filled triangle with its tip at (x, y)."""
    s, w = ARROW, ARROW * 0.62
    if direction == "right":
        d = f"M {x} {y} L {x - s} {y - w} L {x - s} {y + w} Z"
    elif direction == "down":
        d = f"M {x} {y} L {x - w} {y - s} L {x + w} {y - s} Z"
    else:  # up
        d = f"M {x} {y} L {x - w} {y + s} L {x + w} {y + s} Z"
    return f'<path class="sch-arrow" d="{d}"/>'


def schematic(spec, number, caption):
    """Render one drawing. Returns a <figure> block."""
    nodes, edges = spec["nodes"], spec["edges"]

    n = {}
    for key, tup in nodes.items():
        n[key] = {
            "col": tup[0],
            "row": tup[1],
            "role": tup[2],
            "label": tup[3],
            "trigger": tup[4] if len(tup) > 4 else None,
        }

    columns = {}
    for key, node in n.items():
        columns.setdefault(node["col"], []).append(key)

    def row_y(row):
        return row * (BOX_H + ROW_GAP)

    extents = {}
    for col, keys in columns.items():
        tops = [row_y(n[k]["row"]) for k in keys]
        extents[col] = (min(tops), max(tops) + BOX_H)
    tallest = max(bottom - top for top, bottom in extents.values())

    for col, keys in columns.items():
        top, bottom = extents[col]
        offset = (tallest - (bottom - top)) / 2 - top
        for k in keys:
            n[k]["x"] = round(n[k]["col"] * (BOX_W + COL_GAP)) + MARGIN
            n[k]["y"] = round(row_y(n[k]["row"]) + offset) + MARGIN

    has_loop = any(n[e[1]]["col"] < n[e[0]]["col"] for e in edges)
    width = max(node["x"] for node in n.values()) + BOX_W + MARGIN
    height = tallest + MARGIN * 2 + (LOOP_LANE if has_loop else 0)
    lane_y = tallest + MARGIN + LOOP_LANE // 2

    # ---- connectors, drawn first so the boxes sit on top ----
    #
    # Elbows between the same pair of columns are given their own vertical lane,
    # keyed on the source node. Edges leaving one node share a lane, so a
    # fan-out reads as one trunk splitting; edges leaving different nodes get
    # their own, so two of them can never lie on top of each other and be
    # mistaken for a single wire.
    lanes = {}
    for edge in edges:
        a, b = n[edge[0]], n[edge[1]]
        if b["col"] > a["col"] and a["y"] != b["y"]:
            lanes.setdefault(a["col"], [])
            if edge[0] not in lanes[a["col"]]:
                lanes[a["col"]].append(edge[0])

    def lane_offset(col, source):
        keys = lanes.get(col, [])
        if len(keys) < 2:
            return 0
        step = min(14, (COL_GAP // 2 - 8) * 2 // (len(keys) - 1))
        return round((keys.index(source) - (len(keys) - 1) / 2) * step)

    wires = []
    for edge in edges:
        a, b = n[edge[0]], n[edge[1]]
        dashed = "dash" in edge[2:]
        cls = "sch-wire sch-wire--dash" if dashed else "sch-wire"

        acx, bcx = a["x"] + BOX_W // 2, b["x"] + BOX_W // 2
        acy, bcy = a["y"] + BOX_H // 2, b["y"] + BOX_H // 2

        if a["col"] == b["col"]:
            if a["y"] < b["y"]:
                d = f'M {acx} {a["y"] + BOX_H} L {bcx} {b["y"]}'
                head = _arrow(bcx, b["y"], "down")
            else:
                d = f'M {acx} {a["y"]} L {bcx} {b["y"] + BOX_H}'
                head = _arrow(bcx, b["y"] + BOX_H, "up")
        elif b["col"] > a["col"]:
            sx, ex = a["x"] + BOX_W, b["x"]
            if acy == bcy:
                d = f"M {sx} {acy} L {ex} {bcy}"
            else:
                mid = (sx + ex) // 2 + lane_offset(a["col"], edge[0])
                d = f"M {sx} {acy} H {mid} V {bcy} H {ex}"
            head = _arrow(ex, bcy, "right")
        else:
            # feedback: down out of the source, along the lane, up into the target
            d = (f'M {acx} {a["y"] + BOX_H} V {lane_y} '
                 f'H {bcx} V {b["y"] + BOX_H}')
            head = _arrow(bcx, b["y"] + BOX_H, "up")

        wires.append(f'<path class="{cls}" d="{d}"/>')
        wires.append(head)

    # ---- boxes ----
    boxes = []
    for key in sorted(n, key=lambda k: (n[k]["col"], n[k]["row"])):
        node = n[key]
        x, y = node["x"], node["y"]
        boxes.append(f'<g class="sch-node">')
        boxes.append(
            f'<rect class="sch-box" x="{x}" y="{y}" width="{BOX_W}" height="{BOX_H}"/>')
        boxes.append(
            f'<text class="sch-role" x="{x + 14}" y="{y + 24}">'
            f'{html.escape(node["role"].upper())}</text>')
        if node["trigger"]:
            boxes.append(
                f'<text class="sch-trigger" x="{x + BOX_W - 14}" y="{y + 24}" '
                f'text-anchor="end">{html.escape(node["trigger"].upper())}</text>')
        for i, line in enumerate(node["label"].split("|")[:2]):
            boxes.append(
                f'<text class="sch-label" x="{x + 14}" y="{y + 50 + i * 18}">'
                f'{html.escape(line)}</text>')
        boxes.append("</g>")

    body = "\n      ".join(wires + boxes)
    alt = html.escape(f"Drawing {number}. {caption}")

    return f"""<figure class="schematic">
  <div class="schematic-scroll">
    <svg viewBox="0 0 {width} {height}" width="{width}" height="{height}"
         role="img" aria-label="{alt}">
      <title>{alt}</title>
      {body}
    </svg>
  </div>
  <figcaption><span class="sch-no">{number}</span>{html.escape(caption)}</figcaption>
</figure>"""


# ==========================================================================
# NS-00 — the shared drawing. The same box runs every agent, which is why the
# fifth one costs less to run than the first. Rendered on every workflow page.
# ==========================================================================

BOX_DRAWING = {
    "nodes": {
        "host":   (0, 1, "Host",        "A spare PC, a NUC in|the office, or a VPS"),
        "docker": (1, 1, "Docker",      "One compose file,|version-controlled"),
        "n8n":    (2, 0, "n8n",         "The drawing above,|as nodes you can watch", "webhook"),
        "py":     (2, 1, "Python 3.12", "Workers for the jobs|n8n should not do"),
        "cron":   (2, 2, "cron",        "Anything on a clock|rather than a trigger", "cron"),
        "data":   (3, 0, "Data layer",  "Sheets to read,|warehouse for history"),
        "tools":  (3, 1, "Your tools",  "Phone, email, diary,|accounts, ads"),
        "health": (3, 2, "Health check", "Heartbeat out|every two minutes", "cron"),
    },
    "edges": [
        ("host", "docker"),
        ("docker", "n8n"), ("docker", "py"), ("docker", "cron"),
        ("n8n", "data"), ("n8n", "tools"),
        ("py", "data"),
        ("cron", "health"),
        ("health", "docker", "dash"),
    ],
}

BOX_CAPTION = ("The box every agent runs in. The same host, the same compose "
               "file, the same n8n — which is why the fifth agent costs less to "
               "run than the first.")


# ==========================================================================
# THE PAGES
#
# Everything on a workflow page is here. Bodies may contain HTML: <code> for
# commands and crontab lines, <a> for the one article backlink, and
# <span class="tbd"> for a value nobody has settled yet. Do not guess at a tbd.
# ==========================================================================

CRON_ARTICLE = "/journal/best-cron-jobs-for-ai-agents"

PRICE = [
    ("Installed", "Built, connected to your number, tested on your real calls, "
                  "handed over working.", "£500", "one-off"),
    ("Maintained", "Monitoring, fixes, and changes as the business changes. "
                   "A named person to ring.", "£50", "per month"),
]

PRICE_NOTE = ("You get that number before anything starts, not after. If it is "
              "not the number you were expecting, say so then — it is a much "
              "cheaper conversation than the one at the end.")

PAGES = [
    {
        "number": "01",
        "slug": "answering-the-phone",
        "title": "Answering the phone",
        "subject": "Voice agent and missed-call text-back",
        "summary": ("Every call you cannot answer gets picked up. If it is not you, "
                    "it is an agent that takes the name, the number and the job, and "
                    "texts them back inside a minute."),
        "meta": ("A voice agent that answers the calls you miss, takes the job "
                 "details, and texts the caller back inside a minute. Installed for "
                 "£500, maintained for £50 a month."),

        "intro": [
            "Most of the work a small firm loses, it loses at the phone. Not to a "
            "better quote. To whoever picked up second.",

            "You are on a roof, under a sink, or driving. The phone rings out. The "
            "caller has three more numbers on the same search page and no particular "
            "reason to prefer yours. By the time you hear the voicemail — if they left "
            "one, and most do not — the job belongs to somebody else.",

            "This is the agent that stops that. It rings your mobile first, because if "
            "you can answer, you should. If you cannot, it answers, takes the details "
            "in a plain voice, and writes them down where you will see them. The caller "
            "has a text from you before they have dialled the next number.",
        ],

        "schematic": {
            "nodes": {
                "call":  (0, 0, "Trigger",     "Inbound call to|your number", "webhook"),
                "fork":  (1, 0, "Routing",     "Rings your mobile|for twenty seconds"),
                "agent": (2, 0, "Voice agent", "Answers if you cannot.|Asks three questions"),
                "text":  (2, 1, "Text-back",   "Text to the caller|inside a minute"),
                "sweep": (2, 2, "Sweep",       "Catches anything|the webhook missed", "cron"),
                "sheet": (3, 0, "Job sheet",   "One row: name, job,|postcode, urgency"),
                "alert": (3, 1, "Alert",       "The same thing to|your phone and inbox"),
            },
            "edges": [
                ("call", "fork"),
                ("fork", "agent"),
                ("agent", "text"),
                ("agent", "sheet"),
                ("text", "alert"),
                ("sweep", "sheet"),
            ],
        },
        "caption": ("Answering the phone. Your mobile rings first; the agent only "
                    "answers when you do not."),

        "stages": [
            ("The call comes in",
             "It rings your mobile for twenty seconds, exactly as it does now. If you "
             "pick up, the agent never runs and you never hear from it. Nothing about "
             "your day changes on the calls you can take."),
            ("The agent answers",
             "It gives the firm's name and asks three things: what the job is, where it "
             "is, and when they need it. It does not pretend to be a person, and it does "
             "not quote. Quoting is yours."),
            ("The details get written down",
             "Name, number, postcode, job, urgency. One row on the job sheet, one line in "
             "your inbox, one text to your phone. The same five facts in all three, so "
             "there is nothing to reconcile later."),
            ("The caller gets a text",
             "Inside a minute, in your name. We missed you, here is what we do, reply here "
             "and we will ring back. Most people answer that text rather than carry on "
             "down the list."),
            ("You ring back knowing something",
             "You are not returning a blank missed call. You know the job, the address and "
             "whether it can wait until Thursday."),
            ("Nothing gets quietly lost",
             "A sweep runs every five minutes and picks up anything the telephony provider "
             "failed to hand over. A call that neither of you answered appears on the sheet "
             "as a miss, rather than not appearing at all."),
        ],

        "stack": [
            ("Docker",
             "One compose file per client, version-controlled. Everything below runs "
             "inside it."),
            ("n8n, self-hosted",
             "The drawing above, as nodes you can watch run. You get a login on day one."),
            ("Python 3.12",
             "The workers: the five-minute sweep, the tidy-up of what the agent heard, "
             "and the writes to the sheet."),
            ("cron",
             "Two schedules on this workflow. The sweep, and the Monday morning summary."),
            ("Telephony",
             "Twilio, or your existing provider if it has an API worth the name. The "
             "number, the twenty-second fork to your mobile, and the text-back all sit "
             "here."),
            ("A voice model",
             "Answers, listens, asks its three questions, stops. Not a chatbot with a "
             "phone line attached."),
            ("Google Sheets",
             "The job sheet. Anything a person needs to read during the working day "
             "lives here, because everyone can already read a spreadsheet."),
            ("The warehouse",
             'Still to be chosen — <span class="tbd">product name to be confirmed</span>. '
             'Every call, every miss, every callback, kept with its history so the '
             'monthly figures are countable rather than remembered.'),
        ],

        "build": [
            ("The box it runs in",
             "Docker on the host. That host is a spare PC in the office, a NUC on a "
             "shelf, or a VPS at about five pounds a month — whichever you already have. "
             "One <code>docker-compose.yml</code> per client, kept in version control, "
             "brought up with <code>docker compose up -d</code>. If the machine dies, the "
             "same file on a new machine puts everything back."),

            ("Inside the container",
             "Python 3.12, and only the libraries this workflow actually needs: "
             "<code>requests</code> for the telephony API, <code>gspread</code> for the "
             "job sheet, and <code>python-dateutil</code> for the working-hours logic. "
             "<code>cron</code> goes in the same image for anything that runs on a clock "
             "rather than on a trigger."),

            ("The cron jobs",
             "This workflow needs two. <code>*/5 * * * *</code> sweeps for calls the "
             "webhook did not deliver, because telephony webhooks fail quietly and a "
             "silent failure here is a lost job. <code>0 7 * * 1</code> sends the Monday "
             "morning summary: calls taken, calls missed, callbacks made. The full list we "
             "run on an agent, and what breaks when each one is missing, is written up in "
             f'<a href="{CRON_ARTICLE}">the cron jobs worth setting up for an agent</a>.'),

            ("n8n",
             "Self-hosted, in the same compose file. This is where the drawing above stops "
             "being a drawing: every box is a node, and every arrow is a connection you can "
             "click. You get a login and can watch a call move through it in real time. We "
             "would rather you looked than took our word for it."),

            ("Credentials and accounts",
             "Every account is opened in your name, on your card, with us added as a "
             "partner. Not ours with you as a guest. If you want us gone, you remove us in "
             "one click and everything keeps running. That is the arrangement, and it is a "
             "selling point rather than a footnote."),

            ("The data layer",
             "Google Sheets for the job sheet, because a person has to read it between "
             "jobs. The warehouse — <span class=\"tbd\">to be confirmed</span> — for "
             "anything with history: every call, every miss, every callback, every "
             "recording reference. Sheets is for today. The warehouse is for the question "
             "you will ask in March about last October."),

            ("Wiring the phone in",
             "In this order, because each step needs the one before it. The number first, "
             "ported or new. Then the fork to your mobile with the twenty-second timeout. "
             "Then the voice agent on the far side of that timeout. Then the text-back on "
             "the same number, so the message comes from the number they rang. Then the "
             "write to the sheet. Then the alert to you. Testing the text-back before the "
             "number is live tests nothing."),

            ("Testing on real calls before hand-over",
             "We ring it ourselves from four or five different phones, including one with a "
             "bad line, and we get somebody who is not us to ring it too. It has to answer "
             "in under six rings, get the postcode right, write one row rather than two, and "
             "text back inside sixty seconds. It has to do all of that on ten consecutive "
             "calls. Until it does, it is not finished and we do not invoice."),
        ],

        "media": [
            ("Recording of a real call", "A thirty-second clip of the agent taking a job, "
             "with the client's permission and the caller's."),
            ("The job sheet", "A screenshot of a real week, with names removed."),
            ("The text as the caller sees it", "A photograph of the phone, not a mock-up."),
        ],
    },
]


# ==========================================================================
# RENDERING
# ==========================================================================

def price_block():
    rows = []
    for name, note, figure, unit in PRICE:
        rows.append(f"""      <div class="price-row">
        <span class="item">
          <strong>{name}</strong>
          <span>{note}</span>
        </span>
        <span class="figure">{figure} <small>{unit}</small></span>
      </div>""")
    return "\n".join(rows)


def numbered(items, css_class):
    out = []
    for i, (title, body) in enumerate(items, 1):
        out.append(f"""      <li class="reveal">
        <span class="num">{i:02d}</span>
        <div>
          <h3>{title}</h3>
          <p>{body}</p>
        </div>
      </li>""")
    return f'    <ol class="{css_class}">\n' + "\n".join(out) + "\n    </ol>"


def render(page, prev_page, next_page):
    url = f"https://northsaga.ai/work/{page['slug']}"
    title = f"{page['title']} — Northsaga"

    parts = []
    for name, note in page["stack"]:
        parts.append(f"""      <li class="reveal">
        <h3>{name}</h3>
        <p>{note}</p>
      </li>""")

    media = []
    for name, note in page["media"]:
        media.append(f"""      <li>
        <h3>{name}</h3>
        <p>{note}</p>
      </li>""")

    paging = ['      <a class="work-back" href="/#work">All of the work</a>']
    if prev_page:
        paging.append(f'      <a class="work-prev" href="/work/{prev_page["slug"]}">'
                      f'<span>Previous</span>{prev_page["title"]}</a>')
    if next_page:
        paging.append(f'      <a class="work-next" href="/work/{next_page["slug"]}">'
                      f'<span>Next</span>{next_page["title"]}</a>')

    return "".join([
        chrome.head(
            title=title,
            description=page["meta"],
            url=url,
            og_title=title,
            og_description=page["summary"],
        ),
        chrome.BANNER.format(source="tools/build-work-pages.py",
                             script="build-work-pages.py"),
        chrome.header(),
        chrome.menu(current="work"),
        f"""
<main>

<!-- ============================ INTRO ============================ -->
<section class="band work-head">
  <div class="container">
    <p class="eyebrow">Workflow {page['number']} · {page['subject']}</p>
    <h1 class="display">{page['title']}</h1>
    <p class="lede" style="margin-top:var(--space-3);">{page['summary']}</p>

    {schematic(page['schematic'], f"NS-{page['number']}", page['caption'])}

    <div class="prose" style="margin-top:var(--space-5);">
      {"".join(f"<p>{p}</p>" for p in page['intro'])}
    </div>
  </div>
</section>

<!-- ============================ STAGES ============================ -->
<section class="band band--tall" id="stages">
  <div class="container">
    <p class="eyebrow">What happens, in order</p>
{numbered(page['stages'], 'stages')}
  </div>
</section>

<!-- ============================ PARTS ============================ -->
<section class="band band--paper band--tall" id="parts">
  <div class="container">
    <p class="eyebrow">What it is built from</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:20ch;">
      Named parts, not a black box.
    </h2>
    <ul class="parts-list">
{chr(10).join(parts)}
    </ul>
  </div>
</section>

<!-- ============================ BUILD ORDER ============================ -->
<section class="band band--tall" id="build">
  <div class="container">
    <p class="eyebrow">How it is built, in order</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:22ch;">
      From a bare machine to a live agent.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      First line to last. Someone competent could follow this. That is the point of
      printing it.
    </p>

    {schematic(BOX_DRAWING, "NS-00", BOX_CAPTION)}

{numbered(page['build'], 'build-steps')}
  </div>
</section>

<!-- ============================ MEDIA ============================ -->
<section class="band" id="media">
  <div class="container">
    <p class="eyebrow">See it working</p>
    <ul class="media-list is-placeholder">
{chr(10).join(media)}
    </ul>
  </div>
</section>

<!-- ============================ PRICE ============================ -->
<section class="band band--tall" id="price" style="background:var(--ink-deep);">
  <div class="container">
    <p class="eyebrow">What this one costs</p>
    <div class="price-block">
{price_block()}
    </div>
    <p class="price-note">{PRICE_NOTE}</p>

    <div class="hero-actions">
      <a class="btn" href="/#contact">Book the survey</a>
      <a class="btn btn--quiet" href="/#ledger">Everything else it costs</a>
    </div>
  </div>
</section>

<!-- ============================ PAGING ============================ -->
<nav class="band work-paging" aria-label="Workflows">
  <div class="container">
    <div class="work-paging-inner">
{chr(10).join(paging)}
    </div>
  </div>
</nav>

</main>
""",
        chrome.footer(),
    ])


def homepage_list():
    """The block to paste into .install-list in index.html."""
    items = []
    for page in PAGES:
        items.append(f"""      <li class="reveal">
        <h3><a href="/work/{page['slug']}">{page['title']}</a></h3>
        <p>{page['summary']}</p>
      </li>""")
    return ("<!-- GENERATED — paste into .install-list in index.html. Only the\n"
            "     workflows currently in tools/build-work-pages.py appear here. -->\n"
            + "\n".join(items) + "\n")


def main():
    out_dir = os.path.join(ROOT, "work")
    os.makedirs(out_dir, exist_ok=True)

    for i, page in enumerate(PAGES):
        prev_page = PAGES[i - 1] if i > 0 else None
        next_page = PAGES[i + 1] if i < len(PAGES) - 1 else None
        path = os.path.join(out_dir, page["slug"] + ".html")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(render(page, prev_page, next_page))
        print(f"wrote work/{page['slug']}.html")

    with open(os.path.join(HERE, "_homepage-list.html"), "w", encoding="utf-8") as fh:
        fh.write(homepage_list())
    print("wrote tools/_homepage-list.html")


if __name__ == "__main__":
    main()
