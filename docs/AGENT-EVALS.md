<!-- generated-by: groundrules v1.10.0 -->
# Agent evals — groundrules

> A log of the **agent's own** observed failure modes while developing this plugin —
> recurring mistakes, hallucinations, drifts — and the guard added for each.
> Reverse-chronological. This is **meta**: about how the agent behaves *here*, not about the
> plugin's domain. Project/domain lessons go in `docs/LEARNINGS.md`.

Fed by the checkpoint-capture ritual (cf. `CLAUDE.md` → "Capture at checkpoints", typically
before a push/release).

> **This file is the journal, not the suite.** The runnable regression suite over the agent's
> configuration lives in `evals/` and is run with `claude plugin eval` ([ADR 0037](decisions/0037-executable-evals-over-agent-config.md)).
> An entry here whose guard sits at `Status: watching` is a **case candidate**: the observed failure
> mode is the prompt, the guard is the grader. `validated` is meant to mean *a case exists and is green*.

---

## 2026-09-02 — Reasoned about a layer-B copy as if it were the shipped layer-A source

**Observed**: asked to analyse the loop's verifier against an external brief, the agent read
`docs/prototypes/loop/LOOP.md` + `verifier.md` (**layer B** — a frozen proof-of-concept, explicitly
*"NOT shipped"* in its own README) and reported a defect *"in the living default"*. The shipped copy,
`skills/bootstrap/templates/loop/` (**layer A** — what users actually get), had already fixed it and
carried an extra callout. The two had silently diverged. The user was told the wrong file was at
fault; the agent corrected itself only after diffing the two on the way to editing.

**Pattern**: the repo's two disjoint layers are stated in `CLAUDE.md` ("*am I touching the plugin
sources (A) or the project docs (B)?*"), but the question is asked at **write** time. Here the error
was at **read** time — reading B and generalising to A. A duplicated file makes it worse: both copies
look canonical when read alone, and only a diff reveals which one ships.

**Guard**: when a file has a counterpart in the other layer, **diff the two before drawing any
conclusion about behaviour**, not just before editing — and name the layer explicitly when reporting.
Concretely, for anything under `docs/prototypes/`: its shipped counterpart under
`skills/bootstrap/templates/` is the one that governs behaviour.

**Status**: watching — and the first candidate case for the `evals/` suite
([ADR 0037](decisions/0037-executable-evals-over-agent-config.md)); tracked in `PLAN.md`.

## 2026-06-13 — Jumps to execution without capturing / confirming scope first

**Observed** (same session, twice):
1. Mid-thread on "git workflow" (3 points, only point 1 closed), a new complex task surfaced
   (content-aware CLAUDE.md tailoring). The agent **immediately produced a full implementation
   plan and proposed to execute it** — abandoning the open git-workflow points, with no capture
   of the in-flight state. The user had to stop it ("enregistre ce qu'on a en cours").
2. When proposing the *working method itself*, the agent delivered it as a near-*fait accompli* —
   it had already **created the PRD and edited `PLAN.md` before alignment**. It acted, then asked.

**Pattern**: default reflex is to **start editing**; the brake ("capture / confirm scope before
executing") lives in the *user's* vigilance, not the agent's behavior. Notably, the agent did
this *while* proposing a discipline whose whole point is the opposite — the taxonomy-on-paper did
not change the reflex. Distinct from "asserts without verifying" (below): this is *acts before
aligning*, not *claims before checking*.

**Guard**: **VALIDATED 2026-06-13 — framed by [ADR 0027](decisions/0027-reflection-realization-interactive-loop.md).**
- **Put the brake on the *scope change*, not on the execution.** Inside an agreed task, act freely
  and fast — no asking. The pause fires only when the perimeter *moves*: a new task surfaces, an
  idea widens the blast radius, or "discuss/propose" turns into "build". Then: capture to the
  backlog, get explicit clearance before executing the new scope. Friction stays off agreed work
  (so the practice survives) and only gates boundary-crossings.
- Underlying distinction: **"I have enough to act" ≠ "I'm cleared to act"** — the first is the
  agent's *confidence*, the second is the user's *alignment*; the drift is taking the former for
  the latter.
- ADR 0027 situates this as **the back pressure of the reflection regime** (there is no automatic
  back pressure for thinking — the human is the judge), and notes the same guard reappears *inside
  a loop's verifier*: on a real implicit decision, **block, do not guess**.

**Status**: resolved — guard codified in ADR 0027. (The forks of the reflection — trigger, form,
granularity, reach — were settled there; the remaining template wording refinement is tracked in
PLAN/ROADMAP, not here.)

## 2026-06-08 — "Just restart" advised without verifying the installed plugin version (recurrence)

**Observed**: when the user reported `/groundrules:checkpoint` then `/groundrules:slim` not appearing, the agent repeatedly advised "restart Claude Code" — without checking which plugin version was actually *installed*. On disk the installed plugin was still **1.1.0** (cache capped there); the user had only run `/plugin marketplace update` (catalog), never updated the plugin. A restart just reloaded 1.1.0. Only after inspecting `~/.claude/plugins/cache/…` did the real cause surface.

**Pattern**: **recurrence** of "asserts/trusts without verifying" (see entry below) — diagnosing a symptom from a mental model ("new skill ⇒ restart") instead of checking ground truth first.

**Guard**: when a command/skill "doesn't appear", **verify the installed version on disk before advising** (`ls ~/.claude/plugins/cache/<marketplace>/<plugin>/`) — distinguish *marketplace catalog* (updated) from *installed plugin* (often not). The README "Updating the plugin" section and the skills' Phase 0 notices now spell out the two-step update explicitly.

**Status**: watching — the prior guard ("verify before assert") didn't fire here; this strengthens it toward *environment/installation* claims specifically.

## 2026-06-08 — Asserts / trusts without verifying first

**Observed** (two instances, one session):
1. Labelled the new session-close ritual a *"forcing function"* without checking whether any
   trigger could fire it — it couldn't (the agent can't perceive session end). The user
   caught the over-claim.
2. Echoed graphify's star count from a WebFetch AI summary that had **hallucinated** inflated
   figures; only a direct GitHub API call gave the real numbers. (Caught before asserting to
   the user, but the first draft trusted the summary.)

**Pattern**: stating something *works* / *is true* on the strength of a plausible-sounding
source (own reasoning, an AI summary) before verifying against ground truth.

**Guard**: before asserting a mechanism works or quoting an external metric — verify it.
For Claude Code behavior, check the docs (the `claude-code-guide` agent); for external repo
metrics, hit the API, not a WebFetch summary; for a "this will trigger/fire" claim, name the
concrete event that fires it. "Verify before you assert" is now also reflected in the
`CLAUDE.md` "Verifying the work" discipline.

**Status**: watching — re-evaluate over the next few sessions.
