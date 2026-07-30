# CLAUDE.md

Guidance for Claude Code and other AI assistants working in this repository.

## Project

**North Saga** (`northsaga.ai`) — "Where History Meets Technology." A Next.js
content site about North Sea / Hanseatic League maritime trade networks,
presented through a hand-built "Renaissance manuscript" visual theme
(parchment background, drop caps, marginalia, folio numbers).

It is a small, early-stage static content site: a themed homepage plus a
markdown-backed blog. There is no backend, no database, no API routes, no
auth, and no test suite.

## Commands

```bash
npm install       # install dependencies (node_modules is gitignored)
npm run dev       # dev server on http://localhost:3000
npm run build     # production build + static prerender (see caveat below)
npm run start     # serve the production build
npm run lint      # DO NOT RUN — see below
```

**`npm run lint` is not usable.** There is no `.eslintrc*` in the repo, so
`next lint` drops into an interactive "How would you like to configure
ESLint?" prompt and hangs a non-interactive shell. `eslint` and
`eslint-config-next` are in `devDependencies` but were never configured.
Either skip linting or add an ESLint config first.

**`npm run build` currently fails.** See [Known issues](#known-issues). Use it
as the verification step anyway — it is the only real check in the repo — but
expect the pre-existing failures described below, and don't assume you caused
them.

## Layout

```
pages/                 Next.js Pages Router (not App Router)
  _app.js              Only imports styles/globals.css
  index.js             Homepage — the Renaissance-themed page
  blog/index.js        Blog listing
  blog/[id].js         Blog post, SSG via getStaticPaths/getStaticProps
  chronicles.js        Tag-filtered listing (currently renders empty)
  index.js.backup      Dead file — old homepage, not a route
lib/
  blog.js              Markdown loading: frontmatter + remark → HTML
  utils.ts             shadcn `cn()` helper (clsx + tailwind-merge)
content/blog/*.md      Blog posts; filename (minus .md) is the URL slug
components/ui/         shadcn/ui primitives — currently unused by any page
styles/globals.css     The real stylesheet: fonts, CSS vars, design system
tailwind.config.js     Renaissance palette + fonts + shadcn token wiring
css                    Dead file — extensionless, superseded by globals.css
#                      Dead file — empty, created by a stray shell redirect
```

Routes that actually exist: `/`, `/blog`, `/blog/[id]`, `/chronicles`.

## Stack

- **Next.js 14, Pages Router.** Do not add `app/` directory files; the project
  is entirely Pages Router and `_app.js` is the only shell.
- **React 18**, no server components (`components.json` sets `"rsc": false`).
- **Tailwind CSS 3** with `tailwindcss-animate`.
- **TypeScript is configured but barely used.** `tsconfig.json` has
  `strict: true` and `allowJs: true`. Every page and `lib/blog.js` is plain
  JavaScript; only `lib/utils.ts` and `components/ui/*.tsx` are TypeScript.
  Follow the local convention: new pages in `.js`, new UI components in `.tsx`.
- **Path alias:** `@/*` → repo root. So `@/lib/utils`, `@/components/ui/button`.
  Note that the existing pages use relative imports (`../../lib/blog`) instead;
  both work.

## Content pipeline

`lib/blog.js` is the whole CMS. It reads `content/blog/*.md` at build time:

- `getSortedPostsData()` — frontmatter only, sorted by `date` descending.
- `getAllPostIds()` — slugs for `getStaticPaths`.
- `getPostData(id)` — frontmatter plus `contentHtml` rendered by
  `remark` + `remark-html`, injected with `dangerouslySetInnerHTML`.

Frontmatter fields the pages consume:

```yaml
---
title: 'Post Title'
date: '2024-07-07'          # string; sorted lexicographically, so keep YYYY-MM-DD
excerpt: 'One-line summary shown on listing pages.'
tags: ['history', 'technology']
readTime: 5                 # integer minutes
author: 'North Saga Team'
---
```

**Frontmatter gotchas:**

- The values are single-quoted YAML. A literal apostrophe must be escaped by
  **doubling it** (`today''s`), not with a backslash (`today\'s`). A backslash
  breaks the whole document — this is the cause of the current build failure.
- `date` is compared as a string, never parsed. Non-`YYYY-MM-DD` dates will
  sort wrong. (`date-fns` is a dependency but nothing imports it.)
- Adding a `.md` file to `content/blog/` is all that's needed to publish a
  post; the route is generated automatically. Filename is the slug.
- There is no draft/unpublished mechanism. Every file in the directory ships.

## Design system

The homepage (`pages/index.js`) is the reference implementation of the site's
intended look. The design system lives in `styles/globals.css` under
`@layer components`, built from Tailwind `@apply`.

Custom colors (`tailwind.config.js`): `parchment` / `parchment-dark`,
`ink-black` / `ink-brown`, `burgundy`, `merchant-gold` / `merchant-gold-light`,
`sea-blue`.

Fonts, self-hosted via `@fontsource` imports at the top of `globals.css`:
`font-garamond` (EB Garamond, body) and `font-display` (Cinzel, headings).
Also `leading-golden` (1.618) and `text-drop-cap` (4.5rem).

Component classes: `.drop-cap`, `.marginalia`, `.folio`, `.section-divider`,
`.ornament`, `.renaissance-card`, `.renaissance-button`, `.blog-post`,
`.post-meta`, `.read-more`, plus bare `nav ul` styling.

**Style the way the homepage does.** Use these classes and the named palette
rather than ad-hoc utilities. The blog pages do not currently follow this —
they use generic `bg-gradient-to-br from-amber-50 to-orange-50` / white cards
that predate the theme. Treat that as debt, not as a pattern to copy; if you
touch a blog page, moving it onto the Renaissance system is welcome.

Editorial voice on rendered pages leans archaic on purpose ("Anno Domini
MMXXV", "Finis coronat opus", ❦ ornaments). Keep it when writing UI copy.

## Known issues

These are pre-existing. Fix them if the task calls for it; otherwise don't be
surprised by them.

1. **Build fails on `content/blog/technology-behind-history.md`.** Its
   `excerpt` uses `today\'s` — an invalid backslash escape inside a
   single-quoted YAML scalar. `gray-matter` throws
   `YAMLException: can not read a block mapping entry`, which fails
   prerendering for `/blog`, `/blog/technology-behind-history`, and
   `/chronicles`. Fix: `today''s`. Note that `lib/blog.js` has no error
   handling, so one malformed post takes down every page that lists posts.

2. **Dead nav links on the homepage.** `pages/index.js` links to
   `/tech-codex` and `/about`; neither page exists. Both 404.

3. **`/chronicles` always renders empty.** It filters posts for the tag
   `chronicle`, and no post carries that tag. It is also a near-duplicate of
   `pages/blog/index.js`.

4. **Homepage post list is hardcoded.** The "Latest Chronicles" section in
   `pages/index.js` hardcodes two posts in JSX with hand-written dates rather
   than calling `getSortedPostsData()`. New posts will not appear there.

5. **shadcn CSS variables are in the wrong color space.** `globals.css`
   defines them as space-separated *RGB* (`--background: 250 248 243`) while
   `tailwind.config.js` consumes them as `hsl(var(--background))`. The values
   are out of range for HSL and clamp to white. Any shadcn component using
   `bg-background`, `bg-card`, `text-primary`, etc. will render with wrong
   colors. Either convert the variables to HSL triples or change the config to
   `rgb(...)`.

6. **`components/ui/*` is unused.** accordion, badge, button, card, separator
   and tabs are installed but imported by nothing. They will not look right
   until issue 5 is resolved.

7. **Cruft to leave alone unless asked:** `pages/index.js.backup`, the
   extensionless `css` file, and the empty `#` file.

## Conventions

- Pages Router idioms only — `getStaticProps` / `getStaticPaths`, no
  `getServerSideProps` anywhere so far, and everything is statically generated.
- `next/link` for internal navigation, `next/head` for page metadata.
  Only `pages/index.js` currently sets `<Head>`; adding it to other pages is
  an improvement.
- Tailwind utilities inline in JSX; shared patterns promoted to
  `@layer components` in `globals.css`.
- No test framework, no CI, no formatter config. Match surrounding style by eye.

## Git

- Default branch: `main`.
- Commit messages in this repo are short, imperative, single-line
  (e.g. "Add blog pages", "Fix 'Read the Chronicles' button to go to /blog").
  Match that.
- Do not commit `node_modules/`, `.next/`, or `.vercel` — all gitignored.
