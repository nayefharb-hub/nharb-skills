# Changelog

One section per release, newest first. A release is the tag `vX.Y.Z` on `main`.
Each heading is exactly `## X.Y.Z — YYYY-MM-DD`: the upgrade prompt reads these headings.

## 1.2.0 — 2026-11-07

- **New skill `/nharb:full-replay`.** A full-replay sweep: after the user's yes, on a separate
  worktree of the default branch, it checks the suite is green, re-runs every recorded mutation
  proof, retries each claim that is not OK once, and reports every verdict, the silent checks
  (most important first), the flukes, and the checks with no replayable proof. Only after its own
  report is complete does it compare with the most recent earlier sweep report. It proposes one
  ticket per gate, after searching for existing ones, and files them only on the user's confirmation.
  It never fixes anything, never runs on CI or a schedule, and never blocks a merge or a release.
  It names no project's commands: it reads them, and where reports are kept, from the project's own
  instructions, and stops when the project names no replay command.

## 1.1.0 — 2026-11-06

- **New skill `/nharb:install`.** Pins a skill source in a project: a line in
  `.claude/skills/pinned-versions`, the hook `.claude/hooks/pinned-skills.sh` and its entry in
  `.claude/settings.json`, after asking. It accepts any source with release tags `vX.Y.Z`, a
  matching `VERSION` and a plugin name; a source that needs building (gstack) is refused with the
  reason.
- **One pin file for every source.** Projects pin in `.claude/skills/pinned-versions`
  (`<name> <version> <repository>`) instead of `.claude/nharb-version`, which is no longer read.
  A project on 1.0.x moves by running `/nharb:install`.
- **Project hook (`hooks/session-start.sh`):** installs every source the pin file lists, each in
  `~/.claude/skills/<name>`; it rejects a line whose name, version or repository is malformed.
- **Version check (all skills):** in a project that does not pin nharb, offers to run
  `/nharb:install`. `bin/nharb-upgrade` rewrites the pin line and lets the hook install;
  `bin/nharb-install` is gone.

## 1.0.1 — 2026-11-06

- **Project hook (`hooks/session-start.sh`):** `[[ ]]` tests instead of `[ ]` (SonarCloud S7688).
  Behaviour unchanged; projects that copied the hook can re-copy it.
- **Changelog:** states the heading format the upgrade prompt reads.

## 1.0.0 — 2026-11-06

- **New skill `/nharb:handoff`.** Writes the end-of-session handoff: only what is in flight, the
  next step, the decisions that block them, what was found and not filed, and suggested skills.
  `relay` (the default) replaces one standing file per project; `shotgun` writes a one-off prompt
  to paste into a new session.
- **Versioning.** One `VERSION` for the repository, release tags `vX.Y.Z`, a per-project pin
  (`.claude/nharb-version`) installed by `hooks/session-start.sh`, and a version check every
  skill runs first, which asks before upgrading.
