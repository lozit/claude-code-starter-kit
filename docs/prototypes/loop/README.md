<!-- generated-by: groundrules v1.11.0 -->
# Prototype — minimal runnable loop (M1, brick 1)

> **Status: prototype, NOT shipped.** These files are a proof-of-concept for the
> [loop-readiness milestone (M1)](../../ROADMAP.md) decided in
> [ADR 0027](../../decisions/0027-reflection-realization-interactive-loop.md) and spec'd in
> [`docs/prd/loop-minimal-runnable.md`](../../prd/loop-minimal-runnable.md). They are **not** copied
> into user projects and **not** wired into `bootstrap`/`adopt` — that is the *next* brick. The point
> here is to prove the **maker/verifier loop contract** on a fixture before productizing it.
>
> **Frozen at the single-invocation shape (2026-09-09).** The shipped template now splits each
> iteration into two `claude -p` calls — a maker pass, then a **separate** verifier pass — so the
> verifier's fresh context is supplied by the runner rather than merely asked for (ADR 0044). This
> prototype keeps the old one-invocation runner, so its `verifier.md` deliberately does **not**
> carry the new standalone-inputs and act-on-verdict sections. **The shipped template governs.**

## What this is

The smallest loop that still exercises the three behaviours the contract must guarantee:

1. **Convergence** — the maker produces code; the verifier passes it once the acceptance test is green.
2. **Distrust-the-report** — a deliberately-broken maker output is **rejected** by the verifier (it
   re-derives from the diff, not from the maker's self-claim).
3. **Park, don't guess** — on a real implicit decision the loop writes `blocked.md` and moves on,
   instead of inventing an answer.

## The artifacts

| File | Role |
|------|------|
| [`maker.md`](maker.md) | The **maker** prompt — implement one atomic task; report with a 4-status protocol. |
| [`verifier.md`](verifier.md) | The **verifier** prompt — two-stage ordered review (spec THEN quality), distrust the maker, evidence-before-claim. |
| [`LOOP.md`](LOOP.md) | The fixed prompt replayed **each iteration**: read state → first ready task → maker → verifier → commit / park. |
| [`run-loop.sh`](run-loop.sh) | The capped shell runner — hard `MAX` ceiling, stop on empty backlog / `DONE`. |
| [`blocked.md.example`](blocked.md.example) | The shape of the file the loop writes when it can't verify its way out (the backward crossing). |
| [`fixture/`](fixture/) | The greenfield fixture task + its **pre-written acceptance test** (red before any code). |

## The contract in one paragraph

The **maker** takes the first ready task, implements *only* that task, and reports exactly one of
**DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT** — never claiming a test passes without having
run it this turn. The **verifier** is a *separate* role that **does not trust the maker's report**: it
re-runs the acceptance test, reads the actual diff, and reviews in two ordered stages — **(1)
spec-compliance** (does it do what the task says, no placeholders, test green) **THEN (2) code-quality**
— and returns **PASS** or **REJECT** with evidence. On PASS the loop commits and checks the task off; on
maker `BLOCKED` or a persistent verifier `REJECT`, the loop writes `blocked.md` and escalates (the
realization→reflection backward crossing, ADR 0027 §3).

## How to run the validation

This prototype was validated by **subagent simulation** (the same technique as our skill E2Es): a maker
subagent implements the fixture, a verifier subagent reviews the diff — run on the good path, the
adversarial path, and the block path. See the verdict in [`docs/LEARNINGS.md`](../../LEARNINGS.md).

A **live** run (a real `claude -p` shell loop) is provided via `run-loop.sh` and left to the user — it
is gated by the hard iteration cap. To try it on the fixture:

```bash
cp -r docs/prototypes/loop/fixture /tmp/loop-fixture && cd /tmp/loop-fixture
# point the runner at this dir; MAX caps the iterations (anti-runaway)
bash /path/to/groundrules/docs/prototypes/loop/run-loop.sh --max 5
```
