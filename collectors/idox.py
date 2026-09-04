"""Client for Idox Public Access planning portals.

All three councils we collect from run Idox, which is the same application with
the same URL shapes and the same HTML on every install. That is why one client
covers Norwich, Broadland and South Norfolk rather than three scrapers.

Standard library only: urllib, http.cookiejar, html.parser.

Two things make this resilient rather than brittle:

  * Detail fields are read by their LABEL, not by position. Idox renders every
    detail tab as a table of <th>Label</th><td>Value</td> pairs; we pull them
    all into a dict and look up "Ward", "Applicant Name" and so on. A council
    reordering its table, or adding a row, changes nothing here.
  * The result-list parser accepts any <a> pointing at applicationDetails.do,
    rather than depending on the surrounding markup.

If a council's markup does defeat this, `probe()` and `--dump-html` are the
tools for finding out quickly. See README.md.
"""

import gzip
import http.cookiejar
import io
import random
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser

USER_AGENT = (
    "Mozilla/5.0 (compatible; NorthsagaPlanningCollector/1.0; "
    "+https://northsaga.ai; contact hello@northsaga.ai)"
)

# Be a good citizen: councils run these portals on small budgets. Jittered so
# three councils are not hit on the same tick every morning.
MIN_DELAY = 1.0
MAX_DELAY = 2.5


class FetchError(RuntimeError):
    pass


# --- HTML helpers ---------------------------------------------------------

class _TableParser(HTMLParser):
    """Collect every <th>label</th><td>value</td> pair on the page."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.pairs = {}
        self._cell = None
        self._buf = []
        self._label = None

    def handle_starttag(self, tag, attrs):
        if tag in ("th", "td"):
            self._cell = tag
            self._buf = []

    def handle_endtag(self, tag):
        if tag not in ("th", "td") or self._cell != tag:
            return
        text = re.sub(r"\s+", " ", "".join(self._buf)).strip()
        if tag == "th":
            self._label = text.rstrip(":")
        elif self._label:
            self.pairs.setdefault(self._label, text)
            self._label = None
        self._cell = None
        self._buf = []

    def handle_data(self, data):
        if self._cell:
            self._buf.append(data)


class _LinkParser(HTMLParser):
    """Collect hrefs and their link text."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []          # [(href, text)]
        self._href = None
        self._buf = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            attrs = dict(attrs)
            if attrs.get("href"):
                self._href = attrs["href"]
                self._buf = []

    def handle_endtag(self, tag):
        if tag == "a" and self._href is not None:
            text = re.sub(r"\s+", " ", "".join(self._buf)).strip()
            self.links.append((self._href, text))
            self._href = None
            self._buf = []

    def handle_data(self, data):
        if self._href is not None:
            self._buf.append(data)


def parse_detail_fields(html):
    """Every label/value pair on an application detail tab, as a dict."""
    p = _TableParser()
    p.feed(html)
    return p.pairs


def parse_links(html):
    p = _LinkParser()
    p.feed(html)
    return p.links


def _first(fields, *labels):
    """First non-empty value among several possible label spellings."""
    for label in labels:
        value = fields.get(label)
        if value:
            return value
    return ""


# --- Client ---------------------------------------------------------------

class IdoxClient:
    def __init__(self, base_url, timeout=45, delay=True, verbose=False):
        self.base = base_url.rstrip("/")
        self.timeout = timeout
        self.delay = delay
        self.verbose = verbose
        jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(jar),
            urllib.request.HTTPRedirectHandler(),
        )
        self.opener.addheaders = [
            ("User-Agent", USER_AGENT),
            ("Accept", "text/html,application/xhtml+xml"),
            ("Accept-Language", "en-GB,en;q=0.9"),
            ("Accept-Encoding", "gzip"),
        ]

    def _sleep(self):
        if self.delay:
            time.sleep(random.uniform(MIN_DELAY, MAX_DELAY))

    def get(self, url, data=None):
        """Fetch a URL (POST if data is given) and return decoded HTML."""
        if url.startswith("/"):
            url = urllib.parse.urljoin(self.base + "/", url.lstrip("/"))
        body = urllib.parse.urlencode(data).encode("utf-8") if data else None
        req = urllib.request.Request(url, data=body)
        if self.verbose:
            print("    %s %s" % ("POST" if body else "GET", url))
        try:
            with self.opener.open(req, timeout=self.timeout) as resp:
                raw = resp.read()
                if resp.headers.get("Content-Encoding") == "gzip":
                    raw = gzip.GzipFile(fileobj=io.BytesIO(raw)).read()
                charset = resp.headers.get_content_charset() or "utf-8"
                return raw.decode(charset, errors="replace")
        except urllib.error.HTTPError as exc:
            raise FetchError("HTTP %s for %s" % (exc.code, url)) from exc
        except (urllib.error.URLError, OSError) as exc:
            raise FetchError("%s for %s" % (exc, url)) from exc
        finally:
            self._sleep()

    def probe(self):
        """Confirm this base URL really is a live Idox Public Access instance.

        Run this first when pointing the collector at a new council. It is the
        cheapest way to find out that a base URL is wrong.
        """
        html = self.get("/search.do?action=advanced")
        markers = ("advancedSearchResults.do", "Public Access", "searchCriteria")
        hits = [m for m in markers if m in html]
        return bool(hits), hits, len(html)

    def search_decided(self, start_date, end_date, max_pages=60):
        """Detail-page URLs for applications DECIDED between two dates.

        Dates are `datetime.date`. Idox wants dd/mm/yyyy.
        """
        # Establish the session and the search form's cookies first; Idox
        # rejects a results POST that arrives without them.
        self.get("/search.do?action=advanced")

        form = {
            "searchCriteria.caseType": "",
            "searchType": "Application",
            "searchCriteria.resultsPerPage": "100",
            "date(applicationDecisionStart)": start_date.strftime("%d/%m/%Y"),
            "date(applicationDecisionEnd)": end_date.strftime("%d/%m/%Y"),
        }
        html = self.get("/advancedSearchResults.do?action=firstPage", data=form)

        seen = set()
        page = 0
        while True:
            page += 1
            for href, _text in parse_links(html):
                if "applicationDetails.do" not in href:
                    continue
                url = urllib.parse.urljoin(self.base + "/", href)
                key = _keyval(url)
                if key and key not in seen:
                    seen.add(key)
                    yield url

            nxt = _next_page_link(html)
            if not nxt or page >= max_pages:
                break
            html = self.get(urllib.parse.urljoin(self.base + "/", nxt))

    def fetch_application(self, detail_url):
        """Merge the summary and details tabs into one field dict."""
        fields = {}
        for tab in ("summary", "details"):
            url = _with_tab(detail_url, tab)
            try:
                fields.update(parse_detail_fields(self.get(url)))
            except FetchError:
                if tab == "summary":
                    raise
                # The details tab is optional on some installs; a missing ward
                # or applicant is better than losing the whole application.
        return fields


def _keyval(url):
    q = urllib.parse.parse_qs(urllib.parse.urlparse(url).query)
    return (q.get("keyVal") or q.get("keyval") or [""])[0]


def _with_tab(url, tab):
    parts = urllib.parse.urlparse(url)
    q = urllib.parse.parse_qs(parts.query)
    q["activeTab"] = [tab]
    return urllib.parse.urlunparse(
        parts._replace(query=urllib.parse.urlencode(q, doseq=True)))


def _next_page_link(html):
    """The 'next page' href on a results page, if there is one."""
    for href, text in parse_links(html):
        label = text.strip().lower().rstrip(" »>").strip()
        if label == "next" and ("searchResults.do" in href or "page=" in href):
            return href
    return None


# --- Field mapping --------------------------------------------------------
#
# Label spellings vary slightly between Idox installs, so each field lists
# every spelling we have seen. Add to these lists rather than changing code.

FIELD_LABELS = {
    "code": ("Reference", "Reference Number", "Application Number", "Case Reference"),
    "approval_date": ("Decision Issued Date", "Decision Date", "Decision Made Date",
                      "Date of Decision", "Decision Issued"),
    "address": ("Address", "Site Address", "Location"),
    "ward": ("Ward", "Ward Name"),
    "app_type": ("Application Type", "Case Type", "Application Type Description"),
    "description": ("Proposal", "Description", "Development Description"),
    "contact_name": ("Applicant Name", "Applicant", "Agent Name"),
    "decision": ("Decision", "Actual Decision", "Status"),
}


def extract(fields):
    """Turn a raw label/value dict into our column names."""
    out = {}
    for column, labels in FIELD_LABELS.items():
        out[column] = _first(fields, *labels)
    return out
