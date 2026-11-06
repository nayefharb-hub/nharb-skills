#!/bin/bash
# nharb skills: install the version this project pins, at session start.
#
# Copy this file into a project as .claude/hooks/nharb-skills.sh, register it as a
# SessionStart hook in the project's .claude/settings.json, and commit the pin file
# .claude/nharb-version holding a release, e.g. 1.0.0.
#
# - The installed copy (~/.claude/skills/nharb) already matches the pin: does nothing.
# - It doesn't (a first session, or a cloud container from an older snapshot): installs
#   exactly the pinned release. Never the latest: upgrades happen only when a skill asks
#   and the user says yes, which also changes the pin.
# - Anything fails: says so and exits 0, so the session always starts.
set -uo pipefail

PIN_FILE="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/nharb-version"
DIR="${NHARB_DIR:-$HOME/.claude/skills/nharb}"
REMOTE="${NHARB_REMOTE:-https://github.com/nayefharb-hub/nharb-skills}"

if [[ ! -f "$PIN_FILE" ]]; then
  echo "nharb: no .claude/nharb-version in this project; skills not installed"
  exit 0
fi
V="$(tr -d '[:space:]' < "$PIN_FILE")"

# Installed already: let the installed copy's own installer do the work.
if [[ -x "$DIR/bin/nharb-install" ]]; then
  "$DIR/bin/nharb-install" "$V" || true
  exit 0
fi

# First install: clone only the pinned release.
command -v git >/dev/null 2>&1 || { echo "nharb: git not found; skills not installed"; exit 0; }
if [[ -e "$DIR" ]]; then
  echo "nharb: $DIR exists but is not an nharb install; leaving it alone"
  exit 0
fi
mkdir -p "$(dirname "$DIR")"
tmp="$DIR.tmp.$$"
if git -c advice.detachedHead=false clone -q --depth 1 --branch "v$V" "$REMOTE" "$tmp" 2>/dev/null; then
  mv "$tmp" "$DIR"
  echo "nharb: installed $V"
else
  rm -rf "$tmp"
  echo "nharb: v$V could not be fetched from $REMOTE; the nharb skills are unavailable this session. Check .claude/nharb-version."
fi
exit 0
