<!-- generated-by: groundrules v1.10.0 -->
# 0028 — Git workflow conventions (branching, commit granularity, AI attribution)

**Date**: 2026-06-13
**Status**: Superseded by [ADR 0036](0036-git-workflow-corrected.md)

## Context

A git-workflow review (2026-06-13) surfaced three points where the repo's *practice* had drifted
from any written rule:

1. **Branching** — the generated `CLAUDE.md.tpl` prescribed *"feature branch for non-trivial
   changes"*, yet the repo itself works trunk-only on `main`. Template vs. dogfood inconsistency.
2. **Commit granularity** — the repo had drifted to **one large `feat: VX.Y.Z` commit per release**
   (whose body duplicates the `CHANGELOG`), leaving long stretches with no committed safety net
   (e.g. ~20 uncommitted files accumulated across one session).
3. **AI attribution** — `Co-Authored-By: Claude` appeared on only **2 commits** of the whole
   history: inconsistent, neither on nor off.

None of these is about the plugin's *output*; all are about how *this repo* is developed. They are
recorded here so the practice has a written, intentional home.

## Decision

**1. Branching — state the model, don't prescribe one.**
- The generated `CLAUDE.md` is **branching-model-neutral** (trunk-based vs. feature-branch + PR —
  "pick one"); groundrules no longer hard-codes a choice (consistent with *handoff-not-gospel* /
  no-opinionated-config). Already applied to `CLAUDE.md.tpl`.
- The dogfood's own model is **trunk-based on `main`** (solo maintainer); stated in the meta
  `CLAUDE.md`.

**2. Commit granularity — boundary commits, not a mega-commit per release.**
- Commit at **natural boundaries** (a completed chunk/feature) with **Conventional Commits**, *not*
  one mega-commit per release and *not* one per trivial change.
- **Tag + finalize the `CHANGELOG`** at release; commits happen throughout.
- "**Commit only on explicit request**" is preserved (this governs *who triggers*, not granularity).
- Commit messages **reference the relevant `CHANGELOG` section** rather than re-listing it (DRY).
- Rationale: a pure-markdown/JSON repo has no tests → `git bisect` has ~zero value; the `CHANGELOG`
  already *is* the granular human-facing history; the mega-commit's only effect was to remove the
  mid-batch safety net.

**3. AI attribution — attribute by default, defer to any forbidding rule.**
- Add `Co-Authored-By: Claude …` on commits **by default**, applied **consistently** going forward.
- **Unless a rule forbids it** — a global/enterprise `CLAUDE.md` instruction, or a project's
  `.groundrules.json` `policies.noAiAttribution: true`. This mirrors groundrules' own attribution
  detection ([ADR 0011](0011-detect-no-ai-attribution-policy.md)): the plugin already suppresses
  attribution when a policy is detected; the dogfood follows the same logic.
- For *this* repo: **attribute** (no rule forbids it; the repo is a tool about AI-assisted
  development and dogfoods it — the trailer tells that story honestly).
- **No history rewrite**: the existing commits (the 2 with the trailer, the rest without) stay as
  they are. Rewriting public history (force-push) breaks clones and falsifies records.

## Alternatives considered

- **One commit per release (status quo)** — rejected: no mid-batch safety net, coarse history, and
  the commit body duplicates the `CHANGELOG`.
- **Atomic commit per change** — rejected: over-ceremony for a solo doc repo and it breaks the
  established batching discipline.
- **No AI attribution at all** — a valid choice (and it would actively dogfood the suppression path
  of ADR 0011), but the maintainer chose attribution-by-default with policy-based deferral.
- **Retroactively fixing the 2 inconsistent commits** — rejected: history rewrite, not worth it.

## Consequences

### Positive
- The three git practices now have a written, intentional home; template-vs-dogfood inconsistency
  (point 1) is closed with an ADR, not just a CHANGELOG line.
- Boundary commits give a mid-batch safety net and revert-by-chunk without per-change ceremony.
- Attribution is consistent and policy-aware — dogfooding ADR 0011's own logic.

### Negative / Tradeoffs
- Boundary commits ask the maintainer to say "commit" at boundaries (slightly more interaction than
  a single release commit) — accepted for the safety net.
- "Attribute unless a rule forbids" is a small conditional the agent must remember; encoded in the
  meta `CLAUDE.md` Git workflow section.

## Notes

- Points 1 & 2 were already partially applied (templates, meta `CLAUDE.md`) before this ADR; this
  records the *why* and adds the commit-granularity + attribution decisions.
- **Superseded 2026-09-02 by [ADR 0036](0036-git-workflow-corrected.md)**: two premises here went
  stale — `main` is now a protected branch (direct push refused, admins included), and the
  maintainer's global `CLAUDE.md` *does* forbid AI attribution, so this ADR's *"for this repo:
  attribute (no rule forbids it)"* is false. The boundary-commit convention (point 2) survives
  unchanged in 0036.
