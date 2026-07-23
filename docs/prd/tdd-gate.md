<!-- generated-by: groundrules v1.10.0 -->
# PRD — TDD-before-loop gate (acceptance test = the loop's back pressure)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — all 4 open questions resolved; ready to build pending go · **Milestone**: M1 loop-readiness (fourth brick)

## Problem

[Brick 3](realize-skill.md) gates `[loop]` on the *existence* of "a re-runnable stop condition" — but a
stop condition that is weak, trivially-green, or written by the same agent that implements the task is
**no real back pressure**. A maker can satisfy a vague check, or (as brick 1's adversarial run showed) a
green test can be *gamed*. The loop's safety rests entirely on the strength and independence of its stop
condition; brick 3 left that strength unspecified.

Brick 4 hardens the gate into **TDD-before-loop**: a task is `[loop]`-eligible only if it has a
**pre-written acceptance test, authored separately from the maker (writer ≠ maker), that currently
fails (red)**. The acceptance test is the *executable form of the spec* (the PRD's Success criteria, or
a mini-spec authored at `realize` time) — authored in **reflection**, before the loop runs. Red-first is
the proof the test actually constrains the behaviour; writer-≠-maker is the proof the maker can't grade
its own homework. This is **not** global TDD (handoff-not-gospel, ADR 0010/0023) — it is the
**precondition of the loop regime only**; the interactive regime keeps the human as back pressure.

## Success criteria

- `realize`'s `[loop]` bar is upgraded: a task is `[loop]` only with a **pre-written acceptance test**
  that (a) expresses the task's specified behaviour, (b) is authored by someone other than the loop's
  maker (the human or the `realize`/reflection session), and (c) is **currently red** (fails before any
  implementation). Missing/green/maker-authored test → the task **stays `[supervised]`**.
- When a `[loop]` candidate has **no** acceptance test, `realize` **guides authoring one interactively**
  (a mini-spec → a failing test), writes it to disk on confirmation, and **confirms it is red** (runs it
  where it can; otherwise requires the user to confirm red) — *then* tags `[loop]`. It never silently
  autogenerates test code, and never tags `[loop]` on an unconfirmed/green test.
- The **maker** treats the pre-written acceptance test as **authoritative and immutable** (may add its
  own *assistive* unit tests, may never edit the acceptance test); the **verifier replays the
  pre-written acceptance test** as the authority and **rejects a too-weak test** (the brick-2 verifier
  already carries this — brick 4 sharpens the wording: acceptance test ≠ maker's unit tests).
- **Doc surface**: `PRD.md.tpl` *Success criteria* gains a one-line note that criteria should be
  expressible as acceptance tests (their executable form); the loop docs state TDD is the **loop-regime
  precondition only**, not a global mandate.
- No runtime machinery; Markdown only; English; signatures consistent.

## Scope

**In scope**
- **`realize` gate hardening** (the core change): replace brick-3's "a stop condition exists" with the
  pre-written-red-acceptance-test bar; add the **author-the-test** interactive step (mini-spec → failing
  test → confirm red) for `[loop]` candidates lacking one; keep the conservative default to
  `[supervised]`.
- **`maker.md` / `verifier.md` wording sharpening** (brick-2 loop templates): make explicit the
  distinction between the **authoritative pre-written acceptance test** and the maker's **assistive unit
  tests**; the verifier's authority is the former.
- **`PRD.md.tpl`** *Success criteria* note (acceptance-test framing).
- A short **loop-regime-only TDD** note in `loop/README.md` (and/or the loop docs) — not a global rule.
- README justification rows if a posture changes; CHANGELOG; PRD is the reflection home.

**Out of scope** (explicit)
- **The verifier's "reject too-weak test" mechanic itself** — already shipped in brick 2's `verifier.md`
  (Stage-1 check); brick 4 only sharpens its wording, doesn't re-build it.
- **Global/always-on TDD** — explicitly rejected (handoff-not-gospel); the gate is loop-regime only.
- **A test-generation engine / language-specific test scaffolding** — `realize` is
  framework-agnostic; it *guides* authoring and references the test command, the human owns exotic-stack
  test code.
- **Backward crossing as a skill** (brick 5); **template refinement** (brick 6); **running the loop**.
- The **superpowers** case (it owns its own TDD pipeline — defer, as in bricks 2–3).

## Constraints

- **Template over code** (ADR 0002): Markdown instructions; no engine. The acceptance test is a real
  test file in the project's own test location, run by a command — groundrules references it, doesn't
  abstract it.
- **The guard** (ADR 0027 §4) + **handoff-not-gospel** (ADR 0010/0023): TDD is imposed **only** as the
  loop-regime precondition, never globally; conservative default to `[supervised]`.
- **Writer ≠ maker**: the acceptance test must exist (and be red) **before** the loop's maker runs —
  authored by the human or the reflection-side `realize` session.
- **Never overwrite**; **English-only**; carry the signature.

## Build plan

Ordered steps, each with a validation point.

1. **Upgrade `realize`'s gate** (`skills/realize/SKILL.md` Phase 2/3): redefine the verifiable criterion
   as "a pre-written, currently-red acceptance test authored separately from the maker"; add the
   interactive author-the-test step + the red-check. Validate: dry-read — a task with no test is either
   given one (red-confirmed) or stays `[supervised]`; a green/maker-authored test never yields `[loop]`.
2. **Sharpen `maker.md` / `verifier.md`**: acceptance test (authoritative, immutable) vs maker unit
   tests (assistive); verifier replays the acceptance test. Validate: the wording is unambiguous to a
   fresh reader; no contradiction with the brick-2 contract.
3. **`PRD.md.tpl`** Success-criteria note + a loop-regime-only TDD line in `loop/README.md`. Validate:
   no implication of global TDD; PRD note is one line, fillable.
4. **README / CHANGELOG / PLAN**. Validate: skill-list & justification drift checks clean.
5. **Fresh-subagent E2E**: feed `realize` a `[loop]` candidate **with no test**, one **with a green
   (trivial) test**, and one **with a real red test**. Validate: only the last is tagged `[loop]`
   directly; the first triggers author-the-test→red→`[loop]`; the trivial-green one is refused (or its
   test strengthened) — nothing reaches `[loop]` on a non-red or maker-authored test.

## Risks

What could go wrong, and the mitigation.

- **TDD creep into a global mandate** (the thing we explicitly reject). *Mitigation*: every surface
  states "loop-regime precondition only"; the interactive regime is untouched; no change to the
  generated `CLAUDE.md` workflow beyond the loop docs.
- **`realize` over-reaching into writing test code** for stacks it doesn't understand. *Mitigation*:
  framework-agnostic — it guides + references the command; the human owns exotic test code; the gate is
  "a red test exists", not "realize wrote it".
- **Red-check not runnable** (env not set up at realize time). *Mitigation*: fall back to explicit user
  confirmation of red; document that an unverified-red test is the user's assertion.
- **Friction makes users skip the loop entirely.** *Mitigation*: the gate only raises the bar for
  `[loop]`; `[supervised]` always remains the no-friction path — the loop is opt-in on opt-in.

## Open questions — resolved (2026-06-14)

- **Does brick 4 *narrow* brick-3 `[loop]` tasks?** → **resolved: yes, tighten.** The bar becomes a
  **behavioural acceptance test**; a pure build/lint is necessary-not-sufficient — a task whose only
  stop condition was "build/lint green" no longer qualifies for `[loop]` without a behavioural test.
- **Author-the-test depth** → **resolved: guide + draft, gate on a red test existing.** `realize`
  drafts the failing test when the stack is obvious and writes it on confirmation, but authorship may be
  the user's; the gate is *a red-confirmed acceptance test exists*, not *who typed it*.
- **Red-first when realize can't run the test** → **resolved: accept user-confirmed red.** Don't
  hard-block on a missing env; record an unverified-red as the user's assertion.
- **Where the acceptance test lives** → **resolved: the project's own test location**, referenced by the
  backlog task's command (the maker/verifier run it in place).
