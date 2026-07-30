# northsaga.ai

Static marketing site. Hand-written HTML, CSS and vanilla JS.

**No framework, no build step, no dependencies, no npm.** There is deliberately
no `package.json`. If something appears to need a build step, stop and ask.

## Run it

Any static server from the repo root:

```bash
python3 -m http.server 8000
```

Then open <http://localhost:8000>. Note that `cleanUrls` is a Vercel
behaviour, so locally `/case-studies` needs the `.html` — on the deployed site
it does not.

## Layout

```
index.html          Homepage
case-studies.html   Serves at /case-studies (cleanUrls)
css/tokens.css      Single source of design values — all colour lives here
css/site.css        Layout and components; references tokens only
js/site.js          Menu overlay, mark draw-on-load, scroll reveals
assets/logo/        The mark — PLACEHOLDER geometry, see CLAUDE.md
vercel.json         cleanUrls, caching and security headers
sitemap.xml         Update when adding a page
```

## Deploy

Vercel from `main`. No build command. Output directory is the repo root.

## Before anything else

Read [CLAUDE.md](CLAUDE.md). It carries the brand rules, the voice rules and
the list of unfilled content gaps — starting with the ledger prices, which are
the highest-priority gap on the site.
