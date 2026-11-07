---
name: full-replay
description: Run a full-replay sweep. It re-runs every recorded mutation proof of the project's tests locally, reports which checks stayed silent, and proposes tickets for them. Use when the user asks for a full replay or a sweep, or when the project's instructions say a sweep is due.
argument-hint: "[why the sweep is due]"
---

# Full-replay sweep

A **mutation proof** records that a check fails when the code under test is broken in a known
way: the mutant. A sweep re-runs every proof, so it finds the checks that have gone **silent**
since they were proven: the check changed and no longer catches the break, or the code moved and
the mutant no longer breaks anything that runs.

The sweep **searches and reports**. It never fixes, quarantines, loosens or deletes a check or a
proof. Fixing is ordinary ticket work after the sweep. It never runs on CI or a schedule, never
blocks a merge or a release, and never merges.

## Check the version

First, follow `~/.claude/skills/nharb/references/version-check.md`.

## 1. Find the project's sweep

Read the project's always-loaded instructions (`CLAUDE.md`, `AGENTS.md`), and the documents they
route testing and documentation questions to. Find:

- the command that checks the suite is green on the real build, and anything that must run before
  it (a tripwire, a dependency install);
- the command that replays **every** proof, the one that replays one gate or test file, and what
  each verdict it prints means;
- the environment variables that point a test run at another build, which a sweep must not inherit;
- where the project records which checks have no replayable proof, and its kinds of them;
- its ticket system;
- when a sweep is due, and how long one takes, if stated.

Do not look up earlier sweep reports yet (step 6).

If the project names no command that replays every proof, say so and stop: the skill does not
apply.

**Done when** you hold each item above, or know that the project does not state it.

## 2. Ask

Ask the user with AskUserQuestion, with three facts: what will run (every proof, after the suite),
why the sweep is due (the merge and the change, or the user's request), and the expected time the
project states (or "not stated"). Options:
**Run the sweep** and **Not now**. Skip the question only when the user asked for the sweep in the
message that started this skill.

**Done when** the user said yes. On **Not now**, stop: the sweep stays due.

## 3. Set up and check the suite

- Make a **separate** git worktree of the default branch's remote head, with full history. Never
  use the user's checkout. Install what the project's instructions say a fresh checkout needs.
- Unset the variables found in step 1.
- Run the pre-checks, then the suite command. **It must be green on this head.** A proof means
  something only where its check passes on the real build: a check that is already red fails
  under its mutant for the wrong reason.

**Done when** the suite is green on the worktree's head. Otherwise stop.

## 4. Replay every proof

Note the head commit and the time, then run the replay-everything command in the background, with
its output in a log file. Run nothing else in that worktree until it ends. Note the end time.

Then retry each claim that is not OK **once, alone**, with the one-gate command, reading only that
claim's result:

- a crash or timeout that passes the retry is a **fluke**;
- a check that passed under its mutant (it did not notice) still counts as **silent**, even if
  the retry is OK.

**Done when** every claim has a verdict, and every claim that was not OK has its retry result.

**Stop, report what happened, and file nothing** when:
- a pre-check fails;
- the replay exits with a usage or environment error;
- the worktree's head changed during the run;
- the clone is shallow and old builds cannot be read.

## 5. Write the report

Write it from this run's output alone:

1. **The run:** head commit, date, time taken, and the suite command's result it relied on.
2. **Counts per verdict,** with the tool's own label and a plain word for each (for example
   "VACUOUS: silent, did not notice the break").
3. **Silent checks,** most important first: those behind a public claim or a critical area, when
   the project records which. For each: the gate and check, the mutant or build, the verdict, the
   tool's one-line reason, and the retry result. A proof that is OK only because the old build
   crashed is listed apart, not counted as proven.
4. **Flukes.**
5. **Checks with no replayable proof,** counted by kind and by gate from the project's files,
   never from memory or from this skill.
6. **The 10 slowest jobs.**

Nothing is skipped silently: anything not replayed is listed, with the tool's reason.

**Done when** the report is complete.

## 6. Compare with the last sweep

Only now, look for earlier sweep reports where the project's documents say they are kept. Check
that each place exists, and do not stop at the first one: use the **most recent** report, and say
which you used and what else you found. Add a closing section: **new since the last sweep, still
silent, now OK**. If none is found, say so.

**Done when** the comparison is added, or its absence explained.

## 7. Propose tickets

For each silent check:
- search the project's ticket system for an open ticket on the same check, and propose a comment
  there instead of a new ticket;
- by default, propose one ticket per gate (one test file). Propose a merge when several gates went
  silent from an evident shared cause, and say why;
- each ticket names the gate and check, the mutant or build, the verdict and its reason, the
  commit, and the command that reproduces it.

Show the list with AskUserQuestion and **file nothing until the user confirms**. The user may merge,
split or drop items.

**Done when** the confirmed tickets are filed, or the user declined them.

## 8. Save and hand over

Post the report where the project's documents say sweep reports are kept, beginning with the line
`**Full-replay sweep report**`. If the project names a record file and the command that writes it,
run that command too, and commit the result under the project's rules for commits and pushes. Tell
the user where the report is, the counts, the tickets, and the time taken.

**Done when** the report is saved and the user has the summary.
