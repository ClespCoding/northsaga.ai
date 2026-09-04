#!/bin/sh
# Install the three planning-collector jobs as macOS LaunchAgents.
#
#   ./install.sh                                  use sensible defaults
#   CREDENTIALS=~/.northsaga/sa.json ./install.sh  point at your key
#   ./install.sh --uninstall                      remove them again
#
# Three jobs, one per council, staggered five minutes apart:
#
#   05:55  Norwich City Council
#   06:00  Broadland District Council
#   06:05  South Norfolk Council
#
# Staggering matters: Broadland and South Norfolk may share one portal, and
# hitting it twice in the same second looks like an attack rather than a
# collection. Each job takes its own lock, so a slow Norwich run never blocks
# Broadland.

set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
COLLECTORS_DIR=$(CDPATH= cd -- "$HERE/.." && pwd)
AGENTS_DIR="$HOME/Library/LaunchAgents"
CREDENTIALS=${CREDENTIALS:-"$HOME/.northsaga/service-account.json"}

LABELS="ai.northsaga.planning.norwich \
ai.northsaga.planning.broadland \
ai.northsaga.planning.south-norfolk"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This installs macOS LaunchAgents and only runs on macOS." >&2
    echo "On Linux use collectors/crontab.example instead." >&2
    exit 1
fi

uninstall() {
    for label in $LABELS; do
        target="$AGENTS_DIR/$label.plist"
        if [ -f "$target" ]; then
            launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
            rm -f "$target"
            echo "removed $label"
        fi
    done
    echo "Done. The collector itself is untouched."
}

if [ "${1:-}" = "--uninstall" ]; then
    uninstall
    exit 0
fi

# --- checks before we install anything ---
if [ ! -x "$COLLECTORS_DIR/run-daily.sh" ]; then
    echo "FATAL: $COLLECTORS_DIR/run-daily.sh is missing or not executable." >&2
    exit 1
fi

if [ ! -f "$CREDENTIALS" ]; then
    echo "FATAL: no service-account key at $CREDENTIALS" >&2
    echo "Put the key there, or run: CREDENTIALS=/path/to/key.json $0" >&2
    exit 1
fi

# A private key readable by anyone but its owner is worth warning about.
perms=$(stat -f '%Lp' "$CREDENTIALS" 2>/dev/null || echo "")
case "$perms" in
    600|400|"") : ;;
    *) echo "WARNING: $CREDENTIALS is mode $perms, not 600." >&2
       echo "         chmod 600 '$CREDENTIALS'" >&2 ;;
esac

mkdir -p "$AGENTS_DIR" "$COLLECTORS_DIR/logs"

for label in $LABELS; do
    src="$HERE/$label.plist"
    target="$AGENTS_DIR/$label.plist"

    [ -f "$src" ] || { echo "FATAL: missing template $src" >&2; exit 1; }

    # Substitute the real absolute paths into the template.
    sed -e "s|__COLLECTORS_DIR__|$COLLECTORS_DIR|g" \
        -e "s|__CREDENTIALS__|$CREDENTIALS|g" \
        "$src" > "$target"
    chmod 644 "$target"

    # Reload cleanly whether or not a previous version is loaded.
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$target"
    echo "installed $label"
done

echo
echo "Installed 3 jobs into $AGENTS_DIR"
echo "  05:55  norwich"
echo "  06:00  broadland"
echo "  06:05  south-norfolk"
echo
echo "Check they are registered:"
echo "  launchctl list | grep northsaga"
echo
echo "Run one immediately, without waiting for the morning:"
echo "  launchctl kickstart -p gui/$(id -u)/ai.northsaga.planning.norwich"
echo
echo "Logs: $COLLECTORS_DIR/logs/"
echo
echo "NOTE: a LaunchAgent needs the user logged in. If the Mac is asleep at"
echo "05:55 the job runs when it next wakes, and the 7-day lookback means"
echo "nothing is lost. If the Mac is often off overnight, this belongs on a"
echo "machine that is not — see the GCP note in collectors/README.md."
