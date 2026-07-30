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
├── css/
│   ├── tokens.css          ← Every colour, size and space value. Change things HERE.
│   └── site.css            Layout and components
│
├── js/
│   └── site.js             Menu, header state, scroll reveal. ~70 lines.
│
└── assets/
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

- [ ] **Ledger prices** (`#ledger`) — the `£000` figures. This section is the reason the
      site works; real numbers or cut the section entirely. A fake range is worse than none.
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
