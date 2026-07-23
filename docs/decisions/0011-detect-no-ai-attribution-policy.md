<!-- generated-by: groundrules v1.10.0 -->
# 0011 — Detect a "no AI attribution" policy and adapt suggested commits

**Date**: 2026-06-03
**Status**: Accepted

## Context

Some orgs forbid AI attribution in commits/MRs. A managed enterprise `CLAUDE.md` may state it explicitly, e.g. *"Do not add AI attribution markers — no `Co-Authored-By` … no 'Generated with Claude Code'."* Meanwhile the agent's own default guidance often **appends** a `Co-Authored-By: Claude …` trailer. So a starter-kit skill that creates or suggests a commit could violate the org policy.

`bootstrap` actually commits (Phase 6). `adopt`/`migrate`/`verify-bootstrap` don't commit but **suggest** committing in their next-steps. Either way, the message should respect the policy.

## Decision

1. **Detect** (read-only) a no-attribution policy in `bootstrap`/`adopt` Phase 1: scan the detected project + global `CLAUDE.md` for patterns (`no AI attribution`, `Co-Authored-By`, `Generated with Claude`, `do not add … attribution`, `pas d'attribution`). Set `NO_AI_ATTRIBUTION`.
2. **Persist** it in `.starter-kit.json` as `policies.noAiAttribution`, so other skills (`migrate`…) read it without re-scanning.
3. **Adapt commits**: when a skill commits (`bootstrap`) or suggests a commit message (`adopt`, `migrate`), and the policy is set, the message must contain **no AI attribution trailer/footer** — this **overrides the agent's default attribution guidance**. Skills still never auto-commit beyond what they already did (`bootstrap`'s single bootstrap commit); `adopt`/`migrate` only *suggest*.

Independently, `bootstrap`'s bootstrap commit carries no attribution by default regardless of detection (it never did).

## Alternatives considered

- **Always strip attribution unconditionally** — rejected: outside a forbidding org, a `Co-Authored-By` trailer is fine/expected; only suppress when a policy says so.
- **A hook that rewrites commit messages** — rejected: hooks are invasive, per-project, and out of scope for offline template skills (the user reviews/owns commits). Detection + instruction is enough.
- **Ignore it (user edits the message)** — rejected: the whole point is that the agent's default would silently add the trailer; detection lets the skill pre-empt it.

## Consequences

### Positive
- Suggested/performed commits respect enterprise policy automatically when detected.
- `policies.noAiAttribution` gives downstream skills a cheap, single source of truth.

### Negative / Tradeoffs
- Detection is heuristic (string match); an oddly-phrased policy could be missed → falls back to the agent default (which the user can still edit). Conservative but not exhaustive.
- Reading the global `~/.claude/CLAUDE.md` read-only is a small scope addition (previously only existence was checked) — acceptable, no writes.

### Neutral
- The skills remain non-committing except `bootstrap`'s own bootstrap commit; this ADR governs message *content*, not whether to commit.

## Notes

- Implemented in `bootstrap` (Phase 1 detection, Phase 6 commit), `adopt` (Phase 1, Phase 6 suggestion), `migrate` (Phase 8 suggestion via `policies.noAiAttribution`).
- Complements [ADR 0009](0009-global-claude-md-awareness.md) / [ADR 0010](0010-managed-project-claude-md-deference.md) (CLAUDE.md awareness).
