---
name: close
description: "Use at a checkpoint, or when closing a work session, to reconcile PLAN.md with what the session actually changed: reads the diff since a baseline (commits, paths, CHANGELOG lines), compares it with the open items, and shows the edit as a diff. Proposes; never writes without confirmation. A check, not a reminder."
disable-model-invocation: true
allowed-tools: Read, Edit, Bash, AskUserQuestion
---

# /groundrules:close

You will **reconcile `PLAN.md` with what actually changed**, and propose the edit. All output is in **English**.

> The generated `CLAUDE.md` carries the rule that keeps `PLAN.md` true — *keep a doc in sync in the same change that makes it stale*. That rule is a **reminder**, and it relies on the agent noticing, mid-task, that a sentence in another file just became false. So `PLAN.md` drifts: items stay open after the work that closed them, an in-progress item outlives the release that shipped it. The drift is **computable** — git says what changed, `PLAN.md` says what it believes — so it can be checked. This is the check.

**Scope**: `PLAN.md` and git metadata. **Nothing else.** No other file is read, no other record is compared, and no assumption is made about what else a project might keep or where.

**Budget**: cheap enough to run at every checkpoint — **seconds, not minutes**. A close that costs a minute runs once a week and is a reminder wearing a command's name.

## Phase 1 — What changed (read-only)

Pick the baseline, in this order:

1. `$ARGUMENTS` if given: a ref (`main`, `v1.10.0`, `HEAD~4`) or a window (`--since="8 hours ago"`).
2. On a topic branch: `git merge-base HEAD <default>`, where `<default>` is `main` or `master`, whichever exists — everything this branch did.
3. Otherwise the last tag (`git describe --tags --abbrev=0`); if none, the last 15 commits.

Then, in as few commands as possible:

- `git log <base>..HEAD --format='%h %s'` — the commit subjects.
- `git diff <base> --stat` and `git status --short` — the paths touched, committed or not.
- `git diff <base> -- CHANGELOG.md` — the `[Unreleased]` lines added, if any. They are already a human-written summary of the change, so they are the strongest signal available.

State the baseline in one line. If nothing changed, say so and stop — **an empty close is a valid outcome.**

## Phase 2 — What the record says

Read `PLAN.md`. Absent → say so and stop; there is nothing to reconcile. Otherwise take the open items of `## In progress`, `## Up next` and `## Waiting / blocked` — unchecked `- [ ]` bullets and their sub-bullets.

**Match on what changed, never on filenames.** An item is *touched* when something it names appears in Phase 1: a path or directory, a backticked identifier, a skill or command name, an ADR or PRD number, the subject of a commit or of a `CHANGELOG` line. A **filename** is **not** a match — nothing links a file's name to a `PLAN.md` line, and a matcher built on names produces a false positive for every item whose work was described in the project's own words. **A check that cries wolf gets switched off, and then it is worse than no check.** When unsure, list the item as *possibly touched* for the human to resolve; never drop it silently.

For each touched item, propose the smallest true edit:

- **Tick** — the diff delivers the item: its stated deliverable exists in the diff, or a `CHANGELOG` line says it shipped. Edit: `[x]`, moved to `## Recently done` in the file's own style (mirror what the file already does, e.g. a trailing `— under [Unreleased] (YYYY-MM-DD)`).
- **Rewrite one sentence** — the item stays open, but a status sentence in it is now false: *"not yet"*, *"pending"*, *"no X yet"*, *"in progress"*, a count, a version. Edit: that sentence only.
- **Split** — the diff delivers a sub-bullet only: tick the sub-bullet, leave the parent open.

Do not touch untouched items, the `## Ideas — to triage` inbox, or the file's `generated-by` signature.

## Phase 3 — Propose, then one gesture

Show, in this order:

- the baseline, and a two-line summary of what changed;
- the **diff** — unified, exact, ready to apply.

Then **one** `AskUserQuestion` — *Apply this `PLAN.md` edit?* — with **Apply** / **Apply with edits** (they say what to change, you apply) / **Nothing**. One question, one gesture.

Nothing to propose → no question. Say the record is already true; that is a result, not a failure.

**It proposes; it never writes on its own inference.** `PLAN.md` is authored — somebody decided it should say what it says. A record rewritten by the agent alone is the stale record with a fresh date on it. The value is that the proposal exists *while the knowledge is still in context*, not that it is applied blind.

## Phase 4 — Write, recap

On confirmation, apply the edit (preserve the signature; `## Recently done` grows in the file's existing order). Then:

- ✅ `PLAN.md`: N items ticked, M sentences rewritten — or *unchanged*
- ⏭️ suggested commit subject: `docs(plan): close — <what the record now states>` — the message says what the record *now says*, not what the session did; the diff already says that.

**NEVER commit automatically.**

## Important rules

- **`PLAN.md` and nothing else.** If a user keeps a status note elsewhere, that is theirs: this skill does not reach for it and does not mention it.
- **Propose, never auto-write.** The confirmation is one gesture, and it is the human's.
- **Match on what changed** — paths, identifiers, ADR/PRD numbers, commit and `CHANGELOG` subjects — never on a filename.
- **Cheap or unused.** `PLAN.md` plus git metadata; no tour of `docs/`, no re-reading file contents beyond the hunks git already shows.
- **Empty is fine.** Manufacturing an edit to have something to show is the failure this command exists to prevent.
- **Sibling of `/groundrules:checkpoint`, not part of it.** `checkpoint` is an interview that captures **knowledge** (decided → ADR, learned → LEARNINGS, drift → AGENT-EVALS). This captures nothing; it reconciles **status**, and it must stay cheap. Run both before a push.
- This skill writes `PLAN.md` only; it never commits, tags, or pushes.
