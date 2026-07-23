<!-- generated-by: groundrules v1.10.0 -->
# PRD — Template refinement: route work by regime in the generated CLAUDE.md

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — both open questions resolved on their leans; ready to build · **Milestone**: M1 loop-readiness (sixth brick — last before release)

## Problem

The generated `CLAUDE.md` still says, flatly, *"Plan mode before any non-trivial task."* That predates
the reflection/realization model M1 built ([ADR 0027](../decisions/0027-reflection-realization-interactive-loop.md)),
whose explicit consequence is to **sharpen that single bullet into a regime-routing triad**: a
*decision* → an ADR; an *interactive, non-trivial* change → plan mode; an *atomic/testable/isolatable*
task → spec + loop. With bricks 1–5 in place (loop scaffolding, `realize`, the TDD gate, the triage
convention), the generated `CLAUDE.md` should finally **teach the user the model the rest of M1
implements** — know your phase, know your regime, cross the frontier deliberately.

## Success criteria

- The generated `CLAUDE.md` "Claude Code workflow" guidance **routes by kind of work** instead of a flat
  "plan mode for everything non-trivial": a **decision/fork** → an ADR (`add-adr`) before acting; an
  **interactive, non-trivial** change → **plan mode**; a **non-trivial feature** → a PRD (`prd`) first.
- Projects with loop scaffolding additionally see the **loop route**: an **atomic/testable/isolatable**
  task → `/groundrules:realize` → the loop (with the TDD gate). Non-loop projects stay lean (no dangling
  reference to machinery they don't have).
- **Consistent** with the loop docs already shipped (loop/README.md "loops fit atomic/testable/isolatable
  work"; realize's `[loop]` bar) — no contradiction, no duplication of detail (CLAUDE.md points; the loop
  docs hold).
- Reverses nothing for trivial work; `bootstrap`/`adopt` generation and the content-aware tailoring keep
  working. README/CHANGELOG synced. Last brick before the M1 release.

## Scope

**In scope**
- **`CLAUDE.md.tpl`** "## Claude Code workflow" — replace the flat "plan mode before any non-trivial
  task" bullet with the regime triad (decision → ADR · interactive non-trivial → plan mode · feature →
  PRD), keeping the existing `/compact`, `/clear`, worktrees, custom-skills, delegation bullets.
- The **loop route** line (atomic/testable → `realize` → loop) — placement decided in open questions
  (inline-conditional vs loop-conditional insertion).
- A consistency pass so the wording matches `loop/README.md` and `realize`.
- README (justification row if a posture is reframed) + CHANGELOG; PRD is the reflection home.

**Out of scope** (explicit)
- **No new skill, no new doc, no runtime.** A wording refinement of one template section.
- **No change to `realize` / the loop templates' behaviour** — only the CLAUDE.md guidance that points
  at them.
- The **M1 release** itself (signatures sweep, version bump, tag) — the *next* step after this brick,
  done as its own pass.
- The superpowers interop note (already handled elsewhere).

## Constraints

- **Template over code** (ADR 0002); **CLAUDE.md stays lean** (ADR 0024) — the refinement must not grow
  the section meaningfully; it replaces one bullet with a tighter routing list.
- **Content-aware tailoring** (ADR 0029): "## Claude Code workflow" is a collapsible section (omitted if
  the global covers it) — bias-to-keep applies; the regime triad is groundrules' signature method.
- **Handoff-not-gospel**: the triad guides; the user edits it. **English-only**; signature consistent.

## Build plan

Ordered steps, each with a validation point.

1. **Refine `CLAUDE.md.tpl`** "## Claude Code workflow" → the regime triad + the loop route (per the
   open-question decision). Validate: a fresh read routes the four work-kinds correctly; the section is
   no longer than before; trivial work is untouched.
2. **Consistency pass**: align wording with `loop/README.md` Boundaries and `realize`'s bar; ensure a
   non-loop CLAUDE.md has no dangling loop reference. Validate: grep for contradictions.
3. **README / CHANGELOG / PLAN**. Validate: justification/skill-list drift clean.
4. **Fresh-subagent E2E**: generate a CLAUDE.md **with** loop opted in and **without**, and check each
   shows the right routing (loop route present only when scaffolded; the base triad always; lean
   preserved). Validate: no leftover "plan mode before any non-trivial task" flat phrasing; no dangling
   loop reference in the non-loop output.

## Risks

What could go wrong, and the mitigation.

- **CLAUDE.md bloat** from a longer workflow section. *Mitigation*: it *replaces* a bullet, not adds a
  section; the loop route is one conditional line; slim-aware.
- **Dangling loop reference in non-loop projects.** *Mitigation*: the open-question decision (inline-
  conditional wording or conditional insertion) ensures non-loop output never points at absent `loop/`.
- **Over-prescription** (reads as a mandate). *Mitigation*: keep the handoff-not-gospel register — it's
  routing guidance the user edits, not a gate.

## Open questions — resolved (2026-06-14, on their leans)

- **Loop route placement** → **resolved: an inline-conditional one-liner** always present in
  CLAUDE.md.tpl ("…and if this repo has `loop/` scaffolding, route atomic/testable/isolatable tasks
  through `/groundrules:realize`") — no new insertion machinery, advertises the loop option, degrades
  gracefully for non-loop projects (one conditional clause is acceptable; the brick-2
  conditional-insertion was justified by a whole multi-line section).
- **Keep "## Claude Code workflow" collapsible** → **resolved: yes** — bias-to-keep already protects it;
  don't expand the tailoring logic for one section.
