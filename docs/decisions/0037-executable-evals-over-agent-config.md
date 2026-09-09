<!-- generated-by: groundrules v1.11.0 -->
# 0037 — An executable eval suite over the agent's configuration (`evals/`), native format, out of band

**Date**: 2026-09-02
**Status**: Accepted

## Context

`docs/AGENT-EVALS.md` has a hole that predates any playbook: **its guards are unfalsifiable.** Each
entry records one observed failure mode of the agent and the guard added for it — then sits at
`Status: watching`, and nothing can ever move it to `validated` except the agent happening not to
repeat the mistake in front of a human who remembers the entry. Two of the three current entries have
sat at `watching` for three months. A guard nobody can run is a hope with a date on it, and the file
has no way to tell a guard that works from a guard that was never exercised.

That is the problem this ADR exists for. The failure mode is live, not theoretical: this very session
reasoned about the loop's verifier against `docs/prototypes/loop/`, believing it was the shipped
default, while `skills/bootstrap/templates/loop/` — the copy users actually get — had silently
diverged and already carried the fix. No guard fired, because no guard *can* fire.

The **vocabulary** for the missing piece comes from Anthropic's *AI-native SDLC playbook*
(<https://claude.com/blog/the-ai-native-sdlc-playbook>), surfaced by
`intake/2026-09-02-ai-native-sdlc-evals-and-verification.md`. It separates three kinds of control —
**skills** (advisory), **hooks** (deterministic, they block), and **evals**, defined as regression
suites over the agent's configuration: *"when a new model is swapped in or a prompt is rewritten, the
eval suite says whether the agent still does the work to the same standard"*, triggered by *"changes to
CLAUDE.md, skills or hooks, since that configuration steers the agent"*. That is the third control this
repo does not have. The playbook supplies the name and the trigger; the reason to want it was already
sitting in `docs/AGENT-EVALS.md`.

Two facts make it buildable rather than aspirational:

1. **`docs/AGENT-EVALS.md` is not that object, and should not become it.** It is a retrospective,
   narrative log fed by the checkpoint ritual. The playbook means a runnable suite fired by a change.
   Same word, two shapes, two lifecycles.
2. **The runner exists, and it is a CLI.** `claude plugin eval` ships in Claude Code (verified against
   2.1.258): cases as `<eval dir>/**/case.yaml` or `prompt.md` + `graders/*.md`, `--ablation
   with-without` for a no-plugin baseline arm and score delta, `--threshold` exiting non-zero, `--json`
   and an HTML report. It runs **out of band** — a command the maintainer invokes — not in the agent's
   execution path.

Fact 2 dissolves the collision the brief feared. [ADR 0025](0025-no-runtime-hook-no-watch.md) refused
an **in-band** `PreToolUse` hook — machinery in the agent's write path, coupled to the Claude Code hook
format — and concluded that *"verification stays post-hoc via `verify-bootstrap`, never enforced by
runtime hooks"*. An eval command is post-hoc verification: the same regime, one register up
(behaviour instead of output). Nothing in 0025 is revisited.

## Decision

**1. Adopt an executable eval suite for this plugin, at `evals/`, run with `claude plugin eval`.**
It tests **groundrules' own configuration** — the skills, their templates, the instructions in
`SKILL.md` — and nothing else.

**2. `docs/AGENT-EVALS.md` keeps its name, its role, and its retrospective register — and becomes the
suite's source.** An entry whose guard sits at `Status: watching` is a **case candidate**: the observed
failure mode is the prompt, the guard is the grader. This gives `validated` the meaning it lacks
today — *a case exists and is green* — and is, incidentally, the playbook's *"production incidents
become permanent evals"* in this repo's terms. The two objects are disambiguated by location — `docs/AGENT-EVALS.md`
is the journal, `evals/` is the suite. Deciding the word was already taken would have been a legitimate
outcome; keeping both is cheaper than renaming a file that works.

**3. Portability — adopt the native case format as it is, with no abstraction layer and no translator.**
This is the point the decision turns on, so it is stated flatly rather than left implicit:

> **Portability is a property of what groundrules *generates*, not of how groundrules is *tested*.**

[ADR 0023](0023-project-scope-for-team-portability.md)'s multi-harness direction protects the
**output** — the docs, the conventions, the generated `CLAUDE.md`, all of which must survive a change
of harness. The **system under test** here is the opposite: a Claude Code plugin, made of `SKILL.md`
files, a `plugin.json` manifest and `/groundrules:*` slash commands. It is already, irreducibly,
Claude-Code-specific. Testing a Claude-Code-specific artifact with Claude Code's own runner adds
**zero** new portability debt — where inventing a neutral case format plus a translator would add a
real abstraction ([ADR 0002](0002-plain-text-placeholder-substitution.md) *template over code*,
[ADR 0034](0034-posture-keep-the-diff-small.md) *keep the diff small*) to protect a portability that is
not at risk. If a second harness is ever supported, its adapter is a different system under test and
gets its own suite in its own terms; cases are cheap prompt-and-grader Markdown, not an asset worth
migrating.

**4. Trigger — by convention, out of band, never a hook.** Two points, both already checklist-shaped:
- **At release** — added to the meta `CLAUDE.md` release checklist, next to the README-drift sweep.
- **On a change to the configuration itself** — a PR touching `skills/**`, `skills/*/templates/**` or
  the meta `CLAUDE.md`, which is exactly the playbook's trigger, and which `main`'s PR gate
  ([ADR 0036](0036-git-workflow-corrected.md)) now makes a visible moment rather than a memory.

**5. Never generated into user projects, never invoked by a skill.** No `evals/` scaffold in
`bootstrap`, no template, no Phase that shells out to it. Offline-first ([ADR 0015](0015-best-effort-update-check.md))
is a property of the **skills**; this is maintainer-side development tooling, in the same category as
the `gh` calls used to cut a release.

**6. Start small and non-blocking.** Up to three cases, each sourced from an existing
`docs/AGENT-EVALS.md` entry. A red case is a signal to read, not a release blocker, until the suite has
earned trust.

## Alternatives considered

- **A harness-neutral case format + a translator** — rejected, per point 3. The abstraction protects
  nothing that is at risk and costs exactly what ADR 0002 and ADR 0034 exist to prevent.
- **Fold the suite into `docs/AGENT-EVALS.md`** (one word, one file) — rejected: a runnable suite and a
  narrative journal have different shapes, different lifecycles and different readers. Merging them
  would degrade the journal, which currently works.
- **Rename `docs/AGENT-EVALS.md` to free the word** — rejected: churn across CHANGELOG, the checkpoint
  skill, the template and every back-reference, to fix an ambiguity that one sentence resolves.
- **A change-triggered hook** (the brief's natural trigger) — rejected, and *not* because ADR 0025
  forbids it: because the trigger does not need to be in band. A convention at the PR gate gets the
  same coverage with none of the runtime surface.
- **CI now (GitHub Actions on the config paths)** — deferred, deliberately. This repo has no `.github/`
  at all; adding one means an API key in repository secrets, a per-PR cost with LLM graders (`--runs`
  defaults to 3), and non-deterministic verdicts gating a merge. Revisit once the suite is trusted and
  its cost per run is known — the `--threshold` flag exists precisely for that day.
- **Do nothing — the journal is enough** — rejected: that is the very problem, not the fallback. Every
  guard stays unfalsifiable and the file cannot distinguish one that works from one never exercised.

## Consequences

### Positive
- The guards in `docs/AGENT-EVALS.md` become testable; `validated` acquires an operational meaning.
- The playbook's third control is adopted without touching the repo's zero-runtime identity: skills
  stay advisory, no hook is introduced, and ADR 0025 stands as written.
- `--ablation with-without` measures something no amount of prose can: whether the plugin's presence
  actually changes the agent's behaviour, and by how much.

### Negative / Tradeoffs
- **Real money and real non-determinism**: LLM graders, three runs per case by default. The suite must
  stay small or it will not be run — and an eval suite nobody runs is worse than none, because it looks
  like coverage.
- **Coupled to a Claude Code version.** `claude plugin eval` is young (`experimental.evals` in the
  manifest); its case format may move under us. Accepted knowingly — see point 3; the blast radius is a
  handful of Markdown files.
- **One word, two artifacts.** Mitigated by location and by a line in each file, not by a rename.

### Neutral
- Nothing changes for users of the plugin: no generated file, no new dependency, no new phase.

## Notes

- Source: Anthropic, *The AI-Native SDLC playbook* — <https://claude.com/blog/the-ai-native-sdlc-playbook>.
  Read for this ADR; the quotes above are from it.
- Brief: `intake/2026-09-02-ai-native-sdlc-evals-and-verification.md` (tensions 1 and 2; 3 and 4 closed
  separately).
- Runner verified present: `claude plugin eval --help`, Claude Code 2.1.258, 2026-09-02.
- **2026-09-08 — present is not runnable.** Invoking the command prints `plugin eval is currently
  in early access` and does nothing (Claude Code 2.1.265). The 2026-09-02 check read the help text,
  which answers *does this exist*, not *can this run*. Decision 6's *"a red case is a signal to
  read"* and the operational meaning this ADR gives to `validated` both depend on executing the
  suite, and are **suspended** until the gate opens. The three cases are authored
  (`evals/`), unexecuted, and no `docs/AGENT-EVALS.md` entry may move to `validated` on the
  strength of one existing. The reflex itself is logged in `docs/AGENT-EVALS.md` (2026-09-08).
- **2026-09-09 — decision 1 is amended by [ADR 0042](0042-skill-creator-harness-as-the-runner.md).**
  The gate did not open (re-verified twice, once after installing `skill-creator` and restarting),
  so the suite moved to `skill-creator`'s harness, which needs no early access. Everything else in
  this ADR stands. The cases are still unexecuted, and `validated` still means nothing yet.
- Authoring the first cases is tracked in `PLAN.md`, not here — this ADR decides, it does not build.
