"""The three councils we collect from.

IMPORTANT — the base URLs below are UNVERIFIED. They were written without
network access to the councils (this repo's build environment blocks them), so
each council lists several candidate URLs rather than one guess.

`python3 collect.py --probe` tries each candidate in turn and tells you which
one is a live Idox instance. Run that once, put the winner first in the list,
and the guesswork is over for good.

Broadland District Council and South Norfolk Council run a joint planning
service and may share a single portal. If the probe finds the same working URL
for both, set `shared_portal` and the collector will fetch once and split the
results by the ward/parish on each application.
"""

COUNCILS = {
    "norwich": {
        "name": "Norwich City Council",
        "candidates": [
            "https://planning.norwich.gov.uk/online-applications",
        ],
    },
    "broadland": {
        "name": "Broadland District Council",
        "candidates": [
            "https://publicaccess.southnorfolkandbroadland.gov.uk/online-applications",
            "https://secure.broadland.gov.uk/PublicAccess/online-applications",
            "https://area.broadland.gov.uk/online-applications",
        ],
    },
    "south-norfolk": {
        "name": "South Norfolk Council",
        "candidates": [
            "https://publicaccess.southnorfolkandbroadland.gov.uk/online-applications",
            "https://info.south-norfolk.gov.uk/online-applications",
            "https://area.south-norfolk.gov.uk/online-applications",
        ],
    },
}

DEFAULT_COUNCILS = ("norwich", "broadland", "south-norfolk")


def base_url(slug):
    """The base URL currently in use for a council (first candidate)."""
    return COUNCILS[slug]["candidates"][0]


def display_name(slug):
    return COUNCILS[slug]["name"]
