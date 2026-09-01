#!/usr/bin/env python3
"""Collect decided planning applications and append them to the leads sheet.

    python3 collect.py --probe                  confirm council URLs are right
    python3 collect.py --check-auth             confirm the sheet is writable
    python3 collect.py --days 7 --dry-run       collect, print, write nothing
    python3 collect.py --days 1                 the daily run
    python3 collect.py --since 2026-06-19 --until 2026-09-01    backfill

No model calls anywhere in this path. Grading is deterministic keyword matching
(see grade.py), so a daily run costs nothing but bandwidth.

Exit codes:  0 success (including "nothing new")
             1 partial — at least one council failed, others written
             2 fatal — nothing could be collected or written
"""

import argparse
import datetime as dt
import json
import os
import re
import sys
import traceback

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import councils as councils_mod      # noqa: E402
import grade as grade_mod            # noqa: E402
import idox                          # noqa: E402
from sheets import Sheets, SheetsError  # noqa: E402

# The live Broadland Products leads sheet.
DEFAULT_SPREADSHEET_ID = "1WovO-GYIxdAZV0kILT4sGd22GXTYCTDPt7wfOcNikeU"
DEFAULT_TAB = "Sheet1"
DEFAULT_AUDIT_SPREADSHEET_ID = "122bst4JwVasWgKuTz8cbShIHnLSBfQPbNrWMLwLT9cw"
DEFAULT_AUDIT_TAB = "Sheet1"

# Column order. The first 13 match the sheet exactly as it stands today;
# `council` is appended because we now collect from three of them.
COLUMNS = [
    "code", "approval_date", "address", "ward", "app_type", "description",
    "contact_name", "contact_email", "contact_phone",
    "relevant_to_gates_rails", "priority", "internal_status", "last_updated",
    "council",
]

MONTHS = {m.lower(): i for i, m in enumerate(
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], start=1)}


def parse_date(text):
    """Idox date strings -> YYYY-MM-DD. Returns '' if unrecognised."""
    if not text:
        return ""
    text = text.strip()

    m = re.search(r"\b(\d{1,2})/(\d{1,2})/(\d{4})\b", text)
    if m:
        d, mo, y = (int(g) for g in m.groups())
        return _iso(y, mo, d)

    m = re.search(r"\b(\d{4})-(\d{2})-(\d{2})\b", text)
    if m:
        return m.group(0)

    m = re.search(r"\b(\d{1,2})\s+([A-Za-z]{3,})\s+(\d{4})\b", text)
    if m:
        d, name, y = m.group(1), m.group(2)[:3].lower(), m.group(3)
        if name in MONTHS:
            return _iso(int(y), MONTHS[name], int(d))
    return ""


def _iso(year, month, day):
    try:
        return dt.date(year, month, day).isoformat()
    except ValueError:
        return ""


def looks_approved(decision):
    """True if the decision text reads as a grant rather than a refusal."""
    d = (decision or "").lower()
    if not d:
        return True          # some installs leave it blank on the summary tab
    refused = ("refus", "withdraw", "dismiss", "invalid", "returned", "split decision")
    return not any(r in d for r in refused)


def collect_council(slug, start, end, verbose=False, limit=None):
    """Fetch and normalise one council's decided applications."""
    base = councils_mod.base_url(slug)
    client = idox.IdoxClient(base, verbose=verbose)
    name = councils_mod.display_name(slug)
    rows, skipped = [], 0

    urls = client.search_decided(start, end)
    for n, url in enumerate(urls, start=1):
        if limit and n > limit:
            break
        try:
            fields = client.fetch_application(url)
        except idox.FetchError as exc:
            print("    ! %s" % exc, file=sys.stderr)
            skipped += 1
            continue

        raw = idox.extract(fields)
        if not raw["code"]:
            skipped += 1
            continue
        if not looks_approved(raw.get("decision")):
            continue

        approval = parse_date(raw["approval_date"])
        relevance, priority = grade_mod.grade(raw["description"], raw["app_type"])

        rows.append({
            "code": raw["code"],
            "approval_date": approval,
            "address": raw["address"],
            "ward": raw["ward"],
            "app_type": raw["app_type"],
            "description": raw["description"],
            "contact_name": raw["contact_name"],
            "contact_email": "",
            "contact_phone": "",
            "relevant_to_gates_rails": relevance,
            "priority": priority,
            "internal_status": "New",
            "last_updated": dt.date.today().isoformat(),
            "council": name,
        })

    return rows, skipped


def cmd_probe(args):
    """Try every candidate URL for each council and report which work."""
    any_ok = False
    for slug in args.councils:
        print("\n%s (%s)" % (councils_mod.display_name(slug), slug))
        for candidate in councils_mod.COUNCILS[slug]["candidates"]:
            client = idox.IdoxClient(candidate, delay=False, verbose=args.verbose)
            try:
                ok, markers, size = client.probe()
            except idox.FetchError as exc:
                print("  [unreachable] %s\n      %s" % (candidate, exc))
                continue
            if ok:
                any_ok = True
                print("  [OK]          %s\n      %d bytes, markers: %s"
                      % (candidate, size, ", ".join(markers)))
            else:
                print("  [not idox]    %s\n      reachable, %d bytes, no Idox markers"
                      % (candidate, size))
    print("\nPut the [OK] URL first in that council's `candidates` list in councils.py.")
    return 0 if any_ok else 2


def cmd_check_auth(args):
    try:
        api = Sheets(args.credentials)
        print("service account: %s" % api.client_email)
        title, tabs = api.check_auth(args.spreadsheet_id)
        print("leads sheet:     %s" % title)
        print("tabs:            %s" % ", ".join(tabs))
        header = api.read_header(args.spreadsheet_id, args.tab)
        print("header (%d cols): %s" % (len(header), ", ".join(header)))
        missing = [c for c in COLUMNS if c not in header]
        if missing:
            print("\nNOTE: the sheet is missing these columns: %s" % ", ".join(missing))
            print("Add them to row 1 before the first real run, or rows will misalign.")
        if args.audit_spreadsheet_id:
            atitle, _ = api.check_auth(args.audit_spreadsheet_id)
            print("audit sheet:     %s" % atitle)
        return 0
    except (SheetsError, OSError) as exc:
        print("FAILED: %s" % exc, file=sys.stderr)
        return 2


def build_row(record, header):
    """Order a record to match the sheet's actual header row."""
    return [record.get(col, "") for col in header]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--councils", nargs="+", default=list(councils_mod.DEFAULT_COUNCILS),
                    choices=sorted(councils_mod.COUNCILS), metavar="SLUG",
                    help="councils to collect (default: all three)")
    ap.add_argument("--days", type=int, default=7,
                    help="collect decisions from the last N days (default 7)")
    ap.add_argument("--since", help="start date YYYY-MM-DD (overrides --days)")
    ap.add_argument("--until", help="end date YYYY-MM-DD (default today)")
    ap.add_argument("--spreadsheet-id", default=DEFAULT_SPREADSHEET_ID)
    ap.add_argument("--tab", default=DEFAULT_TAB)
    ap.add_argument("--audit-spreadsheet-id", default=DEFAULT_AUDIT_SPREADSHEET_ID)
    ap.add_argument("--audit-tab", default=DEFAULT_AUDIT_TAB)
    ap.add_argument("--credentials",
                    default=os.environ.get("GOOGLE_APPLICATION_CREDENTIALS",
                                           "/etc/northsaga/service-account.json"))
    ap.add_argument("--limit", type=int, help="stop after N applications per council")
    ap.add_argument("--dry-run", action="store_true",
                    help="collect and print, write nothing")
    ap.add_argument("--probe", action="store_true",
                    help="test council base URLs and exit")
    ap.add_argument("--check-auth", action="store_true",
                    help="test sheet credentials and exit")
    ap.add_argument("--json", help="also write collected rows to this file")
    ap.add_argument("--verbose", "-v", action="store_true")
    args = ap.parse_args(argv)

    if args.probe:
        return cmd_probe(args)
    if args.check_auth:
        return cmd_check_auth(args)

    end = dt.date.fromisoformat(args.until) if args.until else dt.date.today()
    start = (dt.date.fromisoformat(args.since) if args.since
             else end - dt.timedelta(days=args.days))
    started = dt.datetime.now()
    print("Collecting decisions %s .. %s from: %s"
          % (start, end, ", ".join(args.councils)))

    # Connect to the sheet up front — better to fail before scraping than after.
    api = header = existing = None
    if not args.dry_run:
        try:
            api = Sheets(args.credentials)
            header = api.read_header(args.spreadsheet_id, args.tab) or COLUMNS
            existing = set(api.read_column(args.spreadsheet_id, args.tab, "A"))
            print("Sheet has %d existing rows." % max(len(existing) - 1, 0))
        except (SheetsError, OSError) as exc:
            print("FATAL: cannot open the sheet: %s" % exc, file=sys.stderr)
            return 2

    all_rows, failures, total_skipped = [], [], 0
    for slug in args.councils:
        print("\n%s" % councils_mod.display_name(slug))
        try:
            rows, skipped = collect_council(slug, start, end,
                                            verbose=args.verbose, limit=args.limit)
        except idox.FetchError as exc:
            print("  FAILED: %s" % exc, file=sys.stderr)
            failures.append(slug)
            continue
        except Exception:                      # noqa: BLE001 - one council must
            traceback.print_exc()              # not take down the other two
            failures.append(slug)
            continue

        total_skipped += skipped
        print("  %d decided, %d unreadable" % (len(rows), skipped))
        all_rows.extend(rows)

    # Deduplicate: within this run, and against what the sheet already holds.
    fresh, seen = [], set()
    for row in all_rows:
        key = row["code"]
        if key in seen or (existing and key in existing):
            continue
        seen.add(key)
        fresh.append(row)

    by_priority = {}
    for row in fresh:
        by_priority[row["priority"]] = by_priority.get(row["priority"], 0) + 1
    summary = ", ".join("%s:%d" % (p, by_priority[p]) for p in sorted(by_priority))
    print("\n%d collected, %d new after dedup%s"
          % (len(all_rows), len(fresh), (" (%s)" % summary) if summary else ""))

    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(fresh, fh, indent=2, ensure_ascii=False)
        print("Wrote %s" % args.json)

    if args.dry_run:
        for row in fresh[:20]:
            print("  %-16s %-11s %-4s %s"
                  % (row["code"], row["approval_date"], row["priority"],
                     row["description"][:60]))
        if len(fresh) > 20:
            print("  ... and %d more" % (len(fresh) - 20))
        print("\nDry run: nothing written.")
        return 1 if failures else 0

    written = 0
    if fresh:
        try:
            written = api.append_rows(args.spreadsheet_id, args.tab,
                                      [build_row(r, header) for r in fresh])
            print("Appended %d rows." % written)
        except SheetsError as exc:
            print("FATAL: append failed: %s" % exc, file=sys.stderr)
            return 2
    else:
        print("Nothing new to append.")

    _write_audit(api, args, started, all_rows, fresh, written, failures, total_skipped)
    return 1 if failures else 0


def _write_audit(api, args, started, all_rows, fresh, written, failures, skipped):
    """One row per run, so a silent failure is visible the next morning."""
    if not args.audit_spreadsheet_id:
        return
    elapsed = (dt.datetime.now() - started).total_seconds()
    if failures:
        status = "PARTIAL"
    elif fresh and not written:
        status = "ERROR"          # had rows to write and wrote none
    else:
        status = "OK"
    row = [[
        started.strftime("%Y-%m-%d %H:%M:%S"),
        status,
        ", ".join(args.councils),
        len(all_rows), len(fresh), written, skipped,
        ", ".join(failures) or "-",
        "%.1fs" % elapsed,
    ]]
    try:
        api.append_rows(args.audit_spreadsheet_id, args.audit_tab, row)
    except SheetsError as exc:
        # Never let audit logging fail the run that actually did the work.
        print("WARNING: could not write audit row: %s" % exc, file=sys.stderr)


if __name__ == "__main__":
    sys.exit(main())
