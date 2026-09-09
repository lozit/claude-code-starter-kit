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

### Getting a baseline arm that is actually a baseline

Measured on 2026-09-09, and it cost three attempts (`docs/LEARNINGS.md`). The plugin reaches an
unshielded arm through three channels, and any one of them makes the delta read as zero:

- **A subagent launched from this repository is handed the project `CLAUDE.md`** before it does
  anything. That file *is* part of the configuration under test.
- **The plugin is installed on the maintainer's machine**, so its full sources are readable from
  the plugin cache by any session, from any directory.
- The repository is findable on disk.

The arm that finally answered *without* the plugin was:

```bash
cd "$(mktemp -d)" && echo "<the case prompt>" |   claude -p --disallowed-tools Bash Read Grep Glob WebFetch WebSearch Task
```

**State the confound**: this buys isolation at the price of conflating *no plugin* with *no ability
to look anything up*. A cleanly ablated arm — the plugin absent but tools available — needs a
sandbox this repository does not have. `claude plugin eval --ablation with-without` provides one,
which is a real argument for going back to it if the gate ever opens.

## Two deliberate deviations from `skill-creator`'s conventions

- **The suite lives at the repository root, not inside a skill directory.** `skill-creator` files
  `evals/evals.json` under the skill it tests. Two of the three cases here are not about one
  skill: the layer confusion is about a repository-wide convention, and the update trap spans the
  README and three skills' notices. ADR 0037 scoped this suite to *the plugin's configuration*,
  so `skill_name` is `groundrules` and the suite sits once at the root.
- **`scripts/run_eval.py` is not used.** That script evaluates whether a skill's **description**
  makes it trigger, and requires a skill directory. These are **behavioural** cases — what the
  agent does once it is running — which is the other half of `skill-creator`'s workflow.

## What has actually been run

All three ran **three times** on 2026-09-09, which is what turns a green into a rate.

| id | With the plugin | Baseline | Delta | Verdict on the case |
|---|---|---|---|---|
| 1 | **3/3 green** | inapplicable | unmeasurable | green **discounted** — 2 of 3 runs read the answer key |
| 2 | **1/1 green** (sharpened) | **fail** 4 of 6 | **real** | sharpened 2026-09-09; the old version did not discriminate |
| 3 | **3/3 green** | **0/3** — all three fail | **real and repeated** | it does what it was written to do |

Nine with-plugin runs, nine green. Case 3's three isolated baselines all fail the same way: they
refuse to commit, offer a `Stop` hook as a plausible mechanism, and leave the automatic reading
open — one of them invented a command name. That is a consistent delta, not a lucky one.

**Case 3 is the suite's first real signal, and it is positive.** With the plugin, the answer denied
the automatic trigger and named the real ones. Isolated, it speculated that a `Stop` hook *probably*
drives the capture, invented a command name, and left the automatic reading open. The configuration
is what makes the difference — exactly what the case was written to detect.

**Case 2 was sharpened on 2026-09-09, and now discriminates.** In its first form both arms passed:
the catalog-versus-install distinction is derivable from general knowledge of Claude Code and needs
nothing from this plugin. The prompt now carries a **checkable false premise** — the user's
colleague says `close` shipped in 1.10.0, when it shipped in 1.11.0 — which is verifiable from this
repository and unknowable without it. The with-plugin arm opened by correcting it and *proved* the
correction against both tags, and drew a consequence the case had not anticipated: a catalog
refreshed before the release could not have carried the version either. The isolated baseline never
questioned the figure at all; it worked around the premise without examining it, and invented a
verification command (`commands/close.md`) for a plugin whose skills live in `skills/<name>/`.
**A prompt whose comfortable answer is wrong is what makes a case measure anything.** The with-plugin arm did find something the case had not anticipated, now an expectation:
the user's *marketplace clone* can itself be stale, so an update run before the release was
published reinstalls the same old version.

**Case 1's baseline is inapplicable, as predicted.** Its question is about files in this
repository; a shielded arm has no way to reach them and correctly refused to answer. **A baseline
does not apply uniformly across case shapes** — for a case that asks the agent to read this repo,
*without the plugin* is not a meaningful condition, and pretending to measure a delta there would
manufacture one.

### `validated` is retired; two entries are now `probed`

Three runs each is a rate, so "not enough runs" expired. The real problem was the word:
**a green covers the case's instance, never the behavioural class its entry names.** Case 3 grades
one question; its entry is *asserts / trusts without verifying first*, and that class **recurred on
2026-09-08**, when this repository adopted a runner on the strength of its `--help`. Had
`validated` existed as ADR 0037 defined it, the entry would have read green at the moment the guard
was failing.

[ADR 0043](../docs/decisions/0043-probed-not-validated.md) retires the word. Entries are `watching`
or **`probed: <case>, N/N since <date>`** — one named instance, at a measured rate, and nothing
about the class. Cases 2 and 3 make their entries `probed`. Case 1's does **not**: its green is
discounted, two of three runs having read the file that grades them.

### The answer key is inside the repository under test

Running case 1, the with-plugin arm **read `evals/evals.json`** — it greps the repo, and the file
is in it. It then referred to the case grading its own answer. Nothing suggests it used the
expectations to shape its reply, and on this run it would not have needed to; but an agent that can
read what it is graded on is not being graded on what you think. There is no clean fix while the
suite lives in the repository the cases explore. **Weigh every future green from a repo-reading
case against this**, and prefer prompts whose answer cannot be improved by knowing the rubric.

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
