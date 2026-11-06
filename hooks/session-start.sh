#!/bin/bash
# Pinned skills: install the skill sources this project pins, at session start.
#
# /nharb:install copies this file into a project as .claude/hooks/pinned-skills.sh and
# registers it as a SessionStart hook. It reads .claude/skills/pinned-versions, one line per
# skill source:
#
#   <name> <version> <repository>      e.g.  nharb 1.1.0 https://github.com/nayefharb-hub/nharb-skills
#
# For each source, ~/.claude/skills/<name> is a git clone checked out at the tag v<version>:
# - It is already that release: nothing happens.
# - It is not (a first session, or a cloud container from an older snapshot): exactly the
#   pinned release is installed. Never a newer one: a skill asks before upgrading, and an
#   upgrade rewrites the line.
# - Anything fails: it says so and exits 0, so the session always starts.
set -uo pipefail

PIN_FILE="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/skills/pinned-versions"
ROOT="${PINNED_SKILLS_ROOT:-$HOME/.claude/skills}"

install_one() {
  local name="$1" version="$2" repo="$3"
  local dir="$ROOT/$name" current tmp
  current="$(tr -d '[:space:]' 2>/dev/null < "$dir/VERSION" || true)"

  if [[ "$current" == "$version" ]]; then
    echo "$name: $version installed"
    return 0
  fi

  if [[ -d "$dir/.git" ]]; then
    if git -C "$dir" fetch -q --depth 1 origin tag "v$version" 2>/dev/null \
       && git -C "$dir" -c advice.detachedHead=false checkout -q "v$version" 2>/dev/null; then
      echo "$name: installed $version (was ${current:-none})"
      return 0
    fi
  elif [[ -e "$dir" ]]; then
    echo "$name: $dir exists but is not a git clone; leaving it alone"
    return 0
  else
    mkdir -p "$ROOT"
    tmp="$dir.tmp.$$"
    if git -c advice.detachedHead=false clone -q --depth 1 --branch "v$version" "$repo" "$tmp" 2>/dev/null; then
      mv "$tmp" "$dir"
      echo "$name: installed $version"
      return 0
    fi
    rm -rf "$tmp"
  fi

  if [[ -n "$current" ]]; then
    echo "$name: v$version could not be fetched from $repo; still using installed $current. Check .claude/skills/pinned-versions."
  else
    echo "$name: v$version could not be fetched from $repo; its skills are unavailable this session. Check .claude/skills/pinned-versions."
  fi
}

if [[ ! -f "$PIN_FILE" ]]; then
  echo "pinned skills: no .claude/skills/pinned-versions in this project; nothing installed"
  exit 0
fi
if ! command -v git >/dev/null 2>&1; then
  echo "pinned skills: git not found; nothing installed"
  exit 0
fi

while read -r name version repo _; do
  [[ -z "${name:-}" || "$name" == \#* ]] && continue
  # The name becomes a folder under ~/.claude/skills and the version a tag: accept only safe forms.
  if [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*$ || ! "${version:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ \
        || ! "${repo:-}" =~ ^(https://|/) ]]; then
    echo "pinned skills: skipping malformed line: $name ${version:-} ${repo:-}"
    continue
  fi
  install_one "$name" "$version" "$repo"
done < "$PIN_FILE"
exit 0
