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
