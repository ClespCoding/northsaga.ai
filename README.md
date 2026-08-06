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
