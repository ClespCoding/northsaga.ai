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
