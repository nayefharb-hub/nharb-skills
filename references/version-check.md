# The nharb version check

Every nharb skill runs this before its own steps. The scripts live in the installed copy,
`~/.claude/skills/nharb/bin/`.

1. Run `~/.claude/skills/nharb/bin/nharb-update-check`. It prints one line:
   - `UP_TO_DATE <installed>`: carry on with the skill, saying nothing about versions.
   - `CHECK_FAILED <reason>`: say in one line that the version could not be checked, and why,
     then carry on with the installed version.
   - `UPGRADE_AVAILABLE <installed> <latest>`: go to step 2.
2. Run `~/.claude/skills/nharb/bin/nharb-changelog <installed> <latest>` for what changed.
3. Ask the user with AskUserQuestion: "nharb `<installed>` is installed; `<latest>` is available."
   Put the changelog lines in the question. Options:
   - **Upgrade now**: install `<latest>` and record it as this project's version.
   - **Not now**: keep `<installed>` for this run.
4. On **Not now**, carry on with the installed version.
5. On **Upgrade now**:
   - run `~/.claude/skills/nharb/bin/nharb-upgrade <latest> <project root>`;
   - when it reports that the pin `.claude/nharb-version` changed, commit that file alone, with
     the message `nharb: upgrade to <latest>`, on the session's own branch, under the project's
     rules for commits and pushes;
   - re-read the skill's `SKILL.md` (it may have changed) and follow the new version from its
     first step after this check.

**Done when** the skill runs on a version the user has accepted: the installed one, or the latest
after an upgrade with its pin committed.
