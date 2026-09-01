"""Relevance and priority scoring for planning applications.

Deterministic keyword matching. No model calls, no network, no cost per run —
this is the whole point: the collector runs every morning for free.

The rules below were reverse-engineered from the grades already sitting in the
Broadland Products sheet (187 rows, graded to 2026-06-18). They are an
inference, not a specification. `tests/test_grade.py` measures them against
those real rows, so if you retune the keywords you will see immediately whether
agreement went up or down.

Everything tunable lives in this file, at the top. Nothing else needs editing
to change how leads are graded.
"""

import re

# --- Tunables -------------------------------------------------------------
#
# Order matters. The first band that matches wins, except that EXCLUDED
# application types short-circuit everything.

# Application types that are never a gates/railings opportunity, whatever the
# description says. Matched against app_type, case-insensitively, as substrings.
EXCLUDED_APP_TYPES = (
    "works to trees",
    "tpo",
    "discharge of conditions",
    "advertisement consent",
    "non material amendment",
    "material amendment",
    "variation of condition",
    "reg.77",
    "habitats",
)

# Application types that cap the score at P1 even when a strong keyword hits —
# retrospective or paper exercises rather than live jobs.
CAPPED_APP_TYPES = (
    "certificate of lawfulness",
)

# Band 0 — explicit metalwork, demolition, or a job that always implies
# structural steel and balustrading. The best leads.
STRONG = (
    "steel",
    "stainless",
    "metalwork",
    "railing",
    "balustrade",
    "handrail",
    "fence",
    "fencing",
    "gate",
    "roof terrace",
    "balcony",
    "juliet",
    "demolition",
    "demolish",
    "into 2no. dwellings",
    "into 2 no. dwellings",
)

# Maintenance and cosmetic work. Real applications, but nothing to fabricate.
# Checked after STRONG, so "repair ... steel balustrade" still scores P0.
MAINTENANCE = (
    "repair",
    "redecorat",
    "painting",
    "plaque",
    "gutter",
    "downpipe",
    "repoint",
    "re-point",
)

# Band 1 — structural work. Likely to need fabricated steel, a staircase, an
# access gate or a railing somewhere in the job.
STRUCTURAL = (
    "erection of",
    "dwelling",
    "dwellinghouse",
    "residential units",
    "loft conversion",
    "dormer",
    "two storey",
    "2-storey",
    "two-storey",
    "second floor",
    "annex",
    "annexe",
    "outbuilding",
    "garage conversion",
    "conversion of the existing garage",
    "conversion of garage",
    "outline",
    "first floor extension",
    "upward extension",
    "raising of",
    "roof extension",
)

# Band 2 — modest works. Worth a look, rarely urgent.
MODEST = (
    "extension",
    "change of use",
    "conversion",
    "alterations",
    "refurbishment",
    "replacement",
    "porch",
    "canopy",
    "window",
    "door",
    "installation",
)

# relevant_to_gates_rails value paired with each priority band.
BAND_RELEVANCE = {
    "P0": "Yes",
    "P1": "Yes",
    "P2": "Maybe",
    "P3": "No",
}


# --- Scoring --------------------------------------------------------------

def _norm(text):
    """Lowercase and collapse whitespace so keyword matching is predictable."""
    return re.sub(r"\s+", " ", (text or "")).strip().lower()


def _any_in(needles, haystack):
    return any(n in haystack for n in needles)


def grade(description, app_type=""):
    """Return (relevant_to_gates_rails, priority) for one application.

    >>> grade("Installation of new stainless steel fence.", "Full")
    ('Yes', 'P0')
    >>> grade("Beech (T1): fell.", "Works to Trees Subject to TPO")
    ('No', 'P3')
    """
    desc = _norm(description)
    kind = _norm(app_type)

    # Excluded types never produce a lead, regardless of description.
    if _any_in(EXCLUDED_APP_TYPES, kind):
        return BAND_RELEVANCE["P3"], "P3"

    if _any_in(STRONG, desc):
        band = "P0"
    elif _any_in(MAINTENANCE, desc):
        band = "P3"
    elif _any_in(STRUCTURAL, desc):
        band = "P1"
    elif _any_in(MODEST, desc):
        band = "P2"
    else:
        band = "P3"

    # Retrospective / lawfulness applications are real but not live jobs.
    if band == "P0" and _any_in(CAPPED_APP_TYPES, kind):
        band = "P1"

    return BAND_RELEVANCE[band], band
