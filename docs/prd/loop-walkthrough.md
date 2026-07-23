<!-- generated-by: groundrules v1.10.0 -->
# PRD — Loop walkthrough + validation suite (show how to use the loop on a fresh project)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — forks resolved (shell harness + SCENARIOS-as-walkthrough · subagent-sim + live documented) + 3 open questions on their leans; ready to build · **Milestone**: post-M1 (loop adoption / demonstrability)

## Problem

M1 shipped the whole loop (scaffolding · `realize` · TDD gate · triage), validated **brick by brick**
by ad-hoc subagent E2Es. But there is **no single artifact that shows a newcomer how to actually use
the loop end-to-end on a fresh project** — empty folder → `bootstrap` (loop opt-in) → `/groundrules:realize`
→ `run-loop.sh` → watch it converge, commit, check off → hit a `BLOCKED` → triage. Nor a repeatable way
to confirm the loop still behaves. The **primary goal is demonstrability** — *show how to use it* — with
the series doubling as a validation suite.

## Success criteria

- A **runnable walkthrough** (`test/loop/WALKTHROUGH.md`) takes a reader from an **empty folder to a
  working loop**, with the **exact commands** and the **expected artifact/output at each step**. Someone
  who has never seen the loop can follow it and end with a real commit the loop produced.
- It demonstrates the **five behaviours that matter**, each with an expected outcome: (1) **converge**
  (maker DONE → verifier PASS → commit + check-off), (2) **reject a gamed diff**, (3) **park a decision**
  (`blocked.md` + `Resolution: (open)`), (4) the **TDD gate** (`realize` refuses `[loop]` without a red
  test, authors one), (5) **triage** the block (route + close the `Resolution:` line).
- A **deterministic** `validate-runner.sh` proves the runner's safety **without an LLM** — by stubbing
  `claude` with a canned-output script: the `MAX` cap stops a never-`DONE` loop, a `DONE: backlog empty`
  stops early, one iteration = one fresh invocation. Repeatable, CI-able, zero tokens.
- **Honest about the LLM layer**: the walkthrough labels which steps are deterministic (the runner, file
  assertions) vs which need an agent / tokens (bootstrap, realize, the maker/verifier prompts), and
  offers the behavioural steps as **subagent-simulated** (replayable by us) with the **live `claude -p`
  run documented as opt-in** (gated by `MAX`).
- Self-contained **fixtures** (a `slugify` task + its red acceptance test; a small mixed plan) so the
  walkthrough reproduces identically.

## Scope

**In scope** (a new top-level `test/loop/`)
- **`WALKTHROUGH.md`** — the narrated end-to-end usage demo: each step = a command + what you should see
  + (where checkable) the artifact to verify. The centerpiece (this is "how to use it").
- **`validate-runner.sh`** — the deterministic layer: a stub `claude` emitting scripted maker/verifier
  output, asserting `run-loop.sh`'s `MAX` cap, `DONE` stop, and per-iteration freshness; plus static
  assertions on a generated `loop/` (files present, runner executable, no stray `{{KEY}}`).
- **`fixtures/`** — the `slugify` greenfield task + pre-written **red** acceptance test, and a small
  mixed plan for the `realize` step.
- A short pointer from the README (and/or `docs/prototypes/loop/README.md`) to the walkthrough.

**Out of scope** (explicit)
- **A `/groundrules:verify-loop` skill** — not now (script + doc first; a skill only if it earns it).
- **Mandatory live `claude -p` runs** / CI wiring — the live run is documented opt-in; CI is a later call.
- **Testing `bootstrap`/`realize` internals** beyond asserting their *outputs* (they are LLM-driven; we
  validate artifacts, not token-by-token behaviour).
- Re-deriving the per-brick E2Es — this consolidates them into one usage-shaped series, doesn't replace
  the LEARNINGS already captured.

## Constraints

- **The skills are agent-driven** — there is no `bootstrap`/`realize` CLI; the walkthrough's agent steps
  are run by Claude (interactively or simulated), only `run-loop.sh` and the assertions are pure shell.
- **Template over code / no runtime** (ADR 0002/0025): the deterministic harness is a thin shell test of
  the one executable (`run-loop.sh`); no new runtime in the plugin.
- **English-only**; carry the `generated-by` signature; keep the walkthrough copy-pasteable.

## Build plan

Ordered steps, each with a validation point.

1. **`validate-runner.sh` + a `claude` stub** — deterministic runner tests (MAX cap; `DONE` stop;
   iteration count). Validate: the script passes against the shipped `run-loop.sh` and fails if the cap
   is removed (a real test, not a tautology).
2. **Fixtures** — `slugify` task + red acceptance test (assert red before code); a small mixed plan.
   Validate: the acceptance test exits non-zero before implementation.
3. **`WALKTHROUGH.md`** — the narrated path (empty folder → bootstrap loop → realize → run → converge →
   block → triage), each step with command + expected outcome, labelled deterministic vs agent-driven.
   Validate: a fresh reader can follow it without prior loop knowledge.
4. **README pointer** + CHANGELOG. Validate: discoverable; drift checks clean.
5. **Validate the walkthrough by replay** — a fresh subagent executes `WALKTHROUGH.md` end-to-end on a
   `/tmp` project (the behavioural steps simulated). Validate: it reaches a real loop-produced commit,
   the block path writes `blocked.md`, and `validate-runner.sh` passes — i.e. the demo actually works as
   written. Capture any gap.

## Risks

What could go wrong, and the mitigation.

- **Non-determinism makes the walkthrough look broken** (a live maker phrasing differs from the doc's
  expected output). *Mitigation*: phrase expected outcomes as **invariants** ("the test goes green and a
  commit appears", "`blocked.md` gains a section"), not exact transcripts; pin only the deterministic
  layer to exact output.
- **The demo rots** as the loop evolves. *Mitigation*: `validate-runner.sh` + the replay step are the
  guard; run them before a release that touches the loop (a `checkpoint`/release hook).
- **Reader needs tokens/CLI they don't have.** *Mitigation*: the deterministic layer needs neither; the
  agent steps are clearly flagged, with the subagent-sim path as the no-cost option.
- **Scope creep into a full CI suite.** *Mitigation*: this is a *usage demo that validates*, not a
  regression matrix; keep it to the five behaviours + the runner.

## Open questions — resolved (2026-06-14, on their leans)

- **One `WALKTHROUGH.md` vs a separate `SCENARIOS.md`** → **resolved: one `WALKTHROUGH.md`** (narrative
  *is* the scenario list, expected outcomes inline); `validate-runner.sh` stays separate (it's code).
- **Location** → **resolved: top-level `test/loop/`** — validates the shipped product, establishes the
  repo's first `test/`.
- **Fixture** → **resolved: generic `slugify`** (plain Python, no pytest, self-contained, reproducible).
