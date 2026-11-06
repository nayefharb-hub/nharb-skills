# Changelog

One section per release, newest first. A release is the tag `vX.Y.Z` on `main`.

## 1.0.0 — 2026-11-06

- **New skill `/nharb:handoff`.** Writes the end-of-session handoff: only what is in flight, the
  next step, the decisions that block them, what was found and not filed, and suggested skills.
  `relay` (the default) replaces one standing file per project; `shotgun` writes a one-off prompt
  to paste into a new session.
- **Versioning.** One `VERSION` for the repository, release tags `vX.Y.Z`, a per-project pin
  (`.claude/nharb-version`) installed by `hooks/session-start.sh`, and a version check every
  skill runs first, which asks before upgrading.
