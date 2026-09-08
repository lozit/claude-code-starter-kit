# `close`: reconcile `PLAN.md` with what the session actually changed

**Written**: 2026-09-08. **Rewritten the same day, and the first version is the reason this
one says what it says** — it justified the skill with one user's own stale records, named a
convention this plugin does not generate, and had the skill reach for an external note. None
of that belongs in a public plugin. What follows is the part that holds for every user, and
nothing else.

## Why

Every groundrules project carries `PLAN.md`: what is in progress, what is next, what is
recently done. Every generated `CLAUDE.md` carries the rule that keeps it true — *keep a doc
in sync in the same change that makes it stale.*

**That rule is a reminder, and this plugin has already recorded that reminders do not fire.**
[ADR 0022](docs/decisions/0022-agent-evals-and-session-close.md) established that an agent
cannot perceive a session ending, and anchored the capture ritual to boundaries it *can* see.
The same reasoning applies one step further: an agent cannot reliably notice, mid-task, that
a sentence in another file just became false. So `PLAN.md` drifts — items stay open after the
work that closed them, "in progress" outlives the release that shipped it, and the drift is
found later by a person reading it.

The plugin's own standing answer is written into every `CLAUDE.md` it generates: **prefer a
check to a reminder.** And this drift is *computable*: git says what changed, `PLAN.md` says
what it believes. Two records, one comparison.

## What to obtain

**A skill, invoked by the human, that compares `PLAN.md` with the diff and proposes the
edit.**

- **Input**: the changes since a baseline — an argument, else the branch's merge-base with the
  default branch, else the last tag. Commit subjects, paths touched, and the `[Unreleased]`
  lines added to `CHANGELOG.md`.
- **Comparison**: against `PLAN.md`'s open and in-progress items.
- **Output**: the edit **shown as a diff** — items to tick, an in-progress item whose subject
  the diff shows as shipped, a sentence the change made false. One confirmation, one gesture.
- **It proposes; it never writes on its own inference.** `PLAN.md` is authored: somebody
  decided it should say what it says. A record rewritten by the agent alone is the stale
  record with a fresh date on it. The value is that the proposal exists *while the knowledge
  is still in context*, not that it is applied blind.

## The trap, and the steer

**Match on what changed, never on filenames.** Nothing links a file's name to a `PLAN.md`
line, and a matcher built on names produces a false positive for every item whose work was
described in the project's own words. Match on paths, backticked identifiers, ADR and PRD
numbers, commit subjects. **A check that cries wolf gets switched off, and then it is worse
than no check.** List uncertain items as *possibly touched* for the human to resolve rather
than dropping them.

**`PLAN.md` and nothing else.** No other file, no other record, no assumption about what else
a project might keep or where. If a user keeps a status note elsewhere, that is theirs; this
skill does not reach for it and does not mention it.

**Cheap by construction.** `PLAN.md` plus git metadata. A close that costs a minute runs once
a week and is a reminder wearing a command's name; one that costs seconds runs at every
checkpoint.

**Nothing in band.** No hook, no automatic trigger — [ADR 0025](docs/decisions/0025-no-runtime-hook-no-watch.md)
refused in-band runtime hooks, and ADR 0022 refused an automatic end-of-session trigger
because the agent cannot perceive the end. This is invoked by the person who can. It shares
0022's anchors: the agent may *propose* it at the boundaries it already flows through.

**Siblings, not one skill.** `checkpoint` is an interview that captures **knowledge**
(decided → ADR, learned → LEARNINGS). This captures nothing; it reconciles **status**, and it
must stay cheap. Folding it into `checkpoint` makes the cheap one expensive.

## Done when

- Run in a repository where `PLAN.md` has an in-progress item whose work is in the diff, it
  proposes ticking it, as a diff, and writes only after confirmation.
- Run where nothing in the diff matches anything open, it says so and writes nothing.
- An item whose only link to the change is a filename is **not** matched.
- It reads `PLAN.md` and git, and no other file.
- The generated `CLAUDE.md` checkpoint list names it, so the rule fires where it is loaded.
