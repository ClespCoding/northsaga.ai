# Prompt for Hermes — get the planning collector running

Hand this whole file to Hermes on the machine that can reach the council
portals. It assumes shell access and the ability to edit files.

---

You are getting a planning-application collector working on this machine. It is
already written and unit-tested; it has never made a live run, because it was
written in an environment with no access to the council websites. Your job is to
make the first live run work and get rows into a Google Sheet.

## Ground rules

- **Do not invent data.** Never write a row to the sheet that did not come from
  a council portal. If collection fails, report the failure — an empty sheet is
  correct, a fabricated one is not.
- **Do not rewrite the collector.** Fix what is broken, minimally. If the design
  seems wrong, say so in your report rather than redesigning it.
- **No LLM calls in the collection path.** Grading is deterministic keyword
  matching by design, so the daily job costs nothing to run. Do not "improve"
  this by adding a model call.
- Work through the steps in order. Each one tells you what "working" looks like.
  Stop and report if a step fails in a way the notes do not cover.

## Step 0 — get the code

```sh
git clone https://github.com/ClespCoding/northsaga.ai.git
cd northsaga.ai
git checkout claude/northsaga-planning-apps-ggktg8
cd collectors
```

Requirements: `python3` (3.8+) and the `openssl` binary. Nothing else — no pip
install, no virtualenv.

Confirm the offline tests still pass before changing anything:

```sh
./tests/run-all.sh          # expect: "all offline tests passed"
```

If they fail here, something is wrong with the checkout, not with your machine.
Report and stop.

## Step 1 — find the real council URLs

The base URLs in `councils.py` are **unverified guesses**. Norwich is probably
right; Broadland and South Norfolk run a joint planning service and the correct
host is unknown.

```sh
python3 collect.py --probe
```

Each candidate prints `[OK]`, `[not idox]`, or `[unreachable]`.

- For each council, edit `councils.py` and move the `[OK]` URL to the **front**
  of that council's `candidates` list.
- If a council has no `[OK]` URL, find its Idox Public Access portal yourself.
  Search for the council name plus "planning application search". You are
  looking for a URL ending in `/online-applications`. Add it as a candidate and
  re-run `--probe` until it reports `[OK]`.
- Broadland and South Norfolk may legitimately share one URL. That is fine —
  put the same URL in both lists.

Do not continue until all three report `[OK]`.

## Step 2 — credentials

The collector writes as a Google service account. The existing one is:

```
887461347076-compute@developer.gserviceaccount.com
```

It is already an Editor on both spreadsheets. You need its JSON key file on this
machine. Ask George for it if it is not already here — **do not create a new
service account**, and do not paste the key contents into any report, log,
commit or message.

```sh
mkdir -p ~/.northsaga && chmod 700 ~/.northsaga
# put the key at ~/.northsaga/service-account.json
chmod 600 ~/.northsaga/service-account.json
export GOOGLE_APPLICATION_CREDENTIALS=~/.northsaga/service-account.json

python3 collect.py --check-auth
```

Expected: the service account email, the sheet title
"Broadland Products — Planning Leads (Norwich)", its tab names, and the header
row.

**It will probably warn that the `council` column is missing.** That is
expected. Add `council` as a new column in row 1 of the leads sheet, to the
right of `last_updated`, then re-run `--check-auth` until the warning is gone.
Existing rows leave it blank; do not backfill them.

## Step 3 — a dry run

```sh
python3 collect.py --days 3 --dry-run --limit 5 --verbose
```

This collects and prints, and writes nothing. Judge the output:

- **Rows printed with sensible codes, dates, addresses and priorities** — good,
  go to step 4.
- **"0 collected" with no errors** — the search ran but the results parsing
  found nothing. Re-run with `--verbose`, take one of the URLs it fetched, open
  it in a browser, and compare the real HTML against what `idox.py` expects.
  The likely fixes, in order of probability:
  1. The result list uses a different link pattern — see `search_decided()`.
  2. The date field is named something not in `FIELD_LABELS["approval_date"]`.
     Add the real label to that tuple; do not change the code around it.
  3. The advanced-search form fields differ — see the `form` dict in
     `search_decided()`.
- **Rows with empty `ward` or `contact_name`** — that council labels those
  fields differently. Add the real labels to `FIELD_LABELS` in `idox.py`.
- **HTTP errors or timeouts** — the portal may block unfamiliar user agents or
  rate-limit. Do not remove the delays in `idox.py`; they are deliberate.

Fields are looked up by **label**, not position, so most fixes are one string
added to a tuple in `FIELD_LABELS`. Prefer that over restructuring the parser.

## Step 4 — the first real run

```sh
python3 collect.py --days 7
```

Then open the sheet and confirm the rows are actually there, in the right
columns, with the `council` column populated. Also check the audit log
spreadsheet ("Planning Applications - Audit Log") has gained one row for this
run.

## Step 5 — backfill the gap

The sheet has collected nothing since **18 June 2026**. Once step 4 is
confirmed good, fill the gap:

```sh
python3 collect.py --since 2026-06-19 --until "$(date +%Y-%m-%d)"
```

This will take a while and may be several hundred rows across three councils.
Rows are de-duplicated on application code, so it is safe to re-run if it is
interrupted.

## Step 6 — schedule it

Three jobs, one per council, staggered five minutes apart.

**macOS:**

```sh
CREDENTIALS=~/.northsaga/service-account.json ./launchd/install.sh
launchctl list | grep northsaga
```

That installs 05:55 Norwich, 06:00 Broadland, 06:05 South Norfolk. Note a
LaunchAgent needs the user logged in, and a sleeping Mac runs the job on wake.

**Linux:**

```sh
crontab collectors/crontab.example      # edit the paths in it first
```

Verify without waiting for the morning:

```sh
launchctl kickstart -p gui/$(id -u)/ai.northsaga.planning.norwich   # macOS
COUNCILS=norwich ./run-daily.sh                                      # anywhere
```

## Step 7 — commit and report

Commit any fixes to the branch `claude/northsaga-planning-apps-ggktg8` and push;
this updates pull request #1. Short, imperative, single-line commit messages.
**Never commit the service-account key or anything in `logs/`.**

Report back with:

1. The working base URL for each council.
2. Every change you made to `idox.py` or `councils.py`, and why.
3. Row counts: collected, new after dedup, written — for the daily run and the
   backfill separately.
4. Whether the audit log is being written.
5. Confirmation the three scheduled jobs are registered.
6. Anything you could not make work.

If the grading looks wrong on real rows, do not retune it silently. The keyword
tables are in `grade.py` and `tests/test_grade.py` measures them against 43
rows already graded in the sheet. Change a keyword, re-run that test, and report
whether agreement went up or down.
