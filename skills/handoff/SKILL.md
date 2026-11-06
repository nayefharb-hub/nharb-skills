---
name: handoff
description: Write the end-of-session handoff so the next session can pick up the work. Two modes, relay (the default) keeps it in one standing file, shotgun writes a one-off prompt to paste. Use when a session ends, when the user says hand off, hand over or wrap up, or before the container may be reclaimed.
argument-hint: "[relay|shotgun] [what the next session is for]"
---

# Handoff

A handoff is a **relay baton**: only what this session knows that nothing else records. That is
the work **in flight** (branches, pull requests, tickets being worked, uncommitted changes, where
each stopped), the **next step**, the user's decisions that **block** that work, what was **found
and not yet filed**, and the skills the next session should reach for. It is never a backlog: open
work that is not in flight lives in the tracker.

Everything else is **linked, never copied**. Facts the repository can answer (HEAD, version, tags)
become the commands that answer them; tickets, specs, ADRs, commits and pull requests are named by
ID, path or URL. Remove secrets, tokens and personal information.

## Check the version

First, follow `~/.claude/skills/nharb/references/version-check.md`.

## Choose the mode

Read the arguments:

- `shotgun` → **shotgun**: a one-off handoff, a self-contained prompt the user pastes into a new
  session by hand. Nothing is committed or kept.
- `relay`, or no mode → **relay**, the default: the handoff replaces one standing file (in a git
  repository, Google Drive or a folder) that the next session reads.

Any other text in the arguments is the next session's focus; shape the next step around it.

## Gather this session's state (both modes)

Read it from the tools, not from memory:

- `git status`, the current branch, commits not yet pushed, and the open pull request for the
  branch, with its state (draft, CI result, review);
- the task list, if the session used one;
- the conversation: what the user decided, what they asked for and did not get yet, what they must
  decide before the next step.

**Done when** every branch, pull request, ticket in progress, uncommitted change and blocking
question of this session is in your notes.

## The baton (both modes)

```markdown
# Handoff

Written <YYYY-MM-DD> by <session link or id>, on branch `<branch>`.
Check the facts in the repository, not here: <the commands this project uses for HEAD, version
and latest release>.

## Where it stopped
<One paragraph: what this session did and where it stopped.>

## In flight
- `<branch>` / <ticket>: <PR and its state>. Done: <…>. Left: <…>. Uncommitted: <nothing, or what>.

## Next step
- <ticket>: <the one next action, and what is already decided for it>.

## Blocking decisions
- <ticket>: <the decision the user owes before the in-flight work or the next step can move>.

## Found, not yet filed
- <what, where, and the evidence>. Empty when the session ends well.

## Suggested skills
- `<skill>`: <when the next session should invoke it>.
```

A section with nothing in it says "nothing". **Done when** each line passes the baton test: it is in
flight, next, or blocking; the next session could not find it in the repository, the tracker or
another document; and it is still true.

## Relay

### 1. Find the destination

If the project's always-loaded instructions (`CLAUDE.md`, `AGENTS.md`) name the handoff file or
location, use it without asking.

Otherwise, search the working tree for Markdown files whose name contains `handoff` or `handover`,
any case, skipping dependency folders, `.git`, and frozen snapshot folders. Leave out any file the
instructions mark as not to be edited, and say why. Then ask once, with AskUserQuestion: one option
per candidate ("Replace `<path>`", with its last commit date), "Create `HANDOFF.md` at the
repository root", and "Elsewhere" (a Google Drive document or a folder, named through "Other").
After the answer, offer to record the destination in the instructions file so later sessions
don't ask again.

A folder on the user's own computer is reachable only when the session runs on that machine. In a
cloud session, offer a git file or a Drive document instead.

**Done when** you hold one destination.

### 2. Sort the previous baton

Read the previous handoff at the destination, if there is one, and put every item in one place:

- **in flight**, or the next step, or a decision that blocks either: it **stays**, ticket or not.
  Mark it `(carried, not re-checked)` unless this session checked it.
- **resolved**: this session finished it, or the user closed it. It drops out.
- **open, not in flight, and tracked**: a ticket holds it. It drops out.
- **open, not in flight, and tracked nowhere**: propose a ticket to the user (title and body), file
  it on their yes, then drop the item. If they decline, ask whether to drop it.

**Done when** every item of the previous baton is in one place and nothing open has lost its
ticket.

### 3. Check for another session's baton

For a git destination, fetch the default branch and compare the file there with its version at
this session's merge base (`git diff $(git merge-base HEAD origin/<default>) origin/<default> --
<path>`). For Drive, compare the document's last-modified time with when you read it.

- **No change:** go on.
- **Changed:** another session handed off while this one worked. Read its version and sort its
  items as in step 2, alongside yours. Each in-flight entry names its own branch, so both sessions'
  entries sit side by side. Tell the user that two sessions were in flight.

**Done when** any change by another session is in your items.

### 4. Write and save

Replace the whole destination with the baton.

- **Git:** commit the file alone, as the last commit of this session's branch, with the message
  `Handoff: <date>, <one-line summary>`, and push it with the session's own pull request. Follow the
  project's rules for branches and pushes. If the session has no branch of its own, ask the user
  where the handoff goes before committing.
- **Drive:** replace the document's content.
- **Folder:** write the file.

**Done when** the baton is saved at the destination (pushed, for git).

### 5. Report

Tell the user the destination, the commit or document link, a two-line summary, any tickets filed in
step 2, and the first message for the next session: read the instructions file, then the handoff.

## Shotgun

### 1. Write the prompt

Turn the baton into one message a fresh session can act on with nothing else: open with the
repository and branch to check out and what the session is for, then the baton. Include whatever
the next session cannot reach by itself; a link to a file only on this machine is useless there.

**Done when** the prompt makes sense to a reader who has seen nothing of this session.

### 2. Hand it over

Save it as a Markdown file in the session's scratch folder (the scratchpad when the session has
one, else the OS temp directory), never in the repository, and commit nothing. Then show the whole
prompt in your reply, ready to copy, with the file's path.

**Done when** the user has the prompt in the reply and the file's path.
