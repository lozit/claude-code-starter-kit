<!-- generated-by: groundrules v1.11.0 -->
# 0034 — Posture: a "keep the diff small" axis (simplicity + surgical changes)

**Date**: 2026-06-29
**Status**: Accepted

## Context

The generated `CLAUDE.md` `## Posture` section (ADR 0026) encodes two behavioural axes: **Push back**
(anti-sycophancy, sharpened by the premortem reframing technique — ADR 0032) and **Stay reversible**. Both
are about the *social/safety* register — how the agent relates to the user and to destructive actions.

A scan of [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) —
a small plugin distilling four anti-pitfall coding principles attributed to Karpathy — surfaced that two of
its principles map to an axis groundrules' Posture **does not** cover: the *shape of the diff*. Our template
says nothing about writing minimal code or making surgical changes (`grep` for `simplic`/`surgical`/`minimal`
in `CLAUDE.md.tpl` returned nothing). The other two Karpathy principles are already covered, more deeply:
*Think Before Coding* ≈ our Push back + `/premortem`, and *Goal-Driven Execution* ≈ our loop/realize/verifier
(ADR 0027/0030/0031). So the net-new value is narrow and concrete: the diff-shape axis.

## Decision

Add a third axis to the generated Posture section — **"Keep the diff small"** — folding in three sub-ideas:
*simplicity first* (minimum that solves the stated problem, no speculative abstraction), *surgical changes*
(touch only what the task requires, match surrounding style), and *clean up only your own mess* (remove only
what your change orphaned). Dogfooded in this repo's own `CLAUDE.md` Posture.

Phrasing choices, deliberately **not** a copy of the source plugin:

- **Question-led, not imperative.** Leads with *"Would a senior engineer call this overcomplicated?"* rather
  than the source's imperative "Don't assume / Don't hide confusion." Consistent with ADR 0032's finding that
  reframing as a question beats an explicit instruction. We kept only their one memorable test (the
  "senior engineer / overcomplicated" heuristic).
- **Folded into the existing section, not a new one.** A standalone block would fight the CLAUDE.md line
  budget (ADR 0024) and `/slim`. Three bullets under the existing `## Posture` is the whole footprint.

## Alternatives considered

- **Recommend installing `andrej-karpathy-skills` alongside groundrules** — rejected: ~90% overlap with our
  Posture (principles 1 and 4 already covered, deeper), so it would duplicate guidance and add friction,
  against "the repo is the only memory / we don't duplicate" (ADR 0020).
- **Copy all four principles verbatim** — rejected: two are redundant with us, and the imperative phrasing is
  weaker than our question-reframing (ADR 0032).
- **A new `## Code posture` section or a dedicated skill** — rejected: bloat vs the line budget (ADR 0024);
  the axis is three bullets, it belongs in the existing Posture.

## Consequences

### Positive
- The generated CLAUDE.md now covers the diff-shape register the user's coding agent most visibly drifts on
  (over-engineering, drive-by refactors), in groundrules' own voice.
- Tiny footprint; no new section, skill, or placeholder.

### Negative / Tradeoffs
- It's generic coding guidance, mildly opinionated — but it stays in the *starter* CLAUDE.md the user is told
  to edit, so it's a default, not a mandate.
- Three more lines against the CLAUDE.md budget; judged worth it for a register that was entirely absent.
