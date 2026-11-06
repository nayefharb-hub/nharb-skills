---
name: install
description: Pin a skill source in this project so every session installs it at a fixed release. Use when a project does not pin a skill source yet, when the user gives a repository link of skills to install or add, or when another nharb skill offers set-up.
argument-hint: "[repository link]"
---

# Install a skill source

Pins a skill source in the project, so that every session, in the cloud or on any machine, installs
exactly the pinned release at its start. Three things in the project do it, committed together:

- **`.claude/skills/pinned-versions`**: one line per source, `<name> <version> <repository>`;
- **`.claude/hooks/pinned-skills.sh`**: the session-start hook that installs what that file pins
  into `~/.claude/skills/<name>`, and does nothing when the installed release already matches;
- **its entry in `.claude/settings.json`**, which runs the hook at every session start.

A source's skills then load as `/<name>:<skill>`. Upgrades stay deliberate: each skill compares
the installed release with the latest and asks before moving the pin.

## Steps

### 1. Name the source

The argument is the source's repository link. With no argument, it is
`https://github.com/nayefharb-hub/nharb-skills`.

**Done when** you hold one repository link.

### 2. Check that the source can be pinned

Read its release tags with `git ls-remote --tags --refs <link> 'v*'`. The latest release is the
highest `vX.Y.Z`. Clone that tag into a scratch folder (`git clone --depth 1 --branch v<latest>
<link> <scratch>`) and check:

- its `VERSION` file reads `<latest>`;
- its `.claude-plugin/plugin.json` has a `name` of lowercase letters, digits and hyphens. That
  name is the source's folder in `~/.claude/skills/` and the prefix of its skills;
- its skills are complete as cloned: nothing has to be built first.

A source that fails any of these cannot be pinned this way yet. Examples: no `vX.Y.Z` tags, a
`VERSION` that differs from its tag, no plugin name, or a build step after cloning (gstack runs
`./setup`). Tell the user what is missing, and stop.

**Done when** you hold the source's name and latest release, or have stopped with the reason.

### 3. Ask

Ask with AskUserQuestion: "Pin `<name>` `<latest>` in this project?" Name what changes: the line
in `.claude/skills/pinned-versions`, the hook `.claude/hooks/pinned-skills.sh`, and its entry in
`.claude/settings.json`, committed on this session's branch. Say which of them already exist. Options:

- **Set it up**: go on.
- **Not now**: stop, changing nothing.

**Done when** the user has answered.

### 4. Write the three files

- **`.claude/skills/pinned-versions`.** If it does not exist, create it with this header:
  ```
  # Skill sources this project pins: one line each, "<name> <version> <repository>".
  # Written by /nharb:install and by an upgrade; read at session start by .claude/hooks/pinned-skills.sh.
  ```
  Then replace the line that starts with `<name> `, or add one: `<name> <latest> <link>`.
- **`.claude/hooks/pinned-skills.sh`.** Copy `~/.claude/skills/nharb/hooks/session-start.sh`
  into it and make it executable. If the project already has one that differs, replace it and
  say so.
- **`.claude/settings.json`.** Make sure `hooks.SessionStart` has a command hook
  `$CLAUDE_PROJECT_DIR/.claude/hooks/pinned-skills.sh`. Add it next to any hooks already there,
  removing none. Create the file if it is missing, and keep it valid JSON.

**Done when** all three are written and `.claude/settings.json` parses.

### 5. Install now

Run `CLAUDE_PROJECT_DIR=<project root> <project root>/.claude/hooks/pinned-skills.sh` and show
its output. The source's skills load as `/<name>:<skill>` from the next session start.

**Done when** the hook reports `<name>: <latest> installed` or `installed <latest>`, or you have
shown the user why it did not.

### 6. Commit and report

Commit the three files together, with the message `skills: pin <name> <latest>`, on the session's
own branch, under the project's rules for commits and pushes. If the project documents its hooks
(for example in `.claude/README.md`), tell the user that document needs a line; leave it to them.

Report what was pinned, the commit, and that the skills load from the next session.

**Done when** the commit exists, or the user has said where it goes.
