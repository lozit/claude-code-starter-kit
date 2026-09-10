<!-- generated-by: groundrules v1.11.0 -->
# Agent evals — groundrules

> A log of the **agent's own** observed failure modes while developing this plugin —
> recurring mistakes, hallucinations, drifts — and the guard added for each.
> Reverse-chronological. This is **meta**: about how the agent behaves *here*, not about the
> plugin's domain. Project/domain lessons go in `docs/LEARNINGS.md`.

Fed by the checkpoint-capture ritual (cf. `CLAUDE.md` → "Capture at checkpoints", typically
before a push/release).

> **This file is the journal, not the suite.** The runnable regression suite over the agent's
> configuration lives in `evals/`, run on `skill-creator`'s harness ([ADR 0037](decisions/0037-executable-evals-over-agent-config.md),
> runner amended by [ADR 0042](decisions/0042-skill-creator-harness-as-the-runner.md)). An entry
> here whose guard sits at `Status: watching` is a **case candidate**: the observed failure mode is
> the prompt, the guard is the expectation list.
>
> **Status vocabulary** ([ADR 0043](decisions/0043-probed-not-validated.md), which retired
> `validated`): `watching` — no case, or a case whose green is discounted for a stated reason.
> `probed: <case>, N/N since <date>` — a case exists and is green over a **rate**, covering one
> **named instance**. An entry names a behavioural *class*, which no finite suite covers, so
> **`probed` never means the class is safe**: a recurrence does not falsify the probe, it records
> that the class failed elsewhere. The entry's history is the signal; the status only indexes it.

---

## 2026-09-09 — Opened a duplicate `### Changed` section in `CHANGELOG.md`, twice in two days

**Observed**: inserting an entry under `## [Unreleased]`, the agent anchored on the literal string
`### Changed` and wrote a **new** section above the existing one, leaving the release with
`Changed` / `Fixed` / `Changed`. Caught, fixed, and **committed the fix on 2026-09-08** — then
repeated exactly on 2026-09-09, in the same file, on the next entry inserted. Keep a Changelog
expects one section per type per release; two invite an entry being filed in the wrong half, and a
reader trusting the first one they reach.

**Pattern**: an insertion anchored on a **heading name** rather than on the section's position
within its release. The heading recurs once per released version, so the anchor is ambiguous by
construction and the first match is rarely the intended one. The 2026-09-08 fix corrected the
*instance* and left the *habit*, which is why the recurrence took one day.

**Guard**: when inserting into a file with repeating structure — a changelog, a decisions index, a
status table — **anchor on something unique**, the first line of the block that follows, not on a
heading that appears once per section. And after any insertion, **count**: one `### <type>` per
release, one row per ADR, one entry per id. The count is a check; re-reading the diff is a
reminder, and this entry is what a reminder is worth.

**Root cause, found 2026-09-10**: the guard above could not fire, because nothing in this repository
loaded the file holding it — the meta `CLAUDE.md` had no *Session start* section, while the template
this plugin ships gives every generated project one. Fixed by giving the dogfood the list it ships;
the general lesson is in `docs/LEARNINGS.md`.

**Status**: watching — case 4 of `evals/evals.json` grades it, and is the suite's first **fully
deterministic** case: count the headings, no judge. **Run 3/3 green on 2026-09-10, and the green is
not evidence**: the failure did not reproduce. The recorded failure happened mid-session, inserting
by a scripted string anchor into a large real file under load; the case hands a fresh agent a small
fixture and one focused instruction. Different task. The case needs the *conditions* rebuilt — several
insertions at once, across a longer file — before a green means anything.

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

**Status**: watching — no case of its own. Case 3 grades the *class* this belongs to on a different
instance, and was green 3/3 six days **after** this happened, which is exactly why
[ADR 0043](decisions/0043-probed-not-validated.md) retired `validated`: a probe covers an instance,
never the class.

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

**Status**: watching — case 1 of `evals/evals.json`, run three times on 2026-09-09: 3/3 green (5/5 expectations each). **The green is discounted**, so the entry stays `watching`: two of the three runs read `evals/evals.json`, the file holding the expectations that grade them. Its baseline arm is also **inapplicable** — the question is about files in this repository, so a shielded arm has nothing to answer from. The runs earned their keep anyway: they turned up a divergence this entry had never recorded (the shipped Stage 1 carries seven checks to the prototype's five, including a *is the test strong enough* rejection and an invariants check the prototype lacks), and two of them found the defects fixed in [ADR 0044](decisions/0044-runner-enforces-verifier-isolation.md).
([ADR 0037](decisions/0037-executable-evals-over-agent-config.md)). It also turned up a divergence
this entry had never recorded: the shipped Stage 1 carries seven checks to the prototype's five.

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

**Status**: watching — case 2 of `evals/evals.json` was **sharpened on 2026-09-09** and the old 3/3 does not carry to a changed case. In its first form both arms passed, so it measured general competence rather than this configuration. The prompt now carries a checkable false premise (the user's colleague dates `close` to 1.10.0; it shipped in 1.11.0), verifiable here and unknowable elsewhere. **3/3 at 6/6 with the plugin** (2026-09-10) against **4/6 on the isolated baseline**, which never questioned the figure and invented a verification path. Two runs found things the case had not anticipated: a catalog refreshed before the release could not have carried the version, and **this machine holds two installs of the plugin** — user scope at 1.11.0, project scope pinned at 1.10.0 for this very repository, so the dogfood runs an old copy of its own plugin. **`probed` by case 2, 3/3 since 2026-09-10** — covering the version-claim instance only.

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

**Status**: `probed` by case 3 of `evals/evals.json`, 3/3 since 2026-09-09 — covering the session-end-trigger instance only, against **0/3 on the isolated baseline**: all three refused to commit, offered a `Stop` hook as a plausible mechanism and left the automatic reading open, and one invented a command name. A real, repeated delta. **The class is not safe**, and this is the rule rather than the exception: it recurred on 2026-09-08, six days before these greens — see the top entry, and [ADR 0043](decisions/0043-probed-not-validated.md).
