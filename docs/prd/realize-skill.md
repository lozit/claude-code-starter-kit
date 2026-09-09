<!-- generated-by: groundrules v1.11.0 -->
# PRD — /groundrules:realize (the forward bridge: approved plan → partitioned backlog)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — all 5 open questions resolved; ready to build pending go · **Milestone**: M1 loop-readiness (third brick)

## Problem

[Brick 2](loop-scaffolding-bootstrap-adopt.md) laid the loop machinery, but `loop/backlog.md` is
**hand-filled**. There is no guided, safe way to turn an approved plan into a backlog the loop can
execute — and feeding a loop the wrong tasks is the paradigm's sharpest danger: an autonomous loop that
grabs a *decision* or an *exploratory/cross-cutting* task will guess and commit, exactly the over-reach
the maker/verifier back pressure exists to prevent.

`/groundrules:realize` is the **forward crossing** of [ADR 0027 §3](../decisions/0027-reflection-realization-interactive-loop.md):
it takes an **approved** plan (whose output, in plan mode, is otherwise ephemeral) and **persists it
into a partitioned backlog** — classifying each task **`[loop]`** (atomic · isolatable · verifiable ·
invariant-aware · no embedded decision) vs **`[supervised]`** (everything else), and **refusing to tag
`[loop]` anything without a real, re-runnable stop condition**. It is the *reflection-side* twin of the
verifier's back pressure: the gate that decides what an autonomous loop is even allowed to attempt.

## Success criteria

- A new slash-command skill `/groundrules:realize` ingests an approved plan and proposes a
  **partition**: every task labelled `[loop]` or `[supervised]` **with a stated rationale**.
- It **refuses `[loop]` without a verifiable stop condition** — such a task stays `[supervised]` and the
  refusal reason is shown (the load-bearing back pressure).
- **Conservative + explicit**: the default on any doubt is `[supervised]`; the skill **proposes** and
  the user **confirms/vetoes before any write** — it **never auto-promotes** a task to `[loop]`
  (could-act ≠ cleared-to-act, ADR 0027 §4).
- On confirmation it writes the `[loop]` tasks into **`loop/backlog.md`** in the exact loop-safe format
  brick 2's `maker.md` consumes (what · where · acceptance check), **appending/merging** — never a
  silent overwrite — and marks the `[supervised]` tasks in `PLAN.md` without moving them.
- **Preconditions enforced**: requires loop scaffolding (`loop.scaffolded`); if absent it guides the
  user (offer inline generation or point to the bootstrap/adopt opt-in). **Defers when superpowers is
  detected** (consistent with brick 2 — superpowers owns realization).
- No runtime machinery; Markdown skill; English-only; carries the signature.

## Scope

**In scope**
- A new standalone skill `skills/realize/SKILL.md` (`disable-model-invocation: true`; tools
  Read/Write/Bash/AskUserQuestion), with phases:
  - **Phase 0 — preconditions**: superpowers detected → defer (explain, stop); `loop.scaffolded` false
    → guide to opt in (offer inline `loop/` generation reusing brick-2's mapping, or point to
    bootstrap/adopt); else continue.
  - **Phase 1 — ingest the plan**: from a source (see open questions) — a pasted/approved plan, a named
    PRD's *Build plan*, or `PLAN.md` tasks.
  - **Phase 2 — classify** each task against the `[loop]` bar (atomic · isolatable · verifiable ·
    invariant-aware · no decision), reading `CLAUDE.md` → `## Invariants` for awareness; **propose
    decomposition** of a too-big task interactively (don't force — undecomposed → `[supervised]`).
  - **Phase 3 — propose the partition**: per-task label + rationale + the explicit refusal cases; user
    confirms/vetoes (the guard).
  - **Phase 4 — write**: append `[loop]` tasks to `loop/backlog.md` (resume-safe), mark `[supervised]`
    in `PLAN.md`.
  - **Phase 5 — recap**: what was looped, what stayed supervised and why, next step (run the loop).
- README "The workflow" entry; `docs/prd/` is its reflection home; CHANGELOG.

**Out of scope** (explicit)
- **TDD-before-loop gate (brick 4).** Brick 3 requires only that *a verifiable stop condition exists*;
  it does **not** author acceptance tests, enforce writer/verifier separation, or reject a too-weak
  test. Hardening "a stop condition" into "a pre-written acceptance test by someone other than the
  maker, which the verifier may reject as too weak" is **brick 4**. *(The load-bearing boundary — see
  open questions.)*
- **Backward crossing as a skill (brick 5)** — `loop/blocked.md` triage stays a convention.
- **Template refinement (brick 6)**; **running the loop** (brick 2's runner); the **superpowers** case.
- **Auto-execution** — realize only produces the backlog; it never launches the loop.

## Constraints

- **Template over code** (ADR 0002): Markdown instructions; output is the loop-safe task format in
  `loop/backlog.md`, no engine.
- **The guard** (ADR 0027 §4): propose-don't-impose; an explicit confirmation gate before any `[loop]`
  write; conservative default to `[supervised]`.
- **Never overwrite** `loop/backlog.md` / `PLAN.md` silently (append/merge, resume-safe).
- **English-only** (ADR 0012); `disable-model-invocation: true`; carries the `generated-by` signature.
- **AskUserQuestion batching** (our "Don't": group by theme, ≤4 per call).

## Build plan

Ordered steps, each with a validation point.

1. **Confirm the loop-safe task format** brick 2 emits in `loop/backlog.md` (what · where · acceptance
   check). Validate: a realize-produced task is consumed by `loop/maker.md` unchanged.
2. **Write `skills/realize/SKILL.md`** (the phases above). Validate: dry-read against three scenarios —
   no scaffolding, superpowers present, a mixed plan.
3. **README** — add `/groundrules:realize` to "The workflow" (run the skill↔README drift check).
4. **CHANGELOG `[Unreleased]`** + PLAN move (brick 3 → done).
5. **Fresh-subagent E2E**: feed a **mixed** plan — some atomic+verifiable tasks, some decision/
   exploratory, some too-big — and confirm realize (a) loops only the safe ones, (b) refuses the rest
   with a rationale, (c) writes `loop/backlog.md` in the maker-consumable format, (d) leaves
   `[supervised]` in `PLAN.md`, (e) is resume-safe and defers under superpowers. Validate: the looped
   tasks each carry a stop condition; nothing decision-laden slipped into `[loop]`.

## Risks

What could go wrong, and the mitigation.

- **Over-promotion to `[loop]`** (the dangerous failure — an unsafe task gets looped and the loop
  guesses/commits). *Mitigation*: the refusal gate + explicit confirmation + conservative
  default-to-`[supervised]`; the E2E's adversarial mixed plan tests exactly this.
- **Scope bleed into brick 4** (starting to author acceptance tests). *Mitigation*: brick 3 only checks
  "*is there* a re-runnable stop condition?"; authoring/strengthening it is brick 4 — an explicit
  boundary in Scope.
- **Plan-mode output is ephemeral.** *Mitigation*: realize accepts a pasted/approved plan and persists
  it; the skill documents that "plan mode → realize" is the persistence step (the forward crossing).
- **Decomposition rabbit hole.** *Mitigation*: realize *proposes* splits but never forces; an
  undecomposed task stays `[supervised]`.

## Open questions — resolved (2026-06-14)

- **The brick-3 / brick-4 boundary (load-bearing)** → **resolved: yes, that boundary.** Brick 3 ships
  the partition + checks that *a re-runnable stop condition exists*; brick 4 hardens it into TDD back
  pressure (a pre-written acceptance test, writer ≠ maker, verifier-may-reject-too-weak). Keeps brick 3
  shippable and prevents it absorbing brick 4.
- **Input source** → **resolved: support all three** (a pasted/approved plan · a named PRD's *Build
  plan* · `PLAN.md` tasks), ask which at Phase 1; primary = a pasted approved plan or a named PRD.
- **No-scaffolding behaviour** → **resolved: don't hard-fail** — offer inline `loop/` generation (reuse
  brick-2's file mapping) or point to the bootstrap/adopt opt-in.
- **`[supervised]` tasks** → **resolved: tag `[supervised]` in place** in `PLAN.md` (partition visible),
  without moving anything.
- **State in `.groundrules.json`** → **resolved: nothing for V1** (the backlog is the artifact); revisit
  if a later brick needs to know realize ran.
