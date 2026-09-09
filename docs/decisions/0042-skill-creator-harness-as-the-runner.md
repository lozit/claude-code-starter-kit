<!-- generated-by: groundrules v1.11.0 -->
# 0042 — The eval suite runs on `skill-creator`'s harness, because the runner ADR 0037 chose is gated

**Date**: 2026-09-09
**Status**: Accepted (amends [ADR 0037](0037-executable-evals-over-agent-config.md), decision 1)

## Context

[ADR 0037](0037-executable-evals-over-agent-config.md) adopted an executable eval suite over this
plugin's configuration, and picked its runner in decision 1: `claude plugin eval`. That choice
rested on one sentence in its Context — *"The runner exists, and it is a CLI"* — supported by
having read `claude plugin eval --help`.

The command exists. It cannot be run. Invoking it prints `plugin eval is currently in early
access` and returns without doing anything. Verified three times: 2026-09-08 on Claude Code
2.1.265, then twice on 2026-09-09 — once after installing the official `skill-creator` plugin, and
once again after a full restart, on the hypothesis that the gate was tied to that plugin. It is
not.

A help text answers *does this command exist*, which is not the question *can I run this command*.
That gap is logged in `docs/AGENT-EVALS.md` (2026-09-08) as a recurrence of *asserts without
verifying* — the failure mode this very suite's third case grades.

Everything downstream of decision 1 depended on being able to execute: *a red case is a signal to
read*, and `validated` acquiring an operational meaning in `docs/AGENT-EVALS.md`. Three cases were
authored in the CLI's format and could not be run, so the suite was a written promise.

**A second runner exists and is not gated.** The official `skill-creator` plugin carries its own
harness: for each case, two runs are spawned in the same turn — one with the plugin loaded, one
without as a baseline — and the results are aggregated across repeated runs. It uses the session's
own authentication, needs no separate credential, and needs no early access.

It is also, in method, exactly what this repository had been doing by hand for two days: fresh
subagents given only the instructions and a fixture, reporting what they did. Every substantive
defect fixed in v1.11.0 was found that way. `skill-creator` adds the two things the manual version
lacked — the **baseline arm**, which measures whether the plugin changes behaviour at all, and
**aggregation over runs**, which separates a real failure from noise.

## Decision

**1. The suite runs on `skill-creator`'s harness.** Cases are declared in `evals/evals.json` —
`prompt`, `expected_output`, and a list of verifiable `expectations` — and executed by invoking the
`skill-creator` skill. Decision 1 of ADR 0037 is amended; every other decision in 0037 stands
unchanged, including that the suite is sourced from `docs/AGENT-EVALS.md`, never generated into
user projects, never invoked by a skill, and out of band.

**2. `claude plugin eval` is not kept in parallel.** The three cases are transposed, and their
CLI-format files are deleted rather than maintained alongside. Two formats for one suite is the
abstraction [ADR 0034](0034-posture-keep-the-diff-small.md) exists to refuse, and the CLI's format
had a specific claim on it: **it has never been parsed by the tool either**, so keeping it would
mean maintaining an unverified container for an unavailable runner. The content — the prompts and
what each expectation asserts — is the work, and it transposed in an afternoon; it will transpose
back just as cheaply if the gate opens.

**3. The suite sits at the repository root, not inside a skill directory.** `skill-creator` files
`evals/evals.json` under the skill it tests. Two of the three cases are not about one skill: the
layer confusion is a repository-wide reading discipline, and the update trap spans the README and
three skills' Phase 0 notices. ADR 0037 scoped this suite to *the plugin's configuration*, so
`skill_name` is `groundrules` and the suite sits once at the root.

**4. `scripts/run_eval.py` is not used.** It evaluates whether a skill's **description** causes it
to trigger, and requires a skill directory. These are **behavioural** cases — what the agent does
once running — which is the other half of `skill-creator`'s workflow and needs no such plumbing.

**5. Nothing here makes a case validated.** No case has been run under either runner. No
`docs/AGENT-EVALS.md` entry moves to `validated` because a case exists; a case that has never run
is a written promise, not evidence. This ADR removes a blocker, it does not deliver a result.

## Alternatives considered

- **Wait for the gate.** Rejected: the wait has no known end, it depends on an enablement this
  project does not control, and meanwhile three guards that have sat unfalsifiable for months
  stay that way. A decision whose success condition is somebody else's roadmap is not a decision.
- **Keep both formats.** Rejected, per decision 2. The cost is real and continuous; the benefit is
  a transposition that is cheap either way.
- **File cases per skill, as `skill-creator` expects.** Rejected, per decision 3: two of three
  would be misfiled, and a misfiled case is one nobody thinks to run when they change the thing it
  guards.
- **Drop the suite and keep testing by hand.** Rejected: the manual method found real defects, but
  it has no baseline arm, no repetition, and no record — each run lived in one session's
  transcript. That is the gap `docs/AGENT-EVALS.md` has had since it was created.

## Consequences

### Positive
- The suite becomes **runnable**, which was the only thing ADR 0037 was missing.
- The baseline arm answers a question no amount of prose can: does loading this plugin change what
  the agent does, and by how much.
- The method that found every substantive defect in v1.11.0 stops depending on someone remembering
  to spawn subagents by hand.

### Negative / Tradeoffs
- **A dependency on another plugin.** `skill-creator` must be installed to run the suite. It is
  maintainer-side only, so nothing about the offline-first property of the *skills* changes
  ([ADR 0015](0015-best-effort-update-check.md)), but a contributor who wants to run the suite now
  needs one more install.
- **A second harness may move under us**, exactly as the first did. The blast radius is one JSON
  file.
- **Real money and real non-determinism**, unchanged from ADR 0037: paired runs, repeated. The
  suite must stay small or it will not be run.

### Neutral
- Nothing changes for users of the plugin: no generated file, no new dependency, no new phase.

## Notes

- Runner gate verified 2026-09-08 (Claude Code 2.1.265) and twice on 2026-09-09, the second time
  after installing `skill-creator` and restarting, which is what ruled out that hypothesis.
- `skill-creator` is `skill-creator@claude-plugins-official`. Its eval schema is documented in the
  plugin's own `references/schemas.md`.
- The reflex that produced ADR 0037's premature claim is logged in `docs/AGENT-EVALS.md`
  (2026-09-08), and 0037 carries a dated note suspending the claims that depended on it.
