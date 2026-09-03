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
