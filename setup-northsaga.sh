#!/bin/sh
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

DEST="${1:-northsaga.ai}"
mkdir -p "$DEST"
cd "$DEST"

nsbin() { openssl base64 -d -A > "$1"; }

mkdir -p 'agents' 'assets' 'assets/data' 'assets/favicon' 'assets/logo' 'css' 'journal' 'js' 'tools'

cat > '.gitignore' <<'NSEOF'
.DS_Store
.vercel
node_modules
*.log
__pycache__/
NSEOF

cat > '2026-08-06_HANDOFF.md' <<'NSEOF'
# Northsaga site — handoff, 6 August 2026

Session covered the "workflow pages, build order, and the cron article" brief.
Read `BRAND.md` and `CLAUDE.md` first, as always. This file is what changed and
what is still open.

---

## Where things are

The site is `/Users/georgeastin/Claude/Projects/isaga/northsaga-site`. It is its
own git repository, sitting inside the `isaga` project directory (which is not
one).

**Everything below was committed and pushed on 6 August 2026** as `bb585cd`,
"Add the missed-call text-back workflow page and the cron jobs article", and is
live on `main`. `.gitignore` gained `__pycache__/` in the same commit. This
handoff file itself is deliberately left untracked.

**Then a second pass, same day, superseded some of it.** Read this list before
trusting anything below:

- `work/` is now **`agents/`**, and `tools/build-work-pages.py` is now
  `tools/build-agent-pages.py`. `vercel.json` carries a permanent redirect from
  `/work/:slug`. `css/work.css` and the `.work-*` class names were **not**
  renamed — they also serve the journal, and renaming them buys nothing.
- **Agent 02, `quote-follow-up`, exists.** Five to go, not six.
- **The node grammar gained an icon.** A node is now
  `(col, row, ROLE, 'l1|l2', icon, trigger)` — the fifth element used to be the
  trigger and is now the icon. Glyphs live in `tools/icons.py`.
- **Schematics fit the viewport by default** and zoom via `js/schematic.js`.
  They no longer keep their intrinsic width and scroll. The judgement call
  below about the drawing at 390px is therefore closed.
- Feedback wires now enter their target from the left through the column
  gutter, not from below through whatever box happens to be underneath.

## The one thing that surprised us

**The brief assumed seven workflow pages, `tools/build-work-pages.py`,
`css/work.css` and `setup-northsaga.sh` already existed. None of them did.** The
repo was at the state `README.md` describes: `index.html`, `case-studies.html`,
two stylesheets, one script. Confirmed by searching the whole tree and by
`git log` — the last commit replaced a guessed site with this source.

Two decisions were taken on that:

1. **Build the generator and one workflow page for review**, rather than writing
   seven pages of copy the brief treated as already approved. Workflow 01,
   `answering-the-phone`, is the reference. The other six go into the same dict.
2. **Leave `assets/og-image.png` alone.** §3.5 asked for cairosvg generation;
   `README.md` and `CLAUDE.md` both say cairosvg produces a broken image because
   the fallback face overflows the 1200px canvas. The documents agree on the
   outcome even though they disagree on the method, so the existing PNG stands.

---

## New files

| File | What it is |
| --- | --- |
| `tools/chrome.py` | `head()`, `header()`, `menu()`, `footer()` shared by both generators, plus `NAV`. A menu item is added here once, not twice. |
| `tools/build-work-pages.py` | `schematic()`, the shared `NS-00` drawing, and the `PAGES` list holding every page's content. |
| `tools/build-journal.py` | Renders `assets/data/cron-jobs.json` into the article. |
| `tools/build-installer.py` | Writes `setup-northsaga.sh`. Run last. |
| `css/work.css` | Loaded only by `/work/*` and `/journal/*`. |
| `assets/data/cron-jobs.json` | The article's content. Twelve schedules. |
| `work/answering-the-phone.html` | **Generated.** Do not hand-edit. |
| `journal/best-cron-jobs-for-ai-agents.html` | **Generated.** Do not hand-edit. |
| `setup-northsaga.sh` | **Generated.** Self-extracting installer. |
| `tools/_homepage-list.html` | **Generated.** Paste-in block, not shipped. |

## Changed files

- **`css/tokens.css`** — four tokens added: `--paper-ink-dim`, and `--sch-label`
  / `--sch-role` / `--sch-trigger` (fixed px, because the drawings have a fixed
  viewBox and pan rather than reflow).
- **`css/site.css`** — two additions, both in components that already live there
  and cannot work from `work.css`: the `nth-child(7)` menu stagger, and a hover
  rule for a linked heading in `.install-list`.
- **`index.html`** — "Writing" in the menu and footer; ledger now `£500` for one
  agent and `£50` per month per agent; the ledger comment rewritten to say which
  three lines are still open; the first `.install-list` item links to the new
  workflow page.
- **`case-studies.html`** — "Writing" in the menu and footer.
- **`sitemap.xml`** — the workflow page and the article.
- **`README.md`** — structure tree updated, a "Generated pages" section added,
  the pre-launch list corrected.
- **`../.claude/launch.json`** — a `northsaga-site` preview entry serving the
  subdirectory on port 8000.

---

## How to build

Order matters. The installer embeds the generated pages, so it goes last.

```bash
cd tools
python3 build-work-pages.py
python3 build-journal.py
python3 build-installer.py
```

Verify the installer round-trips:

```bash
./setup-northsaga.sh /tmp/check && diff -r . /tmp/check -x .git -x __pycache__ -x .DS_Store -x setup-northsaga.sh -x _homepage-list.html
```

It currently reports no differences: 29 text files, 5 binary assets, 285 KB.

Preview with `preview_start` on the `northsaga-site` config, or
`python3 -m http.server 8000`. `cleanUrls` is a Vercel behaviour, so locally the
extensionless `/work/answering-the-phone` gives a 404 and `.html` is needed. That
is expected and is not a bug to chase.

## The schematic grammar

In `tools/build-work-pages.py`:

```python
'nodes': {
  'a': (0, 0, 'Trigger', 'Inbound call|to your number', 'webhook'),
  'b': (1, 0, 'Routing', 'Rings your mobile|for twenty seconds'),
}
'edges': [('a','b'), ('b','c'), ('c','a','dash')]
```

Four- and five-element nodes are both accepted; the fifth is `'cron'` or
`'webhook'` and prints as a small brass label top-right. Two label lines
maximum, roughly 26 characters each. Columns run left to right, each centred
vertically. `'dash'` marks a feedback loop; a right-to-left edge is routed in a
lane beneath the drawing.

**One non-obvious bit worth not undoing.** Elbow connectors are assigned a
vertical lane keyed on the *source node*: edges leaving the same box share a
trunk, so a fan-out reads as one line splitting, while edges from different
boxes get their own lane. Before that, `text-back → alert` and
`sweep → job sheet` rendered exactly on top of each other and read as a single
wire.

---

## Still open

**Content the business owes:**

- The **six remaining workflow pages**. Add each to `PAGES` and re-run. The price
  block is already real; the media links on each page are not.
- The **warehouse product name** — `<span class="tbd">` on the workflow page, in
  both the parts list and build step 6. Nothing chosen. Do not guess.
- **Three ledger lines** still `£000`: operations survey, the full three-to-five
  agent install, the systems build. `is-placeholder` stays on the block until all
  five are real.
- Everything already on the `README.md` pre-launch list: proof cards, both case
  studies, the founder section and photograph, telephone and hours, the
  unverified SE21/22/24/27 postcodes in three places, the company registration
  line.

**Judgement calls to confirm:**

- **Vendor names in print.** §3.1 asked for the specific APIs, so the page names
  Twilio, `requests`, `gspread`, `python-dateutil` and Google Sheets, each with an
  "or your existing provider" clause where honest. One edit in `PAGES` if the
  business would rather not commit to any of them publicly.
- **The schematic at 390px.** The first screenful has a lot of empty navy above
  and below the lone Trigger box, because each column is centred against the
  tallest one. It pans correctly and reads well once scrolled. A media query
  scaling the drawing down on narrow screens is the fix if the dead space is
  judged worse than smaller text.
- **`_homepage-list.html` has not been pasted** into `.install-list`. With one
  page generated it would delete five items. Paste it once all seven exist.

## Verified this session

Both new pages at 1280px and 390px: no horizontal page overflow, both schematics
scroll inside their own wrapper, no console errors, all internal links resolve.
No hex values or font stacks outside `tokens.css`. No banned words and no
exclamation marks in the new copy. All twelve crontab expressions parse as valid
five-field cron. Installer diff is clean.
NSEOF

cat > 'BRAND.md' <<'NSEOF'
# Northsaga — Brand Guidelines

*Version 1.0 · The identity in one file. If a decision isn't covered here, ask: would this look right engraved on a brass plate?*

---

## 1. The idea

Northsaga installs AI agents into small businesses and then maintains them, the way a
firm installs anything else into an estate: survey, fixed-price install, maintenance
contract.

The brand's whole job is to make that feel **earned rather than sold**. Our audience —
trades and small firms — have been marketed at by agencies for years and have learned
to distrust it. So the identity borrows from things they already trust: ledgers,
certificates, brass plates, engineering drawings, old family firms.

**New tools. Old standards.**

---

## 2. The mark

A symmetric arrow that is also the letter **N**. Four strokes, no more.

The left arm mirrors the N's diagonal at *exactly* the same angle — this is what makes
it read as one glyph rather than a "1" next to an "N". Never redraw it by eye; always
use the supplied files.

| File | Use |
|---|---|
| `assets/logo/northsaga-mark-bone.svg` | Default. On navy or any dark ground. |
| `assets/logo/northsaga-mark-ink.svg` | On paper, light backgrounds, printed forms. |
| `assets/logo/northsaga-mark-brass.svg` | Sparingly. Stamps, seals, embossing. |
| `assets/logo/northsaga-lockup-bone.svg` | Horizontal lockup: **N** + *orthsaga*. |
| `assets/logo/northsaga-lockup-ink.svg` | Same, for light grounds. |

**Rules**

- Clear space on all sides: at least the width of the mark's left arm.
- Minimum size: 20px tall on screen, 8mm in print. Below that, use the favicon crop.
- Never add a gradient, glow, drop shadow, outline or container box.
- Never rotate, skew, stretch or recolour outside the palette.
- Never place on a busy photograph. If it must sit on an image, put it on a solid panel.

**On the chrome version.** The faceted metal treatment developed during design is *not*
the logo. It is reserved for physical or ceremonial use — signage, an embossed proposal
cover, a vehicle livery. It never appears on the website, in documents, or in social
avatars.

---

## 3. Colour

| Token | Hex | Role |
|---|---|---|
| `--ink` | `#0E1A24` | Base background. Deep navy-black. |
| `--ink-deep` | `#08111A` | Menu overlay, footer, the ledger section. |
| `--ink-raised` | `#16242F` | Cards and panels sitting on the base. |
| `--bone` | `#E9E4D9` | Primary type on dark. |
| `--bone-dim` | `#97A1A9` | Secondary type, captions. |
| `--paper` | `#EDE9DE` | Light section backgrounds. |
| `--paper-ink` | `#12202B` | Type on light sections. |
| `--brass` | `#B08D4F` | Accent on dark: rules, eyebrows, figures. |
| `--brass-soft` | `#7C6438` | Accent on light. |

**Brass is the earned colour.** It marks things of consequence — a price, a section
label, a rule under a heading. It is never a background, never a fill, never more than
roughly 5% of any screen. Overuse turns the brand from *heritage* into *casino*.

There is no other accent. No green, no red, no gradients. If something needs to stand
out and brass is already in use, use size or whitespace instead of a new colour.

---

## 4. Type

**Display — Cormorant Garamond**, weight 300, occasionally 300 italic for emphasis.
Set large, tight (line-height 1.0–1.15), and always given room. This is the heritage
voice. Google Fonts, free.

**Body — Archivo**, weights 400/500. A plain grotesque: honest, slightly industrial,
completely legible at small sizes. It does the explaining while the serif does the
talking.

**Utility** — Archivo 500, uppercase, `letter-spacing: 0.22em`. Used for eyebrows,
buttons and table labels only. Never for sentences.

*If you later licence a paid display face, **Canela**, **Freight Display** or a modern
**Caslon** all drop in cleanly. Change `--font-display` in `css/tokens.css` and nothing
else needs touching.*

Rules: sentence case in body copy, uppercase only in the utility role, never all-caps
paragraphs, never letter-spaced serif.

---

## 5. Photography

Real photographs of real people and real jobs. Your face, your team, your clients'
vans and workshops.

- No stock photography. No illustrated characters. No abstract "AI" imagery — no
  neural networks, no glowing brains, no blue circuitry.
- Prefer natural light, muted colour, slightly cool grade so it sits with the navy.
- A photograph of a person looking at the camera outperforms anything else on this
  brand. Use them.

---

## 6. Voice

Write the way you would speak to a foreman: plainly, specifically, without selling.

**Do**
- Name the thing. "Missed-call text-back", not "intelligent engagement solutions".
- Use real numbers, including prices.
- Say what you will not do, as well as what you will.
- Short sentences. Full stops instead of dashes.

**Don't**
- Never: leverage, synergy, seamless, transform, revolutionise, unlock, empower, cutting-edge, game-changing.
- No exclamation marks.
- No claims you cannot name a client for.

**Approved lines**

- *New tools. Old standards.* — primary. Footer, cards, livery.
- *Built the old way. Runs the new way.* — headline use.
- *At Northsaga, the technology is new. The way we work isn't.* — long form, adverts.
- *We don't sell AI. We earn the right to install it.* — use sparingly; strong but boastful.

> **Do not use** "We make our money the old-fashioned way. We earn it." That is Smith
> Barney's line from their John Houseman advertisements (c. 1980) and remains widely
> recognised. Borrow the *cadence* — a claim, a full stop, a humbler correction — but
> not the words. The lines above already do that.

---

## 7. Trust behaviours

These are part of the brand, not the marketing plan. An "earned trust" identity fails
if the business behaves like everyone else.

1. **Named humans, real photographs** on the site. Never a faceless "team".
2. **Published pricing logic.** The ledger section is the point of the whole website.
3. **Proof over promise.** Named client, named problem, named number. One real case
   study is worth more than every explainer post.
4. **Plain English everywhere** — including invoices, contracts and error messages.
5. **Hand-over on request.** If a client wants to take it in-house, they can. Say so
   publicly; it is why they will stay.
NSEOF

cat > 'CLAUDE.md' <<'NSEOF'
# CLAUDE.md

Governs all work in this repository. Read it, and `BRAND.md`, before touching
anything.

## Precedence

**`BRAND.md` is the source of brand truth.** This file adds the operational
detail — repo layout, conventions, what is unfinished — and never contradicts
it. If the two ever disagree, `BRAND.md` wins and this file gets corrected.

## What the business is

Northsaga installs AI agents into small businesses and then maintains them. The
commercial model deliberately mirrors installing a piece of equipment into a
firm's estate — not a SaaS subscription, not an agency retainer.

1. **Survey** — a paid half-day mapping how work actually moves through the
   business: who does what, where it stalls, what the stall costs. The client
   keeps the map whether or not they proceed.
2. **Install** — a single agreed upfront price, stated plainly before
   commitment, using the framing: *"for what you want, given these cost
   metrics, that would be X — does that number align with your expectations,
   or does it shock you?"*
3. **Maintain** — a monthly fee for monitoring, fixes and tuning, with a named
   person to ring.

Alongside the agents, Northsaga installs the operating system the agents plug
into: EOS-inspired job profiles, scorecards, quarterly priorities ("rocks")
and clear accountability. The agents are the visible part; the operating
system is what makes them stick.

Northsaga also still does SEO for local clients, delivered agentically — for
example scraping property and competitor pricing data across postcodes and
compiling it by price, age and aspect. On the site this is the "price and
patch watch" item.

## Ideal client profile

Owner-managed local businesses and trades in **Dulwich and West Norwood, south
London**, typically 3–30 staff: builders, electricians, plumbers, roofers,
landscapers, garages, veterinary practices, dental and private clinics, estate
and lettings agents, independent retailers, professional services.

They are practical, time-poor, sceptical of marketing, and have usually been
let down by an agency before. Write for that reader.

**The postcodes are unverified.** SE21, SE22, SE24 and SE27 are hard-coded in
**three places** — the contact section, the footer, and the `areaServed` block
of the JSON-LD on every page. They match Dulwich Village, East Dulwich, Herne
Hill and West Norwood, but nobody has confirmed them against the real service
area, and "and surrounding" was never resolved into a list. Confirm with the
business and correct all three places together.

## The mark

See `BRAND.md` §2 for the rules. The operational points:

**Never redraw it by eye. Always reference `assets/logo/`.** The geometry is
four strokes, and it is exact:

| Stroke | Path |
| --- | --- |
| Left arm | `M 0 -160 L -70 -32` |
| Left stem | `M 0 -160 L 0 160` |
| N diagonal | `M 0 -160 L 175 160` |
| Right stem | `M 175 -160 L 175 160` |

All three of the N's strokes meet at a single apex, `0 -160`. The left arm
projects up-left from that same apex.

The mirror is exact and load-bearing: the arm is `(-70, 128)` and the diagonal
is `(175, 320)`, both `|dx/dy| = 0.546875` — 118.673° and 61.327°. **That
equality is what stops the mark reading as "1N".** If you ever regenerate or
rescale the artwork, check that ratio still holds.

Files, per `BRAND.md`:

| File | Use |
| --- | --- |
| `northsaga-mark-bone.svg` | Default, on dark |
| `northsaga-mark-ink.svg` | On paper and light grounds |
| `northsaga-mark-brass.svg` | Sparingly — stamps, seals, embossing |
| `northsaga-lockup-bone.svg` | Horizontal lockup, on dark |
| `northsaga-lockup-ink.svg` | Horizontal lockup, on light |

The header and hero inline the mark's four paths directly in the HTML rather
than linking the SVG file, because the hero strokes have to be animated and
the header has to inherit `currentColor`. **That means the geometry is
duplicated in every page.** If it ever changes, change `assets/logo/` first,
then propagate to the header and hero block of every page.

- Clear space: at least the width of the left arm on all sides.
- Minimum size: 20px on screen, 8mm in print. Below that use the favicon crop.
- Never a gradient, glow, shadow, outline or containing box.
- **The chrome/faceted treatment is not the logo** and must never appear on
  the website.

**The logo SVGs contain live text** for the "orthsaga" wordmark, so they need
Cormorant Garamond installed to render correctly outside the site. Convert the
text to outlines before sending anything to a printer or signwriter.

The same caveat applies to `assets/og-image.svg`. `assets/og-image.png` is
generated from it and **must be rendered by a browser with the webfonts
loaded** — rendering it with cairosvg falls back to a wide sans, and the
headline overflows the 1200px canvas and gets cut off.

## Colour, type, layout

All in `BRAND.md` §3 and §4. Operationally:

- **Every value lives in `css/tokens.css`.** Nothing hard-codes a hex anywhere
  else. `css/site.css` references tokens only.
- Brass is **the earned colour** — a price, a section eyebrow, a rule under a
  heading. Never more than roughly 5% of a screen. There is no second accent,
  and no gradients.
- Cormorant Garamond 300 for display, set large and tight. Archivo 400/500 for
  body. Archivo 500 uppercase at `--tracking-eyebrow` (0.22em) for eyebrows,
  buttons and labels **only** — never sentences. No letter-spaced serif.
- Square corners throughout (`--radius: 0`). Hairline rules rather than boxes
  and cards wherever possible.

**One known tension with `BRAND.md`.** §3 says brass is "never a background,
never a fill", but `site.css` uses a brass fill in two places: `.btn:hover`
and the `.is-placeholder::after` tag. Both look deliberate and both are tiny,
so they have been left alone — but they are exceptions to a rule stated
absolutely. Raise it with the business rather than quietly extending the
pattern.

## Motion

**One orchestrated moment only** — the mark draws itself once on load, four
strokes, about a second. Everything else is a quiet reveal on scroll
(`.reveal` → `.is-in`).

`prefers-reduced-motion` is respected everywhere, without exception. Do not
add animation for its own sake; scattered effects make the site read as
generated.

## Navigation

A full-screen menu overlay in the Mylands style: the panel wipes up over the
page via `clip-path`, oversized Cormorant links rise in with a stagger, the
two-rule hamburger rotates into a cross. **This is a signature element —
extend it for new pages, don't replace it with a conventional nav bar.**

The stagger is per-item CSS in `site.css`
(`body[data-menu="open"] .menu-nav li:nth-child(N) a`). **Adding a menu item
means adding an `nth-child` delay**, or the new item snaps in with no stagger.
There are currently six.

## Voice

`BRAND.md` §6 is authoritative. The short version: plain English, spoken to a
foreman, not sold to a prospect. Name things concretely — "missed-call
text-back", never "intelligent engagement solutions". Short sentences. Real
numbers including prices. Say what Northsaga will not do.

**Banned outright:** leverage, synergy, seamless, transform, revolutionise,
unlock, empower, cutting-edge, game-changing, exclamation marks, and any claim
that cannot be attached to a named client.

**Approved lines:**
- *New tools. Old standards.* (primary)
- *Built the old way. Runs the new way.* (headline)
- *At Northsaga, the technology is new. The way we work isn't.* (long form)
- *We don't sell AI. We earn the right to install it.* (sparingly — strong but
  boastful)

### Never use the Smith Barney line

**"We make our money the old-fashioned way. We earn it."** is Smith Barney's
line from their John Houseman advertisements (c. 1980) and remains widely
recognised. It must never appear on any Northsaga property.

Borrow the cadence — claim, full stop, humbler correction — never the words.
Recorded here so it is not reintroduced later by someone who only remembers
that the cadence was approved.

### Trust behaviours the site must uphold

`BRAND.md` §7. These are brand rules, not marketing preferences. Any change
that breaks one is wrong.

1. **Named humans and real photographs.** No stock imagery, no illustrated
   characters, no abstract "AI" visuals — no neural networks, no glowing
   brains, no blue circuitry.
2. **Published pricing logic.** The ledger section is the point of the site.
3. **Proof over promise:** named client, named problem, named number.
4. **Plain English everywhere**, including invoices and error messages.
5. **Hand-over on request.** If a client wants to take it in-house, they can,
   and the site says so publicly. The ledger note carries this — don't quietly
   drop it.

## Technical rules

- Static HTML, CSS and vanilla JS. **No framework, no build step, no
  dependencies, no npm.** There is deliberately no `package.json`. If a task
  seems to need a build step, **stop and ask**.
- `css/tokens.css` is the single source of design values; `css/site.css` holds
  layout and components.
- **Watch selector specificity, particularly section padding.** Class-based
  and element-based selectors have cancelled each other out here before.
  Padding is set by `.band` / `.band--tall` only — never add a bare
  `section { padding }` rule.
- No `localStorage`. No third-party analytics or trackers without explicit
  instruction.
- Fonts load from Google Fonts. Self-hosting them in `assets/fonts/` is a
  desirable future change — see `README.md`.
- **Accessibility floor, non-negotiable:** responsive to 390px with no
  horizontal overflow, visible keyboard focus, semantic landmarks, alt text,
  reduced motion respected.
- Deployment is Vercel from `main`, no build command, output directory root.
  `vercel.json` holds `cleanUrls`, caching and security headers.

### Adding a page

1. Duplicate the header, menu and footer blocks **exactly**.
2. Add the page to `.menu-nav` in every existing page, and add the matching
   `nth-child` stagger delay in `site.css`.
3. Add the page to `sitemap.xml`.
4. Copy the `LocalBusiness` JSON-LD block.

`cleanUrls` is enabled, so `case-studies.html` serves at `/case-studies`.
Cross-page links omit the extension; in-page anchors from a subpage point at
`/#anchor`.

## Placeholders

Unknown content carries `class="is-placeholder"`, which renders a brass
`PLACEHOLDER — REPLACE` tag pinned to the element's top-right corner. **Remove
the class once the content is real** and the tag disappears. This is
deliberate: an unfilled placeholder should be impossible to ship by accident.

Because the tag is absolutely positioned, put the class on an element with
enough room to show it. On inline items in `.case-meta` the tag is given
right-padding so it does not overlap the next item.

**The ledger prices are the highest-priority content gap.** A page headed
"most agencies will not print this" above a row of `£000` actively undermines
the brand — it breaks the published-pricing trust behaviour at exactly the
moment it draws attention to it. Real numbers, or cut the section; a fake
range is worse than none.

Remaining gaps, in priority order:

1. Ledger prices — five rows on the homepage.
2. The two proof cards on the homepage.
3. Both case studies in full.
4. Founder biography and a real photograph (`#who`).
5. Telephone and opening hours.
6. The service-area postcodes (three places, see above).
7. `hello@northsaga.ai` — appears in several places; confirm or replace.
8. The company registration line in the footer.

The two case studies name real companies — **Broadland Products** and
**Telemechry** (route optimisation). No detail, figure, quote or outcome has
been supplied for either. **Do not invent any.** Every fact on that page is a
placeholder until the business provides it. Inventing one would breach both
"no claims you cannot name a client for" and "proof over promise", on the page
whose entire job is proof.

## Git

- Default branch: `main`.
- Commit messages are short, imperative, single-line.
- Do not commit `.vercel/` or OS cruft.
NSEOF

cat > 'LICENSE' <<'NSEOF'
MIT License

Copyright (c) 2025 ClespCoding

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
NSEOF

cat > 'README.md' <<'NSEOF'
# northsaga.ai

Static site. No build step, no framework, no dependencies. Open `index.html` and it
works. Deploys to Vercel as-is.

---

## Structure

```
northsaga.ai/
├── index.html              Homepage
├── case-studies.html       Serves at /case-studies (cleanUrls)
├── BRAND.md                Brand guidelines — read this first
├── CLAUDE.md               Working rules, conventions, content gaps
├── README.md               This file
├── vercel.json             Caching + security headers, clean URLs
├── site.webmanifest        App icons / theme colour
├── robots.txt
├── sitemap.xml
│
├── agents/                 GENERATED — do not hand-edit. See "Generated pages".
│   ├── answering-the-phone.html
│   └── quote-follow-up.html
│
├── journal/                GENERATED — do not hand-edit.
│   └── best-cron-jobs-for-ai-agents.html
│
├── tools/                  The generators. Python 3 standard library only.
│   ├── chrome.py           Header, menu, footer and <head>, shared by both
│   ├── icons.py            The glyphs that sit in a schematic node
│   ├── build-agent-pages.py  Agent pages + the schematic renderer
│   ├── build-journal.py    Journal pages
│   └── _homepage-list.html Generated — paste into .install-list in index.html
│
├── css/
│   ├── tokens.css          ← Every colour, size and space value. Change things HERE.
│   ├── site.css            Layout and components
│   └── work.css            Agent and journal pages only
│
├── js/
│   ├── site.js             Menu, header state, scroll reveal. ~70 lines.
│   └── schematic.js        Zoom and pan for the drawings. Agent pages only.
│
└── assets/
    ├── data/
    │   └── cron-jobs.json  The journal article's content. Edit this, not the HTML.
    ├── og-image.svg         Source for the share card
    ├── og-image.png         Generated — see note below
    ├── logo/
    │   ├── northsaga-mark-bone.svg      Mark, light — default
    │   ├── northsaga-mark-ink.svg       Mark, dark — for paper
    │   ├── northsaga-mark-brass.svg     Mark, brass — stamps and seals
    │   ├── northsaga-lockup-bone.svg    N + orthsaga, horizontal
    │   └── northsaga-lockup-ink.svg
    └── favicon/
        ├── favicon.svg          Modern browsers
        ├── favicon-16.png
        ├── favicon-32.png
        ├── apple-touch-icon.png (180px)
        └── icon-512.png         PWA / share cards
```

**The one rule:** all design values live in `css/tokens.css`. Change a hex or a size
there and it updates across the whole site. Don't hard-code values in `site.css`.

---

## Generated pages

`agents/*.html` and `journal/*.html` are output. **Do not hand-edit them** — the next
run overwrites your changes. Both generators are plain Python 3, standard library
only, and there is still no build step: you run them when you change content, and
the site deploys as static files either way.

```bash
cd tools
python3 build-agent-pages.py    # agent pages
python3 build-journal.py        # journal pages
python3 build-installer.py      # setup-northsaga.sh — run this last
```

**Agent pages.** Every page's copy, stages, parts list, build order, prices and
schematic lives in the `PAGES` list in `tools/build-agent-pages.py`. Edit there and
re-run. It also writes `tools/_homepage-list.html`, the block to paste into
`.install-list` in `index.html` when the list of agents changes — that block only
contains agents that actually have a page, so don't paste it until they all do.

**The schematics** are drawn by `schematic()` at the top of the same file. A node is
`(column, row, ROLE, 'line 1|line 2', icon, trigger)`. The last two are optional:
`icon` is a key in `tools/icons.py` and draws a glyph in the box's top-left corner,
and `trigger` is `'cron'` or `'webhook'`, printed as a small brass label top-right.
An unknown icon name is a hard error rather than a silent blank. Two label lines
maximum, roughly 26 characters each. An edge is `('a','b')`, or `('a','b','dash')`
for a feedback loop. Columns run left to right and each is centred vertically. `NS-00`,
the drawing of the box everything runs in, is shared and appears on every agent page.

**Keep drawings narrow rather than wide.** A drawing is fitted to the viewport width
so the whole shape is visible on a phone, which means every extra column shrinks the
type in all of them. Three or four columns and more rows reads far better at 390px
than the reverse. `js/schematic.js` then adds zoom — buttons, ctrl-scroll, two-finger
pinch, double-click, and drag to pan — so the reader can get in close. Without
JavaScript the drawing is still complete and still scrollable, just not zoomable.

**The node glyphs** in `tools/icons.py` are drawn here, not copied: simplified marks
that identify a product by silhouette rather than reproductions of anyone's
trademarked artwork. They are deliberately monochrome — `BRAND.md` allows one accent
and brass is it, so a set of vendor colours would be a second palette arriving
through the back door.

**Journal pages.** The article's content is *not* in the HTML. It lives in
`assets/data/cron-jobs.json` so it can be updated on its own — by hand now, by an
agent later — without anybody touching markup. The prose fields (`intro`, `does`,
`why`, `fails`, `caveats`, `outro`) may contain inline HTML, `<code>` and `<a>`; every
other field is escaped.

**The installer.** `setup-northsaga.sh` in the root is a self-extracting copy of the
whole site — one quoted heredoc per text file, the icons base64 in a footer. It is
generated too, so run `build-installer.py` **last**, after the other two, or it ships
stale pages. Check it round-trips:

```bash
./setup-northsaga.sh /tmp/check && diff -r . /tmp/check -x .git -x __pycache__ -x .DS_Store -x setup-northsaga.sh -x _homepage-list.html
```

**The header, menu and footer** are in `tools/chrome.py` and shared by both generators,
so a new menu item is added once rather than twice. `index.html` and `case-studies.html`
are hand-written and still need updating by hand — and a new menu item needs a matching
`nth-child` stagger delay in `css/site.css` or it snaps in with no stagger. There are
currently seven.

---

## Running it locally

```bash
python3 -m http.server 8000
# open http://localhost:8000
```

`cleanUrls` is a Vercel behaviour, so locally `/case-studies` needs the `.html`.
On the deployed site it does not.

---

## Deploying to northsaga.ai on Vercel

1. Push this folder to a GitHub repository.
2. In Vercel: **Add New → Project → Import** the repo.
3. Framework preset: **Other**. Build command: *leave empty*. Output directory: *leave empty* (root).
4. Deploy.
5. **Project → Settings → Domains → Add** `northsaga.ai`, then follow Vercel's DNS
   instructions at your registrar (either point the nameservers at Vercel, or add the
   `A` / `CNAME` records they give you). Add `www.northsaga.ai` too and set it to
   redirect to the apex.

Certificates are issued automatically. Propagation is usually minutes, occasionally
a few hours.

---

## Before you go live — replace these

Everything still needing your input is flagged **in the browser** with a brass
`PLACEHOLDER — REPLACE` tag, via the `is-placeholder` class. Remove that class from the
element once you've filled it in, and the tag disappears.

- [ ] **Ledger prices** (`#ledger`) — three of the five are still `£000`: the operations
      survey, the full three-to-five-agent install, and the systems build. One agent
      (`£500`) and maintenance (`£50` per month, per agent) are real. This section is the
      reason the site works; real numbers or cut the section entirely. A fake range is
      worse than none. `is-placeholder` stays on the block until all five are real.
- [ ] **The warehouse product name** — `<span class="tbd">` on the agent pages, in
      both the parts list and the build order. Nothing has been chosen; don't guess.
- [ ] **The remaining five agent pages** — only `answering-the-phone` and
      `quote-follow-up` exist. Add each one to `PAGES` in
      `tools/build-agent-pages.py` and re-run. The agent price block
      is already real at `£500` / `£50`; the media links on each page are not.
- [ ] **Proof cards** (`#proof`) — real numbers for Broadland Products and Telemechry.
- [ ] **Case studies** (`/case-studies`) — every block on that page is a placeholder.
      Nothing has been invented for either firm.
- [ ] **Who you deal with** (`#who`) — your name, your words, and a real photograph.
- [ ] **Contact details** (`#contact`) — telephone and opening hours.
- [ ] **Service area postcodes** — SE21/22/24/27 are unverified. They appear in the
      contact section, the footer, and the JSON-LD on both pages. Fix all three together.
- [ ] **Email address** — `hello@northsaga.ai` appears in several places; search and replace.
- [ ] **Company registration line** in the footer.

---

## Notes

**Fonts** load from Google Fonts (Cormorant Garamond + Archivo). For a faster first
paint and no third-party request, download both, drop the `.woff2` files into
`assets/fonts/`, and swap the `<link>` in each page for local `@font-face` rules.
Worth doing before launch but not blocking.

**Logo SVGs use live text** for the "orthsaga" wordmark, so they need Cormorant
Garamond installed to render correctly outside the site. Before sending logo files to a
printer or signwriter, convert the text to outlines (Illustrator/Figma: Type → Create
Outlines) so it can't reflow.

**`assets/og-image.png` is generated** from `og-image.svg`. Regenerate it with a
browser that has the webfonts loaded — a plain SVG→PNG converter (cairosvg, rsvg)
substitutes a wider fallback face and the headline overflows the 1200px canvas.

**The mark draws itself** once on page load — four strokes, about a second. It respects
`prefers-reduced-motion`, as does every other transition on the site. That is the only
animated moment on the page, deliberately.

**Adding pages.** Copy `index.html`, keep the header, menu and footer blocks identical,
add the page to `sitemap.xml` and the `.menu-nav` list, and add a matching `nth-child`
stagger delay in `css/site.css`. `cleanUrls` is on, so `about.html` serves at `/about`.
NSEOF

cat > 'case-studies.html' <<'NSEOF'
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Case studies — Northsaga</title>
<meta name="description" content="What Northsaga installed at Broadland Products and Telemechry: the situation before, what went in, what changed, and the number attached to it.">

<link rel="canonical" href="https://northsaga.ai/case-studies">
<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="Case studies — Northsaga">
<meta property="og:description" content="Named firms. Named numbers.">
<meta property="og:type" content="article">
<meta property="og:url" content="https://northsaga.ai/case-studies">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Case studies — Northsaga">
<meta name="twitter:description" content="Named firms. Named numbers.">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal { opacity: 1; transform: none; }</style></noscript>

<!-- WebPage on a subpage. Identity lives on the homepage (Organization at
     https://northsaga.ai/#business). address/telephone/openingHours deliberately
     absent until confirmed; postcodes UNVERIFIED — correct in schema, contact
     section and footer together when the service area is confirmed. -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": "https://northsaga.ai/case-studies#page",
  "url": "https://northsaga.ai/case-studies",
  "name": "Case studies — Northsaga",
  "isPartOf": { "@id": "https://northsaga.ai/#website" },
  "about": { "@id": "https://northsaga.ai/#business" },
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>
</head>
<body>

<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>

<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
    <li><a href="/#work">The work</a></li>
    <li><a href="/#process">How it works</a></li>
    <li><a href="/case-studies" aria-current="page">Case studies</a></li>
    <li><a href="/#ledger">What it costs</a></li>
    <li><a href="/#proof">Proof</a></li>
    <li><a href="/journal/best-cron-jobs-for-ai-agents">Writing</a></li>
    <li><a href="/#contact">Talk to us</a></li>
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
  </div>
</nav>

<main>

<!-- ============================ INTRO ============================ -->
<section class="band band--tall" style="padding-top: calc(var(--space-7) + 2rem);">
  <div class="container">
    <p class="eyebrow">Case studies</p>
    <h1 class="display" style="font-size:var(--step-3); max-width:18ch;">
      The work, with the numbers left in.
    </h1>
    <p class="lede" style="margin-top:var(--space-3);">
      Two installs, described the way we would describe them to you on site: what the
      business looked like before, what went in, what changed, and the figure attached
      to it. Both firms are confirming their detail before it is printed here.
    </p>
  </div>
</section>

<!-- ============================================================================
     EVERY FACT ON THIS PAGE IS A PLACEHOLDER.

     Broadland Products and Telemechry are real companies. No situation,
     intervention, outcome, figure or quote was supplied for either one. Do not
     invent any of it — that would breach "no claims you cannot name a client
     for" (BRAND.md §6) and "proof over promise" (BRAND.md §7), on the page
     whose entire job is proof.

     Fill each block from what the client confirms, then remove the
     is-placeholder class from that element so the brass tag disappears.
     ============================================================================ -->

<section class="band band--tall" style="background:var(--ink-deep);">
  <div class="container">

    <!-- ---------------------------------------- Broadland Products ---- -->
    <article class="case reveal" id="broadland-products">
      <div class="case-head">
        <h2>Broadland Products</h2>
        <p class="case-meta">
          <span class="is-placeholder">Sector</span>
          <span class="is-placeholder">Installed</span>
        </p>
      </div>

      <div class="case-grid">
        <div class="case-block is-placeholder">
          <h3>Before</h3>
          <p>What the business was doing by hand, where the work stalled, and what
             the stall was costing. Replace with what Broadland confirms.</p>
        </div>
        <div class="case-block is-placeholder">
          <h3>What we installed</h3>
          <p>The agents by name, and the job profiles and scorecard they plug into.
             Replace with what Broadland confirms.</p>
        </div>
        <div class="case-block is-placeholder">
          <h3>What changed</h3>
          <p>What is different now, in the client's own terms, and who at the firm
             noticed. Replace with what Broadland confirms.</p>
        </div>
      </div>

      <div class="case-figure">
        <article class="proof-card is-placeholder">
          <span class="figure">00%</span>
          <p>The one number this install is accountable for. No figure ships until
             Broadland Products has confirmed it.</p>
          <cite>Broadland Products</cite>
        </article>
      </div>
    </article>

    <!-- ------------------------------------------------- Telemechry ---- -->
    <article class="case reveal" id="telemechry">
      <div class="case-head">
        <h2>Telemechry</h2>
        <p class="case-meta">
          <span>Route optimisation</span>
          <span class="is-placeholder">Sector</span>
          <span class="is-placeholder">Installed</span>
        </p>
      </div>

      <div class="case-grid">
        <div class="case-block is-placeholder">
          <h3>Before</h3>
          <p>How routes were planned before, who planned them, and what the planning
             cost in hours or fuel. Replace with what Telemechry confirms.</p>
        </div>
        <div class="case-block is-placeholder">
          <h3>What we installed</h3>
          <p>The route optimisation agent and whatever it connects to. Replace with
             what Telemechry confirms.</p>
        </div>
        <div class="case-block is-placeholder">
          <h3>What changed</h3>
          <p>What is different now, in the client's own terms. Replace with what
             Telemechry confirms.</p>
        </div>
      </div>

      <div class="case-figure">
        <article class="proof-card is-placeholder">
          <span class="figure">00 hrs</span>
          <p>The one number this install is accountable for. No figure ships until
             Telemechry has confirmed it.</p>
          <cite>Telemechry · Route optimisation</cite>
        </article>
      </div>
    </article>

  </div>
</section>

<!-- ============================ NEXT ============================ -->
<section class="band band--paper band--tall">
  <div class="container">
    <p class="eyebrow">Next</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:18ch;">
      Yours would start with a survey.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      Half a day, a fixed fee, and a map of your operation at the end of it — yours
      either way. The price for that, and for everything after it, is printed on the
      homepage.
    </p>
    <div class="hero-actions">
      <a class="btn" href="/#ledger">What it costs</a>
      <a class="btn btn--quiet" href="/#contact">Talk to us</a>
    </div>
  </div>
</section>

</main>

<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
        <a href="/#work">The work</a>
        <a href="/#process">How it works</a>
        <a href="/case-studies">Case studies</a>
        <a href="/#ledger">What it costs</a>
        <a href="/journal/best-cron-jobs-for-ai-agents">Writing</a>
        <a href="/#contact">Talk to us</a>
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>
</body>
</html>
NSEOF

cat > 'index.html' <<'NSEOF'
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Northsaga — AI agents installed into small businesses in Dulwich and West Norwood</title>
<meta name="description" content="We install AI agents into small businesses and trades around Dulwich and West Norwood, then maintain them. Fixed price to install, fixed price to keep. Built the old way. Runs the new way.">

<link rel="canonical" href="https://northsaga.ai/">
<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="Northsaga — AI agents installed into small businesses">
<meta property="og:description" content="Built the old way. Runs the new way.">
<meta property="og:type" content="website">
<meta property="og:url" content="https://northsaga.ai">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Northsaga — AI agents installed into small businesses">
<meta name="twitter:description" content="Built the old way. Runs the new way.">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal { opacity: 1; transform: none; }</style></noscript>

<!-- Organization identity. address, telephone and openingHours are deliberately
     absent rather than invented — add them once confirmed, then this can be a
     LocalBusiness again. Tree: Organization (identity) -> WebSite (searchable) +
     areaServed. sameAs only lists profiles that exist; GitHub is the only public
     one today. The postcodes in areaServed are UNVERIFIED; check them against
     the real service area and correct in the schema, contact section and footer
     together. -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "@id": "https://northsaga.ai/#business",
  "name": "Northsaga",
  "url": "https://northsaga.ai/",
  "email": "hello@northsaga.ai",
  "logo": {
    "@type": "ImageObject",
    "url": "https://northsaga.ai/assets/logo/northsaga-mark-bone.svg"
  },
  "description": "Installs and maintains AI agents for owner-managed small businesses and trades in Dulwich and West Norwood, south London.",
  "slogan": "New tools. Old standards.",
  "sameAs": [
    "https://github.com/ClespCoding/northsaga.ai"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "contactType": "customer service",
    "email": "hello@northsaga.ai",
    "availableLanguage": "English"
  },
  "areaServed": [
    { "@type": "Place", "name": "Dulwich, London" },
    { "@type": "Place", "name": "West Norwood, London" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE21", "postalCodeEnd": "SE21" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE22", "postalCodeEnd": "SE22" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE24", "postalCodeEnd": "SE24" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE27", "postalCodeEnd": "SE27" }
  ]
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": "https://northsaga.ai/#website",
  "url": "https://northsaga.ai/",
  "name": "Northsaga",
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>
</head>
<body>

<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>

<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
    <li><a href="#work">The work</a></li>
    <li><a href="#process">How it works</a></li>
    <li><a href="/case-studies">Case studies</a></li>
    <li><a href="#ledger">What it costs</a></li>
    <li><a href="#proof">Proof</a></li>
    <li><a href="/journal/best-cron-jobs-for-ai-agents">Writing</a></li>
    <li><a href="#contact">Talk to us</a></li>
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
  </div>
</nav>

<main>

<!-- ============================ HERO ============================ -->
<section class="hero">
  <div class="container">
    <div class="hero-lockup">
      <svg viewBox="-77 -167 259 334" aria-hidden="true">
        <g fill="none" stroke="currentColor" stroke-width="14">
          <path class="mark-path" style="--len:146"   d="M 0 -160 L -70 -32"/>
          <path class="mark-path" style="--len:320"   d="M 0 -160 L 0 160"/>
          <path class="mark-path" style="--len:365"   d="M 0 -160 L 175 160"/>
          <path class="mark-path" style="--len:320"   d="M 175 -160 L 175 160"/>
        </g>
      </svg>
      <span class="wordmark">orthsaga</span>
    </div>

    <h1>Built the old way.<br>Runs the <em>new</em> way.</h1>

    <p class="lede">
      We install AI agents into small businesses around Dulwich and West Norwood —
      the ones that answer your missed calls, chase your quotes and keep your reviews
      coming — and then we look after them. Fixed price to install. Fixed price to
      keep running.
    </p>

    <div class="hero-actions">
      <a class="btn" href="#ledger">See what it costs</a>
      <a class="btn btn--quiet" href="#work">What we install</a>
    </div>
  </div>
  <span class="hero-scroll">Scroll</span>
</section>

<!-- ============================ THE WORK ============================ -->
<section class="band band--paper band--tall" id="work">
  <div class="container">
    <p class="eyebrow">The work</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:18ch;">
      Six jobs you are currently doing yourself.
    </h2>

    <ul class="install-list">
      <!-- Two of these have an agent page so far. The rest get theirs as they
           are added to tools/build-agent-pages.py; paste tools/_homepage-list.html
           over this list once all of them exist. -->
      <li class="reveal">
        <h3><a href="/agents/answering-the-phone">Missed-call text-back</a></h3>
        <p>Every call you cannot answer gets a text within a minute asking what they need.
           Most of the work you lose, you lose here — usually to whoever picked up second.</p>
      </li>
      <li class="reveal">
        <h3><a href="/agents/quote-follow-up">Quote follow-up</a></h3>
        <p>Quotes get chased on day three, day seven and day fourteen without you
           remembering to do it. Chasing stops the moment they reply.</p>
      </li>
      <li class="reveal">
        <h3>Review chasing</h3>
        <p>A polite ask goes out once the job is signed off — to the right person,
           on the platform that actually matters for your trade.</p>
      </li>
      <li class="reveal">
        <h3>Enquiry triage</h3>
        <p>New enquiries sorted into work, suppliers and noise, with the urgent ones
           flagged before you have opened the laptop.</p>
      </li>
      <li class="reveal">
        <h3>Scheduling and reminders</h3>
        <p>Jobs booked into the diary, confirmations sent, and the day-before reminder
           that stops half your no-shows.</p>
      </li>
      <li class="reveal">
        <h3>Price and patch watch</h3>
        <p>We pull competitor and property data across your postcodes and send one page
           a month: who is charging what, where, and how it has moved since last time.</p>
      </li>
    </ul>
  </div>
</section>

<!-- ============================ PROCESS ============================ -->
<section class="band band--tall" id="process">
  <div class="container">
    <p class="eyebrow">How it works</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:20ch;">
      Survey the estate. Install once. Maintain it properly.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      The same order you would use for anything else you put into a business —
      wiring, plant, a new van. Nothing gets installed before it has been measured.
    </p>

    <ol class="steps">
      <li class="step reveal">
        <span class="num">01</span>
        <h3>Survey</h3>
        <p>Half a day, on site or on a call. We map how work actually moves through your
           business: who does what, where it stalls, and what the stall costs you.
           You keep the map whether or not you hire us.</p>
      </li>
      <li class="step reveal">
        <span class="num">02</span>
        <h3>Install</h3>
        <p>We build the agents and connect them to the tools you already use. One
           upfront price, agreed before anything starts. You see the number long
           before you see an invoice.</p>
      </li>
      <li class="step reveal">
        <span class="num">03</span>
        <h3>Maintain</h3>
        <p>Your prices change, your suppliers change, the software changes underneath
           you. A monthly fee keeps it running and tuned, with a named person to ring
           when it does not.</p>
      </li>
    </ol>
  </div>
</section>

<!-- ============================ THE LEDGER ============================ -->
<section class="band band--tall" id="ledger" style="background:var(--ink-deep);">
  <div class="container">
    <p class="eyebrow">What it costs</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:16ch;">
      Most agencies will not print this.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      Real ranges, not a starting-from figure designed to get us through the door.
      Where you land depends on how many agents you need and how tangled your systems
      already are. We give you the number before you commit — and if it shocks you,
      we would rather hear it then than later.
    </p>

    <!-- Two of the five lines are real: £500 to install an agent, £50 a month
         to maintain one. Three are still £000 — the survey, the full three-to-
         five-agent install, and the systems build. A heading that says "most
         agencies will not print this" sitting above any £000 undermines the
         brand at exactly the moment it draws attention to the pricing, so
         .is-placeholder stays on this block until all five are real. See
         CLAUDE.md. -->
    <div class="ledger is-placeholder">
      <div class="ledger-row">
        <span class="item">
          <strong>Operations survey</strong>
          <span>Half a day. You get the process map and the costings, yours to keep.</span>
        </span>
        <span class="figure">£000 <small>one-off · credited against install</small></span>
      </div>
      <div class="ledger-row">
        <span class="item">
          <strong>One agent, installed</strong>
          <span>Built, connected to your tools, tested on your real jobs, handed over working.</span>
        </span>
        <span class="figure">£500 <small>one-off · per agent</small></span>
      </div>
      <div class="ledger-row">
        <span class="item">
          <strong>Full install — three to five agents</strong>
          <span>The usual starting point for a firm of five to twenty people.</span>
        </span>
        <span class="figure">£0,000 <small>one-off</small></span>
      </div>
      <div class="ledger-row">
        <span class="item">
          <strong>Maintenance and tuning</strong>
          <span>Monitoring, fixes, changes as your business changes. A named person to ring.</span>
        </span>
        <span class="figure">£50 <small>per month, per agent · 30 days' notice</small></span>
      </div>
      <div class="ledger-row">
        <span class="item">
          <strong>Systems build</strong>
          <span>Job profiles, scorecards, quarterly priorities — the operating system the agents plug into.</span>
        </span>
        <span class="figure">from £0,000 <small>one-off · quoted per business</small></span>
      </div>
    </div>

    <div class="ledger-note">
      <p>No lock-in. No per-seat pricing. No percentage of your revenue.</p>
      <p>If you want to bring it in-house later, we hand over everything and show your
         team how to run it. That is the whole arrangement.</p>
    </div>
  </div>
</section>

<!-- ============================ PROOF ============================ -->
<section class="band band--tall" id="proof">
  <div class="container">
    <p class="eyebrow">Proof</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:18ch;">
      Named firms. Named numbers.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      One real job, described properly, is worth more than a page of claims about
      artificial intelligence. These are ours.
    </p>

    <!-- Broadland Products and Telemechry are real companies. No figure has been
         supplied for either. Do not invent one — see CLAUDE.md. -->
    <div class="proof">
      <article class="proof-card is-placeholder reveal">
        <span class="figure">00%</span>
        <p>One-line description of what changed, in the client's terms — jobs won,
           hours returned, calls answered. Replace with the real figure.</p>
        <cite>Broadland Products</cite>
      </article>
      <article class="proof-card is-placeholder reveal">
        <span class="figure">00 hrs</span>
        <p>Second case. Say what the business was doing by hand before, what it does
           now, and who at the firm noticed the difference.</p>
        <cite>Telemechry · Route optimisation</cite>
      </article>
    </div>

    <div class="hero-actions">
      <a class="btn" href="/case-studies">Read the case studies</a>
    </div>
  </div>
</section>

<!-- ============================ WHO ============================ -->
<section class="band band--paper band--tall" id="who">
  <div class="container">
    <p class="eyebrow">Who you deal with</p>
    <h2 class="display" style="font-size:var(--step-3); max-width:20ch;">
      The person who surveys it is the person who installs it.
    </h2>
    <div class="prose is-placeholder" style="margin-top:var(--space-3);">
      <p><strong>[Your name], founder.</strong> Two or three sentences in the first person:
         what you did before this, why you work with trades and small firms specifically,
         and what you will not do. Put a real photograph here — not an illustration and
         not a stock image. This section is doing more work for trust than anything else
         on the page.</p>
    </div>
  </div>
</section>

<!-- ============================ CONTACT ============================ -->
<section class="band band--tall" id="contact">
  <div class="container">
    <p class="eyebrow">Talk to us</p>
    <div class="contact-grid">
      <div>
        <h2 class="display" style="font-size:var(--step-3); max-width:16ch;">
          Start with the survey.
        </h2>
        <p class="lede" style="margin-top:var(--space-3);">
          Half a day, a fixed fee, and a map of your operation at the end of it —
          yours either way. If the numbers do not work for you, you will know inside
          a week rather than inside a quarter.
        </p>
        <div class="hero-actions">
          <a class="btn" href="mailto:hello@northsaga.ai">Book the survey</a>
        </div>
      </div>
      <div>
        <ul class="contact-lines is-placeholder">
          <li><span class="k">Email</span><span class="v">hello@northsaga.ai</span></li>
          <li><span class="k">Telephone</span><span class="v">0000 000 0000</span></li>
          <li><span class="k">Hours</span><span class="v">Mon–Fri, 8–6</span></li>
        </ul>

        <div class="service-area">
          <span class="k">Service area</span>
          <p>
            Dulwich and West Norwood, south London — SE21, SE22, SE24, SE27 and
            surrounding. Owner-managed firms of roughly three to thirty people:
            builders, electricians, plumbers, roofers, landscapers, garages,
            veterinary practices, dental and private clinics, estate and lettings
            agents, independent retailers and professional services.
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

</main>

<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
        <a href="#work">The work</a>
        <a href="#process">How it works</a>
        <a href="/case-studies">Case studies</a>
        <a href="#ledger">What it costs</a>
        <a href="/journal/best-cron-jobs-for-ai-agents">Writing</a>
        <a href="#contact">Talk to us</a>
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>
</body>
</html>
NSEOF

cat > 'llms.txt' <<'NSEOF'
# Northsaga

> New tools. Old standards.

Northsaga installs and maintains AI agents for owner-managed small businesses and trades in Dulwich and West Norwood, south London. Fixed price to install (£500 per agent), fixed price to maintain (£50 per agent per month). Every account is opened in the client's name, and clients can take the whole installation in-house on request.

Key pages:

- [Home](https://northsaga.ai/): what Northsaga does, what it costs, the six agents, the maintenance ledger
- [Case studies](https://northsaga.ai/case-studies): named firms, named numbers
- [Answering the phone agent](https://northsaga.ai/agents/answering-the-phone): voice agent + missed-call text-back, £500 installed / £50 a month maintained
- [Quote follow-up agent](https://northsaga.ai/agents/quote-follow-up): chasing quotes on day three, seven and fourteen, £500 installed / £50 a month maintained
- [The best cron jobs to set up for AI agents](https://northsaga.ai/journal/best-cron-jobs-for-ai-agents): twelve schedules Northsaga puts on every install, what each is for, and what breaks without it

Contact: hello@northsaga.ai

Optional standard: [llms.txt](https://llmstxt.org/)
NSEOF

cat > 'robots.txt' <<'NSEOF'
User-agent: *
Allow: /
Sitemap: https://northsaga.ai/sitemap.xml
NSEOF

cat > 'site.webmanifest' <<'NSEOF'
{
  "name": "Northsaga",
  "short_name": "Northsaga",
  "icons": [
    { "src": "/assets/favicon/favicon-32.png", "sizes": "32x32", "type": "image/png" },
    { "src": "/assets/favicon/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ],
  "theme_color": "#0E1A24",
  "background_color": "#0E1A24",
  "display": "standalone"
}
NSEOF

cat > 'sitemap.xml' <<'NSEOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://northsaga.ai/</loc>
    <lastmod>2026-08-06</lastmod>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://northsaga.ai/case-studies</loc>
    <lastmod>2026-08-06</lastmod>
    <priority>0.8</priority>
  </url>
  <url>
    <loc>https://northsaga.ai/agents/answering-the-phone</loc>
    <lastmod>2026-08-06</lastmod>
    <priority>0.8</priority>
  </url>
  <url>
    <loc>https://northsaga.ai/agents/quote-follow-up</loc>
    <lastmod>2026-08-06</lastmod>
    <priority>0.8</priority>
  </url>
  <url>
    <loc>https://northsaga.ai/journal/best-cron-jobs-for-ai-agents</loc>
    <lastmod>2026-08-06</lastmod>
    <priority>0.7</priority>
  </url>
</urlset>
NSEOF

cat > 'vercel.json' <<'NSEOF'
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": null,
  "buildCommand": null,
  "installCommand": "",
  "outputDirectory": ".",
  "cleanUrls": true,
  "trailingSlash": false,
  "redirects": [
    {
      "source": "/work/:slug",
      "destination": "/agents/:slug",
      "permanent": true
    }
  ],
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    },
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ]
}
NSEOF

cat > 'agents/answering-the-phone.html' <<'NSEOF'
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Answering the phone — Northsaga</title>
<meta name="description" content="A voice agent that answers the calls you miss, takes the job details, and texts the caller back inside a minute. Installed for £500, maintained for £50 a month.">

<link rel="canonical" href="https://northsaga.ai/agents/answering-the-phone">

<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="Answering the phone — Northsaga">
<meta property="og:description" content="Every call you cannot answer gets picked up. If it is not you, it is an agent that takes the name, the number and the job, and texts them back inside a minute.">
<meta property="og:type" content="article">
<meta property="og:url" content="https://northsaga.ai/agents/answering-the-phone">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Answering the phone — Northsaga">
<meta name="twitter:description" content="Every call you cannot answer gets picked up. If it is not you, it is an agent that takes the name, the number and the job, and texts them back inside a minute.">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">
<link rel="stylesheet" href="/css/work.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal { opacity: 1; transform: none; }</style></noscript>

<!-- WebPage stub. Identity lives on the homepage (Organization at
     https://northsaga.ai/#business). address, telephone and openingHours are
     deliberately absent rather than invented — add them once confirmed. The
     postcodes in areaServed are UNVERIFIED; check them against the real
     service area and correct here, in the contact section and in the footer
     together. -->

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": "https://northsaga.ai/agents/answering-the-phone#page",
  "url": "https://northsaga.ai/agents/answering-the-phone",
  "name": "Answering the phone — Northsaga",
  "isPartOf": { "@id": "https://northsaga.ai/#website" },
  "about": { "@id": "https://northsaga.ai/#business" },
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>

</head>
<body>
<!-- GENERATED FILE — do not hand-edit. Source: tools/build-agent-pages.py
     Edit there, then run: cd tools && python3 build-agent-pages.py -->

<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>

<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
    <li><a href="/#work" aria-current="page">The work</a></li>
    <li><a href="/#process">How it works</a></li>
    <li><a href="/case-studies">Case studies</a></li>
    <li><a href="/#ledger">What it costs</a></li>
    <li><a href="/#proof">Proof</a></li>
    <li><a href="/journal/best-cron-jobs-for-ai-agents">Writing</a></li>
    <li><a href="/#contact">Talk to us</a></li>
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
  </div>
</nav>

<main>

<!-- ============================ INTRO ============================ -->
<section class="band work-head">
  <div class="container">
    <p class="eyebrow">Agent 01 · Voice agent and missed-call text-back</p>
    <h1 class="display">Answering the phone</h1>
    <p class="lede" style="margin-top:var(--space-3);">Every call you cannot answer gets picked up. If it is not you, it is an agent that takes the name, the number and the job, and texts them back inside a minute.</p>

    <figure class="schematic">
  <div class="schematic-viewport" tabindex="0" role="group"
       aria-label="Drawing NS-01, scrollable and zoomable">
    <div class="schematic-stage" style="--sch-w:1002px">
      <svg viewBox="0 0 1002 356" preserveAspectRatio="xMidYMid meet"
           role="img" aria-label="Drawing NS-01. Answering the phone. Your mobile rings first; the agent only answers when you do not.">
        <title>Drawing NS-01. Answering the phone. Your mobile rings first; the agent only answers when you do not.</title>
        <path class="sch-wire" d="M 206 178 L 272 178"/>
        <path class="sch-arrow" d="M 272 178 L 265 173.66 L 265 182.34 Z"/>
        <path class="sch-wire" d="M 468 178 H 501 V 56 H 534"/>
        <path class="sch-arrow" d="M 534 56 L 527 51.66 L 527 60.34 Z"/>
        <path class="sch-wire" d="M 632 102 L 632 132"/>
        <path class="sch-arrow" d="M 632 132 L 627.66 125 L 636.34 125 Z"/>
        <path class="sch-wire" d="M 730 56 H 749 V 117 H 796"/>
        <path class="sch-arrow" d="M 796 117 L 789 112.66 L 789 121.34 Z"/>
        <path class="sch-wire" d="M 730 178 H 763 V 239 H 796"/>
        <path class="sch-arrow" d="M 796 239 L 789 234.66 L 789 243.34 Z"/>
        <path class="sch-wire" d="M 730 300 H 777 V 117 H 796"/>
        <path class="sch-arrow" d="M 796 117 L 789 112.66 L 789 121.34 Z"/>
        <g class="sch-node">
        <rect class="sch-box" x="10" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(24 145) scale(0.75)"><path class="sch-icon--fill" d="M7.6 2.6 4.2 6a2 2 0 0 0-.4 2.3 26 26 0 0 0 11.9 11.9 2 2 0 0 0 2.3-.4l3.4-3.4a1 1 0 0 0 0-1.4l-3.6-3.6a1 1 0 0 0-1.4 0l-1.7 1.7a19 19 0 0 1-4.5-4.5l1.7-1.7a1 1 0 0 0 0-1.4L9 2.6a1 1 0 0 0-1.4 0Z"/></g>
        <text class="sch-role" x="50" y="158">TRIGGER</text>
        <text class="sch-trigger" x="192" y="158" text-anchor="end">WEBHOOK</text>
        <text class="sch-label" x="24" y="188">Inbound call to</text>
        <text class="sch-label" x="24" y="206">your number</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="272" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(286 145) scale(0.75)"><path class="sch-icon--fill" d="M7 2h10a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2Z"/><path class="sch-icon--cut" d="M6.8 5.6h10.4v11.8H6.8Z"/></g>
        <text class="sch-role" x="312" y="158">ROUTING</text>
        <text class="sch-label" x="286" y="188">Rings your mobile</text>
        <text class="sch-label" x="286" y="206">for twenty seconds</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 23) scale(0.75)"><path class="sch-icon--fill" d="M12 2a3.2 3.2 0 0 0-3.2 3.2v6.4a3.2 3.2 0 0 0 6.4 0V5.2A3.2 3.2 0 0 0 12 2Z"/><path class="sch-icon--fill" d="M5.4 10.4H3.6a8.4 8.4 0 0 0 7.4 8.3V22h2v-3.3a8.4 8.4 0 0 0 7.4-8.3h-1.8a6.6 6.6 0 0 1-13.2 0Z"/></g>
        <text class="sch-role" x="574" y="36">VOICE AGENT</text>
        <text class="sch-label" x="548" y="66">Answers if you cannot.</text>
        <text class="sch-label" x="548" y="84">Asks three questions</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 145) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 0 0-8.7 15L2 22l5.2-1.3A10 10 0 1 0 12 2Z"/><path class="sch-icon--cut" d="M8.9 7.5c-.2-.4-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.4-.3.3-.9.8-.9 2s.9 2.4 1 2.6c.1.2 1.7 2.7 4.2 3.7 2 .9 2.5.7 2.9.7.5 0 1.4-.6 1.6-1.2.2-.6.2-1.1.1-1.2 0-.1-.2-.2-.5-.3l-1.7-.8c-.2-.1-.4-.1-.6.1l-.7 1c-.1.2-.3.2-.5.1-.2-.1-1-.4-1.9-1.2-.7-.6-1.2-1.4-1.3-1.6-.1-.2 0-.4.1-.5l.4-.5c.1-.1.2-.3.2-.4 0-.2 0-.3-.1-.4l-.6-1.9Z"/></g>
        <text class="sch-role" x="574" y="158">TEXT-BACK</text>
        <text class="sch-label" x="548" y="188">Text to the caller</text>
        <text class="sch-label" x="548" y="206">inside a minute</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 267) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z"/><path class="sch-icon--cut" d="M12 4.4a7.6 7.6 0 1 1 0 15.2 7.6 7.6 0 0 1 0-15.2Z"/><path class="sch-icon--fill" d="M11.2 6.4h1.6v6.4h-1.6Z"/><path class="sch-icon--fill" d="M11.2 11.2h5v1.6h-5Z"/></g>
        <text class="sch-role" x="574" y="280">SWEEP</text>
        <text class="sch-trigger" x="716" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="548" y="310">Catches anything</text>
        <text class="sch-label" x="548" y="328">the webhook missed</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="71" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 84) scale(0.75)"><path class="sch-icon--fill" d="M5 2h9l5 5v15H5Z"/><path class="sch-icon--cut" d="M7.4 11h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M7.4 14.2h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M7.4 17.4h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M11.3 10.4h1.5v9.2h-1.5Z"/></g>
        <text class="sch-role" x="836" y="97">JOB SHEET</text>
        <text class="sch-label" x="810" y="127">One row: name, job,</text>
        <text class="sch-label" x="810" y="145">postcode, urgency</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="193" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 206) scale(0.75)"><path class="sch-icon--fill" d="M12 2a5.6 5.6 0 0 0-5.6 5.6v3.6L4 15.4v1.4h16v-1.4l-2.4-4.2V7.6A5.6 5.6 0 0 0 12 2Z"/><path class="sch-icon--fill" d="M9.4 18.4a2.6 2.6 0 0 0 5.2 0Z"/></g>
        <text class="sch-role" x="836" y="219">ALERT</text>
        <text class="sch-label" x="810" y="249">The same thing to</text>
        <text class="sch-label" x="810" y="267">your phone and inbox</text>
        </g>
      </svg>
    </div>
  </div>
  <figcaption><span class="sch-no">NS-01</span>Answering the phone. Your mobile rings first; the agent only answers when you do not.</figcaption>
</figure>

    <div class="prose" style="margin-top:var(--space-5);">
      <p>Most of the work a small firm loses, it loses at the phone. Not to a better quote. To whoever picked up second.</p><p>You are on a roof, under a sink, or driving. The phone rings out. The caller has three more numbers on the same search page and no particular reason to prefer yours. By the time you hear the voicemail — if they left one, and most do not — the job belongs to somebody else.</p><p>This is the agent that stops that. It rings your mobile first, because if you can answer, you should. If you cannot, it answers, takes the details in a plain voice, and writes them down where you will see them. The caller has a text from you before they have dialled the next number.</p>
    </div>
  </div>
</section>

<!-- ============================ STAGES ============================ -->
<section class="band band--tall" id="stages">
  <div class="container">
    <p class="eyebrow">What happens, in order</p>
    <ol class="stages">
      <li class="reveal">
        <span class="num">01</span>
        <div>
          <h3>The call comes in</h3>
          <p>It rings your mobile for twenty seconds, exactly as it does now. If you pick up, the agent never runs and you never hear from it. Nothing about your day changes on the calls you can take.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">02</span>
        <div>
          <h3>The agent answers</h3>
          <p>It gives the firm's name and asks three things: what the job is, where it is, and when they need it. It does not pretend to be a person, and it does not quote. Quoting is yours.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">03</span>
        <div>
          <h3>The details get written down</h3>
          <p>Name, number, postcode, job, urgency. One row on the job sheet, one line in your inbox, one text to your phone. The same five facts in all three, so there is nothing to reconcile later.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">04</span>
        <div>
          <h3>The caller gets a text</h3>
          <p>Inside a minute, in your name. We missed you, here is what we do, reply here and we will ring back. Most people answer that text rather than carry on down the list.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">05</span>
        <div>
          <h3>You ring back knowing something</h3>
          <p>You are not returning a blank missed call. You know the job, the address and whether it can wait until Thursday.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">06</span>
        <div>
          <h3>Nothing gets quietly lost</h3>
          <p>A sweep runs every five minutes and picks up anything the telephony provider failed to hand over. A call that neither of you answered appears on the sheet as a miss, rather than not appearing at all.</p>
        </div>
      </li>
    </ol>
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
      <li class="reveal">
        <h3>Docker</h3>
        <p>One compose file per client, version-controlled. Everything below runs inside it.</p>
      </li>
      <li class="reveal">
        <h3>n8n, self-hosted</h3>
        <p>The drawing above, as nodes you can watch run. You get a login on day one.</p>
      </li>
      <li class="reveal">
        <h3>Python 3.12</h3>
        <p>The workers: the five-minute sweep, the tidy-up of what the agent heard, and the writes to the sheet.</p>
      </li>
      <li class="reveal">
        <h3>cron</h3>
        <p>Two schedules on this workflow. The sweep, and the Monday morning summary.</p>
      </li>
      <li class="reveal">
        <h3>Telephony</h3>
        <p>Twilio, or your existing provider if it has an API worth the name. The number, the twenty-second fork to your mobile, and the text-back all sit here.</p>
      </li>
      <li class="reveal">
        <h3>A voice model</h3>
        <p>Answers, listens, asks its three questions, stops. Not a chatbot with a phone line attached.</p>
      </li>
      <li class="reveal">
        <h3>Google Sheets</h3>
        <p>The job sheet. Anything a person needs to read during the working day lives here, because everyone can already read a spreadsheet.</p>
      </li>
      <li class="reveal">
        <h3>The warehouse</h3>
        <p>Still to be chosen — <span class="tbd">product name to be confirmed</span>. Every call, every miss, every callback, kept with its history so the monthly figures are countable rather than remembered.</p>
      </li>
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

    <figure class="schematic">
  <div class="schematic-viewport" tabindex="0" role="group"
       aria-label="Drawing NS-00, scrollable and zoomable">
    <div class="schematic-stage" style="--sch-w:1002px">
      <svg viewBox="0 0 1002 396" preserveAspectRatio="xMidYMid meet"
           role="img" aria-label="Drawing NS-00. The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.">
        <title>Drawing NS-00. The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.</title>
        <path class="sch-wire" d="M 206 178 L 272 178"/>
        <path class="sch-arrow" d="M 272 178 L 265 173.66 L 265 182.34 Z"/>
        <path class="sch-wire" d="M 468 178 H 501 V 56 H 534"/>
        <path class="sch-arrow" d="M 534 56 L 527 51.66 L 527 60.34 Z"/>
        <path class="sch-wire" d="M 468 178 L 534 178"/>
        <path class="sch-arrow" d="M 534 178 L 527 173.66 L 527 182.34 Z"/>
        <path class="sch-wire" d="M 468 178 H 501 V 300 H 534"/>
        <path class="sch-arrow" d="M 534 300 L 527 295.66 L 527 304.34 Z"/>
        <path class="sch-wire" d="M 730 56 L 796 56"/>
        <path class="sch-arrow" d="M 796 56 L 789 51.66 L 789 60.34 Z"/>
        <path class="sch-wire" d="M 730 56 H 756 V 178 H 796"/>
        <path class="sch-arrow" d="M 796 178 L 789 173.66 L 789 182.34 Z"/>
        <path class="sch-wire" d="M 730 178 H 770 V 56 H 796"/>
        <path class="sch-arrow" d="M 796 56 L 789 51.66 L 789 60.34 Z"/>
        <path class="sch-wire" d="M 730 300 L 796 300"/>
        <path class="sch-arrow" d="M 796 300 L 789 295.66 L 789 304.34 Z"/>
        <path class="sch-wire sch-wire--dash" d="M 894 346 V 366 H 239 V 178 H 272"/>
        <path class="sch-arrow" d="M 272 178 L 265 173.66 L 265 182.34 Z"/>
        <g class="sch-node">
        <rect class="sch-box" x="10" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(24 145) scale(0.75)"><path class="sch-icon--fill" d="M2.6 4h18.8v6.4H2.6Z"/><path class="sch-icon--fill" d="M2.6 13.6h18.8V20H2.6Z"/><path class="sch-icon--cut" d="M5.2 6.4h2v1.6h-2Z"/><path class="sch-icon--cut" d="M5.2 16h2v1.6h-2Z"/><path class="sch-icon--cut" d="M8.6 6.4h6v1.6h-6Z"/><path class="sch-icon--cut" d="M8.6 16h6v1.6h-6Z"/></g>
        <text class="sch-role" x="50" y="158">HOST</text>
        <text class="sch-label" x="24" y="188">A spare PC, a NUC in</text>
        <text class="sch-label" x="24" y="206">the office, or a VPS</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="272" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(286 145) scale(0.75)"><path class="sch-icon--fill" d="M3.2 10.6h3.4V14H3.2Z"/><path class="sch-icon--fill" d="M7.3 10.6h3.4V14H7.3Z"/><path class="sch-icon--fill" d="M11.4 10.6h3.4V14h-3.4Z"/><path class="sch-icon--fill" d="M7.3 6.7h3.4v3.4H7.3Z"/><path class="sch-icon--fill" d="M11.4 6.7h3.4v3.4h-3.4Z"/><path class="sch-icon--fill" d="M11.4 2.8h3.4v3.4h-3.4Z"/><path class="sch-icon--fill" d="M1.8 15.2h20.4c-.9 3.6-4.6 5.8-9.6 5.8-5.6 0-9.4-2-10.8-5.8Z"/></g>
        <text class="sch-role" x="312" y="158">DOCKER</text>
        <text class="sch-label" x="286" y="188">One compose file,</text>
        <text class="sch-label" x="286" y="206">version-controlled</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 23) scale(0.75)"><path class="sch-icon--fill" d="M3.4 12a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--fill" d="M15.2 6.6a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--fill" d="M15.2 17.4a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--line" d="M6.1 12 17.9 6.6"/><path class="sch-icon--line" d="M6.1 12 17.9 17.4"/></g>
        <text class="sch-role" x="574" y="36">N8N</text>
        <text class="sch-trigger" x="716" y="36" text-anchor="end">WEBHOOK</text>
        <text class="sch-label" x="548" y="66">The drawing above,</text>
        <text class="sch-label" x="548" y="84">as nodes you can watch</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 145) scale(0.75)"><path class="sch-icon--fill" d="M9.2 4.6 3 12l6.2 7.4 1.7-1.4L5.8 12l5.1-6Z"/><path class="sch-icon--fill" d="M14.8 4.6 21 12l-6.2 7.4-1.7-1.4L18.2 12l-5.1-6Z"/></g>
        <text class="sch-role" x="574" y="158">PYTHON 3.12</text>
        <text class="sch-label" x="548" y="188">Workers for the jobs</text>
        <text class="sch-label" x="548" y="206">n8n should not do</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 267) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z"/><path class="sch-icon--cut" d="M12 4.4a7.6 7.6 0 1 1 0 15.2 7.6 7.6 0 0 1 0-15.2Z"/><path class="sch-icon--fill" d="M11.2 6.4h1.6v6.4h-1.6Z"/><path class="sch-icon--fill" d="M11.2 11.2h5v1.6h-5Z"/></g>
        <text class="sch-role" x="574" y="280">CRON</text>
        <text class="sch-trigger" x="716" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="548" y="310">Anything on a clock</text>
        <text class="sch-label" x="548" y="328">rather than a trigger</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 23) scale(0.75)"><path class="sch-icon--fill" d="M12 2c-4.4 0-8 1.3-8 3v14c0 1.7 3.6 3 8 3s8-1.3 8-3V5c0-1.7-3.6-3-8-3Z"/><path class="sch-icon--cut" d="M4 8.2c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3-.6-8-1.6Z"/><path class="sch-icon--cut" d="M4 13.4c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3-.6-8-1.6Z"/></g>
        <text class="sch-role" x="836" y="36">DATA LAYER</text>
        <text class="sch-label" x="810" y="66">Sheets to read,</text>
        <text class="sch-label" x="810" y="84">warehouse for history</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 145) scale(0.75)"><path class="sch-icon--fill" d="M20.7 4.6a5.6 5.6 0 0 1-7 7l-7.3 7.3a2.2 2.2 0 1 1-3.1-3.1l7.3-7.3a5.6 5.6 0 0 1 7-7l-3.3 3.3.9 3.2 3.2.9Z"/></g>
        <text class="sch-role" x="836" y="158">YOUR TOOLS</text>
        <text class="sch-label" x="810" y="188">Phone, email, diary,</text>
        <text class="sch-label" x="810" y="206">accounts, ads</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 267) scale(0.75)"><path class="sch-icon--line" d="M2 12h4.6l2.4-5.8 3.5 11.6 2.4-6.4 1.5 2.6H22"/></g>
        <text class="sch-role" x="836" y="280">HEALTH CHECK</text>
        <text class="sch-trigger" x="978" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="810" y="310">Heartbeat out</text>
        <text class="sch-label" x="810" y="328">every two minutes</text>
        </g>
      </svg>
    </div>
  </div>
  <figcaption><span class="sch-no">NS-00</span>The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.</figcaption>
</figure>

    <ol class="build-steps">
      <li class="reveal">
        <span class="num">01</span>
        <div>
          <h3>The box it runs in</h3>
          <p>Docker on the host. That host is a spare PC in the office, a NUC on a shelf, or a VPS at about five pounds a month — whichever you already have. One <code>docker-compose.yml</code> per client, kept in version control, brought up with <code>docker compose up -d</code>. If the machine dies, the same file on a new machine puts everything back.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">02</span>
        <div>
          <h3>Inside the container</h3>
          <p>Python 3.12, and only the libraries this workflow actually needs: <code>requests</code> for the telephony API, <code>gspread</code> for the job sheet, and <code>python-dateutil</code> for the working-hours logic. <code>cron</code> goes in the same image for anything that runs on a clock rather than on a trigger.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">03</span>
        <div>
          <h3>The cron jobs</h3>
          <p>This workflow needs two. <code>*/5 * * * *</code> sweeps for calls the webhook did not deliver, because telephony webhooks fail quietly and a silent failure here is a lost job. <code>0 7 * * 1</code> sends the Monday morning summary: calls taken, calls missed, callbacks made. The full list we run on an agent, and what breaks when each one is missing, is written up in <a href="/journal/best-cron-jobs-for-ai-agents">the cron jobs worth setting up for an agent</a>.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">04</span>
        <div>
          <h3>n8n</h3>
          <p>Self-hosted, in the same compose file. This is where the drawing above stops being a drawing: every box is a node, and every arrow is a connection you can click. You get a login and can watch a call move through it in real time. We would rather you looked than took our word for it.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">05</span>
        <div>
          <h3>Credentials and accounts</h3>
          <p>Every account is opened in your name, on your card, with us added as a partner. Not ours with you as a guest. If you want us gone, you remove us in one click and everything keeps running. That is the arrangement, and it is a selling point rather than a footnote.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">06</span>
        <div>
          <h3>The data layer</h3>
          <p>Google Sheets for the job sheet, because a person has to read it between jobs. The warehouse — <span class="tbd">to be confirmed</span> — for anything with history: every call, every miss, every callback, every recording reference. Sheets is for today. The warehouse is for the question you will ask in March about last October.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">07</span>
        <div>
          <h3>Wiring the phone in</h3>
          <p>In this order, because each step needs the one before it. The number first, ported or new. Then the fork to your mobile with the twenty-second timeout. Then the voice agent on the far side of that timeout. Then the text-back on the same number, so the message comes from the number they rang. Then the write to the sheet. Then the alert to you. Testing the text-back before the number is live tests nothing.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">08</span>
        <div>
          <h3>Testing on real calls before hand-over</h3>
          <p>We ring it ourselves from four or five different phones, including one with a bad line, and we get somebody who is not us to ring it too. It has to answer in under six rings, get the postcode right, write one row rather than two, and text back inside sixty seconds. It has to do all of that on ten consecutive calls. Until it does, it is not finished and we do not invoice.</p>
        </div>
      </li>
    </ol>
  </div>
</section>

<!-- ============================ MEDIA ============================ -->
<section class="band" id="media">
  <div class="container">
    <p class="eyebrow">See it working</p>
    <ul class="media-list is-placeholder">
      <li>
        <h3>Recording of a real call</h3>
        <p>A thirty-second clip of the agent taking a job, with the client's permission and the caller's.</p>
      </li>
      <li>
        <h3>The job sheet</h3>
        <p>A screenshot of a real week, with names removed.</p>
      </li>
      <li>
        <h3>The text as the caller sees it</h3>
        <p>A photograph of the phone, not a mock-up.</p>
      </li>
    </ul>
  </div>
</section>

<!-- ============================ PRICE ============================ -->
<section class="band band--tall" id="price" style="background:var(--ink-deep);">
  <div class="container">
    <p class="eyebrow">What this one costs</p>
    <div class="price-block">
      <div class="price-row">
        <span class="item">
          <strong>Installed</strong>
          <span>Built, connected to the tools you already use, tested on your real jobs, handed over working.</span>
        </span>
        <span class="figure">£500 <small>one-off</small></span>
      </div>
      <div class="price-row">
        <span class="item">
          <strong>Maintained</strong>
          <span>Monitoring, fixes, and changes as the business changes. A named person to ring.</span>
        </span>
        <span class="figure">£50 <small>per month</small></span>
      </div>
    </div>
    <p class="price-note">You get that number before anything starts, not after. If it is not the number you were expecting, say so then — it is a much cheaper conversation than the one at the end.</p>

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
      <a class="work-back" href="/#work">All of the work</a>
      <a class="work-next" href="/agents/quote-follow-up"><span>Next</span>Quote follow-up</a>
    </div>
  </div>
</nav>

</main>

<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
        <a href="/#work">The work</a>
        <a href="/#process">How it works</a>
        <a href="/case-studies">Case studies</a>
        <a href="/#ledger">What it costs</a>
        <a href="/journal/best-cron-jobs-for-ai-agents">Writing</a>
        <a href="/#contact">Talk to us</a>
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>
<script src="/js/schematic.js" defer></script>
</body>
</html>
NSEOF

cat > 'agents/quote-follow-up.html' <<'NSEOF'
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quote follow-up — Northsaga</title>
<meta name="description" content="An agent that chases your quotes on day three, seven and fourteen and stops the moment the customer replies. Installed for £500, maintained for £50 a month.">

<link rel="canonical" href="https://northsaga.ai/agents/quote-follow-up">

<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="Quote follow-up — Northsaga">
<meta property="og:description" content="Every quote you send gets chased on day three, day seven and day fourteen, in your name, without you remembering to do it. One reply and the chasing stops that minute.">
<meta property="og:type" content="article">
<meta property="og:url" content="https://northsaga.ai/agents/quote-follow-up">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Quote follow-up — Northsaga">
<meta name="twitter:description" content="Every quote you send gets chased on day three, day seven and day fourteen, in your name, without you remembering to do it. One reply and the chasing stops that minute.">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">
<link rel="stylesheet" href="/css/work.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal { opacity: 1; transform: none; }</style></noscript>

<!-- WebPage stub. Identity lives on the homepage (Organization at
     https://northsaga.ai/#business). address, telephone and openingHours are
     deliberately absent rather than invented — add them once confirmed. The
     postcodes in areaServed are UNVERIFIED; check them against the real
     service area and correct here, in the contact section and in the footer
     together. -->

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": "https://northsaga.ai/agents/quote-follow-up#page",
  "url": "https://northsaga.ai/agents/quote-follow-up",
  "name": "Quote follow-up — Northsaga",
  "isPartOf": { "@id": "https://northsaga.ai/#website" },
  "about": { "@id": "https://northsaga.ai/#business" },
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>

</head>
<body>
<!-- GENERATED FILE — do not hand-edit. Source: tools/build-agent-pages.py
     Edit there, then run: cd tools && python3 build-agent-pages.py -->

<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>

<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
    <li><a href="/#work" aria-current="page">The work</a></li>
    <li><a href="/#process">How it works</a></li>
    <li><a href="/case-studies">Case studies</a></li>
    <li><a href="/#ledger">What it costs</a></li>
    <li><a href="/#proof">Proof</a></li>
    <li><a href="/journal/best-cron-jobs-for-ai-agents">Writing</a></li>
    <li><a href="/#contact">Talk to us</a></li>
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
  </div>
</nav>

<main>

<!-- ============================ INTRO ============================ -->
<section class="band work-head">
  <div class="container">
    <p class="eyebrow">Agent 02 · Chasing on day three, seven and fourteen</p>
    <h1 class="display">Quote follow-up</h1>
    <p class="lede" style="margin-top:var(--space-3);">Every quote you send gets chased on day three, day seven and day fourteen, in your name, without you remembering to do it. One reply and the chasing stops that minute.</p>

    <figure class="schematic">
  <div class="schematic-viewport" tabindex="0" role="group"
       aria-label="Drawing NS-02, scrollable and zoomable">
    <div class="schematic-stage" style="--sch-w:740px">
      <svg viewBox="0 0 740 396" preserveAspectRatio="xMidYMid meet"
           role="img" aria-label="Drawing NS-02. Quote follow-up. The chaser reads the register every morning; the reply watch writes back to it and the chasing stops.">
        <title>Drawing NS-02. Quote follow-up. The chaser reads the register every morning; the reply watch writes back to it and the chasing stops.</title>
        <path class="sch-wire" d="M 206 178 H 239 V 117 H 272"/>
        <path class="sch-arrow" d="M 272 117 L 265 112.66 L 265 121.34 Z"/>
        <path class="sch-wire" d="M 206 178 H 239 V 239 H 272"/>
        <path class="sch-arrow" d="M 272 239 L 265 234.66 L 265 243.34 Z"/>
        <path class="sch-wire" d="M 468 239 H 501 V 56 H 534"/>
        <path class="sch-arrow" d="M 534 56 L 527 51.66 L 527 60.34 Z"/>
        <path class="sch-wire" d="M 468 239 H 501 V 178 H 534"/>
        <path class="sch-arrow" d="M 534 178 L 527 173.66 L 527 182.34 Z"/>
        <path class="sch-wire sch-wire--dash" d="M 632 346 V 366 H 239 V 117 H 272"/>
        <path class="sch-arrow" d="M 272 117 L 265 112.66 L 265 121.34 Z"/>
        <g class="sch-node">
        <rect class="sch-box" x="10" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(24 145) scale(0.75)"><path class="sch-icon--fill" d="M5 2h9l5 5v15H5Z"/><path class="sch-icon--cut" d="M7.6 11h8.8v1.5H7.6Z"/><path class="sch-icon--cut" d="M7.6 14.2h8.8v1.5H7.6Z"/><path class="sch-icon--cut" d="M7.6 17.4h5.4v1.5H7.6Z"/></g>
        <text class="sch-role" x="50" y="158">TRIGGER</text>
        <text class="sch-trigger" x="192" y="158" text-anchor="end">WEBHOOK</text>
        <text class="sch-label" x="24" y="188">You send a quote from</text>
        <text class="sch-label" x="24" y="206">the tool you already use</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="272" y="71" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(286 84) scale(0.75)"><path class="sch-icon--fill" d="M5 2h9l5 5v15H5Z"/><path class="sch-icon--cut" d="M7.4 11h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M7.4 14.2h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M7.4 17.4h9.2v1.5H7.4Z"/><path class="sch-icon--cut" d="M11.3 10.4h1.5v9.2h-1.5Z"/></g>
        <text class="sch-role" x="312" y="97">REGISTER</text>
        <text class="sch-label" x="286" y="127">One row: who, what,</text>
        <text class="sch-label" x="286" y="145">how much, what day</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="272" y="193" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(286 206) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z"/><path class="sch-icon--cut" d="M12 4.4a7.6 7.6 0 1 1 0 15.2 7.6 7.6 0 0 1 0-15.2Z"/><path class="sch-icon--fill" d="M11.2 6.4h1.6v6.4h-1.6Z"/><path class="sch-icon--fill" d="M11.2 11.2h5v1.6h-5Z"/></g>
        <text class="sch-role" x="312" y="219">CHASER</text>
        <text class="sch-trigger" x="454" y="219" text-anchor="end">CRON</text>
        <text class="sch-label" x="286" y="249">Nine each morning.</text>
        <text class="sch-label" x="286" y="267">Day three, seven, fourteen</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 23) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 0 0-8.7 15L2 22l5.2-1.3A10 10 0 1 0 12 2Z"/><path class="sch-icon--cut" d="M8.9 7.5c-.2-.4-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.4-.3.3-.9.8-.9 2s.9 2.4 1 2.6c.1.2 1.7 2.7 4.2 3.7 2 .9 2.5.7 2.9.7.5 0 1.4-.6 1.6-1.2.2-.6.2-1.1.1-1.2 0-.1-.2-.2-.5-.3l-1.7-.8c-.2-.1-.4-.1-.6.1l-.7 1c-.1.2-.3.2-.5.1-.2-.1-1-.4-1.9-1.2-.7-.6-1.2-1.4-1.3-1.6-.1-.2 0-.4.1-.5l.4-.5c.1-.1.2-.3.2-.4 0-.2 0-.3-.1-.4l-.6-1.9Z"/></g>
        <text class="sch-role" x="574" y="36">MESSAGE</text>
        <text class="sch-label" x="548" y="66">WhatsApp or text,</text>
        <text class="sch-label" x="548" y="84">sent in your name</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 145) scale(0.75)"><path class="sch-icon--fill" d="M2 4.6h20v14.8H2Z"/><path class="sch-icon--cut" d="M3.6 6.6 12 12.6l8.4-6v2L12 14.6 3.6 8.6Z"/></g>
        <text class="sch-role" x="574" y="158">EMAIL</text>
        <text class="sch-label" x="548" y="188">The same words, on</text>
        <text class="sch-label" x="548" y="206">the same thread</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 267) scale(0.75)"><path class="sch-icon--fill" d="M10 5.4 2.4 12l7.6 6.6V14c5 0 8.4 1.6 10.6 5-.9-4.7-3.7-9.3-10.6-10Z"/></g>
        <text class="sch-role" x="574" y="280">REPLY WATCH</text>
        <text class="sch-trigger" x="716" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="548" y="310">Checks every ten minutes.</text>
        <text class="sch-label" x="548" y="328">A reply stops it</text>
        </g>
      </svg>
    </div>
  </div>
  <figcaption><span class="sch-no">NS-02</span>Quote follow-up. The chaser reads the register every morning; the reply watch writes back to it and the chasing stops.</figcaption>
</figure>

    <div class="prose" style="margin-top:var(--space-5);">
      <p>A quote that is never chased is not a quote. It is a document you spent an evening writing.</p><p>Most small firms chase the first time and then stop, because the second chase is the awkward one and there is always something more urgent than an awkward message. So the quote sits there. The customer is not saying no. They have three quotes, a job that is not on fire, and no reason to decide today. Whoever asks last usually gets the work.</p><p>This is the agent that asks. It knows what you sent, who you sent it to and when, and it comes back three times over a fortnight. Not a template that reads like a template — your words, your name, the job named. And the moment they reply, by any route, it stops. Nobody has ever bought anything from a firm that chased them after they answered.</p>
    </div>
  </div>
</section>

<!-- ============================ STAGES ============================ -->
<section class="band band--tall" id="stages">
  <div class="container">
    <p class="eyebrow">What happens, in order</p>
    <ol class="stages">
      <li class="reveal">
        <span class="num">01</span>
        <div>
          <h3>You send the quote as you always did</h3>
          <p>Nothing changes about how you write or send it. The agent picks it up from your quoting tool, your sent folder or a row you add yourself, whichever you already do. If it means changing how you quote, we have built the wrong thing.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">02</span>
        <div>
          <h3>It gets written down properly</h3>
          <p>Who it went to, what the job is, what you quoted, and the date. One row on the quote sheet. That row is the whole memory of the thing — everything after this reads from it.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">03</span>
        <div>
          <h3>Day three: the short one</h3>
          <p>Two lines. Did it arrive, and is there anything you want going through before they decide. Sent on the channel they contacted you on, because a customer who rang wants a text and a customer who emailed wants an email.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">04</span>
        <div>
          <h3>Day seven: the useful one</h3>
          <p>This one carries something — when you could start, what the price includes, or the answer to the question people always ask about that kind of job. A chase that adds nothing is just a chase.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">05</span>
        <div>
          <h3>Day fourteen: the last one</h3>
          <p>Plainly the last. It says so. Either the job is still live or it is not, and the customer gets to say which without feeling rude. That is usually the message that gets an answer.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">06</span>
        <div>
          <h3>Any reply, and it stops</h3>
          <p>By text, by email, by picking up the phone. The reply watch runs every ten minutes and closes the sequence the same morning. It cannot chase somebody who has already answered you, which is the failure that would cost you the job outright.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">07</span>
        <div>
          <h3>You find out what actually happens</h3>
          <p>Won, lost, or no answer, against what you quoted. After three months you know your real conversion rate and which of the three messages does the work. Most firms have never had that number.</p>
        </div>
      </li>
    </ol>
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
      <li class="reveal">
        <h3>Docker</h3>
        <p>The same compose file as every other agent. This one is another service inside it, not another machine.</p>
      </li>
      <li class="reveal">
        <h3>n8n, self-hosted</h3>
        <p>The drawing above, as nodes you can watch run. Same login as the phone agent if you already have one.</p>
      </li>
      <li class="reveal">
        <h3>Python 3.12</h3>
        <p>The workers: reading the register, deciding who is due a chase today, and matching an inbound reply back to the right quote.</p>
      </li>
      <li class="reveal">
        <h3>cron</h3>
        <p>Two schedules. The nine o'clock chaser, and the ten-minute reply watch.</p>
      </li>
      <li class="reveal">
        <h3>WhatsApp or SMS</h3>
        <p>The WhatsApp Business API where you already use it, otherwise Twilio or your existing provider. Messages go out from your number, not a short code nobody recognises.</p>
      </li>
      <li class="reveal">
        <h3>Email</h3>
        <p>Sent through your own mailbox, on the original thread, so the chase lands under the quote rather than as a fresh message with no context.</p>
      </li>
      <li class="reveal">
        <h3>Google Sheets</h3>
        <p>The quote register. You can open it, sort it and correct it, and the agent reads your corrections on the next run.</p>
      </li>
      <li class="reveal">
        <h3>The warehouse</h3>
        <p>Still to be chosen — <span class="tbd">product name to be confirmed</span>. Every quote, every chase and every outcome kept with its dates, so the conversion rate is a figure rather than a feeling.</p>
      </li>
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

    <figure class="schematic">
  <div class="schematic-viewport" tabindex="0" role="group"
       aria-label="Drawing NS-00, scrollable and zoomable">
    <div class="schematic-stage" style="--sch-w:1002px">
      <svg viewBox="0 0 1002 396" preserveAspectRatio="xMidYMid meet"
           role="img" aria-label="Drawing NS-00. The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.">
        <title>Drawing NS-00. The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.</title>
        <path class="sch-wire" d="M 206 178 L 272 178"/>
        <path class="sch-arrow" d="M 272 178 L 265 173.66 L 265 182.34 Z"/>
        <path class="sch-wire" d="M 468 178 H 501 V 56 H 534"/>
        <path class="sch-arrow" d="M 534 56 L 527 51.66 L 527 60.34 Z"/>
        <path class="sch-wire" d="M 468 178 L 534 178"/>
        <path class="sch-arrow" d="M 534 178 L 527 173.66 L 527 182.34 Z"/>
        <path class="sch-wire" d="M 468 178 H 501 V 300 H 534"/>
        <path class="sch-arrow" d="M 534 300 L 527 295.66 L 527 304.34 Z"/>
        <path class="sch-wire" d="M 730 56 L 796 56"/>
        <path class="sch-arrow" d="M 796 56 L 789 51.66 L 789 60.34 Z"/>
        <path class="sch-wire" d="M 730 56 H 756 V 178 H 796"/>
        <path class="sch-arrow" d="M 796 178 L 789 173.66 L 789 182.34 Z"/>
        <path class="sch-wire" d="M 730 178 H 770 V 56 H 796"/>
        <path class="sch-arrow" d="M 796 56 L 789 51.66 L 789 60.34 Z"/>
        <path class="sch-wire" d="M 730 300 L 796 300"/>
        <path class="sch-arrow" d="M 796 300 L 789 295.66 L 789 304.34 Z"/>
        <path class="sch-wire sch-wire--dash" d="M 894 346 V 366 H 239 V 178 H 272"/>
        <path class="sch-arrow" d="M 272 178 L 265 173.66 L 265 182.34 Z"/>
        <g class="sch-node">
        <rect class="sch-box" x="10" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(24 145) scale(0.75)"><path class="sch-icon--fill" d="M2.6 4h18.8v6.4H2.6Z"/><path class="sch-icon--fill" d="M2.6 13.6h18.8V20H2.6Z"/><path class="sch-icon--cut" d="M5.2 6.4h2v1.6h-2Z"/><path class="sch-icon--cut" d="M5.2 16h2v1.6h-2Z"/><path class="sch-icon--cut" d="M8.6 6.4h6v1.6h-6Z"/><path class="sch-icon--cut" d="M8.6 16h6v1.6h-6Z"/></g>
        <text class="sch-role" x="50" y="158">HOST</text>
        <text class="sch-label" x="24" y="188">A spare PC, a NUC in</text>
        <text class="sch-label" x="24" y="206">the office, or a VPS</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="272" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(286 145) scale(0.75)"><path class="sch-icon--fill" d="M3.2 10.6h3.4V14H3.2Z"/><path class="sch-icon--fill" d="M7.3 10.6h3.4V14H7.3Z"/><path class="sch-icon--fill" d="M11.4 10.6h3.4V14h-3.4Z"/><path class="sch-icon--fill" d="M7.3 6.7h3.4v3.4H7.3Z"/><path class="sch-icon--fill" d="M11.4 6.7h3.4v3.4h-3.4Z"/><path class="sch-icon--fill" d="M11.4 2.8h3.4v3.4h-3.4Z"/><path class="sch-icon--fill" d="M1.8 15.2h20.4c-.9 3.6-4.6 5.8-9.6 5.8-5.6 0-9.4-2-10.8-5.8Z"/></g>
        <text class="sch-role" x="312" y="158">DOCKER</text>
        <text class="sch-label" x="286" y="188">One compose file,</text>
        <text class="sch-label" x="286" y="206">version-controlled</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 23) scale(0.75)"><path class="sch-icon--fill" d="M3.4 12a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--fill" d="M15.2 6.6a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--fill" d="M15.2 17.4a2.7 2.7 0 1 1 5.4 0 2.7 2.7 0 0 1-5.4 0Z"/><path class="sch-icon--line" d="M6.1 12 17.9 6.6"/><path class="sch-icon--line" d="M6.1 12 17.9 17.4"/></g>
        <text class="sch-role" x="574" y="36">N8N</text>
        <text class="sch-trigger" x="716" y="36" text-anchor="end">WEBHOOK</text>
        <text class="sch-label" x="548" y="66">The drawing above,</text>
        <text class="sch-label" x="548" y="84">as nodes you can watch</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 145) scale(0.75)"><path class="sch-icon--fill" d="M9.2 4.6 3 12l6.2 7.4 1.7-1.4L5.8 12l5.1-6Z"/><path class="sch-icon--fill" d="M14.8 4.6 21 12l-6.2 7.4-1.7-1.4L18.2 12l-5.1-6Z"/></g>
        <text class="sch-role" x="574" y="158">PYTHON 3.12</text>
        <text class="sch-label" x="548" y="188">Workers for the jobs</text>
        <text class="sch-label" x="548" y="206">n8n should not do</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="534" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(548 267) scale(0.75)"><path class="sch-icon--fill" d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z"/><path class="sch-icon--cut" d="M12 4.4a7.6 7.6 0 1 1 0 15.2 7.6 7.6 0 0 1 0-15.2Z"/><path class="sch-icon--fill" d="M11.2 6.4h1.6v6.4h-1.6Z"/><path class="sch-icon--fill" d="M11.2 11.2h5v1.6h-5Z"/></g>
        <text class="sch-role" x="574" y="280">CRON</text>
        <text class="sch-trigger" x="716" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="548" y="310">Anything on a clock</text>
        <text class="sch-label" x="548" y="328">rather than a trigger</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="10" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 23) scale(0.75)"><path class="sch-icon--fill" d="M12 2c-4.4 0-8 1.3-8 3v14c0 1.7 3.6 3 8 3s8-1.3 8-3V5c0-1.7-3.6-3-8-3Z"/><path class="sch-icon--cut" d="M4 8.2c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3-.6-8-1.6Z"/><path class="sch-icon--cut" d="M4 13.4c1.7 1 4.6 1.6 8 1.6s6.3-.6 8-1.6v1.8c-1.7 1-4.6 1.6-8 1.6s-6.3-.6-8-1.6Z"/></g>
        <text class="sch-role" x="836" y="36">DATA LAYER</text>
        <text class="sch-label" x="810" y="66">Sheets to read,</text>
        <text class="sch-label" x="810" y="84">warehouse for history</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="132" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 145) scale(0.75)"><path class="sch-icon--fill" d="M20.7 4.6a5.6 5.6 0 0 1-7 7l-7.3 7.3a2.2 2.2 0 1 1-3.1-3.1l7.3-7.3a5.6 5.6 0 0 1 7-7l-3.3 3.3.9 3.2 3.2.9Z"/></g>
        <text class="sch-role" x="836" y="158">YOUR TOOLS</text>
        <text class="sch-label" x="810" y="188">Phone, email, diary,</text>
        <text class="sch-label" x="810" y="206">accounts, ads</text>
        </g>
        <g class="sch-node">
        <rect class="sch-box" x="796" y="254" width="196" height="92"/>
        <g class="sch-icon-g" transform="translate(810 267) scale(0.75)"><path class="sch-icon--line" d="M2 12h4.6l2.4-5.8 3.5 11.6 2.4-6.4 1.5 2.6H22"/></g>
        <text class="sch-role" x="836" y="280">HEALTH CHECK</text>
        <text class="sch-trigger" x="978" y="280" text-anchor="end">CRON</text>
        <text class="sch-label" x="810" y="310">Heartbeat out</text>
        <text class="sch-label" x="810" y="328">every two minutes</text>
        </g>
      </svg>
    </div>
  </div>
  <figcaption><span class="sch-no">NS-00</span>The box every agent runs in. The same host, the same compose file, the same n8n — which is why the fifth agent costs less to run than the first.</figcaption>
</figure>

    <ol class="build-steps">
      <li class="reveal">
        <span class="num">01</span>
        <div>
          <h3>The box it runs in</h3>
          <p>If the phone agent is already installed, this step is done — it is the same host and the same <code>docker-compose.yml</code>, with one more service in it. If this is your first agent, it is Docker on a spare PC, a NUC or a VPS at about five pounds a month, brought up with <code>docker compose up -d</code>.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">02</span>
        <div>
          <h3>Deciding where a quote comes from</h3>
          <p>This is the step that actually decides whether the agent works, and it is the one to be honest about. If your quoting tool has a webhook, we use it. If it does not, we watch your sent folder for the template you use. If neither is reliable, you add a row yourself — ten seconds, and far better than a clever guess that misses one quote in six.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">03</span>
        <div>
          <h3>The register</h3>
          <p>A Google Sheet with one row per quote and columns for the channel, the value, the date and the outcome. It is deliberately something you can read and edit. If you mark a row as won on a Tuesday, nothing chases it on the Wednesday.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">04</span>
        <div>
          <h3>The cron jobs</h3>
          <p>Two. <code>0 9 * * 1-5</code> runs the chaser on weekday mornings only, because a quote chased at eight on a Sunday reads as automated and undoes the point of it. <code>*/10 * * * *</code> runs the reply watch. The full list we run on an agent, and what breaks when each one is missing, is written up in <a href="/journal/best-cron-jobs-for-ai-agents">the cron jobs worth setting up for an agent</a>.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">05</span>
        <div>
          <h3>The three messages</h3>
          <p>Written with you, in a half-hour sitting, from quotes you have already sent. Not generated. They go in version control with everything else, so a change to the day-seven message is a change you can see and undo.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">06</span>
        <div>
          <h3>Matching replies back to quotes</h3>
          <p>The unglamorous half of the build. An inbound text is matched on the number, an email on the thread, and anything the agent cannot place with confidence is flagged for you rather than guessed at. A wrong match closes the wrong quote, so it fails loudly instead.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">07</span>
        <div>
          <h3>Credentials and accounts</h3>
          <p>Every account is opened in your name, on your card, with us added as a partner. The WhatsApp Business number and the mailbox are yours. If you want us gone, you remove us in one click and the chasing carries on.</p>
        </div>
      </li>
      <li class="reveal">
        <span class="num">08</span>
        <div>
          <h3>Testing on real quotes before hand-over</h3>
          <p>We run it against a fortnight of quotes you have already closed and check it would have chased the right ones on the right days and left the rest alone. Then we send live ones to our own phones and mailboxes and reply on each channel in turn, including replying to the day-three message after the day-seven one has been queued. Until it stops every time, it is not finished and we do not invoice.</p>
        </div>
      </li>
    </ol>
  </div>
</section>

<!-- ============================ MEDIA ============================ -->
<section class="band" id="media">
  <div class="container">
    <p class="eyebrow">See it working</p>
    <ul class="media-list is-placeholder">
      <li>
        <h3>The three messages</h3>
        <p>The actual day three, seven and fourteen text for one client, with the job details removed.</p>
      </li>
      <li>
        <h3>The register</h3>
        <p>A screenshot of a real month, with names removed.</p>
      </li>
      <li>
        <h3>A won job, end to end</h3>
        <p>The quote, the two chases, the reply, and the row closing — one thread, with permission.</p>
      </li>
    </ul>
  </div>
</section>

<!-- ============================ PRICE ============================ -->
<section class="band band--tall" id="price" style="background:var(--ink-deep);">
  <div class="container">
    <p class="eyebrow">What this one costs</p>
    <div class="price-block">
      <div class="price-row">
        <span class="item">
          <strong>Installed</strong>
          <span>Built, connected to the tools you already use, tested on your real jobs, handed over working.</span>
        </span>
        <span class="figure">£500 <small>one-off</small></span>
      </div>
      <div class="price-row">
        <span class="item">
          <strong>Maintained</strong>
          <span>Monitoring, fixes, and changes as the business changes. A named person to ring.</span>
        </span>
        <span class="figure">£50 <small>per month</small></span>
      </div>
    </div>
    <p class="price-note">You get that number before anything starts, not after. If it is not the number you were expecting, say so then — it is a much cheaper conversation than the one at the end.</p>

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
      <a class="work-back" href="/#work">All of the work</a>
      <a class="work-prev" href="/agents/answering-the-phone"><span>Previous</span>Answering the phone</a>
    </div>
  </div>
</nav>

</main>

<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
        <a href="/#work">The work</a>
        <a href="/#process">How it works</a>
        <a href="/case-studies">Case studies</a>
        <a href="/#ledger">What it costs</a>
        <a href="/journal/best-cron-jobs-for-ai-agents">Writing</a>
        <a href="/#contact">Talk to us</a>
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>
<script src="/js/schematic.js" defer></script>
</body>
</html>
NSEOF

cat > 'assets/og-image.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="#0E1A24"/>
  <g transform="translate(96,232) scale(0.60)">
    <g fill="none" stroke="#E9E4D9" stroke-width="17"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
  </g>
  <text x="222" y="284" font-family="Cormorant Garamond, Garamond, Georgia, serif"
        font-size="176" font-weight="300" fill="#E9E4D9">orthsaga</text>
  <text x="96" y="392" font-family="Cormorant Garamond, Garamond, Georgia, serif"
        font-size="62" font-weight="300" fill="#E9E4D9">Built the old way. Runs the new way.</text>
  <rect x="96" y="440" width="120" height="2" fill="#B08D4F"/>
  <text x="96" y="502" font-family="Archivo, Helvetica, Arial, sans-serif"
        font-size="25" letter-spacing="5" fill="#97A1A9">AI AGENTS INSTALLED INTO SMALL BUSINESSES</text>
</svg>
NSEOF

cat > 'assets/data/cron-jobs.json' <<'NSEOF'
{
  "slug": "best-cron-jobs-for-ai-agents",
  "title": "The best cron jobs to set up for AI agents",
  "standfirst": "An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.",
  "updated": "2026-08-06",
  "intro": [
    "Most of an agent's work is triggered. A call comes in, a form is filled, an email arrives, and something happens. That part is easy to demonstrate and easy to sell.",
    "The part that decides whether it is still working in six months is the part nobody demonstrates: the jobs that run on a clock whether or not anything happened. Webhooks get dropped. Tokens expire. Queues stick. Somebody changes a password on a Tuesday. None of that announces itself.",
    "These are the schedules we put on an agent install, in the order we add them. Every expression is standard five-field cron, and every one of them is there because something went wrong once without it."
  ],
  "jobs": [
    {
      "expression": "*/5 * * * *",
      "name": "Webhook-miss sweep",
      "does": "Asks the source system directly for anything created in the last hour, and compares it against what the agent actually received.",
      "why": "Webhooks are delivered on a best-effort basis. Providers drop them during their own incidents, and a retry that arrives while your container is restarting is gone for good.",
      "fails": "You lose records silently. Nothing errors, nothing alerts, and the first sign is a customer asking why nobody rang them back. This is the single most valuable job on the list."
    },
    {
      "expression": "*/10 * * * *",
      "name": "Queue drain and retry",
      "does": "Picks up anything that failed on its first attempt — a timed-out API call, a rate-limited send — and retries it with a longer gap each time. Gives up after five attempts and moves the item to a dead-letter table.",
      "why": "Third-party APIs fail for a minute at a time, constantly. Retrying inside the original request just makes the original request slow and then fail anyway.",
      "fails": "Every transient failure becomes a permanent one. The agent looks unreliable when the network was unreliable."
    },
    {
      "expression": "17 */6 * * *",
      "name": "Token and credential refresh",
      "does": "Refreshes OAuth tokens before they expire rather than after, and checks the expiry date on anything that cannot be refreshed automatically.",
      "why": "Refresh tokens expire on a schedule you do not control, and some providers invalidate them when a password changes. Refreshing on a clock means the failure happens while somebody is awake.",
      "fails": "The agent stops mid-week with an authentication error, usually on the integration you check least often. Note the 17: keeping jobs off the top of the hour spreads the load and makes a log easier to read."
    },
    {
      "expression": "*/2 * * * *",
      "name": "Heartbeat",
      "does": "Sends a ping to an external monitor. If the monitor stops hearing from it for ten minutes, it alerts a person.",
      "why": "This is the one job that has to be watched from outside the box. An agent cannot tell you it is down, because it is down.",
      "fails": "The container stops on a Friday evening and you find out on Monday from a customer. A heartbeat costs nothing and turns a lost weekend into a text message."
    },
    {
      "expression": "*/15 * * * *",
      "name": "Health check on the things it depends on",
      "does": "Checks that the database answers, the sheet is writable, and each API returns something sensible to a cheap read-only call.",
      "why": "A heartbeat proves the agent is running. It does not prove the agent can do anything. These are different failures and they need different checks.",
      "fails": "The agent runs happily for days while writing every record into a spreadsheet somebody moved to the bin."
    },
    {
      "expression": "0 7 * * 1-5",
      "name": "Daily digest",
      "does": "Sends one email or text before the working day: what came in, what the agent handled, and what needs a person.",
      "why": "It is the owner's daily proof the thing is earning its keep, and it is how they notice a problem the monitoring did not think to look for.",
      "fails": "Nobody looks at the agent at all, and confidence in it quietly drains away even while it works perfectly."
    },
    {
      "expression": "0 7 * * 1",
      "name": "Weekly summary",
      "does": "Monday morning. The week's totals against the week before: calls answered, quotes chased, reviews asked for, jobs booked.",
      "why": "Daily numbers are noise. Weekly numbers are a trend, and a trend is what tells you whether the agent still fits how the business works now.",
      "fails": "You end up arguing about whether it is working from memory rather than from a number."
    },
    {
      "expression": "30 2 * * *",
      "name": "Backup and export",
      "does": "Dumps the database and copies it, plus the n8n workflow definitions and the compose file, somewhere that is not the same machine.",
      "why": "A backup on the host is not a backup. It is a second copy of the thing that is about to fail.",
      "fails": "A dead disk or a bad migration takes the history with it. The agent can be rebuilt in an afternoon from the compose file; what happened last March cannot be rebuilt at all."
    },
    {
      "expression": "0 3 * * 0",
      "name": "Log rotation and pruning",
      "does": "Compresses last week's logs, deletes anything older than the retention period, and prunes unused Docker images and volumes.",
      "why": "Agents are chatty. Verbose logging plus a few months is how a small VPS runs out of disk.",
      "fails": "The disk fills. Everything stops at once, and the error messages are all about disk space rather than about the actual work, which makes the cause obvious and the hour it takes you to find it annoying."
    },
    {
      "expression": "0 * * * *",
      "name": "Cost and usage check against the budget",
      "does": "Adds up the hour's model and API spend, compares it against a daily ceiling, and warns at 80 per cent. At 100 per cent it stops non-urgent work and leaves the live paths running.",
      "why": "A loop that retries a failing call is a loop that spends money. Usage-based pricing turns a bug into an invoice.",
      "fails": "You find out from the bill. The check is cheap, and having the ceiling written down as a number is a useful conversation with the client before it is a useful alert."
    },
    {
      "expression": "13 4 * * *",
      "name": "Scrapes, with jitter",
      "does": "Runs the daily competitor and property pull. The job starts with a random pause of up to fifteen minutes — <code>sleep $((RANDOM % 900))</code> in front of the command — so the pull lands somewhere in a window rather than on a stroke.",
      "why": "Cron has no jitter of its own, so everybody's overnight job fires at midnight or on the hour, on the second. That is both rude to whoever you are pulling from and the easiest possible pattern to block.",
      "fails": "You hammer someone's server in lockstep with a thousand other scripts, get rate-limited or blocked, and deserve it. The odd minute and the random pause cost nothing and solve it."
    },
    {
      "expression": "40 3 * * *",
      "name": "Stale-record cleanup",
      "does": "Closes off anything the agent left half-finished: quotes still being chased after ninety days, jobs marked pending with no activity for a fortnight, follow-up sequences whose contact replied on another channel.",
      "why": "Agents create records and are much worse at deciding when a record is finished. The pile grows until the useful ones are hard to see.",
      "fails": "Somebody gets a fourth polite chase about a quote they accepted six weeks ago. That is worse than never having chased at all."
    }
  ],
  "caveats": [
    "Two things to get right before any of these help. First, cron runs in the machine's timezone, and a UK host moves an hour twice a year: run the container in UTC and do the conversion where the message is written, or your 7am digest arrives at 8 for half the year.",
    "Second, cron will happily start a job while the last one is still running. Wrap anything that could overlap in a lock — <code>flock -n</code> on the command line is enough — or the sweep that is running slowly because the API is slow will start a second copy, then a third."
  ],
  "outro": [
    "None of this is clever. It is the maintenance schedule, written down, the same way a boiler has one. The reason it is worth printing is that the schedule is the difference between an agent that still works next year and a demonstration that worked once."
  ]
}
NSEOF

cat > 'assets/favicon/favicon.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-127.5 -180 360 360">
  <rect x="-127.5" y="-180" width="360" height="360" fill="#0E1A24"/>
  <g fill="none" stroke="#E9E4D9" stroke-width="22" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
</svg>
NSEOF

cat > 'assets/logo/northsaga-lockup-bone.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 300" role="img" aria-label="Northsaga">
  <g transform="translate(120,168) scale(0.62)">
    <g fill="none" stroke="#E9E4D9" stroke-width="16" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
  </g>
  <text x="255" y="222" font-family="Cormorant Garamond, Garamond, Georgia, serif"
        font-size="200" font-weight="300" letter-spacing="1" fill="#E9E4D9">orthsaga</text>
</svg>
NSEOF

cat > 'assets/logo/northsaga-lockup-ink.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 300" role="img" aria-label="Northsaga">
  <g transform="translate(120,168) scale(0.62)">
    <g fill="none" stroke="#0E1A24" stroke-width="16" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
  </g>
  <text x="255" y="222" font-family="Cormorant Garamond, Garamond, Georgia, serif"
        font-size="200" font-weight="300" letter-spacing="1" fill="#0E1A24">orthsaga</text>
</svg>
NSEOF

cat > 'assets/logo/northsaga-mark-bone.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-77 -167 259 334" role="img" aria-label="Northsaga">
  <g fill="none" stroke="#E9E4D9" stroke-width="14" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
</svg>
NSEOF

cat > 'assets/logo/northsaga-mark-brass.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-77 -167 259 334" role="img" aria-label="Northsaga">
  <g fill="none" stroke="#B08D4F" stroke-width="14" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
</svg>
NSEOF

cat > 'assets/logo/northsaga-mark-ink.svg' <<'NSEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-77 -167 259 334" role="img" aria-label="Northsaga">
  <g fill="none" stroke="#0E1A24" stroke-width="14" stroke-linecap="butt"><path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/><path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/></g>
</svg>
NSEOF

cat > 'css/site.css' <<'NSEOF'
/* ==========================================================================
   NORTHSAGA — SITE STYLES
   Order: reset → base type → layout → header/menu → sections → footer → motion
   ========================================================================== */

/* ---------- Reset ---------- */
*, *::before, *::after { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; scroll-behavior: smooth; }
body, h1, h2, h3, h4, p, figure, blockquote, dl, dd, ul, ol { margin: 0; padding: 0; }
ul, ol { list-style: none; }
img, svg { display: block; max-width: 100%; }
button { font: inherit; color: inherit; background: none; border: 0; cursor: pointer; }
a { color: inherit; text-decoration: none; }

/* ---------- Base ---------- */
body {
  background: var(--ink);
  color: var(--bone);
  font-family: var(--font-body);
  font-size: var(--step-0);
  line-height: 1.65;
  font-weight: 400;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}

::selection { background: var(--brass); color: var(--ink); }

:focus-visible {
  outline: 2px solid var(--brass);
  outline-offset: 3px;
}

/* ---------- Reusable type roles ---------- */
.display {
  font-family: var(--font-display);
  font-weight: 300;
  line-height: 1.02;
  letter-spacing: -0.005em;
}

.eyebrow {
  font-family: var(--font-body);
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}
.eyebrow::after {
  content: "";
  flex: 1;
  height: 1px;
  background: var(--hairline);
}

.lede {
  font-size: var(--step-1);
  line-height: 1.55;
  color: var(--bone-dim);
  max-width: 46ch;
}

.prose { max-width: var(--measure); }
.prose p + p { margin-top: var(--space-2); }

/* ---------- Layout ---------- */
.container {
  width: 100%;
  max-width: var(--container);
  margin-inline: auto;
  padding-inline: var(--gutter);
}

.band { padding-block: var(--space-6); }
.band--tall { padding-block: var(--space-7); }

.band--paper {
  background: var(--paper);
  color: var(--paper-ink);
}
.band--paper .eyebrow { color: var(--brass-soft); }
.band--paper .eyebrow::after { background: var(--hairline-light); }
.band--paper .lede { color: rgba(18, 32, 43, 0.68); }

.rule {
  height: 1px;
  background: var(--hairline);
  border: 0;
}

/* ==========================================================================
   HEADER + FULL-SCREEN MENU
   ========================================================================== */
/* Must sit ABOVE .menu (z-index 70). The header is a stacking context, so
   .menu-toggle's z-index is scoped to it — at z-index 60 the overlay covered
   the toggle and the cross could not be clicked, leaving Escape as the only
   way to close the menu. */
.site-header {
  position: fixed;
  inset: 0 0 auto 0;
  z-index: 80;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-3) var(--gutter);
  mix-blend-mode: normal;
  transition: background var(--dur-fast) var(--ease),
              border-color var(--dur-fast) var(--ease);
}
.site-header[data-scrolled="true"] {
  background: rgba(14, 26, 36, 0.86);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--hairline);
}

/* With the header above the overlay, its scrolled bar would otherwise draw
   across the open menu. The mark and the cross still float over the panel. */
body[data-menu="open"] .site-header[data-scrolled="true"] {
  background: transparent;
  backdrop-filter: none;
  border-bottom-color: transparent;
}

.header-mark {
  display: flex;
  align-items: baseline;
  gap: 0.55rem;
}
.header-mark svg { width: 22px; height: auto; }
.header-mark span {
  font-family: var(--font-display);
  font-size: 1.5rem;
  font-weight: 300;
  letter-spacing: var(--tracking-wordmark);
}

/* Hamburger — two rules that rotate into a cross. Mylands-style restraint. */
.menu-toggle {
  position: relative;
  z-index: 80;
  width: 46px;
  height: 22px;
  display: grid;
  align-content: center;
  gap: 7px;
  justify-items: end;
}
.menu-toggle i {
  display: block;
  height: 1px;
  background: var(--bone);
  transition: transform var(--dur-slow) var(--ease),
              width var(--dur-slow) var(--ease),
              opacity var(--dur-fast) var(--ease);
}
.menu-toggle i:nth-child(1) { width: 46px; }
.menu-toggle i:nth-child(2) { width: 30px; }
.menu-toggle:hover i:nth-child(2) { width: 46px; }

body[data-menu="open"] .menu-toggle i:nth-child(1) {
  width: 40px;
  transform: translateY(4px) rotate(45deg);
}
body[data-menu="open"] .menu-toggle i:nth-child(2) {
  width: 40px;
  transform: translateY(-4px) rotate(-45deg);
}

.menu-label {
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--bone-dim);
  margin-right: var(--space-2);
}

/* Overlay */
.menu {
  position: fixed;
  inset: 0;
  z-index: 70;
  background: var(--ink-deep);
  display: grid;
  grid-template-rows: 1fr auto;
  padding: calc(var(--space-7) + 1rem) var(--gutter) var(--space-4);
  clip-path: inset(0 0 100% 0);
  transition: clip-path 720ms var(--ease);
  pointer-events: none;
}
body[data-menu="open"] .menu {
  clip-path: inset(0 0 0 0);
  pointer-events: auto;
}

.menu-nav { align-self: center; }
.menu-nav li { overflow: hidden; }
.menu-nav a {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: var(--step-4);
  line-height: 1.12;
  display: inline-block;
  transform: translateY(105%);
  transition: transform 640ms var(--ease), color var(--dur-fast) var(--ease);
}
body[data-menu="open"] .menu-nav a { transform: translateY(0); }
.menu-nav a:hover { color: var(--brass); }

/* stagger */
body[data-menu="open"] .menu-nav li:nth-child(1) a { transition-delay: 120ms; }
body[data-menu="open"] .menu-nav li:nth-child(2) a { transition-delay: 180ms; }
body[data-menu="open"] .menu-nav li:nth-child(3) a { transition-delay: 240ms; }
body[data-menu="open"] .menu-nav li:nth-child(4) a { transition-delay: 300ms; }
body[data-menu="open"] .menu-nav li:nth-child(5) a { transition-delay: 360ms; }
body[data-menu="open"] .menu-nav li:nth-child(6) a { transition-delay: 420ms; }
body[data-menu="open"] .menu-nav li:nth-child(7) a { transition-delay: 480ms; }

.menu-foot {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2) var(--space-5);
  justify-content: space-between;
  align-items: end;
  border-top: 1px solid var(--hairline);
  padding-top: var(--space-3);
  font-size: var(--step--1);
  color: var(--bone-dim);
  opacity: 0;
  transition: opacity 400ms var(--ease) 420ms;
}
body[data-menu="open"] .menu-foot { opacity: 1; }
.menu-foot a:hover { color: var(--brass); }

/* ==========================================================================
   HERO
   ========================================================================== */
.hero {
  min-height: 100svh;
  display: grid;
  align-content: center;
  padding-block: var(--space-7) var(--space-6);
  position: relative;
}

.hero-lockup {
  display: flex;
  align-items: center;
  gap: clamp(0.6rem, 1.6vw, 1.4rem);
  margin-bottom: var(--space-4);
}
.hero-lockup svg {
  width: clamp(58px, 9vw, 128px);
  height: auto;
  flex: none;
}
.hero-lockup .wordmark {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: var(--step-5);
  line-height: 0.9;
  letter-spacing: var(--tracking-wordmark);
}

.hero h1 {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: var(--step-3);
  line-height: 1.14;
  max-width: 20ch;
  margin-bottom: var(--space-3);
}
.hero h1 em {
  font-style: italic;
  color: var(--brass);
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2) var(--space-3);
  margin-top: var(--space-4);
}

.hero-scroll {
  position: absolute;
  bottom: var(--space-3);
  left: var(--gutter);
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--bone-dim);
}

/* ---------- Buttons ---------- */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.7rem;
  padding: 0.95rem 1.6rem;
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  border: 1px solid var(--brass);
  color: var(--bone);
  transition: background var(--dur-fast) var(--ease),
              color var(--dur-fast) var(--ease);
}
.btn:hover { background: var(--brass); color: var(--ink); }

.btn--quiet {
  border-color: var(--hairline-strong);
  color: var(--bone-dim);
}
.btn--quiet:hover { background: transparent; color: var(--bone); border-color: var(--bone); }

.band--paper .btn { color: var(--paper-ink); border-color: var(--brass-soft); }
.band--paper .btn:hover { background: var(--brass-soft); color: var(--paper); }

/* ==========================================================================
   WHAT WE INSTALL — plain list, hairline separated
   ========================================================================== */
.install-list { margin-top: var(--space-4); }
.install-list li {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--space-1) var(--space-4);
  padding-block: var(--space-3);
  border-top: 1px solid var(--hairline-light);
}
.install-list li:last-child { border-bottom: 1px solid var(--hairline-light); }
.install-list h3 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  line-height: 1.15;
}
.install-list p {
  color: rgba(18, 32, 43, 0.66);
  max-width: 54ch;
}

/* An item links to its workflow page once that page exists. */
.install-list h3 a { border-bottom: 1px solid var(--hairline-light); }
.install-list h3 a:hover {
  color: var(--brass-soft);
  border-bottom-color: var(--brass-soft);
}

@media (min-width: 820px) {
  .install-list li { grid-template-columns: 1fr 1.25fr; }
}

/* ==========================================================================
   HOW IT WORKS — a genuine sequence, so it is genuinely numbered
   ========================================================================== */
.steps {
  display: grid;
  gap: var(--space-4);
  margin-top: var(--space-5);
}
@media (min-width: 860px) {
  .steps { grid-template-columns: repeat(3, 1fr); gap: var(--space-5); }
}
.step { border-top: 1px solid var(--hairline); padding-top: var(--space-3); }
.step .num {
  font-family: var(--font-display);
  font-size: var(--step-2);
  color: var(--brass);
  display: block;
  margin-bottom: var(--space-2);
}
.step h3 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  margin-bottom: var(--space-1);
}
.step p { color: var(--bone-dim); }

/* ==========================================================================
   THE LEDGER — signature element. Priced like a trade, not a SaaS.
   Dot leaders are the typographic device of bills, indexes and menus.
   ========================================================================== */
.ledger {
  margin-top: var(--space-5);
  border-top: 2px solid var(--brass);
}
.ledger-row {
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: baseline;
  gap: var(--space-2);
  padding-block: var(--space-3);
  border-bottom: 1px solid var(--hairline);
}
.ledger-row .item { display: block; }
.ledger-row .item strong {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  display: block;
  line-height: 1.2;
}
.ledger-row .item span {
  color: var(--bone-dim);
  font-size: var(--step--1);
  display: block;
  margin-top: 0.35rem;
  max-width: 52ch;
}
.ledger-row .figure {
  font-family: var(--font-display);
  font-size: var(--step-2);
  color: var(--brass);
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}
.ledger-row .figure small {
  display: block;
  font-family: var(--font-body);
  font-size: var(--step--1);
  color: var(--bone-dim);
  text-align: right;
  letter-spacing: 0.04em;
}

.ledger-note {
  margin-top: var(--space-4);
  padding: var(--space-3);
  border: 1px solid var(--hairline);
  background: var(--ink-raised);
  max-width: 60ch;
}
.ledger-note p { color: var(--bone-dim); font-size: var(--step--1); }
.ledger-note p + p { margin-top: var(--space-1); }

/* ==========================================================================
   PROOF / PEOPLE
   ========================================================================== */
.proof {
  display: grid;
  gap: var(--space-4);
  margin-top: var(--space-5);
}
@media (min-width: 860px) { .proof { grid-template-columns: repeat(2, 1fr); } }

.proof-card {
  border: 1px solid var(--hairline);
  padding: var(--space-4) var(--space-3);
  background: var(--ink-raised);
}
.proof-card .figure {
  font-family: var(--font-display);
  font-size: var(--step-4);
  color: var(--brass);
  line-height: 1;
  display: block;
  margin-bottom: var(--space-2);
}
.proof-card p { color: var(--bone-dim); }
.proof-card cite {
  display: block;
  margin-top: var(--space-2);
  font-style: normal;
  font-size: var(--step--1);
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--bone);
}

/* Placeholder flagging — remove .is-placeholder once real content is in */
.is-placeholder { position: relative; }
.is-placeholder::after {
  content: "PLACEHOLDER — REPLACE";
  position: absolute;
  top: 0; right: 0;
  font-family: var(--font-body);
  font-size: 0.6rem;
  letter-spacing: 0.18em;
  padding: 0.3rem 0.5rem;
  background: var(--brass);
  color: var(--ink);
}

/* ==========================================================================
   CASE STUDIES
   Same devices as the rest of the site: hairline rules, no cards, the figure
   carried by the existing .proof-card treatment.
   ========================================================================== */
.case { padding-top: var(--space-4); }
.case + .case { margin-top: var(--space-6); }

.case-head { border-top: 2px solid var(--brass); padding-top: var(--space-3); }

.case-head h2 {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: var(--step-3);
  line-height: 1.1;
}

.case-meta {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-1) var(--space-3);
  margin-top: var(--space-2);
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--bone-dim);
}

.case-grid {
  display: grid;
  gap: var(--space-4);
  margin-top: var(--space-4);
}
@media (min-width: 860px) {
  .case-grid { grid-template-columns: repeat(3, 1fr); gap: var(--space-5); }
}

.case-block { border-top: 1px solid var(--hairline); padding-top: var(--space-3); }

/* The placeholder tag is pinned to the element's top-right corner, so a block
   whose content starts at the top needs room or the tag lands on the heading. */
.case-block.is-placeholder { padding-top: calc(var(--space-3) + 1.6rem); }
.case-meta .is-placeholder { padding-right: 11.5rem; }

.case-block h3 {
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass);
  margin-bottom: var(--space-2);
}
.case-block p { color: var(--bone-dim); }

.case-figure { margin-top: var(--space-4); }

/* ==========================================================================
   CONTACT
   ========================================================================== */
.contact-grid { display: grid; gap: var(--space-4); margin-top: var(--space-4); }
@media (min-width: 860px) { .contact-grid { grid-template-columns: 1.1fr 0.9fr; gap: var(--space-6); } }

.contact-lines { margin-top: var(--space-3); }
.contact-lines li {
  padding-block: var(--space-2);
  border-bottom: 1px solid var(--hairline-light);
  display: flex;
  justify-content: space-between;
  gap: var(--space-2);
  flex-wrap: wrap;
}
.contact-lines .k {
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass-soft);
}
.contact-lines .v { font-family: var(--font-display); font-size: var(--step-1); }

/* Service area sits under the contact lines — plain prose, no new device. */
.service-area {
  margin-top: var(--space-3);
  padding-top: var(--space-3);
  border-top: 1px solid var(--hairline-light);
}
.service-area .k {
  display: block;
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass-soft);
  margin-bottom: var(--space-1);
}
.service-area p { color: rgba(18, 32, 43, 0.68); }

/* ==========================================================================
   FOOTER
   ========================================================================== */
.site-footer {
  background: var(--ink-deep);
  padding-block: var(--space-5) var(--space-3);
  border-top: 1px solid var(--hairline);
}
.footer-top {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-4);
  justify-content: space-between;
  align-items: end;
  padding-bottom: var(--space-4);
}
.footer-motto {
  font-family: var(--font-display);
  font-size: var(--step-2);
  font-weight: 300;
  max-width: 22ch;
}
.footer-area {
  font-size: var(--step--1);
  color: var(--bone-dim);
  max-width: 30ch;
}
.footer-bottom {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2) var(--space-4);
  justify-content: space-between;
  border-top: 1px solid var(--hairline);
  padding-top: var(--space-3);
  font-size: var(--step--1);
  color: var(--bone-dim);
}
.footer-nav { display: flex; gap: var(--space-3); flex-wrap: wrap; }
.footer-nav a:hover, .footer-bottom a:hover { color: var(--brass); }

/* ==========================================================================
   MOTION — the mark draws itself once on load. One moment, not many.
   ========================================================================== */
.mark-path {
  stroke-dasharray: var(--len, 400);
  stroke-dashoffset: var(--len, 400);
  animation: draw 1100ms var(--ease) forwards;
}
.mark-path:nth-child(2) { animation-delay: 90ms; }
.mark-path:nth-child(3) { animation-delay: 180ms; }
.mark-path:nth-child(4) { animation-delay: 270ms; }

@keyframes draw { to { stroke-dashoffset: 0; } }

.reveal {
  opacity: 0;
  transform: translateY(18px);
  transition: opacity 700ms var(--ease), transform 700ms var(--ease);
}
.reveal.is-in { opacity: 1; transform: none; }

@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  .mark-path { stroke-dashoffset: 0; }
  .reveal { opacity: 1; transform: none; }
  .menu { transition: none; }
}

/* ---------- Small screens ---------- */
@media (max-width: 640px) {
  .hero-lockup { gap: 0.5rem; }
  .menu-label { display: none; }
  .ledger-row { grid-template-columns: 1fr; }
  .ledger-row .figure { text-align: left; }
  .ledger-row .figure small { text-align: left; }
}
NSEOF

cat > 'css/tokens.css' <<'NSEOF'
/* ==========================================================================
   NORTHSAGA — DESIGN TOKENS
   Every colour, size and spacing value in the site resolves to something here.
   Change a value here and it changes everywhere. Do not hard-code hex values
   anywhere else.
   ========================================================================== */

:root {
  /* ---- Palette -----------------------------------------------------------
     Deep navy base, bone type, muted antique brass accent.
     Brass is the "earned" colour — engraved plate, ledger rule, brass door
     number. It is used sparingly: rules, eyebrows, figures, focus states.
     Never a gradient. Never a glow.                                         */

  --ink:        #0E1A24;   /* base background — deep navy-black          */
  --ink-deep:   #08111A;   /* menu overlay, footer — one step darker     */
  --ink-raised: #16242F;   /* cards, ledger rows — one step lighter      */

  --bone:       #E9E4D9;   /* primary type on dark                       */
  --bone-dim:   #97A1A9;   /* secondary type, captions                   */

  --paper:      #EDE9DE;   /* light section background                   */
  --paper-ink:  #12202B;   /* type on light sections                     */
  --paper-ink-dim: rgba(18, 32, 43, 0.68);  /* secondary type on light   */

  --brass:      #B08D4F;   /* accent — rules, eyebrows, figures          */
  --brass-soft: #7C6438;   /* accent on light backgrounds / hairlines    */

  --hairline:        rgba(233, 228, 217, 0.14);  /* rules on dark        */
  --hairline-strong: rgba(233, 228, 217, 0.28);
  --hairline-light:  rgba(18, 32, 43, 0.16);     /* rules on light       */

  /* ---- Type ---------------------------------------------------------------
     Display: Cormorant Garamond — heritage, used large and light.
     Body:    Archivo — plain, slightly industrial grotesque. Honest, legible
              at small sizes, no personality war with the serif.
     Swap the display face here if you licence Canela or Freight Display.    */

  --font-display: "Cormorant Garamond", Garamond, Georgia, "Times New Roman", serif;
  --font-body:    "Archivo", "Helvetica Neue", Helvetica, Arial, sans-serif;

  /* Fluid type scale — clamp(min, preferred, max) */
  --step--1: clamp(0.78rem, 0.76rem + 0.10vw, 0.84rem);
  --step-0:  clamp(1.00rem, 0.96rem + 0.18vw, 1.10rem);
  --step-1:  clamp(1.20rem, 1.12rem + 0.36vw, 1.44rem);
  --step-2:  clamp(1.55rem, 1.38rem + 0.75vw, 2.10rem);
  --step-3:  clamp(2.10rem, 1.72rem + 1.70vw, 3.30rem);
  --step-4:  clamp(2.80rem, 2.00rem + 3.60vw, 5.40rem);
  --step-5:  clamp(3.40rem, 2.00rem + 6.00vw, 7.20rem);

  --tracking-eyebrow: 0.22em;   /* small caps labels */
  --tracking-wordmark: 0.02em;

  /* Schematic type. Fixed px rather than the fluid scale: the drawings have a
     fixed viewBox and scroll rather than reflow, so this text has to stay in
     proportion to the boxes it sits inside. Used only by css/work.css. */
  --sch-label:   12px;
  --sch-role:    8.5px;
  --sch-trigger: 7.5px;

  /* ---- Spacing (8px base) ---- */
  --space-1: 0.5rem;
  --space-2: 1rem;
  --space-3: 1.5rem;
  --space-4: 2.5rem;
  --space-5: 4rem;
  --space-6: 6rem;
  --space-7: 9rem;

  /* ---- Layout ---- */
  --measure:   68ch;    /* max reading width  */
  --container: 1240px;  /* max page width     */
  --gutter:    clamp(1.25rem, 5vw, 5rem);

  /* ---- Motion ---- */
  --ease: cubic-bezier(0.22, 0.61, 0.36, 1);
  --dur-fast: 200ms;
  --dur-slow: 620ms;

  /* Nothing in this brand is rounded. Corners are square. */
  --radius: 0;
}
NSEOF

cat > 'css/work.css' <<'NSEOF'
/* ==========================================================================
   NORTHSAGA — WORKFLOW AND JOURNAL PAGES
   Loaded only by /agents/* and /journal/*. Everything here is built from the
   same devices as site.css: hairline rules, square corners, brass used for a
   figure or a label and nothing else. No value is hard-coded — see tokens.css.
   Order: page head → schematic → numbered lists → code → parts → media →
   price → paging → journal
   ========================================================================== */

/* ---------- Page head ----------
   Extra top padding so the h1 clears the fixed header on a short viewport. */
.work-head,
.article-head { padding-top: var(--space-7); }

.work-head h1,
.article-head h1 {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: var(--step-4);
  line-height: 1.02;
  letter-spacing: -0.005em;
  max-width: 16ch;
}

/* ==========================================================================
   SCHEMATICS
   Engineering drawing, not an illustration. Every colour is a class, never an
   attribute.

   The whole drawing is visible at rest on any screen: the stage is
   min(100%, its own width), so it fits a phone and is never blown up past
   full size on a desktop. That makes the type small on a narrow screen, which
   is what js/schematic.js pays for — it widens the stage past 100% and the
   viewport scrolls. Without JS you get the complete drawing and no zoom,
   which is the right thing to fail to.
   ========================================================================== */
.schematic { margin-top: var(--space-5); }

.schematic-viewport {
  overflow: auto;
  max-height: 78vh;
  -webkit-overflow-scrolling: touch;
  /* One finger scrolls; two fingers are handed to the pinch handler. */
  touch-action: pan-x pan-y;
}
.schematic-viewport:focus-visible {
  outline: 2px solid var(--brass);
  outline-offset: 2px;
}
.schematic[data-zoomed="true"] .schematic-viewport { cursor: grab; }
.schematic[data-zoomed="true"] .schematic-viewport:active { cursor: grabbing; }

.schematic-stage { width: min(100%, var(--sch-w)); }

/* site.css sets svg { max-width: 100% } for photographs and the mark. Here the
   stage owns the width and the drawing fills it. */
.schematic-stage svg {
  display: block;
  width: 100%;
  height: auto;
  max-width: none;
}

/* ---------- Zoom controls, injected by js/schematic.js ---------- */
.schematic-controls {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  margin-top: var(--space-2);
}

.sch-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 2.25rem;
  min-height: 2.25rem;
  padding-inline: 0.55rem;
  background: none;
  border: 1px solid var(--hairline-strong);
  border-radius: var(--radius);
  color: var(--bone);
  font-family: var(--font-body);
  font-size: var(--step--1);
  font-weight: 500;
  line-height: 1;
  cursor: pointer;
  transition: border-color var(--dur-fast) var(--ease),
              color var(--dur-fast) var(--ease);
}
.sch-btn:hover:not(:disabled) { border-color: var(--brass); color: var(--brass); }
.sch-btn:disabled { opacity: 0.35; cursor: default; }
.sch-btn--text {
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  font-size: var(--step--1);
}

.sch-level {
  min-width: 3.5rem;
  text-align: center;
  font-size: var(--step--1);
  color: var(--bone-dim);
  font-variant-numeric: tabular-nums;
}

.sch-hint {
  font-size: var(--step--1);
  color: var(--bone-dim);
  margin-left: auto;
  text-align: right;
}

.sch-box {
  fill: var(--ink-raised);
  stroke: var(--hairline-strong);
  stroke-width: 1;
}

/* ---------- Node glyphs ----------
   Drawn in tools/icons.py. Monochrome on purpose: brass is the only accent
   this brand has, so a wall of vendor colours would be a second palette.
   --cut must track .sch-box's fill or the punched-out detail stops reading. */
.sch-icon--fill { fill: var(--bone-dim); }
.sch-icon--cut  { fill: var(--ink-raised); }
.sch-icon--line {
  fill: none;
  stroke: var(--bone-dim);
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.sch-wire {
  fill: none;
  stroke: var(--brass);
  stroke-width: 1.25;
}
.sch-wire--dash { stroke-dasharray: 5 4; }

.sch-arrow { fill: var(--brass); stroke: none; }

.sch-role {
  font-family: var(--font-body);
  font-size: var(--sch-role);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  fill: var(--brass);
}

.sch-trigger {
  font-family: var(--font-body);
  font-size: var(--sch-trigger);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  fill: var(--brass);
  opacity: 0.72;
}

.sch-label {
  font-family: var(--font-body);
  font-size: var(--sch-label);
  fill: var(--bone);
}

.schematic figcaption {
  display: flex;
  gap: var(--space-2);
  margin-top: var(--space-2);
  padding-top: var(--space-2);
  border-top: 1px solid var(--hairline);
  font-size: var(--step--1);
  color: var(--bone-dim);
  max-width: 62ch;
}
.sch-no {
  flex: none;
  color: var(--brass);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
}

/* ==========================================================================
   NUMBERED LISTS — the stages of a workflow, and the order it is built in.
   One component, two names, so a build step cannot drift out of the visual
   language the stages already established.
   ========================================================================== */
.stages,
.build-steps { margin-top: var(--space-4); }

.stages > li,
.build-steps > li {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: var(--space-1) var(--space-3);
  padding-block: var(--space-3);
  border-top: 1px solid var(--hairline);
}
.stages > li:last-child,
.build-steps > li:last-child { border-bottom: 1px solid var(--hairline); }

.stages .num,
.build-steps .num {
  font-family: var(--font-display);
  font-size: var(--step-2);
  line-height: 1.2;
  color: var(--brass);
  font-variant-numeric: tabular-nums;
}

.stages h3,
.build-steps h3 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  line-height: 1.2;
  margin-bottom: var(--space-1);
}

.stages p,
.build-steps p {
  color: var(--bone-dim);
  max-width: var(--measure);
}

.build-steps a { border-bottom: 1px solid var(--brass); }
.build-steps a:hover { color: var(--brass); }

/* Wide screens: heading left, body right, the same split .install-list uses. */
@media (min-width: 900px) {
  .stages > li > div,
  .build-steps > li > div {
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(0, 1.7fr);
    gap: var(--space-4);
    align-items: start;
  }
  .stages h3,
  .build-steps h3 { margin-bottom: 0; }
}

/* ==========================================================================
   CODE — a command, a filename, a crontab line. Body font, because this is
   prose with a command in it rather than a terminal. No highlighting, no
   window chrome, no copy button.
   ========================================================================== */
code {
  font-family: var(--font-body);
  font-size: var(--step--1);
  color: var(--brass);
  background: var(--ink-raised);
  border-radius: var(--radius);
  padding: 0.12em 0.42em;
  white-space: nowrap;
}

.band--paper code {
  color: var(--brass-soft);
  background: var(--paper);
  border: 1px solid var(--hairline-light);
}

/* A value nobody has settled yet. Deliberately visible. Do not guess at one. */
.tbd {
  color: var(--brass);
  border-bottom: 1px dotted var(--brass);
  font-style: italic;
}
.band--paper .tbd {
  color: var(--brass-soft);
  border-bottom-color: var(--brass-soft);
}

/* ==========================================================================
   PARTS LIST — what it is built from, on the paper band
   ========================================================================== */
.parts-list { margin-top: var(--space-4); }
.parts-list li {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: var(--space-1) var(--space-4);
  padding-block: var(--space-3);
  border-top: 1px solid var(--hairline-light);
}
.parts-list li:last-child { border-bottom: 1px solid var(--hairline-light); }
.parts-list h3 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-1);
  line-height: 1.2;
}
.parts-list p {
  color: var(--paper-ink-dim);
  max-width: 58ch;
}
@media (min-width: 820px) {
  .parts-list li { grid-template-columns: 1fr 1.6fr; }
}

/* ==========================================================================
   MEDIA — still a placeholder. The tag is pinned to the top-right corner, so
   the list needs room above it or the tag lands on the first heading.
   ========================================================================== */
.media-list { margin-top: var(--space-4); }
.media-list.is-placeholder { padding-top: calc(var(--space-3) + 1.2rem); }
.media-list li {
  padding-block: var(--space-3);
  border-top: 1px solid var(--hairline);
}
.media-list li:last-child { border-bottom: 1px solid var(--hairline); }
.media-list h3 {
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass);
  margin-bottom: var(--space-1);
}
.media-list p { color: var(--bone-dim); max-width: 58ch; }

/* ==========================================================================
   PRICE — the ledger device, two rows, real numbers
   ========================================================================== */
.price-block {
  margin-top: var(--space-4);
  border-top: 2px solid var(--brass);
  max-width: 64ch;
}
.price-row {
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: baseline;
  gap: var(--space-2);
  padding-block: var(--space-3);
  border-bottom: 1px solid var(--hairline);
}
.price-row .item strong {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  display: block;
  line-height: 1.2;
}
.price-row .item span {
  display: block;
  margin-top: 0.35rem;
  font-size: var(--step--1);
  color: var(--bone-dim);
  max-width: 46ch;
}
.price-row .figure {
  font-family: var(--font-display);
  font-size: var(--step-2);
  color: var(--brass);
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}
.price-row .figure small {
  display: block;
  text-align: right;
  font-family: var(--font-body);
  font-size: var(--step--1);
  color: var(--bone-dim);
  letter-spacing: 0.04em;
}

.price-note {
  margin-top: var(--space-3);
  font-size: var(--step--1);
  color: var(--bone-dim);
  max-width: 56ch;
}

/* ==========================================================================
   PAGING
   ========================================================================== */
.work-paging {
  padding-block: var(--space-4);
  border-top: 1px solid var(--hairline);
}
.work-paging-inner {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-3) var(--space-4);
  justify-content: space-between;
  align-items: baseline;
}
.work-paging a {
  font-family: var(--font-display);
  font-size: var(--step-1);
}
.work-paging a:hover { color: var(--brass); }
.work-paging a span {
  display: block;
  font-family: var(--font-body);
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass);
  margin-bottom: 0.35rem;
}
.work-paging .work-next { text-align: right; }
.work-paging .work-back {
  font-family: var(--font-body);
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--bone-dim);
}

/* ==========================================================================
   JOURNAL
   The list is generated from assets/data/cron-jobs.json. Same devices again:
   the expression carried in a code element, the three questions as labelled
   rows, hairlines between entries.
   ========================================================================== */
.article-meta {
  margin-top: var(--space-3);
  font-size: var(--step--1);
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--bone-dim);
}

.cron-list { margin-top: var(--space-4); }

.cron-entry {
  padding-block: var(--space-4);
  border-top: 1px solid var(--hairline);
}
.cron-entry:last-child { border-bottom: 1px solid var(--hairline); }

.cron-head {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: var(--space-1) var(--space-2);
}
.cron-head .num {
  font-family: var(--font-display);
  font-size: var(--step-1);
  color: var(--brass);
  font-variant-numeric: tabular-nums;
}
.cron-head h3 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: var(--step-2);
  line-height: 1.2;
  flex-basis: 100%;
}
.cron-expr { font-size: var(--step-0); }

.cron-body { margin-top: var(--space-2); }
.cron-body > div {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 0.25rem var(--space-3);
  padding-block: var(--space-1);
}
.cron-body dt {
  font-size: var(--step--1);
  font-weight: 500;
  letter-spacing: var(--tracking-eyebrow);
  text-transform: uppercase;
  color: var(--brass);
}
.cron-body dd { color: var(--bone-dim); max-width: var(--measure); }

@media (min-width: 820px) {
  .cron-body > div { grid-template-columns: 15rem minmax(0, 1fr); }
}

/* .contact-lines was drawn for the paper band. The journal's closing section
   sits on --ink-deep, so it needs the dark hairline and the brighter brass. */
.article-contact { margin-top: var(--space-4); }
.article-contact li { border-bottom-color: var(--hairline); }
.article-contact .k { color: var(--brass); }

/* The one caveat worth printing next to a list of schedules. */
.cron-caveat {
  margin-top: var(--space-4);
  padding: var(--space-3);
  border: 1px solid var(--hairline);
  background: var(--ink-raised);
  max-width: 64ch;
}
.cron-caveat p { color: var(--bone-dim); font-size: var(--step--1); }
.cron-caveat p + p { margin-top: var(--space-1); }

/* ---------- Small screens ---------- */
@media (max-width: 640px) {
  /* Full-bleed the drawing out through the container gutter. On a 390px phone
     that is roughly 40px of extra width, which is 11% more drawing. */
  .schematic-viewport {
    margin-inline: calc(var(--gutter) * -1);
    padding-inline: var(--space-1);
  }
  /* Keep the hint — on a phone the drawing is at its smallest and the reader
     most needs telling that it zooms. It just gets its own line. */
  .schematic-controls { flex-wrap: wrap; }
  .sch-hint {
    margin-left: 0;
    flex-basis: 100%;
    text-align: left;
  }

  .price-row { grid-template-columns: 1fr; }
  .price-row .figure,
  .price-row .figure small { text-align: left; }
  .work-paging .work-next { text-align: left; }
  .stages > li,
  .build-steps > li { gap: var(--space-1) var(--space-2); }
}
NSEOF

cat > 'journal/best-cron-jobs-for-ai-agents.html' <<'NSEOF'
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>The best cron jobs to set up for AI agents — Northsaga</title>
<meta name="description" content="An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.">

<link rel="canonical" href="https://northsaga.ai/journal/best-cron-jobs-for-ai-agents">

<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="The best cron jobs to set up for AI agents">
<meta property="og:description" content="An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.">
<meta property="og:type" content="article">
<meta property="og:url" content="https://northsaga.ai/journal/best-cron-jobs-for-ai-agents">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="The best cron jobs to set up for AI agents">
<meta name="twitter:description" content="An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">
<link rel="stylesheet" href="/css/work.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal { opacity: 1; transform: none; }</style></noscript>

<!-- WebPage stub. Identity lives on the homepage (Organization at
     https://northsaga.ai/#business). address, telephone and openingHours are
     deliberately absent rather than invented — add them once confirmed. The
     postcodes in areaServed are UNVERIFIED; check them against the real
     service area and correct here, in the contact section and in the footer
     together. -->

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents#page",
  "url": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents",
  "name": "The best cron jobs to set up for AI agents — Northsaga",
  "isPartOf": { "@id": "https://northsaga.ai/#website" },
  "about": { "@id": "https://northsaga.ai/#business" },
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "@id": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents#article",
  "headline": "The best cron jobs to set up for AI agents",
  "description": "An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.",
  "datePublished": "2026-08-06",
  "dateModified": "2026-08-06",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents#page"
  },
  "author": {
    "@type": "Person",
    "name": "George Astin",
    "jobTitle": "Founder, Northsaga"
  },
  "publisher": {
    "@id": "https://northsaga.ai/#business"
  },
  "speakable": {
    "@type": "SpeakableSpecification",
    "cssSelector": [
      "h1",
      ".lede"
    ]
  }
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "@id": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents#faq",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Why does the webhook-miss sweep job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Asks the source system directly for anything created in the last hour, and compares it against what the agent actually received. Webhooks are delivered on a best-effort basis. Providers drop them during their own incidents, and a retry that arrives while your container is restarting is gone for good."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the queue drain and retry job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Picks up anything that failed on its first attempt — a timed-out API call, a rate-limited send — and retries it with a longer gap each time. Gives up after five attempts and moves the item to a dead-letter table. Third-party APIs fail for a minute at a time, constantly. Retrying inside the original request just makes the original request slow and then fail anyway."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the token and credential refresh job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Refreshes OAuth tokens before they expire rather than after, and checks the expiry date on anything that cannot be refreshed automatically. Refresh tokens expire on a schedule you do not control, and some providers invalidate them when a password changes. Refreshing on a clock means the failure happens while somebody is awake."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the heartbeat job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Sends a ping to an external monitor. If the monitor stops hearing from it for ten minutes, it alerts a person. This is the one job that has to be watched from outside the box. An agent cannot tell you it is down, because it is down."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the health check on the things it depends on job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Checks that the database answers, the sheet is writable, and each API returns something sensible to a cheap read-only call. A heartbeat proves the agent is running. It does not prove the agent can do anything. These are different failures and they need different checks."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the daily digest job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Sends one email or text before the working day: what came in, what the agent handled, and what needs a person. It is the owner's daily proof the thing is earning its keep, and it is how they notice a problem the monitoring did not think to look for."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the weekly summary job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Monday morning. The week's totals against the week before: calls answered, quotes chased, reviews asked for, jobs booked. Daily numbers are noise. Weekly numbers are a trend, and a trend is what tells you whether the agent still fits how the business works now."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the backup and export job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Dumps the database and copies it, plus the n8n workflow definitions and the compose file, somewhere that is not the same machine. A backup on the host is not a backup. It is a second copy of the thing that is about to fail."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the log rotation and pruning job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Compresses last week's logs, deletes anything older than the retention period, and prunes unused Docker images and volumes. Agents are chatty. Verbose logging plus a few months is how a small VPS runs out of disk."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the cost and usage check against the budget job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Adds up the hour's model and API spend, compares it against a daily ceiling, and warns at 80 per cent. At 100 per cent it stops non-urgent work and leaves the live paths running. A loop that retries a failing call is a loop that spends money. Usage-based pricing turns a bug into an invoice."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the scrapes, with jitter job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Runs the daily competitor and property pull. The job starts with a random pause of up to fifteen minutes — <code>sleep $((RANDOM % 900))</code> in front of the command — so the pull lands somewhere in a window rather than on a stroke. Cron has no jitter of its own, so everybody's overnight job fires at midnight or on the hour, on the second. That is both rude to whoever you are pulling from and the easiest possible pattern to block."
      }
    },
    {
      "@type": "Question",
      "name": "Why does the stale-record cleanup job run on a schedule?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Closes off anything the agent left half-finished: quotes still being chased after ninety days, jobs marked pending with no activity for a fortnight, follow-up sequences whose contact replied on another channel. Agents create records and are much worse at deciding when a record is finished. The pile grows until the useful ones are hard to see."
      }
    }
  ]
}
</script>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "@id": "https://northsaga.ai/journal/best-cron-jobs-for-ai-agents#howto",
  "name": "The best cron jobs to set up for AI agents",
  "description": "An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.",
  "totalTime": "PT1H",
  "step": [
    {
      "@type": "HowToStep",
      "position": 1,
      "name": "Webhook-miss sweep",
      "text": "*/5 * * * * — Asks the source system directly for anything created in the last hour, and compares it against what the agent actually received."
    },
    {
      "@type": "HowToStep",
      "position": 2,
      "name": "Queue drain and retry",
      "text": "*/10 * * * * — Picks up anything that failed on its first attempt — a timed-out API call, a rate-limited send — and retries it with a longer gap each time. Gives up after five attempts and moves the item to a dead-letter table."
    },
    {
      "@type": "HowToStep",
      "position": 3,
      "name": "Token and credential refresh",
      "text": "17 */6 * * * — Refreshes OAuth tokens before they expire rather than after, and checks the expiry date on anything that cannot be refreshed automatically."
    },
    {
      "@type": "HowToStep",
      "position": 4,
      "name": "Heartbeat",
      "text": "*/2 * * * * — Sends a ping to an external monitor. If the monitor stops hearing from it for ten minutes, it alerts a person."
    },
    {
      "@type": "HowToStep",
      "position": 5,
      "name": "Health check on the things it depends on",
      "text": "*/15 * * * * — Checks that the database answers, the sheet is writable, and each API returns something sensible to a cheap read-only call."
    },
    {
      "@type": "HowToStep",
      "position": 6,
      "name": "Daily digest",
      "text": "0 7 * * 1-5 — Sends one email or text before the working day: what came in, what the agent handled, and what needs a person."
    },
    {
      "@type": "HowToStep",
      "position": 7,
      "name": "Weekly summary",
      "text": "0 7 * * 1 — Monday morning. The week's totals against the week before: calls answered, quotes chased, reviews asked for, jobs booked."
    },
    {
      "@type": "HowToStep",
      "position": 8,
      "name": "Backup and export",
      "text": "30 2 * * * — Dumps the database and copies it, plus the n8n workflow definitions and the compose file, somewhere that is not the same machine."
    },
    {
      "@type": "HowToStep",
      "position": 9,
      "name": "Log rotation and pruning",
      "text": "0 3 * * 0 — Compresses last week's logs, deletes anything older than the retention period, and prunes unused Docker images and volumes."
    },
    {
      "@type": "HowToStep",
      "position": 10,
      "name": "Cost and usage check against the budget",
      "text": "0 * * * * — Adds up the hour's model and API spend, compares it against a daily ceiling, and warns at 80 per cent. At 100 per cent it stops non-urgent work and leaves the live paths running."
    },
    {
      "@type": "HowToStep",
      "position": 11,
      "name": "Scrapes, with jitter",
      "text": "13 4 * * * — Runs the daily competitor and property pull. The job starts with a random pause of up to fifteen minutes — <code>sleep $((RANDOM % 900))</code> in front of the command — so the pull lands somewhere in a window rather than on a stroke."
    },
    {
      "@type": "HowToStep",
      "position": 12,
      "name": "Stale-record cleanup",
      "text": "40 3 * * * — Closes off anything the agent left half-finished: quotes still being chased after ninety days, jobs marked pending with no activity for a fortnight, follow-up sequences whose contact replied on another channel."
    }
  ]
}
</script>
</head>
<body>
<!-- GENERATED FILE — do not hand-edit. Source: assets/data/cron-jobs.json
     Edit there, then run: cd tools && python3 build-journal.py -->

<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>

<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
    <li><a href="/#work">The work</a></li>
    <li><a href="/#process">How it works</a></li>
    <li><a href="/case-studies">Case studies</a></li>
    <li><a href="/#ledger">What it costs</a></li>
    <li><a href="/#proof">Proof</a></li>
    <li><a href="/journal/best-cron-jobs-for-ai-agents" aria-current="page">Writing</a></li>
    <li><a href="/#contact">Talk to us</a></li>
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
  </div>
</nav>

<main>

<!-- ============================ HEAD ============================ -->
<section class="band article-head">
  <div class="container">
    <p class="eyebrow">Writing</p>
    <h1 class="display">The best cron jobs to set up for AI agents</h1>
    <p class="lede" style="margin-top:var(--space-3);">An agent that only runs when something pokes it will fail quietly. The schedules we put on every install, what each is for, and what breaks when it is missing.</p>
    <p class="article-meta">Updated 2026-08-06</p>

    <div class="prose" style="margin-top:var(--space-5);">
      <p>Most of an agent's work is triggered. A call comes in, a form is filled, an email arrives, and something happens. That part is easy to demonstrate and easy to sell.</p><p>The part that decides whether it is still working in six months is the part nobody demonstrates: the jobs that run on a clock whether or not anything happened. Webhooks get dropped. Tokens expire. Queues stick. Somebody changes a password on a Tuesday. None of that announces itself.</p><p>These are the schedules we put on an agent install, in the order we add them. Every expression is standard five-field cron, and every one of them is there because something went wrong once without it.</p>
    </div>
  </div>
</section>

<!-- ============================ THE LIST ============================ -->
<section class="band band--tall" id="jobs">
  <div class="container">
    <p class="eyebrow">The schedules</p>
    <ol class="cron-list">
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">01</span>
          <code class="cron-expr">*/5 * * * *</code>
          <h3>Webhook-miss sweep</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Asks the source system directly for anything created in the last hour, and compares it against what the agent actually received.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Webhooks are delivered on a best-effort basis. Providers drop them during their own incidents, and a retry that arrives while your container is restarting is gone for good.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>You lose records silently. Nothing errors, nothing alerts, and the first sign is a customer asking why nobody rang them back. This is the single most valuable job on the list.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">02</span>
          <code class="cron-expr">*/10 * * * *</code>
          <h3>Queue drain and retry</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Picks up anything that failed on its first attempt — a timed-out API call, a rate-limited send — and retries it with a longer gap each time. Gives up after five attempts and moves the item to a dead-letter table.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Third-party APIs fail for a minute at a time, constantly. Retrying inside the original request just makes the original request slow and then fail anyway.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>Every transient failure becomes a permanent one. The agent looks unreliable when the network was unreliable.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">03</span>
          <code class="cron-expr">17 */6 * * *</code>
          <h3>Token and credential refresh</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Refreshes OAuth tokens before they expire rather than after, and checks the expiry date on anything that cannot be refreshed automatically.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Refresh tokens expire on a schedule you do not control, and some providers invalidate them when a password changes. Refreshing on a clock means the failure happens while somebody is awake.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>The agent stops mid-week with an authentication error, usually on the integration you check least often. Note the 17: keeping jobs off the top of the hour spreads the load and makes a log easier to read.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">04</span>
          <code class="cron-expr">*/2 * * * *</code>
          <h3>Heartbeat</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Sends a ping to an external monitor. If the monitor stops hearing from it for ten minutes, it alerts a person.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>This is the one job that has to be watched from outside the box. An agent cannot tell you it is down, because it is down.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>The container stops on a Friday evening and you find out on Monday from a customer. A heartbeat costs nothing and turns a lost weekend into a text message.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">05</span>
          <code class="cron-expr">*/15 * * * *</code>
          <h3>Health check on the things it depends on</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Checks that the database answers, the sheet is writable, and each API returns something sensible to a cheap read-only call.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>A heartbeat proves the agent is running. It does not prove the agent can do anything. These are different failures and they need different checks.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>The agent runs happily for days while writing every record into a spreadsheet somebody moved to the bin.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">06</span>
          <code class="cron-expr">0 7 * * 1-5</code>
          <h3>Daily digest</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Sends one email or text before the working day: what came in, what the agent handled, and what needs a person.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>It is the owner's daily proof the thing is earning its keep, and it is how they notice a problem the monitoring did not think to look for.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>Nobody looks at the agent at all, and confidence in it quietly drains away even while it works perfectly.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">07</span>
          <code class="cron-expr">0 7 * * 1</code>
          <h3>Weekly summary</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Monday morning. The week's totals against the week before: calls answered, quotes chased, reviews asked for, jobs booked.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Daily numbers are noise. Weekly numbers are a trend, and a trend is what tells you whether the agent still fits how the business works now.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>You end up arguing about whether it is working from memory rather than from a number.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">08</span>
          <code class="cron-expr">30 2 * * *</code>
          <h3>Backup and export</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Dumps the database and copies it, plus the n8n workflow definitions and the compose file, somewhere that is not the same machine.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>A backup on the host is not a backup. It is a second copy of the thing that is about to fail.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>A dead disk or a bad migration takes the history with it. The agent can be rebuilt in an afternoon from the compose file; what happened last March cannot be rebuilt at all.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">09</span>
          <code class="cron-expr">0 3 * * 0</code>
          <h3>Log rotation and pruning</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Compresses last week's logs, deletes anything older than the retention period, and prunes unused Docker images and volumes.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Agents are chatty. Verbose logging plus a few months is how a small VPS runs out of disk.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>The disk fills. Everything stops at once, and the error messages are all about disk space rather than about the actual work, which makes the cause obvious and the hour it takes you to find it annoying.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">10</span>
          <code class="cron-expr">0 * * * *</code>
          <h3>Cost and usage check against the budget</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Adds up the hour's model and API spend, compares it against a daily ceiling, and warns at 80 per cent. At 100 per cent it stops non-urgent work and leaves the live paths running.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>A loop that retries a failing call is a loop that spends money. Usage-based pricing turns a bug into an invoice.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>You find out from the bill. The check is cheap, and having the ceiling written down as a number is a useful conversation with the client before it is a useful alert.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">11</span>
          <code class="cron-expr">13 4 * * *</code>
          <h3>Scrapes, with jitter</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Runs the daily competitor and property pull. The job starts with a random pause of up to fifteen minutes — <code>sleep $((RANDOM % 900))</code> in front of the command — so the pull lands somewhere in a window rather than on a stroke.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Cron has no jitter of its own, so everybody's overnight job fires at midnight or on the hour, on the second. That is both rude to whoever you are pulling from and the easiest possible pattern to block.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>You hammer someone's server in lockstep with a thousand other scripts, get rate-limited or blocked, and deserve it. The odd minute and the random pause cost nothing and solve it.</dd>
        </div>
        </dl>
      </li>
      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">12</span>
          <code class="cron-expr">40 3 * * *</code>
          <h3>Stale-record cleanup</h3>
        </div>
        <dl class="cron-body">
        <div>
          <dt>What it does</dt>
          <dd>Closes off anything the agent left half-finished: quotes still being chased after ninety days, jobs marked pending with no activity for a fortnight, follow-up sequences whose contact replied on another channel.</dd>
        </div>
        <div>
          <dt>Why an agent needs it</dt>
          <dd>Agents create records and are much worse at deciding when a record is finished. The pile grows until the useful ones are hard to see.</dd>
        </div>
        <div>
          <dt>What happens if you skip it</dt>
          <dd>Somebody gets a fourth polite chase about a quote they accepted six weeks ago. That is worse than never having chased at all.</dd>
        </div>
        </dl>
      </li>
    </ol>

    <div class="cron-caveat">
      <p>Two things to get right before any of these help. First, cron runs in the machine's timezone, and a UK host moves an hour twice a year: run the container in UTC and do the conversion where the message is written, or your 7am digest arrives at 8 for half the year.</p>
      <p>Second, cron will happily start a job while the last one is still running. Wrap anything that could overlap in a lock — <code>flock -n</code> on the command line is enough — or the sweep that is running slowly because the API is slow will start a second copy, then a third.</p>
    </div>
  </div>
</section>

<!-- ============================ CLOSE ============================ -->
<section class="band band--tall" id="close" style="background:var(--ink-deep);">
  <div class="container">
    <div class="prose">
      <p>None of this is clever. It is the maintenance schedule, written down, the same way a boiler has one. The reason it is worth printing is that the schedule is the difference between an agent that still works next year and a demonstration that worked once.</p>
    </div>

    <h2 class="display" style="font-size:var(--step-3); max-width:20ch; margin-top:var(--space-4);">
      Or we install it for you.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      £500 an agent to install, £50 an agent a month to
      maintain, and the schedule above comes with it. Every account in your name,
      and you can take the whole thing in-house whenever you want it.
    </p>

    <ul class="contact-lines article-contact is-placeholder" style="max-width:34rem;">
      <li><span class="k">Email</span><span class="v">hello@northsaga.ai</span></li>
      <li><span class="k">Telephone</span><span class="v">0000 000 0000</span></li>
    </ul>

    <div class="hero-actions">
      <a class="btn" href="/#contact">Book the survey</a>
      <a class="btn btn--quiet" href="/agents/answering-the-phone">See one built</a>
    </div>
  </div>
</section>

</main>

<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
        <a href="/#work">The work</a>
        <a href="/#process">How it works</a>
        <a href="/case-studies">Case studies</a>
        <a href="/#ledger">What it costs</a>
        <a href="/journal/best-cron-jobs-for-ai-agents">Writing</a>
        <a href="/#contact">Talk to us</a>
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:hello@northsaga.ai">hello@northsaga.ai</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>
</body>
</html>
NSEOF

cat > 'js/schematic.js' <<'NSEOF'
/* Northsaga — schematic zoom.

   A drawing is fitted to the viewport width by CSS, so the whole shape is
   visible at rest on any screen. That makes the type small on a phone, which
   is the trade this script pays for: fit first, then let the reader zoom in.

   One job only. If this file fails to load, the drawing is still complete and
   still scrollable — you just do not get the controls.

   Zoom is a width on the stage, not a transform, so the SVG re-renders at the
   new size and stays sharp. The viewport scrolls, so panning is native on
   touch and needs no code.  */

(function () {
  'use strict';

  var STEPS = [1, 1.5, 2, 3, 4];
  var figures = document.querySelectorAll('.schematic');
  if (!figures.length) return;

  function nearest(z) {
    var best = 0;
    for (var i = 1; i < STEPS.length; i++) {
      if (Math.abs(STEPS[i] - z) < Math.abs(STEPS[best] - z)) best = i;
    }
    return best;
  }

  figures.forEach(function (fig) {
    var viewport = fig.querySelector('.schematic-viewport');
    var stage = fig.querySelector('.schematic-stage');
    var caption = fig.querySelector('figcaption');
    if (!viewport || !stage) return;

    /* The drawing's own width, from the inline --sch-w the generator writes. */
    var intrinsic = parseFloat(stage.style.getPropertyValue('--sch-w')) || 0;
    var index = 0;

    /* ---- controls ---- */
    var bar = document.createElement('div');
    bar.className = 'schematic-controls';
    bar.innerHTML =
      '<button type="button" class="sch-btn" data-zoom="out" aria-label="Zoom out">' +
      '<span aria-hidden="true">−</span></button>' +
      '<span class="sch-level" role="status">100%</span>' +
      '<button type="button" class="sch-btn" data-zoom="in" aria-label="Zoom in">' +
      '<span aria-hidden="true">+</span></button>' +
      '<button type="button" class="sch-btn sch-btn--text" data-zoom="fit">Fit</button>' +
      '<span class="sch-hint">Pinch or scroll to move around</span>';

    fig.insertBefore(bar, caption);

    var level = bar.querySelector('.sch-level');
    var outBtn = bar.querySelector('[data-zoom="out"]');
    var inBtn = bar.querySelector('[data-zoom="in"]');

    /* Set the zoom, keeping whatever was in the middle of the viewport in the
       middle of it. Without this, zooming in on a wide drawing throws the
       reader back to the left-hand edge every time. */
    function apply(next, originX, originY) {
      next = Math.max(0, Math.min(STEPS.length - 1, next));
      if (next === index) return;

      var before = STEPS[index];
      var after = STEPS[next];
      var ox = originX === undefined ? viewport.clientWidth / 2 : originX;
      var oy = originY === undefined ? viewport.clientHeight / 2 : originY;
      var fx = (viewport.scrollLeft + ox) / before;
      var fy = (viewport.scrollTop + oy) / before;

      index = next;
      stage.style.width = after === 1
        ? ''
        : 'min(' + (after * 100) + '%, ' + (intrinsic * after) + 'px)';

      viewport.scrollLeft = fx * after - ox;
      viewport.scrollTop = fy * after - oy;

      level.textContent = Math.round(after * 100) + '%';
      fig.dataset.zoomed = after > 1 ? 'true' : 'false';
      outBtn.disabled = index === 0;
      inBtn.disabled = index === STEPS.length - 1;
    }

    outBtn.disabled = true;

    bar.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-zoom]');
      if (!btn) return;
      var dir = btn.dataset.zoom;
      apply(dir === 'in' ? index + 1 : dir === 'out' ? index - 1 : 0);
    });

    /* ---- trackpad pinch and ctrl+wheel ---- */
    viewport.addEventListener('wheel', function (e) {
      if (!e.ctrlKey) return;              /* a plain wheel still scrolls */
      e.preventDefault();
      var rect = viewport.getBoundingClientRect();
      apply(index + (e.deltaY < 0 ? 1 : -1),
            e.clientX - rect.left, e.clientY - rect.top);
    }, { passive: false });

    /* ---- two-finger pinch ----
       Only while two fingers are down, so a one-finger drag still scrolls the
       viewport natively and the page still scrolls past the drawing. */
    var startDist = 0;
    var startZoom = 1;

    function spread(t) {
      var dx = t[0].clientX - t[1].clientX;
      var dy = t[0].clientY - t[1].clientY;
      return Math.sqrt(dx * dx + dy * dy);
    }

    viewport.addEventListener('touchstart', function (e) {
      if (e.touches.length !== 2) return;
      startDist = spread(e.touches);
      startZoom = STEPS[index];
    }, { passive: true });

    viewport.addEventListener('touchmove', function (e) {
      if (e.touches.length !== 2 || !startDist) return;
      e.preventDefault();
      var rect = viewport.getBoundingClientRect();
      var cx = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left;
      var cy = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top;
      apply(nearest(startZoom * (spread(e.touches) / startDist)), cx, cy);
    }, { passive: false });

    viewport.addEventListener('touchend', function () { startDist = 0; });

    /* ---- drag to pan, mouse only ---- */
    var dragging = false;
    var lastX = 0;
    var lastY = 0;

    viewport.addEventListener('pointerdown', function (e) {
      if (e.pointerType !== 'mouse' || fig.dataset.zoomed !== 'true') return;
      dragging = true;
      lastX = e.clientX;
      lastY = e.clientY;
      viewport.setPointerCapture(e.pointerId);
    });

    viewport.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      viewport.scrollLeft -= e.clientX - lastX;
      viewport.scrollTop -= e.clientY - lastY;
      lastX = e.clientX;
      lastY = e.clientY;
    });

    viewport.addEventListener('pointerup', function () { dragging = false; });
    viewport.addEventListener('pointercancel', function () { dragging = false; });

    /* ---- double click or double tap toggles fit and 200% ---- */
    viewport.addEventListener('dblclick', function (e) {
      var rect = viewport.getBoundingClientRect();
      apply(index === 0 ? 2 : 0, e.clientX - rect.left, e.clientY - rect.top);
    });
  });
})();
NSEOF

cat > 'js/site.js' <<'NSEOF'
/* Northsaga — site behaviour.
   Three jobs only: the menu, the header state, and the scroll reveal. */

(function () {
  'use strict';

  var body = document.body;
  var toggle = document.getElementById('menuToggle');
  var menu = document.getElementById('menu');
  var header = document.getElementById('siteHeader');

  /* ---- Full-screen menu ---- */
  function setMenu(open) {
    body.dataset.menu = open ? 'open' : 'closed';
    toggle.setAttribute('aria-expanded', String(open));
    var label = toggle.querySelector('.menu-label');
    if (label) label.textContent = open ? 'Close' : 'Menu';
    body.style.overflow = open ? 'hidden' : '';
  }

  if (toggle && menu) {
    setMenu(false);
    toggle.addEventListener('click', function () {
      setMenu(body.dataset.menu !== 'open');
    });

    /* Close on link click and on Escape */
    menu.addEventListener('click', function (e) {
      if (e.target.closest('a')) setMenu(false);
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && body.dataset.menu === 'open') {
        setMenu(false);
        toggle.focus();
      }
    });
  }

  /* ---- Header background once scrolled off the hero ---- */
  if (header) {
    var onScroll = function () {
      header.dataset.scrolled = window.scrollY > 40 ? 'true' : 'false';
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* ---- Scroll reveal (skipped entirely if reduced motion is requested) ---- */
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var items = document.querySelectorAll('.reveal');

  if (reduced || !('IntersectionObserver' in window)) {
    items.forEach(function (el) { el.classList.add('is-in'); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-in');
        io.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -12% 0px' });

    items.forEach(function (el, i) {
      el.style.transitionDelay = (i % 6) * 60 + 'ms';
      io.observe(el);
    });
  }

  /* ---- Footer year ---- */
  var year = document.getElementById('year');
  if (year) year.textContent = new Date().getFullYear();
})();
NSEOF

cat > 'tools/build-agent-pages.py' <<'NSEOF'
#!/usr/bin/env python3
"""Northsaga — agent page generator.

    cd tools && python3 build-agent-pages.py

Every agent page's copy, stages, parts list, build order, prices and schematic
lives in the PAGES list below. agents/*.html is generated output — do not
hand-edit it; edit the dictionary and re-run.

Also writes tools/_homepage-list.html, the block to paste into .install-list in
index.html if the list of agents changes.

Python 3 standard library only. No dependencies, no build step.
"""

import html
import os

import chrome
import icons

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


# ==========================================================================
# THE SCHEMATIC RENDERER
#
# Boxes in brand colours, orthogonal brass connectors. Columns run left to
# right and each column is centred vertically against the tallest one.
#
#   'nodes': {
#     'a': (0, 0, 'Trigger', 'Inbound call|to your number', 'phone', 'webhook'),
#     'b': (1, 0, 'Routing', 'Rings your mobile|for twenty seconds', 'mobile'),
#   }
#   'edges': [('a','b'), ('b','c'), ('c','a','dash')]
#
# A node is (column, row, ROLE, 'line 1|line 2', icon, trigger). The last two
# are optional:
#
#   icon      a key in tools/icons.py — the glyph in the box's top-left corner.
#             An unknown name is a hard error rather than a silent blank.
#   trigger   'cron' or 'webhook', printed as a small brass label top-right.
#
# Two label lines maximum, roughly 26 characters a line.
#
# 'dash' marks a feedback loop. An edge that runs right to left is routed in a
# lane underneath the drawing rather than back through the boxes.
#
# No gradients and no rounded corners. Every fill and stroke is a CSS class
# styled in css/work.css, so no value is hard-coded here.
#
# **Keep drawings narrow rather than wide.** A schematic is fitted to the
# viewport width by default so the whole shape is visible on a phone, which
# means every extra column shrinks the type in all of them. Prefer three or
# four columns and more rows.
# ==========================================================================

BOX_W, BOX_H = 196, 92
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
            "icon": tup[4] if len(tup) > 4 else None,
            "trigger": tup[5] if len(tup) > 5 else None,
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
            # Feedback: down out of the source, left along the lane, up the
            # gutter to the target's left, then in. The riser goes up the empty
            # column gap rather than the target's centre line, because a target
            # with another box below it would otherwise have the wire pass
            # behind that box and read as two broken lines.
            riser = max(4, b["x"] - COL_GAP // 2)
            d = (f'M {acx} {a["y"] + BOX_H} V {lane_y} '
                 f'H {riser} V {bcy} H {b["x"]}')
            head = _arrow(b["x"], bcy, "right")

        wires.append(f'<path class="{cls}" d="{d}"/>')
        wires.append(head)

    # ---- boxes ----
    #
    # The glyph sits top-left and the ROLE label is indented past it. A node
    # without an icon keeps the old indent, so the two can coexist in one
    # drawing without the roles going ragged.
    boxes = []
    for key in sorted(n, key=lambda k: (n[k]["col"], n[k]["row"])):
        node = n[key]
        x, y = node["x"], node["y"]
        boxes.append('<g class="sch-node">')
        boxes.append(
            f'<rect class="sch-box" x="{x}" y="{y}" width="{BOX_W}" height="{BOX_H}"/>')
        if node["icon"]:
            boxes.append(icons.render(node["icon"], x + 14, y + 13))
        boxes.append(
            f'<text class="sch-role" x="{x + 14 + (icons.ICON_SIZE + 8 if node["icon"] else 0)}" '
            f'y="{y + 26}">{html.escape(node["role"].upper())}</text>')
        if node["trigger"]:
            boxes.append(
                f'<text class="sch-trigger" x="{x + BOX_W - 14}" y="{y + 26}" '
                f'text-anchor="end">{html.escape(node["trigger"].upper())}</text>')
        for i, line in enumerate(node["label"].split("|")[:2]):
            boxes.append(
                f'<text class="sch-label" x="{x + 14}" y="{y + 56 + i * 18}">'
                f'{html.escape(line)}</text>')
        boxes.append("</g>")

    body = "\n        ".join(wires + boxes)
    alt = html.escape(f"Drawing {number}. {caption}")

    # The stage is width:min(100%, --sch-w), so the whole drawing is visible at
    # rest on any screen and never blown up past its own size on a wide one.
    # js/schematic.js overrides that inline width to zoom, and the viewport
    # scrolls. Without JS you still get the complete drawing, just no zoom.
    return f"""<figure class="schematic">
  <div class="schematic-viewport" tabindex="0" role="group"
       aria-label="Drawing {number}, scrollable and zoomable">
    <div class="schematic-stage" style="--sch-w:{width}px">
      <svg viewBox="0 0 {width} {height}" preserveAspectRatio="xMidYMid meet"
           role="img" aria-label="{alt}">
        <title>{alt}</title>
        {body}
      </svg>
    </div>
  </div>
  <figcaption><span class="sch-no">{number}</span>{html.escape(caption)}</figcaption>
</figure>"""


# ==========================================================================
# NS-00 — the shared drawing. The same box runs every agent, which is why the
# fifth one costs less to run than the first. Rendered on every workflow page.
# ==========================================================================

BOX_DRAWING = {
    "nodes": {
        "host":   (0, 1, "Host",        "A spare PC, a NUC in|the office, or a VPS", "server"),
        "docker": (1, 1, "Docker",      "One compose file,|version-controlled", "docker"),
        "n8n":    (2, 0, "n8n",         "The drawing above,|as nodes you can watch", "n8n", "webhook"),
        "py":     (2, 1, "Python 3.12", "Workers for the jobs|n8n should not do", "code"),
        "cron":   (2, 2, "cron",        "Anything on a clock|rather than a trigger", "clock", "cron"),
        "data":   (3, 0, "Data layer",  "Sheets to read,|warehouse for history", "database"),
        "tools":  (3, 1, "Your tools",  "Phone, email, diary,|accounts, ads", "wrench"),
        "health": (3, 2, "Health check", "Heartbeat out|every two minutes", "pulse", "cron"),
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
    ("Installed", "Built, connected to the tools you already use, tested on your "
                  "real jobs, handed over working.", "£500", "one-off"),
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
                "call":  (0, 0, "Trigger",     "Inbound call to|your number", "phone", "webhook"),
                "fork":  (1, 0, "Routing",     "Rings your mobile|for twenty seconds", "mobile"),
                "agent": (2, 0, "Voice agent", "Answers if you cannot.|Asks three questions", "mic"),
                "text":  (2, 1, "Text-back",   "Text to the caller|inside a minute", "whatsapp"),
                "sweep": (2, 2, "Sweep",       "Catches anything|the webhook missed", "clock", "cron"),
                "sheet": (3, 0, "Job sheet",   "One row: name, job,|postcode, urgency", "sheets"),
                "alert": (3, 1, "Alert",       "The same thing to|your phone and inbox", "bell"),
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

    {
        "number": "02",
        "slug": "quote-follow-up",
        "title": "Quote follow-up",
        "subject": "Chasing on day three, seven and fourteen",
        "summary": ("Every quote you send gets chased on day three, day seven and "
                    "day fourteen, in your name, without you remembering to do it. "
                    "One reply and the chasing stops that minute."),
        "meta": ("An agent that chases your quotes on day three, seven and fourteen "
                 "and stops the moment the customer replies. Installed for £500, "
                 "maintained for £50 a month."),

        "intro": [
            "A quote that is never chased is not a quote. It is a document you spent "
            "an evening writing.",

            "Most small firms chase the first time and then stop, because the second "
            "chase is the awkward one and there is always something more urgent than "
            "an awkward message. So the quote sits there. The customer is not saying "
            "no. They have three quotes, a job that is not on fire, and no reason to "
            "decide today. Whoever asks last usually gets the work.",

            "This is the agent that asks. It knows what you sent, who you sent it to "
            "and when, and it comes back three times over a fortnight. Not a "
            "template that reads like a template — your words, your name, the job "
            "named. And the moment they reply, by any route, it stops. Nobody has "
            "ever bought anything from a firm that chased them after they answered.",
        ],

        # Three columns rather than five. The whole shape has to be legible on a
        # phone before anybody zooms in — see the note above BOX_W.
        "schematic": {
            "nodes": {
                "quote": (0, 1, "Trigger",  "You send a quote from|the tool you already use",
                          "doc", "webhook"),
                "sheet": (1, 0, "Register", "One row: who, what,|how much, what day",
                          "sheets"),
                "chase": (1, 1, "Chaser",   "Nine each morning.|Day three, seven, fourteen",
                          "clock", "cron"),
                "msg":   (2, 0, "Message",  "WhatsApp or text,|sent in your name",
                          "whatsapp"),
                "mail":  (2, 1, "Email",    "The same words, on|the same thread",
                          "mail"),
                "reply": (2, 2, "Reply watch", "Checks every ten minutes.|A reply stops it",
                          "reply", "cron"),
            },
            "edges": [
                ("quote", "sheet"),
                ("quote", "chase"),
                ("chase", "msg"),
                ("chase", "mail"),
                ("reply", "sheet", "dash"),
            ],
        },
        "caption": ("Quote follow-up. The chaser reads the register every morning; "
                    "the reply watch writes back to it and the chasing stops."),

        "stages": [
            ("You send the quote as you always did",
             "Nothing changes about how you write or send it. The agent picks it up "
             "from your quoting tool, your sent folder or a row you add yourself, "
             "whichever you already do. If it means changing how you quote, we have "
             "built the wrong thing."),
            ("It gets written down properly",
             "Who it went to, what the job is, what you quoted, and the date. One row "
             "on the quote sheet. That row is the whole memory of the thing — "
             "everything after this reads from it."),
            ("Day three: the short one",
             "Two lines. Did it arrive, and is there anything you want going through "
             "before they decide. Sent on the channel they contacted you on, because "
             "a customer who rang wants a text and a customer who emailed wants an "
             "email."),
            ("Day seven: the useful one",
             "This one carries something — when you could start, what the price "
             "includes, or the answer to the question people always ask about that "
             "kind of job. A chase that adds nothing is just a chase."),
            ("Day fourteen: the last one",
             "Plainly the last. It says so. Either the job is still live or it is "
             "not, and the customer gets to say which without feeling rude. That is "
             "usually the message that gets an answer."),
            ("Any reply, and it stops",
             "By text, by email, by picking up the phone. The reply watch runs every "
             "ten minutes and closes the sequence the same morning. It cannot chase "
             "somebody who has already answered you, which is the failure that would "
             "cost you the job outright."),
            ("You find out what actually happens",
             "Won, lost, or no answer, against what you quoted. After three months "
             "you know your real conversion rate and which of the three messages "
             "does the work. Most firms have never had that number."),
        ],

        "stack": [
            ("Docker",
             "The same compose file as every other agent. This one is another service "
             "inside it, not another machine."),
            ("n8n, self-hosted",
             "The drawing above, as nodes you can watch run. Same login as the phone "
             "agent if you already have one."),
            ("Python 3.12",
             "The workers: reading the register, deciding who is due a chase today, "
             "and matching an inbound reply back to the right quote."),
            ("cron",
             "Two schedules. The nine o'clock chaser, and the ten-minute reply watch."),
            ("WhatsApp or SMS",
             "The WhatsApp Business API where you already use it, otherwise Twilio "
             "or your existing provider. Messages go out from your number, not a "
             "short code nobody recognises."),
            ("Email",
             "Sent through your own mailbox, on the original thread, so the chase "
             "lands under the quote rather than as a fresh message with no context."),
            ("Google Sheets",
             "The quote register. You can open it, sort it and correct it, and the "
             "agent reads your corrections on the next run."),
            ("The warehouse",
             'Still to be chosen — <span class="tbd">product name to be confirmed</span>. '
             'Every quote, every chase and every outcome kept with its dates, so the '
             'conversion rate is a figure rather than a feeling.'),
        ],

        "build": [
            ("The box it runs in",
             "If the phone agent is already installed, this step is done — it is the "
             "same host and the same <code>docker-compose.yml</code>, with one more "
             "service in it. If this is your first agent, it is Docker on a spare PC, "
             "a NUC or a VPS at about five pounds a month, brought up with "
             "<code>docker compose up -d</code>."),

            ("Deciding where a quote comes from",
             "This is the step that actually decides whether the agent works, and it "
             "is the one to be honest about. If your quoting tool has a webhook, we "
             "use it. If it does not, we watch your sent folder for the template you "
             "use. If neither is reliable, you add a row yourself — ten seconds, and "
             "far better than a clever guess that misses one quote in six."),

            ("The register",
             "A Google Sheet with one row per quote and columns for the channel, the "
             "value, the date and the outcome. It is deliberately something you can "
             "read and edit. If you mark a row as won on a Tuesday, nothing chases it "
             "on the Wednesday."),

            ("The cron jobs",
             "Two. <code>0 9 * * 1-5</code> runs the chaser on weekday mornings only, "
             "because a quote chased at eight on a Sunday reads as automated and "
             "undoes the point of it. <code>*/10 * * * *</code> runs the reply watch. "
             "The full list we run on an agent, and what breaks when each one is "
             "missing, is written up in "
             f'<a href="{CRON_ARTICLE}">the cron jobs worth setting up for an agent</a>.'),

            ("The three messages",
             "Written with you, in a half-hour sitting, from quotes you have already "
             "sent. Not generated. They go in version control with everything else, "
             "so a change to the day-seven message is a change you can see and undo."),

            ("Matching replies back to quotes",
             "The unglamorous half of the build. An inbound text is matched on the "
             "number, an email on the thread, and anything the agent cannot place "
             "with confidence is flagged for you rather than guessed at. A wrong "
             "match closes the wrong quote, so it fails loudly instead."),

            ("Credentials and accounts",
             "Every account is opened in your name, on your card, with us added as a "
             "partner. The WhatsApp Business number and the mailbox are yours. If you "
             "want us gone, you remove us in one click and the chasing carries on."),

            ("Testing on real quotes before hand-over",
             "We run it against a fortnight of quotes you have already closed and "
             "check it would have chased the right ones on the right days and left "
             "the rest alone. Then we send live ones to our own phones and mailboxes "
             "and reply on each channel in turn, including replying to the day-three "
             "message after the day-seven one has been queued. Until it stops every "
             "time, it is not finished and we do not invoice."),
        ],

        "media": [
            ("The three messages", "The actual day three, seven and fourteen text for "
             "one client, with the job details removed."),
            ("The register", "A screenshot of a real month, with names removed."),
            ("A won job, end to end", "The quote, the two chases, the reply, and the "
             "row closing — one thread, with permission."),
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
    url = f"https://northsaga.ai/agents/{page['slug']}"
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
        paging.append(f'      <a class="work-prev" href="/agents/{prev_page["slug"]}">'
                      f'<span>Previous</span>{prev_page["title"]}</a>')
    if next_page:
        paging.append(f'      <a class="work-next" href="/agents/{next_page["slug"]}">'
                      f'<span>Next</span>{next_page["title"]}</a>')

    return "".join([
        chrome.head(
            title=title,
            description=page["meta"],
            url=url,
            og_title=title,
            og_description=page["summary"],
        ),
        chrome.BANNER.format(source="tools/build-agent-pages.py",
                             script="build-agent-pages.py"),
        chrome.header(),
        chrome.menu(current="work"),
        f"""
<main>

<!-- ============================ INTRO ============================ -->
<section class="band work-head">
  <div class="container">
    <p class="eyebrow">Agent {page['number']} · {page['subject']}</p>
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
        chrome.footer(scripts=["/js/schematic.js"]),
    ])


def homepage_list():
    """The block to paste into .install-list in index.html."""
    items = []
    for page in PAGES:
        items.append(f"""      <li class="reveal">
        <h3><a href="/agents/{page['slug']}">{page['title']}</a></h3>
        <p>{page['summary']}</p>
      </li>""")
    return ("<!-- GENERATED — paste into .install-list in index.html. Only the\n"
            "     agents currently in tools/build-agent-pages.py appear here. -->\n"
            + "\n".join(items) + "\n")


def main():
    out_dir = os.path.join(ROOT, "agents")
    os.makedirs(out_dir, exist_ok=True)

    for i, page in enumerate(PAGES):
        prev_page = PAGES[i - 1] if i > 0 else None
        next_page = PAGES[i + 1] if i < len(PAGES) - 1 else None
        path = os.path.join(out_dir, page["slug"] + ".html")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(render(page, prev_page, next_page))
        print(f"wrote agents/{page['slug']}.html")

    with open(os.path.join(HERE, "_homepage-list.html"), "w", encoding="utf-8") as fh:
        fh.write(homepage_list())
    print("wrote tools/_homepage-list.html")


if __name__ == "__main__":
    main()
NSEOF

cat > 'tools/build-installer.py' <<'NSEOF'
#!/usr/bin/env python3
"""Northsaga — build the self-extracting installer.

    cd tools && python3 build-installer.py

Writes setup-northsaga.sh in the repo root: a single shell script that recreates
the whole site in a directory of your choosing. One quoted heredoc per text
file, then the binary assets base64-encoded in a footer.

Run it last, after build-agent-pages.py and build-journal.py, or the installer
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
NSEOF

cat > 'tools/build-journal.py' <<'NSEOF'
#!/usr/bin/env python3
"""Northsaga — journal page generator.

    cd tools && python3 build-journal.py

The article's content is not in the HTML. It lives in assets/data/cron-jobs.json
so it can be updated on its own — by hand now, by an agent later — without
anybody editing markup. journal/*.html is generated output; do not hand-edit it.

The prose fields (intro, does, why, fails, caveats, outro) may contain inline
HTML — <code> for a command, <a> for a link — and are written through as-is.
Everything else is escaped.

Python 3 standard library only. No dependencies, no build step.
"""

import html
import json
import os

import chrome

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

DATA = os.path.join(ROOT, "assets", "data", "cron-jobs.json")
OUT_DIR = os.path.join(ROOT, "journal")

# £500 an agent to install, £50 a month to maintain. Kept next to the price
# block in tools/build-agent-pages.py — if one changes, change both.
INSTALL_PRICE = "£500"
MAINTAIN_PRICE = "£50"

# Author for schema. George is the founder and writes the copy — the site so far
# publishes no bylines; once a byline is added, keep this in sync.
AUTHOR = {
    "name": "George Astin",
    "role": "Founder, Northsaga",
}


def article_jsonld(data):
    """Article + FAQPage + HowTo structured data for the journal page, built
    from the same cron-jobs.json content the page renders. The FAQ mirrors the
    three labelled fields (does/why/fails) the readers actually see."""
    url = f"https://northsaga.ai/journal/{data['slug']}"
    updated = data["updated"]

    faq_questions = [
        {
            "@type": "Question",
            "name": f"Why does the {job['name'].lower()} job run on a schedule?",
            "acceptedAnswer": {
                "@type": "Answer",
                "text": f"{job['does']} {job['why']}",
            },
        }
        for job in data["jobs"]
    ]

    howto_steps = [
        {
            "@type": "HowToStep",
            "position": i,
            "name": job["name"],
            "text": f"{job['expression']} — {job['does']}",
        }
        for i, job in enumerate(data["jobs"], 1)
    ]

    article = {
        "@context": "https://schema.org",
        "@type": "Article",
        "@id": f"{url}#article",
        "headline": data["title"],
        "description": data["standfirst"],
        "datePublished": updated,
        "dateModified": updated,
        "mainEntityOfPage": {"@type": "WebPage", "@id": f"{url}#page"},
        "author": {
            "@type": "Person",
            "name": AUTHOR["name"],
            "jobTitle": AUTHOR["role"],
        },
        "publisher": {"@id": "https://northsaga.ai/#business"},
        "speakable": {
            "@type": "SpeakableSpecification",
            "cssSelector": ["h1", ".lede"],
        },
    }
    faq = {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "@id": f"{url}#faq",
        "mainEntity": faq_questions,
    }
    howto = {
        "@context": "https://schema.org",
        "@type": "HowTo",
        "@id": f"{url}#howto",
        "name": data["title"],
        "description": data["standfirst"],
        "totalTime": "PT1H",
        "step": howto_steps,
    }
    blocks = [article, faq, howto]

    def dump(obj):
        import json as _json
        return _json.dumps(obj, ensure_ascii=False, indent=2)

    return "\n".join(
        f'<script type="application/ld+json">\n{dump(b)}\n</script>' for b in blocks
    )


def entry(index, job):
    rows = [
        ("What it does", job["does"]),
        ("Why an agent needs it", job["why"]),
        ("What happens if you skip it", job["fails"]),
    ]
    body = "\n".join(
        f"""        <div>
          <dt>{label}</dt>
          <dd>{text}</dd>
        </div>""" for label, text in rows)

    return f"""      <li class="cron-entry reveal">
        <div class="cron-head">
          <span class="num">{index:02d}</span>
          <code class="cron-expr">{html.escape(job['expression'])}</code>
          <h3>{html.escape(job['name'])}</h3>
        </div>
        <dl class="cron-body">
{body}
        </dl>
      </li>"""


def render(data):
    url = f"https://northsaga.ai/journal/{data['slug']}"
    title = f"{html.escape(data['title'])} — Northsaga"

    entries = "\n".join(entry(i, job) for i, job in enumerate(data["jobs"], 1))
    intro = "".join(f"<p>{p}</p>" for p in data["intro"])
    outro = "".join(f"<p>{p}</p>" for p in data["outro"])
    caveats = "\n".join(f"      <p>{p}</p>" for p in data["caveats"])

    return "".join([
        chrome.head(
            title=title,
            description=data["standfirst"],
            url=url,
            og_title=html.escape(data["title"]),
            og_description=data["standfirst"],
            page_jsonld=article_jsonld(data),
        ),
        chrome.BANNER.format(source="assets/data/cron-jobs.json",
                             script="build-journal.py"),
        chrome.header(),
        chrome.menu(current="writing"),
        f"""
<main>

<!-- ============================ HEAD ============================ -->
<section class="band article-head">
  <div class="container">
    <p class="eyebrow">Writing</p>
    <h1 class="display">{html.escape(data['title'])}</h1>
    <p class="lede" style="margin-top:var(--space-3);">{data['standfirst']}</p>
    <p class="article-meta">Updated {html.escape(data['updated'])}</p>

    <div class="prose" style="margin-top:var(--space-5);">
      {intro}
    </div>
  </div>
</section>

<!-- ============================ THE LIST ============================ -->
<section class="band band--tall" id="jobs">
  <div class="container">
    <p class="eyebrow">The schedules</p>
    <ol class="cron-list">
{entries}
    </ol>

    <div class="cron-caveat">
{caveats}
    </div>
  </div>
</section>

<!-- ============================ CLOSE ============================ -->
<section class="band band--tall" id="close" style="background:var(--ink-deep);">
  <div class="container">
    <div class="prose">
      {outro}
    </div>

    <h2 class="display" style="font-size:var(--step-3); max-width:20ch; margin-top:var(--space-4);">
      Or we install it for you.
    </h2>
    <p class="lede" style="margin-top:var(--space-3);">
      {INSTALL_PRICE} an agent to install, {MAINTAIN_PRICE} an agent a month to
      maintain, and the schedule above comes with it. Every account in your name,
      and you can take the whole thing in-house whenever you want it.
    </p>

    <ul class="contact-lines article-contact is-placeholder" style="max-width:34rem;">
      <li><span class="k">Email</span><span class="v">{chrome.EMAIL}</span></li>
      <li><span class="k">Telephone</span><span class="v">0000 000 0000</span></li>
    </ul>

    <div class="hero-actions">
      <a class="btn" href="/#contact">Book the survey</a>
      <a class="btn btn--quiet" href="/agents/answering-the-phone">See one built</a>
    </div>
  </div>
</section>

</main>
""",
        chrome.footer(),
    ])


def main():
    with open(DATA, encoding="utf-8") as fh:
        data = json.load(fh)

    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, data["slug"] + ".html")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(render(data))
    print(f"wrote journal/{data['slug']}.html  ({len(data['jobs'])} schedules)")


if __name__ == "__main__":
    main()
NSEOF

cat > 'tools/chrome.py' <<'NSEOF'
"""Northsaga — shared page chrome for the generators.

CLAUDE.md requires the header, menu and footer blocks to be duplicated exactly
on every page. Rather than duplicate them again in each generator, both
build-agent-pages.py and build-journal.py import them from here, so there is one
place to change when a menu item is added.

Python 3 standard library only. No dependencies, no build step.
"""

# The menu. Adding an item here means adding a matching nth-child stagger delay
# in css/site.css, or the new item snaps in with no stagger. There are seven.
NAV = [
    ("The work",      "/#work",                                   "work"),
    ("How it works",  "/#process",                                "process"),
    ("Case studies",  "/case-studies",                            "case-studies"),
    ("What it costs", "/#ledger",                                 "ledger"),
    ("Proof",         "/#proof",                                  "proof"),
    ("Writing",       "/journal/best-cron-jobs-for-ai-agents",    "writing"),
    ("Talk to us",    "/#contact",                                "contact"),
]

# The footer carries the same list minus Proof, which has no separate page.
FOOTER_NAV = [n for n in NAV if n[2] != "proof"]

EMAIL = "hello@northsaga.ai"

# Organization identity on the homepage, byte-aligned with index.html. On
# generated subpages we render a WebPage stub instead (identity stays on the
# homepage). The postcodes are UNVERIFIED — see CLAUDE.md. They appear in the
# schema, the contact section and the footer, and must be corrected in all three
# together.
ORGANIZATION_JSONLD = """
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "@id": "https://northsaga.ai/#business",
  "name": "Northsaga",
  "url": "https://northsaga.ai/",
  "email": "hello@northsaga.ai",
  "logo": {
    "@type": "ImageObject",
    "url": "https://northsaga.ai/assets/logo/northsaga-mark-bone.svg"
  },
  "description": "Installs and maintains AI agents for owner-managed small businesses and trades in Dulwich and West Norwood, south London.",
  "slogan": "New tools. Old standards.",
  "sameAs": [
    "https://github.com/ClespCoding/northsaga.ai"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "contactType": "customer service",
    "email": "hello@northsaga.ai",
    "availableLanguage": "English"
  },
  "areaServed": [
    { "@type": "Place", "name": "Dulwich, London" },
    { "@type": "Place", "name": "West Norwood, London" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE21", "postalCodeEnd": "SE21" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE22", "postalCodeEnd": "SE22" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE24", "postalCodeEnd": "SE24" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE27", "postalCodeEnd": "SE27" }
  ]
}
</script>
"""

WEBPAGE_JSONLD = """
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "@id": "{url}#page",
  "url": "{url}",
  "name": "{title}",
  "isPartOf": { "@id": "https://northsaga.ai/#website" },
  "about": { "@id": "https://northsaga.ai/#business" },
  "publisher": { "@id": "https://northsaga.ai/#business" }
}
</script>
"""


def head(title, description, url, og_title, og_description, og_type="article",
         page_jsonld=None):
    """The <head> block. Identical to the hand-written pages apart from the
    extra css/work.css link, which only the generated pages need.
    `page_jsonld` is a raw JSON-LD <script> string appended after the
    WebPage block (e.g. an Article on the journal)."""
    schema = WEBPAGE_JSONLD.replace("{url}", url).replace("{title}", title)
    if page_jsonld:
        schema += "\n" + page_jsonld
    return f"""<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">

<link rel="canonical" href="{url}">

<link rel="icon" href="/assets/favicon/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/favicon/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/assets/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0E1A24">

<meta property="og:title" content="{og_title}">
<meta property="og:description" content="{og_description}">
<meta property="og:type" content="{og_type}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="https://northsaga.ai/assets/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{og_title}">
<meta name="twitter:description" content="{og_description}">
<meta name="twitter:image" content="https://northsaga.ai/assets/og-image.png">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300&display=swap" rel="stylesheet">

<link rel="stylesheet" href="/css/tokens.css">
<link rel="stylesheet" href="/css/site.css">
<link rel="stylesheet" href="/css/work.css">

<!-- .reveal starts at opacity 0 and is un-hidden by js/site.js. Without this,
     a failed or disabled script leaves most of the page invisible. -->
<noscript><style>.reveal {{ opacity: 1; transform: none; }}</style></noscript>

<!-- WebPage stub. Identity lives on the homepage (Organization at
     https://northsaga.ai/#business). address, telephone and openingHours are
     deliberately absent rather than invented — add them once confirmed. The
     postcodes in areaServed are UNVERIFIED; check them against the real
     service area and correct here, in the contact section and in the footer
     together. -->
{schema}
</head>
<body>
"""


def header():
    """Header. The mark's four paths are inlined rather than linked because the
    header has to inherit currentColor — see CLAUDE.md. Geometry lives in
    assets/logo/ first; this is a copy of it."""
    return """
<!-- ============================ HEADER ============================ -->
<header class="site-header" id="siteHeader">
  <a class="header-mark" href="/" aria-label="Northsaga home">
    <svg viewBox="-77 -167 259 334" aria-hidden="true">
      <g fill="none" stroke="currentColor" stroke-width="16">
        <path d="M 0 -160 L -70 -32"/><path d="M 0 -160 L 0 160"/>
        <path d="M 0 -160 L 175 160"/><path d="M 175 -160 L 175 160"/>
      </g>
    </svg>
    <span>orthsaga</span>
  </a>

  <button class="menu-toggle" id="menuToggle" aria-expanded="false" aria-controls="menu">
    <span class="menu-label">Menu</span>
    <i></i><i></i>
  </button>
</header>
"""


def menu(current=None):
    lines = []
    for label, href, key in NAV:
        mark = ' aria-current="page"' if key == current else ""
        lines.append(f'    <li><a href="{href}"{mark}>{label}</a></li>')
    items = "\n".join(lines)
    return f"""
<!-- ============================ MENU ============================ -->
<nav class="menu" id="menu" aria-label="Main">
  <ul class="menu-nav">
{items}
  </ul>
  <div class="menu-foot">
    <span>Northsaga — operations, installed. Dulwich and West Norwood.</span>
    <a href="mailto:{EMAIL}">{EMAIL}</a>
  </div>
</nav>
"""


def footer(scripts=()):
    """The footer. `scripts` are extra sources loaded after site.js — the
    generated pages use it for js/schematic.js, which the hand-written pages
    have no drawings for."""
    links = "\n".join(
        f'        <a href="{href}">{label}</a>' for label, href, _ in FOOTER_NAV
    )
    extra = "".join(f'\n<script src="{src}" defer></script>' for src in scripts)
    return f"""
<!-- ============================ FOOTER ============================ -->
<footer class="site-footer">
  <div class="container">
    <div class="footer-top">
      <p class="footer-motto">New tools.<br>Old standards.</p>
      <p class="footer-area">
        Dulwich and West Norwood, south London.<br>
        SE21, SE22, SE24, SE27 and surrounding.
      </p>
      <nav class="footer-nav" aria-label="Footer">
{links}
      </nav>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span id="year">2026</span> Northsaga. Registered in England.</span>
      <a href="mailto:{EMAIL}">{EMAIL}</a>
    </div>
  </div>
</footer>

<script src="/js/site.js" defer></script>{extra}
</body>
</html>
"""


BANNER = ("<!-- GENERATED FILE — do not hand-edit. Source: {source}\n"
          "     Edit there, then run: cd tools && python3 {script} -->\n")
NSEOF

cat > 'tools/icons.py' <<'NSEOF'
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
NSEOF

# ---- binary assets: icons and the share card ----

nsbin 'assets/og-image.png' <<'NSEOF'
iVBORw0KGgoAAAANSUhEUgAABLAAAAJ2CAIAAADAIuwLAAAQAElEQVR4nOzdBVxT6xsH8FcFaQQk
BAUEBBQUFAwssAsDEwvF7tZre+1rd3crJnbntRtsUBRQQFBCUkHv/4Hh/gjbYcA2Nvb7frz3c9je
bWfb2Tnv8z5vKGmbVGAAAAAAAACgeJQYAAAAAAAAKCQEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAA
AACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAA
AAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAI
AAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgE
hAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICC
QkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAA
KCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAA
AICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAA
AAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEA
AAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQ
AgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoK
ASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACg
oBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAA
AAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAA
AACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAA
AAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAI
AAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgE
hAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICC
QkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAA
KCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAA
AICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAA
AAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEA
AAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoIoz
+FNNpyoa6mo5b6cb6S4GAAAAAABQVCAg/IOebqmNS2ZcOrqla/uWxYoV491IG906tKIb6S4qwAAA
AAAAAIqEEipaegx+mzy6v7OjnbqaaqP6NZs3qvMhJMy0bJkNS6Z3atuMbixZUllZucS/dx4zAAAA
AAAA+VdM26QCgwxljQ0vH9tSongJjjLff/xo3nnQp/BIBn8yNNC7dXo3R4E6rbyivkQzAAAAAACQ
Gegy+n/jh/UpUZz/gfwnsIxKyZJUjAEAAAAAAMg/BISZqlSq0LqZa5YbigkrScWoMAMAAAAAAJBz
CAgzTRs3SPTCE0f2ZwAAAAAAAHIOAWG6Jm4uTg52opev5VzFtbYTAwAAAAAAkGcICFnx4sXHDPZi
eTRxZL/ixfHpAQAAAACAHENIwzw9WthYlc9x83/cj6KH0AMZAAAAAACA3FL0gFBDQ23UwB6C7imW
20MZPbBkSWUGAAAAAAAgnxQ9IOzXvUNpPR2WL/TAPl09GAAAAAAAgHxS6IBQT7dUn24FiugGe3eh
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
Ov7vJQxAUSFDCAAgK0L+nDu0csUK9C8hMfHwyYuzFq9jAACQX5/CP2f9s7GrS/qNEZF0dt1z6DQD
UGDIEAIAyJC+PdoP79ddS1M9OCTs7YeQB09f+Bw7l5CYxAAAoGAWzxzn0arR9++p70M+Brz7cP32
oxPnrjIAhYeAEAAAAAAAQEGhyygAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoK
ASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACg
oBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAA
AAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAA
AACgoBAQAgAAAAAAKCgEhAAAAAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQAgAAAAAAKCgEhAAA
AAAAAAoKASEAAAAAAICCQkAIAAAAAACgoBAQ5mLXOHsGktdr6QsGAAAAAADShYAQAAAAAABAQRXT
NqnAAAAAAAAAQPEgQwgAAAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJCQAgAAAAA
AKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAoKASEAAAA
AAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJCQAgA
AAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAoKASE
AAAAAAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJC
QAgAAAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAo
KASEAAAAAAAACgoBIQAAAAAAgIJCQAgAAAAAAKCgEBACAAAAAAAoKASEAAAAAAAACgoBIQAAAAAA
gIJCQAgAAAAAAKCgEBDmmaZdx9FeTlrpm/FP96/Z75+Q+2NULdqP7O+iy6LvbVnp+z6FFVR+9uH/
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
zfSf7jzTV+73mnKfd7334dbnHtpa7iNf7lrmH/szx7/b0L6zo33L5q/e1+mJwb7uT0/23mRZzG/6
Bf8G1v7RE/i6vvXt2u9VAAAAEI93CAEAAIIShAAAAEEJQgAAgKAEIQAAQFCCEAAAIChBCAAAEJQg
BAAACEoQAgAABCUIAQAAghKEAAAAQQlCAACAoAQhAABAUIIQAAAgKEEIAAAQlCAEAAAIShACAAAE
JQgBAACCEoQAAABBCUIAAICgBCEAAEBQghAAACAoQQgAABCUIAQAAAhKEAIAAAQlCAEAAIIShAAA
AEEJQgAAgKAEIQAAQFCCEAAAIChBCAAAEJQgBAAACEoQAgAABCUIAQAAghKEAAAAQQlCAACAoAQh
AABAUIIQAAAgKEEIAAAQlCAEAAAIShACAAAEJQgBAACCEoQAAABBCUIAAICgBCEAAEBQghAAACAo
QQgAABCUIAQAAAhKEAIAAAQlCAEAAIIShAAAAEEJQgAAgKAEIQAAQFCCEAAAIChBCAAAEJQgBAAA
CEoQAgAABCUIAQAAghKEAAAAQQlCAACAoAQhAABAUIIQAAAgKEEIAAAQlCAEAAAIShACAAAEJQgB
AACCEoQAAABBCUIAAICgBCEAAEBQghAAACAoQQgAABCUIAQAAAhKEAIAAAQlCAEAAIIShAAAAEEJ
QgAAgKAEIQAAQFCCEAAAIChBCAAAEJQgBAAACEoQAgAABCUIAQAAghKEAAAAQQlCAACAoAQhAABA
UIIQAAAgKEEIAAAQlCAEAAAIShACAAAEJQgBAACCEoQAAABBCUIAAICgBCEAAEBQghAAACAoQQgA
ABCUIAQAAAhKEAIAAAQlCAEAAIIShAAAAEEJQgAAgKAEIQAAQFCCEAAAIChBCAAAEJQgBAAACEoQ
AgAABCUIAQAAghKEAAAAQQlCAACAoAQhAABAUIIQAAAgKEEIAAAQlCAEAAAIShACAAAEJQgBAACC
EoQAAABBCUIAAICgBCEAAEBQghAAACAoQQgAABCUIAQAAAhKEAIAAAQlCAEAAIIShAAAAEEJQgAA
gKAEIQAAQFCCEAAAIChBCAAAEJQgBAAACOo/AAAA//8EUUOSAAAABklEQVQDAJ5htQQ8N8IKAAAA
AElFTkSuQmCC
NSEOF

nsbin 'assets/favicon/apple-touch-icon.png' <<'NSEOF'
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
/gMNY+Og3BavjQAAAABJRU5ErkJggg==
NSEOF

nsbin 'assets/favicon/favicon-16.png' <<'NSEOF'
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAABmJLR0QA/wD/AP+gvaeTAAABOElE
QVQokWPkk1JhQAI2FsbXbtx+9+ETsiAjI6OYsODLN+8YGBiYkCWM9DTn9jdWFqQyoAIODrZtq6ZD
2CgaynKTXr99a29lIictyYADIDS4OVqxsbJ8/Px13dbdhRmxBDSwsDAVZcR1TVnwn+H/hm37jfQ0
DXQ08GmICPR6+OTZiTMXGRgYfv/+PWHmkpKcBHwaeHi4e6YuhItu3LGfh4vT0doUp4YZ81fevvcQ
Lvrv37/2iXPL85JZWJiwa8AEJ89eev7ydaC3C7EaGBgYOibNy0uN5uRkJ1bDzTv3j5+5mBARSKwG
BgaGvqkL48N9RYQEidXw4vXbtVv2psQGEauBgYFh5oJVbg5WTIxMxGr49OXLguUb2dnZIFxGtOQt
LCTw8dOnP3/+IQuys7GpKstfuX6bgYEBANTAZ1fNMDHmAAAAAElFTkSuQmCC
NSEOF

nsbin 'assets/favicon/favicon-32.png' <<'NSEOF'
iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABmJLR0QA/wD/AP+gvaeTAAAC3UlE
QVRIibXWfyyUcRwH8Pdzj3McOo4kppqZiUZlizILUyot+VU4o3OhEVqa+rP/sqL5MaKR3xXVskuo
ZMk0tVItcoZOOA4pv/7ozt1z/dG69YMTnufz3/P+fr7f175/PN99iHXW9mCySI4JX8dySpzA22sX
h82WDsmWPUtPj+Xq7Mg3401OfdOGhI4bbHWwE1flAoR8YtI7UKRWq3UD5nzTjqbqEdm4T1CsNmTp
2HA+ORYgAFhZrg857LfsDRatJQEvj52e7juUSuXPz5SEKENDDm0Ai8VKS4wBIOmXAujtk26w4Asj
gmgDjh70dXa0//RZNjwiB3CvvpmiqIToMAtzMxoAjr7+mQQBgMz8UkqjATA8Km940sblGiQKj9MA
xIQf2Whl+a5L0tzaoQ0zr5UpFxbCQw5tsbVeE8AzMY6PDgOQkVOi0Wi0uWx0ovruQzZJpiWdWBOQ
dDKCt864qaX9zfuPfy3lF9+amZ0/4Ovp5uq0SsDG2lIQGqBSUdlFlf+2zszNX6+4A+BCqoggiNUA
kcEB+mx2TV3jgHR40e7y2+Ix+cT2bY5+ez1WA2QVlKdfvJpXfHOpboVSmV1UDeBckpBNkisGKIq6
3/B06uu0jg11jS3dkn67zTahgftXDPxPURSVVVAOIDU+ysjIkH4AQFtHZ/vLt+Z8U1FkMCMAgIzc
EoqiRIJgy+Uej1UCkj6puOkZl2twOi6SEQBAVkH5d4XiWKC/vd0mRgD5xJfK2nqSJM+eimYEAFBY
Wjs9M7fPe7e7mwsjwOz8fGFZLYD0ZOFSj8eaAAAVNeIh2ZiLk4O/zx5GgAWVKqeoCkB6cqweqUc/
AODBo9aunn5bG6ugAF9GAI1GcymnGECsYJEfmwYAwKvOD60vXpvxTJgCAFzJK1VTFACS/ONM2oDe
gcGG5jYAxkbc3/Nlhl9J32D94+fdPf2KXyOejurq6QNBXM67MT45pQ11Db+01A+bJP2c8OUPpQAA
AABJRU5ErkJggg==
NSEOF

nsbin 'assets/favicon/icon-512.png' <<'NSEOF'
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
QmCC
NSEOF

chmod +x tools/*.py 2>/dev/null || true

echo "Northsaga installed into $DEST"
echo "  34 text files, 5 binary assets"
echo
echo "  cd $DEST && python3 -m http.server 8000"
