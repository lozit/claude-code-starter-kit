<!-- generated-by: groundrules v1.10.0 -->
# 0025 — Won't-do: PreToolUse `{{KEY}}` hook and `/watch-bootstrap`

**Date**: 2026-06-08
**Status**: Accepted

## Context

Two ideas had sat in the backlog since the V0.5 `apply-best-practices` run (tracked in `docs/best-practices-pending.md`):

1. A **PreToolUse hook** that blocks writing a file containing an unsubstituted `{{KEY}}` placeholder — catching the problem *before* the write rather than after.
2. A **`/watch-bootstrap`** command that watches generated files during plugin development (e.g. warn if `CLAUDE.md` > 200 lines).

Both were "decide whether" items. Triaging the plan (2026-06-08), we close them.

## Decision

**Drop both.**

- **PreToolUse `{{KEY}}` hook — rejected.** `verify-bootstrap` already detects leftover placeholders post-hoc, and as of 2026-06-08 robustly (the backtick rule distinguishes a real bare `{{KEY}}` from a backticked doc reference). More fundamentally, a runtime hook is **machinery against groundrules' nature** (ADR 0002 "template over code"; offline-first; "pure Markdown + JSON, no runtime"): it would add a JS hook coupled to the Claude Code hook format, need a whitelist for the `*.tpl` files (where `{{KEY}}` is legitimate), and break the harness-agnostic direction (ADR 0023 / multi-harness — a Claude-Code-specific hook doesn't port). The marginal benefit (pre-write vs post-hoc catch) isn't worth the runtime surface. The snippet in `best-practices-pending.md` was never even validated against the real hook format.
- **`/watch-bootstrap` — rejected.** Niche, no demand; bootstrap is a short interactive flow that needs no watcher, and the CLAUDE.md-size concern is now served by `/groundrules:slim` + `verify-bootstrap` on demand.

## Consequences

### Positive
- Reinforces the **zero-runtime, markdown-instruction** identity: verification stays post-hoc via `verify-bootstrap`, never enforced by runtime hooks. Keeps the plugin harness-portable.
- Backlog cleaned; the ideas won't be silently re-proposed (the *why* is frozen here).

### Negative / Tradeoffs
- The `{{KEY}}` catch remains post-hoc (run `verify-bootstrap`), not pre-write. Acceptable — a forgotten placeholder is caught before release, and templates are the only place `{{KEY}}` is legitimate.

## Notes

- `docs/best-practices-pending.md` updated: both items marked resolved → this ADR. That file's pending queue is now empty.
- If a future harness offers a *portable* pre-write validation primitive, this can be revisited — but not via a Claude-Code-specific hook.
