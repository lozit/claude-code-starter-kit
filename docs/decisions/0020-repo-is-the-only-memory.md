<!-- generated-by: groundrules v1.11.0 -->
# 0020 — The repo is the only memory

**Date**: 2026-06-07
**Status**: Accepted

## Context

While consolidating a real project (crm-heyjoe), several pieces of project knowledge turned out to live **outside the repo**, in machine-local Claude state: project memories (`~/.claude/projects/<project>/memory/` — language convention, VAT regime, referral-program business rules, import conventions…) and plan-mode files (`~/.claude/plans/*.md`) — some even **referenced from repo docs**. Those references don't survive a clone, a machine change, or another contributor; the knowledge is invisible to anyone but the original machine.

## Decision

**The repo is the only memory.** As a generated-CLAUDE.md convention (full + lean templates):

- All project knowledge lives in the repo (`docs/LEARNINGS.md`, `docs/decisions/`, `PLAN.md`, `CLAUDE.md`).
- Session learnings are written into repo docs, never into agent auto-memory. Agent memory is reserved for **cross-project / personal** facts.
- References to `~/.claude/*` paths are forbidden in repo docs; existing ones must be repatriated.
- A plan-mode file worth keeping is copied into the repo before the session ends.

## Alternatives considered

- **Status quo (agent memory + repo docs coexist)** — rejected: produced real dangling references and machine-locked knowledge on the first audited project.
- **Versioning `~/.claude/projects/<p>/memory/` itself** — rejected: ties the repo to one agent's storage layout, and memory entries are point-in-time observations, not curated docs.

## Consequences

### Positive
- Project knowledge is clonable, reviewable, versioned, and visible to every contributor and every agent/harness — aligned with the post-1.0 multi-harness direction.

### Negative / Tradeoffs
- Slightly more discipline required in sessions (write to docs instead of letting memory accumulate). The CLAUDE.md rule makes the agent enforce it.
