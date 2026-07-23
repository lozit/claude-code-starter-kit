<!-- generated-by: groundrules v1.10.0 -->
# PRD — Minimal runnable loop (M1 proof-of-concept)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: ✅ built & validated (2026-06-14) · **Milestone**: M1 loop-readiness (first brick)

> **Outcome**: prototype in `docs/prototypes/loop/`, validated by subagent simulation on the `slugify`
> fixture (good path converges · adversarial green-but-gamed diff REJECTed · under-specified task
> BLOCKED). Verdict + contract fixes in `docs/LEARNINGS.md`. The three open questions below were
> resolved with their leans. **Next brick**: wire opt-in scaffolding into `bootstrap`/`adopt`.

## Problem

[ADR 0027](../decisions/0027-reflection-realization-interactive-loop.md) sets *loop-readiness* as a
direction, but the **riskiest unknown** is not "can `bootstrap` write files" — it's **does the
maker/verifier loop pattern actually produce good work?** Building generated loop scaffolding into
`bootstrap`/`adopt` before answering that would be productizing an unproven core.

So: build a **minimal runnable loop** and validate the *contract* on a fixture **first**, in
isolation. Prove the pattern, then (later PRDs) wire it into the plugin.

## Success criteria

- A minimal, coherent loop **prototype** exists in the repo (not yet generated into user projects):
  a `maker` prompt, a `verifier` prompt, a `LOOP.md`, a capped runner, and the `blocked.md` convention.
- A **simulated** maker→verifier cycle on a fixture greenfield task (with a **pre-written acceptance
  test**) demonstrably: (a) converges — maker produces code, verifier passes it once the test is green;
  (b) **catches a deliberately-broken maker output** — the verifier rejects a diff that doesn't satisfy
  the test or the spec (distrust-the-report works); (c) **parks a decision** in `blocked.md` rather
  than guessing.
- The runner enforces a **hard iteration cap** (reviewable; no runaway).
- **No runtime machinery** beyond a shell runner; all loop logic is Markdown prompts (ADR 0002/0025).
- A **verdict captured** (`docs/LEARNINGS.md` or a decision): does the pattern work well enough to
  productize, and what to change before wiring it into `bootstrap`/`adopt`?

## Scope

**In scope**
- **Prototype artifacts** in a clearly-marked not-yet-shipped location (e.g. `docs/prototypes/loop/`):
  - `maker.md` + `verifier.md` — the **verifier/maker contract** (`docs/LEARNINGS.md`): two-stage
    ordered review (spec-compliance THEN quality), **distrust the maker's self-report / re-derive from
    the diff**, **evidence-before-claim** gate, maker **4-status protocol** (DONE / DONE_WITH_CONCERNS
    / BLOCKED / NEEDS_CONTEXT).
  - `LOOP.md` — the fixed prompt replayed each iteration: read state (todo, lessons, git) → take the
    first ready task → maker → verifier → on green, commit + check off; on BLOCKED, write `blocked.md`
    and move on.
  - a capped runner (`run-loop.sh`) — the shell loop with a mandatory `MAX` iteration ceiling and a
    `DONE`/empty-backlog stop.
  - the `blocked.md` convention (what the loop writes when it can't verify its way out).
- A **fixture** greenfield task + a **pre-written acceptance test** to validate against.
- **Validation by subagent simulation** (like our skill E2Es): a maker subagent implements the
  fixture task; a verifier subagent reviews it — run both the *good* path and a *deliberately-broken*
  path. (A live `claude -p` shell loop is the eventual artifact; a full live run is optional / the
  user's to try — see Open questions.)
- The **verdict** + any contract fixes the simulation surfaces.

**Out of scope** (explicit)
- **Wiring into `bootstrap`/`adopt`** as opt-in generated scaffolding (the *next* PRD).
- **`/groundrules:realize`** (the plan→backlog bridge) — later; this PRD hand-writes the fixture todo.
- TDD-gating logic *in realize* — later; here the acceptance test is simply hand-written up front
  (demonstrating the principle).
- The backward-crossing **as a skill** — here it's just the `blocked.md` convention.
- The **superpowers** case (superpowers already is a loop pipeline) — this is the non-superpowers
  minimal loop.

## Constraints

- **Template over code** (ADR 0002): prompts are Markdown; the only executable is the shell runner.
- **No runtime hooks / opinionated config** (ADR 0025).
- **Propose, don't impose** — borrow superpowers' *structure*, never its coercive register; no
  mandatory-TDD as a global rule (the acceptance test is the loop regime's back pressure only).
- **Iteration cap is mandatory** — the anti-runaway safety, not an option.
- English-only; carry the `generated-by` signature on prototype docs.

## Build plan

Ordered steps, each with a validation point.

1. **Draft `maker.md` + `verifier.md`** (the contract). Validate: a fresh reader can run each role
   from the prompt alone; the verifier prompt explicitly distrusts the maker report.
2. **Draft `LOOP.md` + `run-loop.sh`** (capped). Validate: the runner has a hard cap and a clear
   stop condition; `LOOP.md` reads state → one task → maker → verifier → commit/park.
3. **Create the fixture** (a tiny greenfield task, e.g. a pure function) + its **pre-written
   acceptance test**. Validate: the test fails before any code (red).
4. **Simulate the loop** with subagents — good path: maker implements → verifier passes once test is
   green. Validate: convergence + a real commit-worthy diff.
5. **Adversarial run** — feed the verifier a deliberately-broken maker output. Validate: the verifier
   **rejects** it (catches the gap), doesn't rubber-stamp.
6. **Decision/BLOCKED path** — give the fixture an ambiguous sub-choice. Validate: the loop writes
   `blocked.md` instead of guessing.
7. **Capture the verdict** in `docs/LEARNINGS.md` (+ contract fixes); note what must change before
   productizing.

## Risks

- **Plausible-but-wrong work the verifier misses.** Mitigation: the distrust-the-report framing +
  the explicit adversarial run (step 5) is the test of exactly this.
- **Token/⏱ cost of a live loop.** Mitigation: validate via subagent simulation here; the live shell
  loop is provided but its full run is gated by a hard iteration cap and left to the user.
- **Over-building the prototype.** Mitigation: minimal by design — one fixture, one task, the
  smallest contract that exercises convergence + rejection + block.

## Open questions — resolved

- **Prototype location** → **resolved: `docs/prototypes/loop/`** for the artifacts (marked not-shipped
  in its `README.md`) + a `/tmp` copy of `fixture/` for each run. As leaned.
- **Validation depth** → **resolved: subagent simulation now** (proved the contract across all three
  paths); the live `claude -p` run is provided via `run-loop.sh` and documented as a user-runnable step,
  gated by the hard `MAX` cap. As leaned.
- **Fixture task choice** → **resolved: `slugify(text)`** — a self-contained pure function with a crisp
  pre-written acceptance test, plus a deliberately under-specified `max_length` task to exercise the
  block path. As leaned.

> One finding promoted a *downstream* open question (tracked in ROADMAP M1) to a requirement: the
> verifier must be able to **reject a too-weak test** — the adversarial path proved a green test alone
> rubber-stamps a gamed diff. See `docs/LEARNINGS.md`.
