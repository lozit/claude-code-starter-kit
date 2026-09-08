<!-- generated-by: groundrules v1.11.0 -->
# PRD — `/goal` interop: surface the two executors (implements ADR 0031)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-20 · **Status**: draft — 4 open questions resolved on their leans; ready to build · **Milestone**: post-M1 (loop adoption)

## Problem

[ADR 0031](../decisions/0031-goal-interop-swappable-loop-executor.md) settled the *positioning*: the loop
**executor is swappable** — Claude Code's native **`/goal`** is the **light** loop (one accumulating
session, a fast evaluator judging the transcript), the groundrules loop (`run-loop.sh` + the
maker/verifier prompts) is the **high-fidelity** loop (fresh context, the verifier *re-runs the oracle*,
parks decisions). groundrules always **writes the goal**; only the runner differs. But that decision is
**not yet visible anywhere a user acts**: `realize` produces a backlog without surfacing the `/goal`
launch option, and neither the generated `loop/README.md` nor the project `README.md` explains *when to
reach for which*. This PRD implements ADR 0031's surfaces — no new behaviour, just making the swappable
executor real for users.

## Success criteria

- After `/groundrules:realize` tags a task `[loop]`, its **recap surfaces both launch options** for that
  task, framed by stakes: the **light** `/goal "<condition>"` (ready to paste) and the **high-fidelity**
  `bash loop/run-loop.sh --max <N>`. The `/goal` condition is **binary/command-based** (derived from the
  task's acceptance command, e.g. `the command \`go test ./...\` exits 0`), never a vague NL goal.
- The generated **`loop/README.md`** has a **"Two ways to run the loop"** section: `/goal` (light) vs
  `run-loop.sh` (high-fidelity), when to use each, how to launch each, and the honest tradeoff (`/goal`'s
  evaluator judges the *transcript*, not an independent re-run) — plus the optional "run the verifier
  once as a final gate after a `/goal` run" mitigation (documented, not automated).
- The project **`README.md`** explains the **two fidelity levels** concisely (when `/goal` vs the full
  loop, why `/goal` alone is lighter) — the user-facing version of ADR 0031 §2.
- **No runtime, no detection, no new skill.** Pure docs + a `realize` recap enhancement (template/prompt
  over code, ADR 0002/0025). Honest sourcing of the tradeoff throughout.

## Scope

**In scope**
- **`skills/realize/SKILL.md`** — Phase 5 recap: per `[loop]` task, emit the two launch options with the
  fidelity framing and a ready-to-paste `/goal "<command-based condition>"` derived from the task's
  acceptance command. (The backlog task already names the command — don't duplicate a condition field
  into it; derive at recap time.)
- **`skills/bootstrap/templates/loop/README.md.tpl`** — a "Two ways to run the loop" section (the
  `/goal` interop note, mirroring the superpowers-defer style): light vs high-fidelity, the one-goal
  (`/goal`) vs whole-backlog (`run-loop.sh`) distinction, the transcript-vs-re-run tradeoff, and the
  optional post-`/goal` verifier gate.
- **`README.md`** — a concise "two ways to run it" explanation in the loop area (fold near *Built for
  the age of loops* / the loop-docs pointer; avoid a new top-level section).
- **`run-loop.sh`** header comment — one line noting `/goal` as the lighter in-the-box alternative.
- CHANGELOG; this PRD is the reflection home.

**Out of scope** (explicit)
- **Runtime detection of `/goal`** (version/availability) — none; docs say "if you have `/goal`"
  (ADR 0025, no runtime).
- **Wrapping `/goal` inside `run-loop.sh`** — rejected in ADR 0031; the interop is usage/doc, not code.
- **Automating a verifier gate after `/goal`** — documented as an optional manual step only.
- **Changing the maker/verifier contract, the TDD gate, or `realize`'s partitioning logic.**
- A new skill.

## Constraints

- **Template/prompt over code** (ADR 0002); **no runtime / no detection** (ADR 0025).
- **Honest tradeoff** everywhere: `/goal` is *lighter*, not *lesser-for-free* — its evaluator trusts the
  transcript; the high-fidelity loop re-runs the oracle. State it, don't bury it.
- **Command-based `/goal` conditions only** (ADR 0031 §4) — a binary check the maker actually runs, so a
  transcript-judging evaluator has something real to verify.
- **English-only**; carry the `generated-by` signature; keep `loop/README.md` readable.

## Build plan

Ordered steps, each with a validation point.

1. **`realize` recap** — emit both launch options + the derived `/goal` condition per `[loop]` task.
   Validate: dry-read — a task with acceptance command `C` yields `/goal "the command \`C\` exits 0"`
   and the `run-loop.sh` line, framed by stakes.
2. **`loop/README.md.tpl`** — the "Two ways to run the loop" section. Validate: a fresh reader can pick
   `/goal` vs `run-loop.sh` from it; the tradeoff and the one-goal-vs-backlog distinction are explicit.
3. **`README.md`** — the two-fidelity-levels explanation. Validate: consistent with ADR 0031 + the loop
   docs; no new top-level section bloat.
4. **`run-loop.sh`** header one-liner + CHANGELOG. Validate: drift checks clean.
5. **Fresh-subagent validation** — run `realize` on a fixture with a `[loop]` task (e.g. the `to_roman`
   or `slugify` red test) and confirm the recap emits a correct, paste-ready `/goal` condition + the
   run-loop option with honest framing; read the two README surfaces for accuracy/contradiction.

## Risks

What could go wrong, and the mitigation.

- **Users read "light" as "use `/goal` for everything" and lose the high-fidelity guarantees.**
  *Mitigation*: frame as *choose by stakes*, lead the tradeoff (transcript-judge vs re-run), and keep
  the post-`/goal` verifier-gate note. (This is exactly the over-strong framing ADR 0031 already
  corrected — keep the corrected version.)
- **The `/goal` condition realize emits is vague** (→ `/goal` loops forever). *Mitigation*: always
  command-based, derived from the acceptance command; never a free-text goal.
- **`/goal` pursues one condition; a backlog has many.** A naive `/goal "<one task>"` ignores the rest.
  *Mitigation*: state the **one-goal (`/goal`) vs whole-backlog (`run-loop.sh`)** distinction explicitly;
  `/goal` is per-task, `run-loop.sh` iterates the backlog.
- **Doc drift** between ADR 0031, `loop/README.md`, and `README.md`. *Mitigation*: single framing
  ("two fidelity levels, choose by stakes"), cross-linked; the validation step greps for contradiction.

## Open questions — resolved (2026-06-20, on their leans)

- **Where the `/goal` condition surfaces** → **resolved: `realize` recap only** (the backlog names the
  command; derive the condition at recap time — no redundant field in the backlog).
- **`README.md` placement** → **resolved: fold in** a tight "two ways to run it" line near the existing
  loop pointers; no new top-level section.
- **Post-`/goal` verifier gate** → **resolved: document** it as an optional manual step in
  `loop/README.md` (ADR 0031 §4's honest mitigation); no machinery.
- **QUICKSTART/TUTORIAL touch-ups** → **resolved: one-line pointer** to the new `loop/README.md`
  section; no rewrite.
