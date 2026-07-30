# CLAUDE.md

Governs all work in this repository. Read it before touching anything.

## Provenance of this file

This file was written from a brief that described a repository state that did
not exist yet. There was no `BRAND.md`, no `index.html`, no `css/`, no `js/`
and no `assets/logo/` — the repo held an unrelated Next.js blog, which was
deleted and replaced by the current static site.

Two consequences that matter:

- **There is no `BRAND.md`.** The brief said to defer to it. It does not
  exist, so this file is the sole source of brand truth. If a `BRAND.md` is
  added later and the two disagree, `BRAND.md` wins and this file gets
  corrected.
- **The logo SVGs in `assets/logo/` are placeholders drawn to a written
  description, not the real artwork.** See [The mark](#the-mark).

## What the business is

Northsaga installs AI agents into small local businesses and then maintains
them. The commercial model deliberately mirrors installing a piece of
equipment into a firm's estate — not a SaaS subscription, not an agency
retainer.

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
compiling it by price, age and aspect.

## Ideal client profile

Owner-managed local businesses and trades in **Dulwich and West Norwood, south
London**, typically 3–30 staff: builders, electricians, plumbers, roofers,
landscapers, garages, veterinary practices, dental and private clinics, estate
and lettings agents, independent retailers, professional services.

They are practical, time-poor, sceptical of marketing, and have usually been
let down by an agency before. Write for that reader.

**Postcodes are unverified.** The site currently hard-codes SE21, SE22, SE24
and SE27 across the contact section, the footer and the `areaServed` block of
every page's JSON-LD. Those four match Dulwich Village, East Dulwich, Herne
Hill and West Norwood, but nobody has confirmed them against the real service
area, and "and surrounding" was never resolved into a list. Confirm with the
business and correct all three places together before treating them as fact.

## Brand rules

### The mark

A symmetric arrow that is also the letter **N**, four strokes. The left arm
mirrors the N's diagonal at exactly the same angle — that mirroring is what
stops it reading as "1N".

**Never redraw it by eye or alter the geometry. Always reference the SVGs in
`assets/logo/`.**

That rule cannot be honoured yet. No artwork was supplied, so
`assets/logo/mark.svg` and `assets/logo/mark-draw.svg` were constructed from
the written description alone: full-height outer verticals plus two diagonals
meeting at a top apex. It is symmetric and it is four strokes, but the
proportion, stroke weight and angle are guesses and the N reading is weak.

Treat the current files as a stand-in, not as reference geometry. Replace them
with the real artwork, then delete this paragraph. Until then, do not derive
new lockups, favicons or spacing rules from them — you would be propagating a
guess.

Never apply a gradient, glow, shadow, outline or containing box to the mark.

### The chrome treatment is not the logo

The faceted metal treatment is reserved for physical and ceremonial use —
signage, embossed proposal covers, livery. **It must never appear on the
website.**

### Colour

All values live in `css/tokens.css` and are referenced as custom properties.
**Nothing hard-codes a hex outside that file.**

| Token | Value | Use |
| --- | --- | --- |
| `--ink` | `#0E1A24` | base |
| `--ink-deep` | `#08111A` | overlays, footer |
| `--ink-raised` | `#16242F` | panels |
| `--bone` | `#E9E4D9` | primary type |
| `--bone-dim` | `#97A1A9` | secondary type |
| `--paper` | `#EDE9DE` | light sections |
| `--paper-ink` | `#12202B` | type on light |
| `--brass` | `#B08D4F` | accent |
| `--brass-soft` | `#7C6438` | accent on light |

Brass is **the earned colour**. It marks only things of consequence — a price,
a section eyebrow, a rule under a heading. It never exceeds roughly 5% of any
screen. There is no second accent. **No gradients anywhere.**

### Type

- **Cormorant Garamond 300** for display, set large and tight.
- **Archivo 400/500** for body.
- **Archivo 500 uppercase, `letter-spacing: 0.22em`** for eyebrows, buttons
  and labels **only** — never for sentences.
- Sentence case in body copy.
- **No letter-spaced serif.**

### Layout

Square corners throughout (`--radius: 0`). Generous whitespace. Hairline rules
rather than boxes and cards wherever possible. Nothing rounded, nothing
shadowed.

### Motion

**One orchestrated moment only** — the mark draws itself once on load.
Everything else is a quiet reveal on scroll.

`prefers-reduced-motion` is respected everywhere, without exception. Do not add
animation for its own sake; scattered effects make the site read as generated.

### Navigation

A full-screen menu overlay in the Mylands style: the panel wipes up over the
page, oversized Cormorant links rise in with a stagger, the hamburger rotates
into a cross. **This is a signature element — extend it for new pages, don't
replace it with a conventional nav bar.**

### Voice

Plain English, spoken to a foreman, not sold to a prospect. Name things
concretely — "missed-call text-back", never "intelligent engagement
solutions". Short sentences. Real numbers including prices. State what
Northsaga will not do as well as what it will.

**Banned outright:** leverage, synergy, seamless, transform, revolutionise,
unlock, empower, cutting-edge, game-changing, exclamation marks, and any claim
that cannot be attached to a named client.

**Approved lines:**
- *New tools. Old standards.* (primary)
- *Built the old way. Runs the new way.* (headline)
- *At Northsaga, the technology is new. The way we work isn't.*

### Never use the Smith Barney line

**"We make our money the old-fashioned way. We earn it."** is Smith Barney's
line from their John Houseman advertisements and remains widely recognised. It
must never appear on any Northsaga property.

Borrow the cadence — claim, full stop, humbler correction — never the words.
This prohibition is recorded here so it is not reintroduced later by someone
who only remembers that the cadence was approved.

### Trust behaviours the site must uphold

These are brand rules, not marketing preferences. Any change that breaks one
is wrong.

- **Published pricing logic.** The ledger section is the point of the site.
- **Named humans and real photographs.** No stock imagery, no illustrated
  characters, and no abstract "AI" visuals — no neural networks, no glowing
  brains, no blue circuitry.
- **Proof over promise:** named client, named problem, named number.
- **No claim ships without a source.** If a figure isn't verified, it doesn't
  go on the page.

## Technical rules

- Static HTML, CSS and vanilla JS. **No framework, no build step, no
  dependencies, no npm.** There is deliberately no `package.json`. If a task
  seems to need a build step, **stop and ask** rather than introducing one.
- `css/tokens.css` is the single source of design values. `css/site.css` holds
  layout and components and references tokens only.
- **Surfaces flip tokens, components don't know which surface they are on.**
  `body` sets `--dim`, `--accent`, `--hairline`, `--hairline-strong` and
  `--accent-hairline` for the dark base; `.section--paper` redeclares the same
  five. Components reference those, never `--bone-dim` or `--brass` directly.
  Writing a `.section--paper .thing { color: … }` override means you reached
  for the wrong token. This is not cosmetic: `--bone-dim` on `--paper` is
  2.2:1 and fails WCAG AA, which is how the pattern was introduced.
- **Watch selector specificity, particularly section padding.** Class-based and
  element-based selectors have cancelled each other out here before. Section
  padding is set by `.section` only — never add a bare `section { padding }`
  rule.
- No `localStorage`. No third-party analytics or trackers without explicit
  instruction.
- Fonts currently load from Google Fonts. Self-hosting them in `assets/fonts/`
  is a desirable future change.
- **Accessibility floor, non-negotiable:** responsive to 390px with no
  horizontal overflow, visible keyboard focus, semantic landmarks, alt text,
  reduced motion respected.
- Deployment is Vercel from `main`, no build command, output directory root.
  `vercel.json` holds caching and security headers.

### Adding a page

1. Duplicate the header, menu and footer blocks **exactly**.
2. Add the page to `.menu-nav` in every existing page.
3. Add the page to `sitemap.xml`.
4. Copy the `LocalBusiness` JSON-LD block.

`cleanUrls` is enabled, so `case-studies.html` serves at `/case-studies`.
Cross-page links omit the extension; in-page anchors from a subpage point at
`/#anchor`.

## Placeholders

Unknown content is marked with `class="is-placeholder"`, which renders a
visible brass `PLACEHOLDER — REPLACE` tag in the browser. This is intentional:
an unfilled placeholder should be impossible to ship by accident.

**The ledger prices are the highest-priority content gap.** A page headed
"most agencies will not print this" above a row of `£000` actively undermines
the brand — it fails the published-pricing trust behaviour at exactly the
moment it draws attention to it. Fill those three numbers before the site goes
in front of anyone.

Remaining gaps, in priority order: ledger prices; the two proof cards on the
homepage; both case studies in full; the founder biography and photograph;
contact details, address, telephone and opening hours; the service-area
postcodes.

The two case studies name real companies — **Broadland Products** and
**Telemechry**. No detail, figure, quote or outcome for either has been
supplied. **Do not invent any.** Every fact on that page is a placeholder
until the business provides it.

## Git

- Default branch: `main`.
- Commit messages are short, imperative, single-line.
- Do not commit `.vercel/` or OS cruft.
