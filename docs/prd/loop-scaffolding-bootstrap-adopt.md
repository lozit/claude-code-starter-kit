<!-- generated-by: groundrules v1.11.0 -->
# PRD — Loop scaffolding, opt-in in `bootstrap`/`adopt` (M1 brick 2)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — all 5 open questions resolved ([ADR 0030](../decisions/0030-loop-namespace-and-backlog.md) for the 2 structural ones); ready to build pending go · **Milestone**: M1 loop-readiness (second brick)

## Problem

[Brick 1](loop-minimal-runnable.md) proved the maker/verifier loop **contract** on a fixture, in
isolation under `docs/prototypes/loop/` — converge / reject-the-gamed-diff / park-don't-guess all held
([verdict in `docs/LEARNINGS.md`](../LEARNINGS.md)). But that prototype is **not generated into user
projects** and **not wired into `bootstrap`/`adopt`**. A groundrules repo is therefore still only
executable interactively — the loop-readiness surface ADR 0027 §5 calls for does not exist yet.

Brick 2 **productizes the proven contract**: an **opt-in, once-per-project** choice in
`bootstrap`/`adopt` that lays down the loop scaffolding (maker/verifier prompts, `LOOP.md`, a capped
runner, the `blocked.md` convention, an `## Invariants` section in the generated `CLAUDE.md`) — carrying
forward the three contract fixes brick 1 surfaced, and **deferring to superpowers** when it is present.
It does **not** yet build the backlog that feeds the loop (`/groundrules:realize`, brick 3) nor gate on
a TDD acceptance test (brick 4); it only puts the validated machinery on disk so a project *can* be
looped.

## Success criteria

- **Both `bootstrap` and `adopt` offer an opt-in** "generate loop scaffolding" choice — **off by
  default**, once per project, framed propose-don't-impose (a one-line *why*, no coercive register).
- When enabled, generation produces, **all from `{{KEY}}` templates** (ADR 0002), each carrying the
  `generated-by` signature, English-only:
  - `maker` + `verifier` prompts (the contract), `LOOP.md` (per-iteration replay), a **capped** runner
    with a mandatory `MAX` ceiling, and the `blocked.md` convention (the backward crossing);
  - an **`## Invariants`** section in the generated `CLAUDE.md` (what the loop must never break).
- **The three brick-1 contract fixes are baked into the templates**: (1) the verifier runs as a
  **separate subagent / fresh context**; (2) the verifier **may reject a too-weak test** (a green test
  that doesn't constrain the diff); (3) the commit step **stages the intended diff, never `git add -A`**,
  and a `.gitignore` ships with the scaffolding.
- **Defer to superpowers**: when superpowers is detected, the option is **not generated** (the whole
  realization pipeline is superpowers'); the recap states *why*.
- **State + idempotence**: `.groundrules.json` records that loop scaffolding was generated; re-running
  is resume-safe (skip / overwrite / `.new`, never a silent overwrite — plugin-meta rule).
- **Docs synced**: README `## What's generated` + workflow updated (mechanical drift check), an **ADR**
  for the structural decision (where the artifacts live; what backlog the loop reads), CHANGELOG
  `[Unreleased]`.
- **Validated by a fresh-subagent E2E** (not just the dogfood): an agent that did not write the code
  bootstraps a fixture project with the loop option on (+ a resume pass) and the files are placed,
  substituted, mutually consistent, and resume-safe.

## Scope

**In scope**
- **New templates** under `skills/bootstrap/templates/loop/`, derived from the validated prototype
  (`docs/prototypes/loop/`) with the 3 fixes already applied, generated into the project's **`loop/`**
  namespace (ADR 0030): `maker.md.tpl`, `verifier.md.tpl`, `LOOP.md.tpl`, `run-loop.sh` (plain file
  unless it needs placeholders), `backlog.md` (loop-safe tasks; hand-fill instructions for now),
  the `blocked.md` convention doc, and a `loop/.gitignore`.
- **`CLAUDE.md.tpl`** gains an **`## Invariants`** section **conditional on the loop opt-in** (fillable;
  minimal, slim-aware) — not emitted for non-loop projects.
- **`bootstrap`**: a **dedicated opt-in question** (off by default, with a one-line *why*), a
  conditional `HAS_LOOP=true` file-mapping block, the `.groundrules.json` flag, and the
  superpowers-defer guard (**when superpowers is detected the question is not asked**).
- **`adopt`**: the same opt-in in Call 3b (optional/specialized docs, *always asked*), missing-only
  generation, resume-safety.
- **README** (`## What's generated`, `## The workflow` if a surface changed; justification rows only if
  a new posture is introduced) + **CHANGELOG** + **one ADR** for the structural decision.
- The generated `loop/LOOP.md` explains, **in the absence of `realize`**, that the loop reads
  `loop/backlog.md` and how to hand-fill it for now (later auto-filled by `realize`, brick 3).

**Out of scope** (explicit)
- **`/groundrules:realize`** (brick 3) — the forward bridge that produces the partitioned `[loop]` vs
  `[supervised]` backlog. Brick 2 lays the machinery; brick 3 fills the backlog.
- **TDD-before-loop gate** (brick 4) — gating `[loop]` on a pre-written acceptance test.
- **Backward-crossing as a skill** (brick 5) — here it stays the `blocked.md` convention only.
- **Template refinement** of "plan mode before non-trivial" (brick 6).
- **Harness neutrality of the runner** (M2) — the generated `run-loop.sh` targets Claude Code
  (`claude -p`); it is clearly marked as such.
- A guaranteed **live loop run** — the runner is provided and gated by the hard `MAX` cap; running it
  is left to the user (as in brick 1).

## Constraints

- **Template over code** (ADR 0002): plain `{{KEY}}` substitution; the only executable is the shell
  runner. No template engine, no application logic in skills beyond the Markdown instructions.
- **No runtime hooks / opinionated config** (ADR 0025): the scaffolding is **opt-in and post-hoc**, not
  a runtime guard; it changes nothing about how the harness behaves until the user runs the loop.
- **Propose, don't impose**: off by default; borrow superpowers' *structure*, never its coercive
  register; no mandatory-TDD as a global rule.
- **Idempotence / resume** (plugin-meta rule): detect what exists, offer skip/overwrite/`.new`.
- **English-only**; every generated file carries the `generated-by` signature.
- **CLAUDE.md stays lean** (<200 lines, ADR 0024): the `## Invariants` section must be minimal and
  fillable, and not trip `/groundrules:slim`.
- **Dogfood stays honest**: this repo is the non-superpowers case; if we generate the scaffolding into
  groundrules itself, it must coexist with the existing `docs/prototypes/loop/` (prototype = source of
  truth) without confusion.

## Build plan

Ordered steps, each with a validation point.

1. **Port the prototype to templates** under `skills/bootstrap/templates/loop/`, with the 3 contract
   fixes already in. Validate: a diff against `docs/prototypes/loop/` is *only* the `{{KEY}}`
   placeholders + the fixes; a fresh reader can run each role from the template alone.
2. **Structure decided** — [ADR 0030](../decisions/0030-loop-namespace-and-backlog.md) (accepted): a
   visible top-level `loop/` namespace; the loop reads `loop/backlog.md`, `PLAN.md` only points to it.
3. **Add the `## Invariants` section** to `CLAUDE.md.tpl` (conditional on the loop opt-in; fillable).
   Validate: the section stays within the line budget; `slim` does not flag it; placeholders are
   `<fill in>`, no fabricated invariants.
4. **Wire `bootstrap`**: the opt-in question, the `HAS_LOOP=true` conditional mapping, the
   `.groundrules.json` field, and the superpowers-defer guard. Validate: the option is off by default;
   with superpowers present it is not offered and the recap says why.
5. **Wire `adopt`**: the opt-in in Call 3b, missing-only generation, resume-safety. Validate: a resume
   run writes `.new` and leaves the originals intact.
6. **Sync docs**: README (`## What's generated` row + any workflow line), CHANGELOG `[Unreleased]`.
   Validate: `ls skills/bootstrap/templates/loop/` ↔ README "what's generated" drift = 0.
7. **Fresh-subagent E2E** (brick-1 lesson): an agent who did not write the code bootstraps a `/tmp`
   fixture with the loop option on, then re-runs (resume). Validate: files placed + substituted (no
   stray `{{KEY}}`), the verifier template mandates a separate subagent, the runner has the `MAX` cap
   and stages-not-`git add -A`, `.gitignore` present, resume writes `.new`. Capture frictions →
   fix + a LEARNINGS entry if non-trivial.

## Risks

What could go wrong, and the mitigation.

- **Inert scaffolding without `realize`.** We lay files nothing feeds, so the user doesn't know how to
  use them. *Mitigation*: `loop/backlog.md` ships with hand-fill instructions, and the opt-in copy says
  "most useful once `/groundrules:realize` lands (brick 3)" (ADR 0030).
- **Root/clutter overload.** Loop tooling pollutes the project root. *Mitigation*: a single dedicated
  `loop/` dir (ADR 0030, consistent with `intake/`); off by default; no extra root-level files (state
  lives under `loop/`).
- **Template ↔ prototype drift.** The shipped templates and `docs/prototypes/loop/` diverge over time.
  *Mitigation*: name the prototype as the reference in the templates' header; a note in the meta
  `CLAUDE.md` to bump both together (same "sweep the skills that read/write a format" lesson).
- **Runner is Claude-Code-specific** — breaks the harness-neutral promise the name implies.
  *Mitigation*: mark `run-loop.sh` explicitly as the Claude Code delivery; M2 owns portability.
- **CLAUDE.md bloat** from `## Invariants`. *Mitigation*: minimal, fillable, conditional on opt-in;
  slim-aware.
- **Productizing a still-thin contract.** The contract was validated by *simulation*, not a live loop.
  *Mitigation*: brick 1's verdict said "good enough to productize"; keep the live run user-gated; revisit
  if the E2E surfaces contract gaps.

## Open questions

<!-- Anything still ambiguous — resolve before building. Delete when empty. -->

**Resolved** (2026-06-14):
- **Artifact location + backlog** → settled together in **[ADR 0030](../decisions/0030-loop-namespace-and-backlog.md)**:
  a single visible top-level **`loop/`** is the loop's namespace (prompts + runner + `loop/backlog.md`
  + `loop/blocked.md` + optional `loop/lessons.md` + `.gitignore`). The loop reads **`loop/backlog.md`**
  (loop-safe tasks only; hand-filled now, `realize`-filled later), **never `PLAN.md` directly**;
  `PLAN.md` carries a one-line pointer to it and does not duplicate. The loop owns `loop/`; the human
  owns `PLAN.md`.
- **Opt-in placement** → **a dedicated question** (off by default, with its own one-line *why*) — the
  scaffolding is heavier than a doc and deserves its own framing, not a checkbox lost in the
  specialized-docs multiSelect.
- **`## Invariants` always-present vs conditional** → **conditional on the loop opt-in**. Without a loop
  the invariants have no enforcement (the verifier is what replays them); a fillable section in a
  non-loop project is inert text that `slim` would flag, and Conventions/Don't already cover the
  interactive case. Reversible — widen later if demand appears, cheaper than shipping bloat and clawing
  it back.
- **superpowers detected** → **don't offer at all** (consistent with "defer the whole realization");
  the recap states why (superpowers already is a maker/verifier pipeline; groundrules contributes the
  memory layer above).
