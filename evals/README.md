<!-- generated-by: groundrules v1.11.0 -->
# `evals/` — the executable suite over this plugin's own configuration

Maintainer-side tooling. It tests **groundrules' own configuration** — the instructions in
`skills/*/SKILL.md` and their templates — and nothing else. Decided in
[ADR 0037](../docs/decisions/0037-executable-evals-over-agent-config.md); the runner was changed in
[ADR 0042](../docs/decisions/0042-skill-creator-harness-as-the-runner.md).

**Nothing here is generated into user projects, and no skill invokes it.** Same category as the
`gh` calls used to cut a release.

## The runner

`claude plugin eval` — the runner ADR 0037 originally chose — is **gated behind early access**.
Invoking it prints `plugin eval is currently in early access` and does nothing (verified three
times: 2026-09-08, and twice on 2026-09-09, once after installing `skill-creator` and restarting).

The suite therefore uses the harness carried by the official **`skill-creator`** plugin, which
needs no gate. Its method is the one this repository had already been applying by hand: for each
case, **two runs in the same turn** — one with the plugin loaded, one without, as a baseline —
then a comparison of what each produced. `skill-creator` adds the two things doing it by hand
lacked: the baseline arm, which measures whether the plugin changes behaviour at all, and
aggregation over repeated runs, which separates a real failure from noise.

To run it, invoke the `skill-creator` skill and point it at `evals/evals.json`. Results belong in
a workspace **outside** this repository's tracked tree.

## Two deliberate deviations from `skill-creator`'s conventions

- **The suite lives at the repository root, not inside a skill directory.** `skill-creator` files
  `evals/evals.json` under the skill it tests. Two of the three cases here are not about one
  skill: the layer confusion is about a repository-wide convention, and the update trap spans the
  README and three skills' notices. ADR 0037 scoped this suite to *the plugin's configuration*,
  so `skill_name` is `groundrules` and the suite sits once at the root.
- **`scripts/run_eval.py` is not used.** That script evaluates whether a skill's **description**
  makes it trigger, and requires a skill directory. These are **behavioural** cases — what the
  agent does once it is running — which is the other half of `skill-creator`'s workflow.

## Read this first: no case here has ever been run

The cases are **authored and unexecuted**. They have never been green and never red. Treat every
claim in them as a specification of what a guard promises, not as evidence that it holds — and in
particular, **no entry in [`docs/AGENT-EVALS.md`](../docs/AGENT-EVALS.md) may move to `validated`
on the strength of a case existing.** That was ADR 0037's whole purpose, and it is the part still
outstanding.

## The three cases

Each comes from an entry in [`docs/AGENT-EVALS.md`](../docs/AGENT-EVALS.md) sitting at
`Status: watching`: the observed failure mode is the prompt, the recorded guard is the
expectation list.

| id | Source entry | What it catches |
|---|---|---|
| 1 | 2026-09-02 — reasoned about a layer-B copy as if it were the shipped source | describing the verifier from the frozen prototype, and calling it what users get |
| 2 | 2026-06-08 — "just restart" advised without checking what is installed | prescribing a remedy before establishing the installed version |
| 3 | 2026-06-08 — asserts / trusts without verifying first | agreeing that a ritual fires on a trigger that cannot exist |

Case 3 is the one this repository keeps failing. Adopting `claude plugin eval` on the strength of
its `--help` — which answers *does this command exist*, not *can I run it* — is the same reflex,
logged as its own `AGENT-EVALS` entry on 2026-09-08.

## Adding a case

Only from an existing `docs/AGENT-EVALS.md` entry, and only while the suite stays small enough to
actually be run. A suite nobody runs is worse than none, because it looks like coverage.

Write the prompt so the comfortable answer is the wrong one. A case the agent passes by agreeing
with the question measures nothing.
