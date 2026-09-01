"""Offline tests for the Idox parsing and date normalisation layers.

HONEST CAVEAT: the HTML below is a reconstruction of Idox Public Access markup,
not a page captured from a live council portal — the build environment for this
repo cannot reach them. So these tests prove the parser's *properties* (it finds
fields by label regardless of order, it tolerates extra rows and missing
tables, it finds detail links anywhere in a results page) rather than proving it
matches Norwich's exact HTML today.

The live check is `python3 collect.py --probe` followed by
`python3 collect.py --days 3 --dry-run --limit 5`.

    python3 tests/test_idox.py
"""

import datetime as dt
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import idox                              # noqa: E402
from collect import parse_date, looks_approved   # noqa: E402

FAILURES = []


def check(label, got, want):
    if got == want:
        print("  ok   %s" % label)
    else:
        print("  FAIL %s\n       got  %r\n       want %r" % (label, got, want))
        FAILURES.append(label)


SUMMARY_TAB = """
<html><body>
<table id="simpleDetailsTable">
  <tr><th>Reference</th><td>26/00321/F</td></tr>
  <tr><th>Application Received</th><td>Mon 03 Mar 2026</td></tr>
  <tr><th>Address</th><td>177 Earlham Road Norwich NR2 3RG</td></tr>
  <tr><th>Proposal</th><td>Rear single storey side return extension,
      loft conversion with dormer to rear main roof.</td></tr>
  <tr><th>Status</th><td>Approved with conditions</td></tr>
</table>
</body></html>
"""

# Deliberately a different row order, with extra rows Norwich may not have.
DETAILS_TAB = """
<html><body>
<table id="applicationDetails">
  <tr><th>Agent Name</th><td>Some Architects Ltd</td></tr>
  <tr><th>Application Type</th><td>Full</td></tr>
  <tr><th>Parish</th><td>Norwich</td></tr>
  <tr><th>Ward</th><td>Nelson</td></tr>
  <tr><th>Applicant Name</th><td>Mr Alastair Howie</td></tr>
  <tr><th>Decision Issued Date</th><td>Wed 03 Jun 2026</td></tr>
</table>
</body></html>
"""

RESULTS_PAGE = """
<html><body>
<ul id="searchresults">
  <li class="searchresult">
    <a href="/online-applications/applicationDetails.do?keyVal=ABC123&amp;activeTab=summary">
      Rear single storey side return extension</a>
    <p class="address">177 Earlham Road Norwich</p>
  </li>
  <li class="searchresult">
    <a href="applicationDetails.do?keyVal=DEF456&amp;activeTab=summary">
      Single storey rear extension</a>
  </li>
</ul>
<a class="next" href="/online-applications/pagedSearchResults.do?page=2">Next</a>
</body></html>
"""


def test_field_extraction():
    print("\nfield extraction (labels, any order)")
    fields = {}
    fields.update(idox.parse_detail_fields(SUMMARY_TAB))
    fields.update(idox.parse_detail_fields(DETAILS_TAB))
    row = idox.extract(fields)

    check("code", row["code"], "26/00321/F")
    check("address", row["address"], "177 Earlham Road Norwich NR2 3RG")
    check("ward", row["ward"], "Nelson")
    check("app_type", row["app_type"], "Full")
    check("contact_name", row["contact_name"], "Mr Alastair Howie")
    check("approval_date raw", row["approval_date"], "Wed 03 Jun 2026")
    check("description",
          row["description"],
          "Rear single storey side return extension, loft conversion with dormer to rear main roof.")


def test_summary_only():
    """A council with no details tab must still yield a usable row."""
    print("\nsummary tab alone (details tab missing)")
    row = idox.extract(idox.parse_detail_fields(SUMMARY_TAB))
    check("code still found", row["code"], "26/00321/F")
    check("ward empty not crashed", row["ward"], "")


def test_result_links():
    print("\nresult-list link discovery")
    links = [h for h, _ in idox.parse_links(RESULTS_PAGE)
             if "applicationDetails.do" in h]
    check("two detail links", len(links), 2)
    check("relative link kept", links[1].startswith("applicationDetails.do"), True)


def test_dates():
    print("\ndate normalisation")
    check("dd/mm/yyyy", parse_date("18/06/2026"), "2026-06-18")
    check("Idox long form", parse_date("Wed 03 Jun 2026"), "2026-06-03")
    check("full month name", parse_date("3 June 2026"), "2026-06-03")
    check("already iso", parse_date("2026-06-18"), "2026-06-18")
    check("empty", parse_date(""), "")
    check("junk", parse_date("Not Available"), "")
    check("impossible date", parse_date("31/02/2026"), "")


def test_decisions():
    print("\ndecision filtering")
    check("granted", looks_approved("Approved with conditions"), True)
    check("blank treated as approved", looks_approved(""), True)
    check("refused", looks_approved("Application Refused"), False)
    check("withdrawn", looks_approved("Withdrawn by applicant"), False)


def test_tab_urls():
    print("\ndetail tab URLs")
    url = "https://x.gov.uk/online-applications/applicationDetails.do?keyVal=ABC&activeTab=summary"
    check("switches tab", "activeTab=details" in idox._with_tab(url, "details"), True)
    check("keeps keyVal", "keyVal=ABC" in idox._with_tab(url, "details"), True)


def main():
    test_field_extraction()
    test_summary_only()
    test_result_links()
    test_dates()
    test_decisions()
    test_tab_urls()

    print("\n%s" % ("FAIL: %d check(s) failed" % len(FAILURES) if FAILURES else "PASS"))
    return 1 if FAILURES else 0


if __name__ == "__main__":
    sys.exit(main())
