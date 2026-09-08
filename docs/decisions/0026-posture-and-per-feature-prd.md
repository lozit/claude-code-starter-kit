<!-- generated-by: groundrules v1.11.0 -->
# 0026 — Posture section + per-feature PRD (harvested from the four-principles doc)

**Date**: 2026-06-13
**Status**: Accepted

## Context

A user-supplied essay (`intake/principles-claude-code.md`) lays out four principles for working with an AI agent — **PRD · Pushback · Memory · Reversibility** — and how to apply them in Claude Code. Audit against groundrules:

- **Memory** — already the core (ADR 0020/0021: index + on-demand, `the repo is the only memory`; groundrules deliberately rejects the doc's `@imports` for context economy). Nothing to add.
- **PRD-via-plan-mode** — already in the generated `CLAUDE.md` ("Plan mode before any non-trivial task").
- **Pushback** — **absent** from the templates.
- **Reversibility (posture)** — **absent** (git/commit guidance existed, but no "confirm before hard-to-undo" line).

Two gaps worth filling.

## Decision

**1. Add a `## Posture` section to the generated `CLAUDE.md`** (full + lean) — how the agent should *work with you*, not just what to do:
- **Push back**: challenge off-strategy / technically-wrong / inconsistent-with-past-decisions plans; surface missed tradeoffs; ask before guessing on ambiguity; don't be sycophantic.
- **Stay reversible**: confirm before hard-to-undo actions (deletion, migration, mass rewrite, destructive command); lean on git + `/rewind`. The *tooling* (a `.claude/settings.json` deny-list, a `PreToolUse` guard) is **mentioned as a pointer, not generated** (it's harness-specific runtime — consistent with ADR 0025).

**2. Add a per-feature PRD via `/groundrules:prd`, superpowers-aware.** A PRD (problem, success criteria, scope in/out, constraints, build plan, risks) is written *before* a non-trivial feature, in `docs/prd/<feature>.md` (template `PRD.md.tpl`). Crucially:
- **If superpowers is present** (`docs/superpowers/plans/` or `specs/`) → groundrules **defers** to it (per-feature spec/plan is superpowers' altitude — the long-standing interop note). 
- **If absent** → groundrules provides the PRD itself.
- This **refines** the prior stance ("delegate per-feature to superpowers") into "fill the gap when superpowers isn't there, defer when it is" — groundrules no longer leaves non-superpowers users without a per-feature spec.

## Alternatives considered

- **Posture in the *global* CLAUDE.md only** — rejected as the default: a generated project CLAUDE.md should carry the posture so it's there even without a configured global; the lean template (which defers cross-cutting rules to the global) keeps only a compact 2-line version.
- **A PRD generated at bootstrap** — rejected: a PRD is per-feature and on-demand (like an ADR via `add-adr`), not a bootstrap artifact. `docs/prd/` is created on first `/groundrules:prd`.
- **Always own per-feature PRDs (ignore superpowers)** — rejected: would duplicate superpowers' altitude for its users; the superpowers-aware deferral is the user's explicit choice.
- **A PreToolUse safety hook / generated permissions deny-list** — rejected (ADR 0025 consistency: runtime, non-portable, opinionated config). Mentioned as pointers in the Posture section instead.

## Consequences

### Positive
- Every generated project now tells its agent to **challenge the user and stay reversible** — high-value behavior, zero runtime, harness-portable. Directly serves the "best practices of configuration" mission.
- Non-superpowers projects get a real per-feature PRD; superpowers projects are untouched.

### Negative / Tradeoffs
- `CLAUDE.md` grows ~12 lines (full template now ~186/200 — within budget; `slim` exists if it tightens later).
- A 10th skill (`prd`); it's per-feature/cross-cutting, not lifecycle surface.

## Notes

- Source: `intake/principles-claude-code.md`. The doc otherwise *validates* groundrules' approach (its combined "starter CLAUDE.md" ≈ what groundrules generates, minus the posture).
