# nharb-skills

Nayef Harb's skills for Claude Code. Each one loads as `/nharb:<skill>`.

| Skill | What it does |
|---|---|
| `/nharb:handoff` | Writes the end-of-session handoff. `relay` (the default) keeps one standing file per project; `shotgun` writes a one-off prompt to paste into a new session. |

## How the `nharb:` prefix works

The repository is installed as the folder `~/.claude/skills/nharb/`. Because that folder holds
`.claude-plugin/plugin.json` with `"name": "nharb"`, Claude Code loads it as a plugin, and every
`skills/<name>/SKILL.md` inside it appears as `nharb:<name>`. No marketplace or install command
is involved.

## Using it in a project

1. Copy `hooks/session-start.sh` into the project as `.claude/hooks/nharb-skills.sh`.
2. Register it in the project's `.claude/settings.json`:
   ```json
   { "hooks": { "SessionStart": [ { "hooks": [
     { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/nharb-skills.sh" }
   ] } ] } }
   ```
3. Commit `.claude/nharb-version`, holding the release the project uses, e.g. `1.0.0`.

At every session start the hook compares the installed copy with that pin. When they match it
does nothing; when they differ (a first session, or a cloud container from an older snapshot) it
installs exactly the pinned release. It never installs anything newer by itself.

## Updates

Every nharb skill first runs `references/version-check.md`: it compares the installed version
with the latest release on GitHub (a `git ls-remote`, nothing downloaded) and, when a newer one
exists, shows what changed and asks **Upgrade now** or **Not now**. **Upgrade now** installs the
latest release and writes it to the project's `.claude/nharb-version`, which the session commits,
so every later session of that project uses it.

One version covers the whole repository: an upgrade updates every nharb skill together.

## Releasing a version

A release is a tag `vX.Y.Z` on `main` (`MAJOR.MINOR.PATCH`). For each release:

1. bump `VERSION`;
2. add a section `## X.Y.Z — <date>` at the top of `CHANGELOG.md`, saying which skills changed;
3. merge to `main`, then tag that commit `vX.Y.Z` and push the tag.

**Release tags are permanent.** Projects pin them, and a session installs a pinned tag by name:
never delete a tag or move it to another commit. A tag ruleset on GitHub (Settings → Rules →
Rulesets, target tags `v*`, restrict deletions and updates) enforces this.

## Layout

```
.claude-plugin/plugin.json   the prefix: "name": "nharb"
VERSION                      the installed release
CHANGELOG.md                 one section per release
bin/                         nharb-update-check, nharb-changelog, nharb-install, nharb-upgrade
hooks/session-start.sh       the project hook (copied into each project)
references/version-check.md  the version check every skill runs first
skills/<name>/SKILL.md       one folder per skill
```
