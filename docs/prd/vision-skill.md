<!-- generated-by: groundrules v1.10.0 -->
# PRD — /groundrules:vision (interactive VISION builder)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-13 · **Status**: validated

## Problem

A strong `docs/VISION.md` (goal, users, constraints, non-goals, acceptance criteria) is the
anchor every other doc and decision hangs from — but today it's only produced as a side-effect of
`bootstrap`'s **optional** intent capture, and:
- **`adopt`/brownfield projects** frequently have **no VISION at all** (adopt doesn't run a deep
  intent interview).
- When a VISION *is* generated, a quick paste or a half-filled template yields a **thin, low-value**
  vision that nobody deepens.

There is no **on-demand, guided** way to build — or refresh — a genuinely strong vision. That gap
is what `/groundrules:vision` fills.

## Success criteria

- Running `/groundrules:vision` in a project with **no** `docs/VISION.md` produces one with **every
  section meaningfully filled from the interview** — no `<fill in>` left in a section the user
  answered.
- Running it with an **existing** `docs/VISION.md` offers to **refine/refresh section by section**
  and **never overwrites silently** (skip / overwrite / save-as-`.new`).
- The interview is **bounded** (grouped `AskUserQuestion`, ≤ ~4 questions per call, by theme — not
  one giant prompt) and a user can answer "to be defined" for any item.
- `bootstrap` is **unchanged** — zero regression.
- The output uses the **existing VISION structure** (no new doc shape to learn).

## Scope

**In scope**
- A new standalone skill `skills/vision/SKILL.md` (`disable-model-invocation: true`; tools
  Read/Write/Bash/AskUserQuestion), **on-demand** — for adopt/brownfield projects without a vision,
  and to deepen/refresh a thin one.
- **Create-if-absent / refine-if-present** behavior (resume mode: skip/overwrite/`.new`).
- A **guided interview** filling the existing VISION template structure (Goal · Users/personas ·
  Constraints · V1 non-goals · Acceptance criteria), reusing `VISION.md.tpl`.
- **Borrow superpowers' interview principles** (`docs/LEARNINGS.md`), adapted to our mechanism:
  propose **2-3 framings with a recommendation** at key choices; **decompose an over-scoped**
  project (flag it, suggest splitting) rather than writing a vision for an unbounded blob; run a
  **"vision self-review"** before writing (placeholder / internal-consistency / ambiguity scan).
- README "The workflow" entry + `docs/prd/` is its reflection home.

**Out of scope** (explicit)
- **No `bootstrap` refactor** — bootstrap keeps its own intent capture; delegation
  (bootstrap → `/vision`) is a *possible later* DRY move, not V1.
- **No new VISION structure** — reuse the existing template sections.
- Not a replacement for `bootstrap`'s intent capture, nor for `adopt`.
- No runtime machinery; no coercive "you must" register (handoff-not-gospel) — borrow superpowers'
  *structure*, not its tone.

## Constraints

- **Template over code** (ADR 0002): the skill is Markdown instructions; the output is the plain
  `VISION.md.tpl` filled by substitution.
- **English-only** output (ADR 0012); `disable-model-invocation: true` (slash-command only).
- **AskUserQuestion batching** (our "Don't": no single giant question — group by theme, 3-4 max).
- **Never overwrite** without confirmation (resume mode).
- Carry the `generated-by` signature; keep it consistent at release.

## Build plan

Ordered steps, each with a validation point.

1. **Confirm the VISION template** is reusable as-is (`skills/bootstrap/templates/VISION.md.tpl`):
   read it, list its sections/placeholders. Validate: the interview maps 1:1 to its placeholders.
2. **Write `skills/vision/SKILL.md`** — Phase 1 detect existing VISION (absent → create flow;
   present → refine/refresh flow, skip/overwrite/`.new`); Phase 2 grouped interview (Goal · Users ·
   Constraints · Non-goals · Acceptance), with the 2-3-framings-+-recommendation and over-scope
   decomposition moves; Phase 3 vision self-review (placeholder/consistency/ambiguity) then write;
   Phase 4 recap. Never commit. Validate: dry-read against the absent and present scenarios.
3. **README** — add `/groundrules:vision` to "The workflow" (run the skill↔README drift check).
4. **CHANGELOG `[Unreleased]`** + PLAN move (Up next → done).
5. **E2E** — run the new skill in /tmp on (a) a project with no VISION, (b) one with a thin VISION →
   confirm create + refine flows, no silent overwrite, no leftover `<fill in>` in answered sections.
   Validate: verify-bootstrap stays clean.

## Risks

What could go wrong, and the mitigation.

- **Overlap/confusion with `bootstrap`'s intent capture.** Mitigation: scope it explicitly as
  on-demand deepen/refresh + adopt-gap filler; the skill's own preamble states it complements, not
  replaces, bootstrap.
- **Interview too long / heavy.** Mitigation: grouped `AskUserQuestion` (≤4/theme), every item
  skippable as "to be defined", synthesize don't transcribe.
- **New skill dir → needs a full Claude Code restart** to register (our LEARNINGS). Mitigation:
  flag it in the recap.
- **Borrowing superpowers' tone, not just structure.** Mitigation: keep our register (propose,
  don't impose); no `<HARD-GATE>`.

## Open questions

<!-- Resolved 2026-06-13 before building. -->
- ~~Seed `intake/INTENT.md` too?~~ → **Resolved: no.** `/vision` stays on `docs/VISION.md`; raw
  intent capture remains `bootstrap`'s job (the skill points there).
- ~~"Refine existing" flow shape?~~ → **Resolved: section-by-section** diff-and-confirm (least
  destructive); never a silent regenerate.
- Template confirmed: reuses `docs-VISION.md.tpl` as-is (placeholders `{{PROJECT_NAME}}`,
  `{{INTENT_SOURCE}}`, `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}`, `{{ACCEPTANCE}}`).
