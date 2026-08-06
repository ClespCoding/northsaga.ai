"""Northsaga — shared page chrome for the generators.

CLAUDE.md requires the header, menu and footer blocks to be duplicated exactly
on every page. Rather than duplicate them again in each generator, both
build-work-pages.py and build-journal.py import them from here, so there is one
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

# LocalBusiness, byte-identical to index.html and case-studies.html. The
# postcodes are UNVERIFIED — see CLAUDE.md. They appear here, in the contact
# section and in the footer, and must be corrected in all three together.
JSONLD = """<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "@id": "https://northsaga.ai/#business",
  "name": "Northsaga",
  "url": "https://northsaga.ai/",
  "email": "hello@northsaga.ai",
  "description": "Installs and maintains AI agents for owner-managed small businesses and trades in Dulwich and West Norwood, south London.",
  "slogan": "New tools. Old standards.",
  "areaServed": [
    { "@type": "Place", "name": "Dulwich, London" },
    { "@type": "Place", "name": "West Norwood, London" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE21", "postalCodeEnd": "SE21" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE22", "postalCodeEnd": "SE22" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE24", "postalCodeEnd": "SE24" },
    { "@type": "PostalCodeRangeSpecification", "postalCodeBegin": "SE27", "postalCodeEnd": "SE27" }
  ]
}
</script>"""


def head(title, description, url, og_title, og_description, og_type="article"):
    """The <head> block. Identical to the hand-written pages apart from the
    extra css/work.css link, which only the generated pages need."""
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

<!-- LocalBusiness. address, telephone and openingHours are deliberately absent
     rather than invented — add them once confirmed. The postcodes in
     areaServed are UNVERIFIED; check them against the real service area and
     correct here, in the contact section and in the footer together. -->
{JSONLD}
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


def footer():
    links = "\n".join(
        f'        <a href="{href}">{label}</a>' for label, href, _ in FOOTER_NAV
    )
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

<script src="/js/site.js" defer></script>
</body>
</html>
"""


BANNER = ("<!-- GENERATED FILE — do not hand-edit. Source: {source}\n"
          "     Edit there, then run: cd tools && python3 {script} -->\n")
