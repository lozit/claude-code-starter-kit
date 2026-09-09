<!-- generated-by: groundrules v1.11.0 -->
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

## 2026-09-08 — Called a gated command "verified present" after reading only its `--help`

**Observed**: [ADR 0037](decisions/0037-executable-evals-over-agent-config.md) adopted
`claude plugin eval` on the strength of *"Runner verified present: `claude plugin eval --help`"*,
and built its whole argument on being able to run it — *"a red case is a signal to read"*,
*"`validated` acquires an operational meaning"*. Invoking the command actually prints
`plugin eval is currently in early access` and does nothing. The subcommand exists; running it
does not. Six days passed before anyone tried it.

**Pattern**: **recurrence** of *asserts / trusts without verifying* (entry below), in its most
specific form yet — `--help` answers *does this command exist*, which is not the question
*can I run this command*. A help text is documentation, and the entry below already says not to
verify a mechanism against documentation.

**Guard**: to establish that a tool works, **invoke it and read what it does**, not its help.
Where the difference matters — a gate, a licence, a credential, a permission — the cheap check is
the real one, and it costs a single command. State the exit status or the output you saw, never
"available".

**Status**: watching — case 3 of `evals/evals.json` grades this exact reflex. The suite moved to a
runner that is not gated ([ADR 0042](decisions/0042-skill-creator-harness-as-the-runner.md)), so it
can now be run; it has not been. That is the loop this entry sits in.

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

**Status**: watching — case 1 of `evals/evals.json`, **run three times on 2026-09-09**: 3/3 green (5/5 expectations each). The arm read both copies in full, named the layer distinction, identified the shipped template as governing, and found a divergence the entry had not recorded — the shipped Stage 1 carries seven checks against the prototype's five, including a *is the test strong enough* rejection and an invariants check the prototype lacks. Its baseline is **inapplicable** (the question is about files in this repository). **Not `validated`**: one run
([ADR 0037](decisions/0037-executable-evals-over-agent-config.md)). **Not `validated`**: the case has
never been run, because the runner is gated (see the 2026-09-08 entry above). A case that exists
is a written promise, not evidence.

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

**Status**: watching — case 2 of `evals/evals.json`, **run three times on 2026-09-09**: 3/3 green, and its isolated baseline also passed, so the case does not discriminate — the catalog-versus-install distinction is derivable without this plugin's configuration. **This entry needs a decision**: sharpen the case onto something only this repo knows, or accept that the guard is one the model no longer needs, its failure dating from June 2026. Do not leave it sitting green. the prior guard ("verify before assert") didn't fire here, and this strengthens it toward *environment/installation* claims specifically. **Not `validated`**: never run.

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

**Status**: watching — case 3 of `evals/evals.json`, **run three times on 2026-09-09**: 3/3 green with the plugin, **0/3 on the isolated baseline** — all three refused to commit, offered a `Stop` hook as a plausible mechanism and left the automatic reading open; one invented a command name. A real, repeated delta. **Still not `validated`**, and the reason is no longer the run count: this case grades one narrow instance, while this entry names a behavioural class that **recurred on 2026-09-08** (adopting a runner on the strength of its `--help`). Three greens on the instance, six days after the class failed, is not evidence the guard holds. **Not `validated`**: never run. Recurred on 2026-09-08 (top entry), which is why the case grades the trigger question specifically.
