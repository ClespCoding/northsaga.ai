"""Measure the grader against rows a human already graded in the live sheet.

These are real descriptions and real grades lifted from
"Broadland Products — Planning Leads (Norwich)". If you retune the keyword
tables in grade.py, run this to see whether agreement went up or down.

    python3 -m collectors.tests.test_grade      (from the repo root)
    python3 tests/test_grade.py                 (from collectors/)
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from grade import grade  # noqa: E402

FIXTURE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "fixtures", "graded_rows.csv")

# The relevance call (Yes/Maybe/No) is what decides whether anyone rings the
# lead, so it must be exact. The P0/P1 split within "Yes" is a judgement call
# and is allowed to drift by one band.
MIN_RELEVANCE_AGREEMENT = 1.00
MIN_PRIORITY_AGREEMENT = 0.90


def main():
    with open(FIXTURE, newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))

    # Rows carrying a note are ones where the sheet's own grades contradict
    # each other. They are printed for visibility but cannot be learned from,
    # so they are excluded from the agreement floors.
    scored = [r for r in rows if not r.get("note")]
    noted = [r for r in rows if r.get("note")]

    rel_hits = pri_hits = 0
    failures = []

    for row in scored:
        want_rel = row["relevant_to_gates_rails"]
        want_pri = row["priority"]
        got_rel, got_pri = grade(row["description"], row["app_type"])

        if got_rel == want_rel:
            rel_hits += 1
        else:
            failures.append(
                "relevance: want %-5s got %-5s | %s" % (want_rel, got_rel, row["description"][:70]))

        if got_pri == want_pri:
            pri_hits += 1
        elif got_rel != want_rel:
            pass  # already reported as a relevance failure
        else:
            failures.append(
                "priority:  want %-3s got %-3s | %s" % (want_pri, got_pri, row["description"][:70]))

    for row in noted:
        got_rel, got_pri = grade(row["description"], row["app_type"])
        print("  SKIPPED %s/%s -> %s/%s | %s\n          %s"
              % (row["relevant_to_gates_rails"], row["priority"], got_rel, got_pri,
                 row["description"][:70], row["note"]))

    total = len(scored)
    rel_rate = rel_hits / total
    pri_rate = pri_hits / total

    for line in failures:
        print("  " + line)

    print("\n%d rows: relevance %d/%d (%.0f%%), priority %d/%d (%.0f%%)"
          % (total, rel_hits, total, rel_rate * 100, pri_hits, total, pri_rate * 100))

    ok = True
    if rel_rate < MIN_RELEVANCE_AGREEMENT:
        print("FAIL: relevance agreement %.0f%% below floor %.0f%%"
              % (rel_rate * 100, MIN_RELEVANCE_AGREEMENT * 100))
        ok = False
    if pri_rate < MIN_PRIORITY_AGREEMENT:
        print("FAIL: priority agreement %.0f%% below floor %.0f%%"
              % (pri_rate * 100, MIN_PRIORITY_AGREEMENT * 100))
        ok = False

    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
