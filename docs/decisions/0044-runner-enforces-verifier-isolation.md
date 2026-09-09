<!-- generated-by: groundrules v1.11.0 -->
# 0044 — The runner spawns the verifier separately; isolation stops being a request and becomes a fact

**Date**: 2026-09-09
**Status**: Accepted

## Context

The loop's whole back pressure rests on the verifier being independent of the maker
([ADR 0027](0027-reflection-realization-interactive-loop.md)). Both prompts said so at length:
`verifier.md` opened with *"Run as a separate subagent / fresh context… no memory of the maker's
reasoning"*, and `LOOP.md` repeated it, adding what the verifier must never receive — the maker's
reasoning, its `STATUS` narrative, the commit message.

**The runner supplied none of it.** `run-loop.sh` ran a single `claude -p` per iteration against
`LOOP.md`, whose steps 3 and 4 were the maker pass and the verifier pass. One agent, one context,
both roles. The verifier therefore had the maker's reasoning in full — it *was* the maker — which
is the exact contamination the prompt spends a paragraph forbidding.

Nothing hid this; `LOOP.md` even hedged, saying the verifier *should* run as a separate subagent.
It was found on 2026-09-09 by the eval suite: several runs of the case that asks an agent to read
the verifier prompt reported the gap between what the prompt claims and what the runner does. A
case about *reading* the verifier found a defect *in* it.

## Decision

**1. An iteration is two invocations, never one.** `run-loop.sh` calls `claude -p` with `LOOP.md`
(the maker pass), then again with `verifier.md` (the verifier pass). The second gets a fresh
context and nothing from the first — not the transcript, not a variable, not a summary.

**2. The maker no longer commits, and no longer reviews.** `LOOP.md` becomes the maker prompt: read
state, pick one task, implement it, run its acceptance test, produce `STATUS`, **stop**. The work
is left **uncommitted in the working tree**, which is what the verifier reads as the diff. This is
a better separation than the old one, not merely a mechanical split: the artifact under review is
now produced by one agent and judged by another, with the write held by the judge.

**3. The verifier finds its own inputs and acts on its own verdict.** It reads the task from
`loop/backlog.md`, the committed acceptance test, the diff from `git diff`, and `CLAUDE.md`'s
invariants — then, on PASS, checks the task off and commits; on REJECT, leaves the tree alone so
the note carries into the next iteration. A clean tree means there is nothing to judge, and it says
so rather than inventing a verdict.

**4. The natural stop skips the verifier.** When the maker reports `DONE: backlog empty`, the
iteration ends there: no verifier invocation is spent on an empty backlog.

**5. The split is asserted, not assumed.** `test/loop/validate-runner.sh` now counts invocations:
three iterations of a never-DONE loop must produce **six** calls, and a `DONE` on the first must
produce **one**. A deterministic stub, zero tokens. Had this assertion existed, the defect could
not have survived — which is the argument for writing it now rather than trusting the prose again.

**6. The prototype stays frozen at the single-invocation shape.** `docs/prototypes/loop/` keeps its
old runner, so its `verifier.md` deliberately does **not** carry the standalone-inputs and
act-on-verdict sections; giving it prompts describing a mechanism its runner lacks would transplant
the very defect this ADR removes. The divergence is stated in the prototype's own README, and **the
shipped template governs** ([`docs/AGENT-EVALS.md`](../AGENT-EVALS.md), 2026-09-02).

## Alternatives considered

- **Stop claiming the isolation instead of providing it** — the cheap fix: reword both prompts to
  say the fresh context is a discipline asked of the agent, not a property of the runner. Rejected.
  An agent asked to forget what it just wrote cannot comply; the request is unsatisfiable, so the
  honest version of that wording would be *the verifier is the maker*, which is the end of the back
  pressure ADR 0027 exists for.
- **Keep one invocation and hand the verifier a scrubbed prompt** (the diff and the task, with the
  maker's reasoning stripped) — rejected: the reasoning is in the context, not in the prompt. You
  cannot un-tell an agent what it has already thought.
- **A third invocation to act on the verdict** — rejected: nothing carries the maker's framing into
  the verdict step, so a third context buys nothing and costs a call per iteration.
- **Leave the maker committing, verifier reverts on REJECT** — rejected: a revert loses work the
  next maker would otherwise refine, and it makes the git history a record of rejected attempts.

## Consequences

### Positive
- The loop's central guarantee becomes true. The verifier's independence is now produced by the
  runner and **checked by a test**, where it used to be a sentence in a prompt.
- The maker's `STATUS` becomes what it always claimed to be — a report to a human — since the
  verifier structurally cannot read it.
- The commit is made by the agent that approved it.

### Negative / Tradeoffs
- **Twice the invocations, so roughly twice the cost per iteration.** Mitigated only by the
  `DONE` short-circuit. This is the price of the property; a cheaper loop that does not have it is
  not the same loop.
- The verifier re-derives context the maker already had, which is slower and is the point.
- One more prompt path in the runner (`--verifier`), and one more file it must find.

### Neutral
- No change for a project that never opted into the loop scaffolding.

## Notes

- Found by `evals/evals.json` case 1 on 2026-09-09, reported independently by several runs. The
  same case also surfaced the self-contradiction in `verifier.md`'s preamble (*"nothing else"*
  against its own checks 5 and 7), fixed in the same change.
- Related: [ADR 0027](0027-reflection-realization-interactive-loop.md) (the back pressure this
  makes real), [ADR 0030](0030-loop-namespace-and-backlog.md) (the `loop/` namespace),
  [ADR 0037](0037-executable-evals-over-agent-config.md) (the suite that found it).
