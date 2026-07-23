<!-- generated-by: groundrules v1.10.0 -->
# 0027 — Reflection vs realization phases; interactive vs loop regimes

**Date**: 2026-06-13
**Status**: Accepted

## Context

Two pressures converged in one session.

1. **An observed agent drift** (`docs/AGENT-EVALS.md`, 2026-06-13): the agent kept sliding from
   *thinking* straight into *editing files* without capturing or confirming — twice, including
   while proposing the very discipline meant to prevent it. The brake lived in the user's
   vigilance, not in the method.
2. **The "loop engineering" paradigm** (Boris Cherny's *"write loops, not prompts"*; Geoffrey
   Huntley's *Ralph* loop; Addy Osmani's *Loop Engineering*; Chroma's *context rot*). Its core —
   *"the model forgets, the repo remembers"*, fresh context per iteration, state on disk — is
   exactly groundrules' own thesis (ADR 0020/0021), now generalized to autonomous execution.

These forced a precise question groundrules had never answered: **what kind of work is this, and
how should the agent act in each kind?** The loop literature is explicitly greenfield/autonomous
and warns it does *not* fit exploratory or brownfield work — so "just loop everything" is wrong,
and so is "always keep a human in the typing loop."

## Decision

Adopt a single model, used both as the **dogfood working method** here and as the **product
direction** groundrules embodies for users.

**1. Every piece of work is either reflection or realization — never blur them.**
- **Reflection** (think): produce the *right durable documentation* before executing. The human is
  the judge (there is no automatic back pressure for thinking). Outputs depend on the object:
  a **choice/fork → ADR**; a **thing to build → PRD**; project framing → VISION/ROADMAP. Reflection
  is the base case — it does not precede itself (no "PRD to write an ADR"; that would regress
  infinitely).
- **Realization** (do): turn the doc into the thing.

**2. The reflection doc is a method-agnostic contract; the executor is swappable.** The same
PRD/spec feeds either realization regime:
- **Interactive** — classic step-by-step with the human. For sensitive / exploratory / brownfield
  / cross-cutting work.
- **Loop** — autonomous (Ralph / `/goal` / `/loop`). For atomic, testable, isolatable, greenfield
  work that carries verifiable back pressure.

**3. The frontier between reflection and realization is bidirectional and crossed *on purpose*.**
- Forward (reflection → realization): a plan/spec is approved, then executed. **Plan mode** is the
  harness-native enforcement of this crossing on the *interactive* side (read-only until the user
  approves) — but its output is ephemeral and must be persisted into the doc-contract
  (`the repo is the only memory`).
- Backward (realization → reflection): a loop that hits a **decision** it cannot verify its way out
  of has re-entered reflection — human territory. It parks the task (`blocked.md`) and escalates.
  A blocker resolved this way often becomes an **ADR**, which makes the loop smarter next run
  (the loop *bonifies* the repo — `lessons.md` generalized).

**4. The "could-act ≠ cleared-to-act" guard is the back pressure of the reflection regime.**
*Having enough to act* (the agent's confidence) is not *being cleared to act* (the user's
alignment). The brake fires on **scope changes** — a new task, a widened blast radius, or
"discuss/propose" turning into "build" — not on execution inside an agreed scope (so friction stays
off agreed work and the practice survives). The same guard reappears *inside a loop's verifier*:
on a real implicit decision, **block, do not guess**.

**5. groundrules tools both phases (product direction — implementation deferred to PRDs):**
- Reflection: already covered (`bootstrap`, `add-adr`, `prd`, `learn`, VISION/ROADMAP).
- Realization: interactive needs nothing special; **loop-readiness** is the new surface —
  - loop *scaffolding* (maker/verifier agents, `LOOP.md`, capped runner, an *Invariants* section,
    the `blocked.md` convention) as an **opt-in in `bootstrap`/`adopt`** (once per project),
  - a **`/groundrules:realize`** skill: the forward bridge that transforms an approved plan into a
    *partitioned* backlog (atomic + verifiable + invariant-aware; `[loop]` vs `[supervised]`) —
    refusing to tag a task `[loop]` without a real stop condition,
  - the backward crossing as a **convention first** (triage `blocked.md` → re-decompose /
    decide→ADR / interactive-fix), promoted to a skill only if it earns it.

Positioning: loops create *comprehension debt*; groundrules' ADRs/LEARNINGS/the *why* are its
antidote. **Loops write the code fast; groundrules keeps the understanding of the code.**

## Alternatives considered

- **A universal "confirm before every edit" guard** — rejected: friction on execution kills flow
  on trivial work; the user disables it out of fatigue. The brake belongs on *scope change*, not
  execution.
- **Treat all work as loopable (adopt loops wholesale)** — rejected: the loop literature itself is
  greenfield-biased and warns against existing codebases and unverifiable/decision work. Loops are
  one *realization regime*, not the method.
- **A runtime hook to intercept plan approval and route interactive-vs-loop** — rejected for now
  (ADR 0025 consistency): hooks are non-interactive, can only block or inject context, and a
  `PostToolUse` nudge is non-deterministic; net gain over a convention + a skill is marginal and
  the cost (runtime, harness-specific, opinionated) is real. Verified against the Claude Code hooks
  reference.
- **One fat `realize` skill doing both frontier crossings** — rejected: it would blur the very
  boundary this ADR keeps sharp. Forward and backward crossings stay distinct and nameable; the
  one-time scaffolding belongs in bootstrap/adopt, not re-run per plan.

## Consequences

### Positive
- A coherent answer to "how should the agent act here": know your phase, know your regime, cross
  the frontier deliberately. The drift in AGENT-EVALS now has a framed remediation.
- groundrules gains a strategic identity beyond bootstrapping: **the reflection layer + memory
  substrate that makes a repo executable by either a human or a loop**, and the antidote to the
  comprehension debt loops create.
- The doc-as-contract makes the executor swappable — interactive today, loop tomorrow, same spec.

### Negative / Tradeoffs
- The model is a *mental discipline* first; its product surface (`realize`, scaffolding, triage) is
  unbuilt and non-trivial — each piece needs its own PRD before implementation.
- "Scope change" is a judgement call (less mechanical than a blast-radius rule); it leans on the
  agent reading the situation honestly.
- Reverses nothing, but sharpens the template's "plan mode before any non-trivial task" into
  "interactive non-trivial → plan mode; atomic/testable/isolatable → spec + loop; decision → ADR"
  (a future template refinement, tracked, not yet applied).

## Notes

- Sources captured in the session: the user-supplied *Write Loops, Not Prompts* synthesis and a
  *variolab* loop-adoption guide (both reference ghuntley.com/ralph, addyosmani.com/loop-engineering,
  research.trychroma.com/context-rot).
- Implementation of the loop-readiness product surface is a **ROADMAP milestone**, to be spec'd in
  PRDs when built — deliberately *not* built as part of this capture (dogfood of the model: this
  ADR is reflection; the build is a separate, later crossing).
