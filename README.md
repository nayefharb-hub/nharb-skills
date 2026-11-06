# nharb-skills

Nayef Harb's skills for Claude Code. Each one loads as `/nharb:<skill>`.

| Skill | What it does |
|---|---|
| `/nharb:handoff` | Writes the end-of-session handoff. `relay` (the default) keeps one standing file per project; `shotgun` writes a one-off prompt to paste into a new session. |
| `/nharb:install` | Pins a skill source in a project (by default this one), so every session installs it at a fixed release. |

## How the `nharb:` prefix works

The repository is installed as the folder `~/.claude/skills/nharb/`. Because that folder holds
`.claude-plugin/plugin.json` with `"name": "nharb"`, Claude Code loads it as a plugin, and every
`skills/<name>/SKILL.md` inside it appears as `nharb:<name>`. No marketplace or install command
is involved.

## Using it in a project

In a session where nharb is installed, run **`/nharb:install`**. After asking, it writes and
commits three things in the project:

- **`.claude/skills/pinned-versions`**, one line per skill source: `<name> <version> <repository>`,
  e.g. `nharb 1.1.0 https://github.com/nayefharb-hub/nharb-skills`;
- **`.claude/hooks/pinned-skills.sh`**, a copy of `hooks/session-start.sh`;
- **its entry in `.claude/settings.json`**, so the hook runs at every session start.

At every session start the hook compares each pinned source with its installed copy in
`~/.claude/skills/<name>`. When they match it does nothing; when they differ (a first session, or a
cloud container from an older snapshot) it installs exactly the pinned release. It never installs
anything newer by itself.

Every nharb skill also checks the project first: in a project that does not pin nharb, it offers
to run `/nharb:install`.

**The very first time on a machine,** before any nharb skill exists there, ask the session to
install nharb by hand:
`git clone --depth 1 --branch v<latest> https://github.com/nayefharb-hub/nharb-skills ~/.claude/skills/nharb`.
Start a new session so the skills load, then run `/nharb:install`.

`/nharb:install` accepts any source that follows these conventions: release tags `vX.Y.Z`, a
`VERSION` file that matches its tag, a `.claude-plugin/plugin.json` name, and skills complete as
cloned. A source that needs a build step after cloning (gstack) cannot be pinned this way yet.

## Updates

Every nharb skill first runs `references/version-check.md`. It compares the installed version with
the latest release on GitHub (a `git ls-remote`, nothing downloaded). When a newer one exists, it
shows what changed and asks **Upgrade now** or **Not now**. **Upgrade now** rewrites the nharb line
of the project's `.claude/skills/pinned-versions` and installs that release; the session commits
the file, so every later session of that project uses it.

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
bin/                         nharb-update-check, nharb-changelog, nharb-upgrade
hooks/session-start.sh       the project hook: installs what .claude/skills/pinned-versions pins
references/version-check.md  the check every skill but install runs first
skills/<name>/SKILL.md       one folder per skill
```
