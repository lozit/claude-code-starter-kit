<!-- generated-by: groundrules v1.11.0 -->
# 0010 — Defer to an existing tool-managed project CLAUDE.md

**Date**: 2026-06-03
**Status**: Accepted

## Context

ADR 0009 handled the case "no project `CLAUDE.md`, but a **global** `~/.claude/CLAUDE.md` exists" (→ lean template + deference note). Examining a real enterprise repo surfaced a different, stronger case: a project `CLAUDE.md` that is **already present and tool-managed**.

The motivating example (a corporate `claude-manager` tool) generates a project `CLAUDE.md` with:
- Explicit **managed-section fences** (`Auto-managed by <manager> … END MANAGED SECTIONS`, "Do not edit this section").
- A stated **policy**: add your own instructions *only* in a designated free zone (`## Project-Specific Notes`, below an "all content below this line is yours" marker).
- Comprehensive content that **already covers** much of what starter-kit's template provides (Conventional Commits, security/`.env`, Keep-a-Changelog, README upkeep, stack, MCP) — and at least one **direct conflict**: it forbids AI attribution (`Co-Authored-By`), which starter-kit's commit guidance adds.

A repo can have only one root `CLAUDE.md`. So when one already exists (especially a managed one), starter-kit generating its own would be a no-op-at-best (resume mode classifies it "foreign → ignore") and an overwrite hazard at worst — and "ignore" wastes the chance to make the managed file *discover* starter-kit's docs.

## Decision

When `bootstrap` (resume) or `adopt` finds a `CLAUDE.md` already present (no starter-kit signature):

1. **Never generate or overwrite** a project `CLAUDE.md`. The existing one is authoritative.
2. **Detect tool-management**: markers like `Auto-managed`, `Do not edit`, a corporate manager name (e.g. `claude-manager`), managed-section fences, or an explicit **free zone** (`END MANAGED`, "below this line is yours", `## Project-Specific Notes`).
3. **Discoverability pointer (opt-in)**: if a free zone is found, offer to **append** (Edit-only, never overwrite) a short pointer to the starter-kit docs (`docs/VISION.md`, `docs/decisions/`, `docs/LEARNINGS.md`, `PLAN.md`) **into that free zone only** — never into managed sections.
4. If **no free zone** is detected (fully managed file) → **skip** writing, report it.
5. Record `adoptedFiles["CLAUDE.md"] = "instructions (managed by <tool>)"`.
6. **Surface, don't resolve, conflicts** between the managed file's rules and starter-kit conventions (e.g. commit attribution).

This case takes **precedence** over ADR 0009's lean logic: a present project `CLAUDE.md` means no generation at all (lean or full).

## Alternatives considered

- **Skip entirely (no pointer)** — safe but the managed `CLAUDE.md` never references starter-kit's docs, so Claude may not discover `docs/VISION.md`/`PLAN.md`. Kept as the automatic fallback when there is no free zone.
- **Append to the file unconditionally** — rejected: many managed files have no safe zone; editing anywhere risks clobbering on the next manager refresh. Only the explicitly-free zone is touched, and only opt-in.
- **Generate a second CLAUDE.md variant (e.g. `CLAUDE.starter-kit.md`)** — rejected: Claude Code only auto-loads `CLAUDE.md`; a side file wouldn't be read, adding clutter for no effect.
- **Merge our sections into the managed file** — rejected: violates the manager's "do not edit managed sections" contract and would be overwritten on refresh.

## Consequences

### Positive
- Zero risk to enterprise-managed instructions (no overwrite, no edit of managed sections).
- The opt-in pointer keeps starter-kit's docs discoverable even when it owns no part of `CLAUDE.md`.
- Honest scoping: in a heavily-managed context, starter-kit's contribution narrows to `docs/` + `PLAN`, and that's made explicit.

### Negative / Tradeoffs
- Free-zone detection is heuristic (marker strings); an unusual manager format may not be recognized → falls back to skip (safe).
- The pointer is plain text appended once; if the user later restructures the free zone it won't auto-update. Acceptable — it's a convenience, not a managed block.

### Neutral
- Surfacing the AI-attribution conflict is advisory; resolving it (e.g. dropping `Co-Authored-By` in that repo) is the user's call.

## Notes

- Implemented in `adopt` (§ "CLAUDE.md projet déjà présent") and referenced from `bootstrap` Phase 5.
- Complements [ADR 0009](0009-global-claude-md-awareness.md) (global, no project file) — this ADR is the project-file-present counterpart.
