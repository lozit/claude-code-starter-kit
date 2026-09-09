<!-- generated-by: groundrules v1.11.0 -->
# 0043 — `validated` is retired; a case makes an entry `probed`, and a class is never validated

**Date**: 2026-09-09
**Status**: Accepted (amends [ADR 0037](0037-executable-evals-over-agent-config.md), decision 2)

## Context

`docs/AGENT-EVALS.md` records failure modes of the agent on this project: what it did, the
generalizable pattern, the guard added. Every entry has sat at `Status: watching` since the file
was created, because nothing could move it.

[ADR 0037](0037-executable-evals-over-agent-config.md) decision 2 set out to fix that: an entry
whose guard sits at `watching` becomes a case, and `validated` would mean *a case exists and is
green*. That was the ADR's headline benefit — it would give `validated` an operational meaning
where today's guards are unfalsifiable.

**On 2026-09-09 the suite ran three times per case and the promise came due. It does not hold.**

An entry names a **behavioural class** — *asserts / trusts without verifying first*. A case grades
one **instance** — does the capture ritual fire at session end. The class has unbounded instances,
so no finite suite covers it, and a green on one instance says nothing about the next.

This is not a theoretical objection. On **2026-09-08**, six days before the case went green three
times out of three, that very class failed on a fresh instance: this repository adopted
`claude plugin eval` on the strength of its `--help` without invoking it, and built an ADR on the
assumption it could be run. Had `validated` existed as ADR 0037 defined it, the entry would have
been showing green at the exact moment the guard was failing. A status that reads *safe* while the
thing it describes is going wrong is worse than no status.

A second, smaller problem surfaced in the same run: case 1's green is **discounted**, because two
of its three runs read `evals/evals.json` — the file holding the expectations grading them. A
binary status has nowhere to put that.

## Decision

**1. `validated` is retired.** It is not renamed or redefined; the word leaves the vocabulary,
because its plain meaning is the claim that cannot be made.

**2. An entry is `watching` or `probed`.**

- **`watching`** — the default. A guard with no case, or a case whose green is discounted for a
  stated reason.
- **`probed: <case>, N/N since <date>`** — a case exists, is green over a **rate** rather than a
  single run, and covers a **named instance**. Nothing more is claimed.

**3. `probed` never means the class is safe**, and the entry says so by carrying its recurrence
log. A recurrence does not falsify the probe — the probe still passes on its instance — it records
that the class failed elsewhere. **The entry's history is the signal; the status is an index into
it.**

**4. A discounted green stays `watching`, with the discount stated.** Case 1's runs read the
answer key, so its entry keeps `watching` and says why. A status that can absorb a caveat silently
is a status that hides one.

**5. Nothing here weakens ADR 0037.** The suite's value — the guards became testable at all, and
authoring a grader forces you to state what a guard actually promises — survives intact. What
changes is the claim made about a green, which was always the weakest part.

## Alternatives considered

- **Broaden cases until they cover the class** — rejected as impossible, not merely expensive. You
  cannot enumerate the instances of *asserts without verifying*; a suite that tried would grow
  until nobody ran it, which ADR 0037 already names as worse than none.
- **Keep `validated` and define it as instance-scoped** — rejected. The word carries its everyday
  meaning into every reading, and the one reader who most needs the caveat is the one skimming for
  a green. Retiring the word is cheaper than defending it forever.
- **Drop statuses entirely and keep only prose** — tempting, and closer to honest: the guard text
  plus the recurrence log is the real content. Rejected because the file is read by an agent at
  session start, and a scannable field is what lets it tell a probed instance from an unprobed one
  without reading every entry.
- **Add a third status for a discounted green** — rejected: it splits the vocabulary to avoid
  writing one sentence. `watching` plus the reason says more.

## Consequences

### Positive
- The file stops promising something a finite suite cannot deliver, six days after it was caught
  promising exactly that.
- A recurrence now has a place to live that does not contradict a green probe.
- What a case buys — one instance, at a measured rate — is stated where it is claimed.

### Negative / Tradeoffs
- **No entry will ever read as *done*.** That is the point, and it will feel like the file never
  converges. It does not; the guards do, and the recurrence log is how you can tell.
- `probed` requires a rate, so a single green now buys nothing. Three runs per case is the working
  default and it costs three times as much.

### Neutral
- **Nothing changes for users of the plugin.** `AGENT-EVALS.md.tpl` only ever used `watching`, so
  the retired word was never generated into a project. This is a dogfood-side correction plus the
  meaning ADR 0037 assigned.

## Notes

- The evidence is `evals/README.md`'s results table and the 2026-09-08 entry of
  `docs/AGENT-EVALS.md` — the recurrence that makes the argument concrete rather than cautious.
- Related: [ADR 0037](0037-executable-evals-over-agent-config.md) (decision 2, amended here),
  [ADR 0042](0042-skill-creator-harness-as-the-runner.md) (decision 1, amended separately). Both
  amendments come from the same source: claims made about the suite before it had ever been run.
