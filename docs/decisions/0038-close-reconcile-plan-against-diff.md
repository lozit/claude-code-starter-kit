<!-- generated-by: groundrules v1.10.0 -->
# 0038 — `/groundrules:close`: reconcile `PLAN.md` against the diff — a check, not a reminder

**Date**: 2026-09-08
**Status**: Accepted

## Context

Every groundrules project carries `PLAN.md`: what is in progress, what is next, what was recently
done. Every generated `CLAUDE.md` carries the rule meant to keep it true — *keep a doc in sync in
the same change that makes it stale.*

**That rule is a reminder, and this plugin has already recorded that reminders do not fire.**
[ADR 0022](0022-agent-evals-and-session-close.md) established that an agent cannot perceive a
session ending — no model-visible signal, `CLAUDE.md` loaded at start only, `SessionEnd` too late,
`Stop` every turn — and so anchored the capture ritual to boundaries the agent *can* see. The same
reasoning applies one step further: an agent cannot reliably notice, mid-task, that a sentence in
*another* file just became false. So `PLAN.md` drifts. An item stays open after the work that
closed it; an "in progress" line outlives the release that shipped it; a person reading the file
later is what catches it.

The plugin's own standing answer is written into every `CLAUDE.md` it generates: **prefer a check
to a reminder.** A reminder relies on attention; a check does not. And this particular drift is
**computable**: git says what changed, `PLAN.md` says what it believes. Two records, one
comparison — which is what makes a check possible here and not merely desirable.

Two prior decisions bound the shape of the answer. [ADR 0022](0022-agent-evals-and-session-close.md)
refused an *automatic* end-of-session trigger, for the reason above.
[ADR 0025](0025-no-runtime-hook-no-watch.md) refused in-band runtime hooks: verification stays
post-hoc and invoked, never enforced in the agent's write path.

## Decision

**1. A new skill, `/groundrules:close`, invoked by the human at a checkpoint or when closing a
work session.** It reads what changed since a baseline — an argument, else the branch's merge-base
with the default branch, else the last tag — taking commit subjects, the paths touched, and the
`[Unreleased]` lines added to `CHANGELOG.md`; compares that with `PLAN.md`'s open items; and
**shows the edit as a diff**: items to tick, an item whose stated deliverable the diff shows as
shipped, a status sentence the change made false.

**2. It proposes; it never writes on its own inference.** One `AskUserQuestion`, one gesture:
*Apply* / *Apply with edits* / *Nothing*. `PLAN.md` is authored — somebody decided it should say
what it says. A record rewritten by the agent alone is the stale record with a fresh date on it.
The value is that the proposal exists **while the knowledge is still in context**, not that it is
applied blind.

**3. It matches on what changed, never on filenames.** Paths, backticked identifiers, skill and
command names, ADR and PRD numbers, commit and `CHANGELOG` subjects. A filename is not a match:
nothing links a file's name to a `PLAN.md` line, and a name matcher produces a false positive for
every item whose work was described in the project's own words. **A check that cries wolf gets
switched off, and then it is worse than no check.** Uncertain items are listed as *possibly
touched* for the human to resolve, never dropped silently.

**4. `PLAN.md` and nothing else.** No other file is read, no other record is compared, and no
assumption is made about what else a project might keep or where. If a user maintains a status
note elsewhere, that is theirs; the skill neither reaches for it nor mentions it. This is a scope
decision, not an omission: the plugin can only check what it generates.

**5. Cheap by construction.** `PLAN.md` plus git metadata. A close that costs a minute runs once a
week and is a reminder wearing a command's name; one that costs seconds runs at every checkpoint.

**6. Named in the checkpoint list** of the generated `CLAUDE.md` (and the meta one), as a fourth
line next to *decided / learned / caught the agent*, so the rule fires where it is loaded.
`/groundrules:checkpoint` points to it at the end of its recap.

**Why this does not reopen ADR 0022.** 0022 ruled out an *automatic* end-of-session trigger,
because the agent cannot perceive the end. `close` is invoked by the person who can. It shares
0022's anchors — the agent may *propose* it at the boundaries it already flows through — and adds
nothing in band, so ADR 0025 stands as written too.

## Alternatives considered

- **A fifth bucket in `/groundrules:checkpoint`** — rejected. `checkpoint` is an interview: three
  questions, drill-downs, up to three files written. `close` must cost seconds and asks one
  question. Different register, different cost; folding one into the other makes the cheap one
  expensive, and a check that is expensive stops being run. They stay siblings, and `checkpoint`
  points to `close`.
- **An automatic trigger — a `Stop` or `SessionEnd` hook, or a write on push** — rejected twice
  over: ADR 0025 (nothing in band) and ADR 0022 (the agent cannot perceive the end). A hook also
  cannot ask the one question that makes the write legitimate.
- **Match items by filename** — rejected. It is the cheapest matcher to write and the fastest way
  to make the check untrustworthy; see decision 3.
- **Generate `PLAN.md` from git** — rejected in ADR 0022 already, when a per-session journal was
  turned down: a transcript is not a record. `PLAN.md` is authored prose about intent, and git
  cannot write it.
- **Reach for records the plugin does not generate** — rejected, per decision 4. A skill that
  assumes a convention the plugin never created is guessing about the user's setup, and a check
  built on a guess reports failures that are not failures.

## Consequences

### Positive
- `PLAN.md` gains a **falsifiable** freshness check, run at the moment the knowledge still exists
  in context, instead of a human noticing days later.
- The check costs seconds, so it can sit in the checkpoint list without making the ritual heavier.
- Nothing in band, nothing automatic: the plugin's zero-runtime identity is untouched.

### Negative / Tradeoffs
- **The matcher is instructions, not code.** False negatives — a drift not surfaced — are the
  accepted cost of refusing name matching. False positives are cheap, because the human is the
  gate and the proposal is a diff.
- **One more skill in a growing list** (fifteen). Justified by the cost argument above: the
  alternative was making `checkpoint` do it, which would have made `checkpoint` worse.
- **It only sees what git and `PLAN.md` show.** Work that changed nothing on disk — a decision
  reversed in conversation — remains invisible to it. That is `checkpoint`'s half.

### Neutral
- The generated `CLAUDE.md` gains one line in its checkpoint list. No new file, no new
  placeholder, no change to any other generated output.

## Notes

- Brief: `intake/2026-09-08-close-the-session-update-the-context.md`.
- Builds on [ADR 0020](0020-repo-is-the-only-memory.md) (the repo is the only memory, and the
  record is authored), [ADR 0022](0022-agent-evals-and-session-close.md) (perceivable boundaries,
  manual trigger, no journal) and [ADR 0025](0025-no-runtime-hook-no-watch.md) (post-hoc, never a
  hook).
- The acceptance cases are the brief's *Done when* list; they run in any repository the plugin has
  bootstrapped, and are tracked in `PLAN.md`.
