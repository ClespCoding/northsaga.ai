# Planning application collector

Collects decided planning applications from three Norfolk councils every
morning, grades each one for gates/railings relevance, and appends the new ones
to the Broadland Products leads sheet.

**No model calls anywhere in this path.** Grading is deterministic keyword
matching in `grade.py`. A daily run costs bandwidth and nothing else.

---

## Status — read this first

The collection logic, grading, sheet writing and cron wiring are written and
tested offline. **The live run has not been executed**, because the environment
this was written in blocks the council portals at the network layer (403 on
CONNECT). Two things therefore need confirming on a machine that can reach
them, in this order:

1. **The council base URLs are unverified guesses.** `councils.py` lists
   several candidates per council. Run `--probe` to find the right one.
2. **The Idox HTML parsing has never seen a real page.** It reads fields by
   label rather than by position, which is the tolerant approach, but a first
   live run may still need one round of correction.

Everything else — JWT signing, date normalisation, grading, dedup, exit codes,
locking — is covered by the offline tests and passing.

## Getting it running

```sh
cd collectors

# 1. Which base URLs actually work?  Put the [OK] one first in councils.py.
python3 collect.py --probe

# 2. Can we authenticate and see the sheet?
export GOOGLE_APPLICATION_CREDENTIALS=/etc/northsaga/service-account.json
python3 collect.py --check-auth

# 3. Collect a few, print them, write nothing.
python3 collect.py --days 3 --dry-run --limit 5 --verbose

# 4. For real.
python3 collect.py --days 7
```

If step 3 returns rows that look right, step 4 is safe. If it returns zero rows
with no errors, the search worked but the result parsing did not — use
`--verbose` to see the URLs being fetched and open one in a browser.

## Scheduling

`crontab.example` installs two jobs: a daily collection at 06:12 and a wider
30-day sweep on Sunday mornings to catch back-dated decisions.

```sh
sudo cp -r . /opt/northsaga/collectors
crontab crontab.example
```

The daily job looks back **7 days, not 1**. Because rows are de-duplicated on
application code, re-collecting an overlapping window costs nothing and means a
morning that fails for any reason repairs itself the next day without anyone
noticing. This is the main defence against the failure mode that left the sheet
stale from June to September.

`run-daily.sh` takes a lock so a slow run never overlaps the next, writes a log
per day, and stays silent on success — cron only mails you when something
broke.

## Credentials

A Google service-account JSON key, readable only by the user cron runs as:

```sh
sudo install -d -m 700 /etc/northsaga
sudo install -m 600 service-account.json /etc/northsaga/service-account.json
```

The service account must be an Editor on both spreadsheets. For
`887461347076-compute@developer.gserviceaccount.com` that is already true of
the leads sheet and the audit log.

Signing uses the `openssl` binary because Python's standard library cannot do
RSA. That keeps the container a plain `python:3-slim` with nothing to
`pip install` and nothing extra to keep patched.

## The sheet

Rows are appended in the sheet's existing column order, read from row 1 at run
time — so if you reorder columns, the collector follows.

The 13 existing columns are unchanged. One column is **added**: `council`,
because we now collect from three. Add it to row 1 before the first real run:

| existing columns 1–13 | 14 |
| --- | --- |
| `code` … `last_updated` | `council` |

`--check-auth` tells you if it is missing. Existing rows simply leave it blank.

Every run appends one row to the audit log: timestamp, status, councils, counts
collected/new/written/unreadable, failures, elapsed. If the collector ever goes
quiet again, that log is where you look first.

## Tuning the grading

All of it is in `grade.py`, in keyword tables at the top of the file. Nothing
else needs editing.

`tests/test_grade.py` measures the rules against 44 rows lifted from the live
sheet with their existing grades. It currently agrees on **43 of 43** learnable
rows. The 44th is excluded and printed as a known disagreement: the sheet
grades "Two storey side extension & remodelling" as Maybe/P2 while grading the
near-identical "2-storey side extension to dwelling" as Yes/P1. That is an
inconsistency in the source data, not a rule to learn — worth settling with
whoever graded them.

Change a keyword, run the test, and you see immediately whether agreement went
up or down.

## Tests

```sh
./tests/run-all.sh
```

Offline, no credentials, no network:

- `test_grade.py` — grading against real graded rows from the sheet.
- `test_idox.py` — field extraction by label, tolerance of missing tabs and
  reordered rows, link discovery, date normalisation, decision filtering.
  The HTML is a reconstruction of Idox markup, not a captured page, so it
  proves the parser's properties rather than a match against Norwich today.
- `test_sheets.py` — generates a throwaway RSA key, builds the JWT exactly as
  the client does, and verifies the signature with openssl. Covers the whole
  auth path except Google accepting the token.

## Files

| File | Purpose |
| --- | --- |
| `collect.py` | Entry point, CLI, dedup, sheet writing, audit log |
| `idox.py` | Idox Public Access client and HTML parsing |
| `grade.py` | Relevance and priority scoring — the tunable part |
| `councils.py` | The three councils and their candidate base URLs |
| `sheets.py` | Google Sheets v4 via service-account JWT |
| `run-daily.sh` | Cron wrapper: locking, logging, exit codes |
| `crontab.example` | The schedule |
