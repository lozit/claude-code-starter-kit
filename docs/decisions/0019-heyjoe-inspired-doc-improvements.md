<!-- generated-by: groundrules v1.10.0 -->
# 0019 — Doc improvements harvested from a real project (crm-heyjoe)

**Date**: 2026-06-06
**Status**: Accepted

## Context

The crm-heyjoe repo evolved its own documentation organization over a real multi-month project, independently of groundrules. Several of its patterns are better than the generated templates — the dogfood feedback loop in action. Analysis date: 2026-06-06.

## Decision

Harvest four patterns into the templates (plus two micro-improvements):

1. **LEARNINGS = rules, not a journal** (`LEARNINGS.md.tpl`): each entry is an actionable rule with **Why** (the story + what it cost) and **When to apply** (trigger conditions), plus the minimal fix snippet. Inspired by heyjoe's `tasks/lessons.md`, which proved the format in practice.
2. **Session-start reading protocol** (`CLAUDE.md.tpl` + lean): an ordered "read first" list — PLAN → LEARNINGS → VISION → artifacts of the work in progress. The highest-leverage instruction a CLAUDE.md can carry.
3. **`docs/PROCESS.md`** (new optional template): the working-method contract — phases, validation gates, interview style. Inspired by heyjoe's `specifications/process.md`. A method contract is literally a "ground rule"; the plugin now has a slot for it.
4. **`RELEASE.md`** (new optional template, root, next to CHANGELOG): the operational runbook — TL;DR commands, environments table, pre-release checklist, secrets, rollback, known fragilities. Offered only when the project deploys. Inspired by heyjoe's `RELEASE.md`.

Micro-improvements: PLAN template gains a **status vocabulary** (`[~]` in review; annotate reverts/commits); intake README states **read-only + binaries welcome** (heyjoe's `specifications/` validated both).

New placeholders `{{HAS_PROCESS}}` / `{{HAS_RELEASE}}`; wired into bootstrap Call 2b, adopt Call 3b, verify-bootstrap whitelist, README, living-docs list.

## Alternatives considered

- **Per-feature artifact folders** (heyjoe's `phase3/<page>-{cahier,data}.md`) — not harvested: per-feature altitude is superpowers' territory (cf. the interop note, ADR 0007 era); groundrules stays at project altitude. PROCESS.md documents *where* per-phase artifacts live instead.
- **ui-conventions.md as a separate template** — not harvested: it's a project-specific operational pattern library; DESIGN_SYSTEM.md already covers the slot at template level.

## Consequences

### Positive
- Templates now encode practices proven on a real project rather than theoretical structure.
- PROCESS/RELEASE close two real gaps (method contract, ops runbook) without bloating the default set (both optional).

### Negative / Tradeoffs
- Two more optional docs in the Call 2b/3b lists (now 7) — the multiSelect stays manageable; revisit if the list keeps growing.
