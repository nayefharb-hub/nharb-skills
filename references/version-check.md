# The nharb version check

Every nharb skill except `install` runs this before its own steps. The scripts live in the
installed copy, `~/.claude/skills/nharb/bin/`; the project's pins live in its
`.claude/skills/pinned-versions`.

1. Run `~/.claude/skills/nharb/bin/nharb-update-check`. It prints one line:
   - `NOT_PINNED <installed>`: this project does not pin nharb, so its sessions will not install
     it. Go to step 2.
   - `UP_TO_DATE <installed>`: carry on with the skill, saying nothing about versions.
   - `CHECK_FAILED <reason>`: say in one line that the version could not be checked, and why,
     then carry on with the installed version.
   - `UPGRADE_AVAILABLE <installed> <latest>`: go to step 3.
2. **Not pinned.** Ask the user with AskUserQuestion: "This project does not pin nharb, so its
   sessions won't install it. Set it up now?" Options:
   - **Set it up**: invoke the skill `nharb:install` (it asks, writes the pin, the hook and the
     settings entry, and commits them), then carry on with this skill.
   - **Not now**: carry on with the installed version; the question comes back next time.
3. **Upgrade available.** Run `~/.claude/skills/nharb/bin/nharb-changelog <installed> <latest>`
   for what changed, and ask with AskUserQuestion: "nharb `<installed>` is installed; `<latest>`
   is available." Put the changelog lines in the question. Options:
   - **Upgrade now**: run `~/.claude/skills/nharb/bin/nharb-upgrade <latest> <project root>`. It
     rewrites the nharb line of `.claude/skills/pinned-versions` and installs that release. When it
     reports the pin changed, commit that file alone, with the message `nharb: upgrade to
     <latest>`, on the session's own branch, under the project's rules for commits and pushes.
     Then re-read the skill's `SKILL.md` (it may have changed) and follow the new version from its
     first step after this check.
   - **Not now**: carry on with the installed version.

**Done when** the skill runs on a version the user has accepted, and the project is pinned or the
user has said not now.
