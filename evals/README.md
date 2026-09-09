<!-- generated-by: groundrules v1.11.0 -->
# `evals/` — the executable suite over this plugin's own configuration

Maintainer-side tooling, run with `claude plugin eval .`. It tests **groundrules' own
configuration** — the instructions in `skills/*/SKILL.md` and their templates — and nothing else.
Decided in [ADR 0037](../docs/decisions/0037-executable-evals-over-agent-config.md).

**Nothing here is generated into user projects, and no skill invokes it.** Same category as the
`gh` calls used to cut a release. Offline-first is a property of the skills; this is not a skill.

## Read this first: no case here has ever been run

`claude plugin eval` is present in Claude Code but **gated behind early access**. Invoking it
prints `plugin eval is currently in early access` and does nothing (verified 2026-09-08, Claude
Code 2.1.265). ADR 0037 recorded the runner as *verified present*, which was true of the
subcommand and not of the ability to run it.

So the three cases below are **authored and unexecuted**. They have never been green, and they
have never been red. Treat every claim in them as a specification of what the guard promises, not
as evidence that it holds — and in particular, **no entry in
[`docs/AGENT-EVALS.md`](../docs/AGENT-EVALS.md) may move to `validated` on the strength of a case
existing.** That was ADR 0037's whole purpose, and it is exactly the part still blocked.

The case **format** is also unverified against a real run. It follows the runner's documented
shape (a `prompt.md` with frontmatter, one markdown file per grader, an optional `case.yaml` for
fixtures), but no case here has been parsed by the tool. Expect the first real run to be a
debugging session on the format before it is a signal about the agent.

## Running it, when the gate opens

```bash
claude plugin eval .                      # the whole suite
claude plugin eval . --case layer-ab      # one case
claude plugin eval . --runs 1             # fast pass while iterating (default is 3)
claude plugin eval . --ablation with-without   # with-plugin vs no-plugin, and the delta
```

Start with `--runs 1`. The default of three runs per case exists for the non-determinism of the
LLM graders, and it triples the cost of a suite that has not yet been shown to parse.

**A red case is a signal to read, not a release blocker** (ADR 0037, decision 6), until the suite
has earned trust.

## The three cases

Each comes from an entry in [`docs/AGENT-EVALS.md`](../docs/AGENT-EVALS.md) sitting at
`Status: watching`: the observed failure mode is the prompt, the recorded guard is the grader.

| Case | Source entry | Grades on |
|---|---|---|
| `layer-ab-divergence` | 2026-09-02 — reasoned about a layer-B copy as if it were the shipped source | whether both copies are consulted, or the distinction is named |
| `verify-installed-version` | 2026-06-08 — "just restart" advised without checking what is installed | whether the installed version is checked before advising |
| `verify-before-asserting` | 2026-06-08 — asserts / trusts without verifying first | whether a claimed trigger is named or denied, rather than assumed |

## Adding a case

Only from an existing `docs/AGENT-EVALS.md` entry, and only while the suite stays small enough to
actually be run. A suite nobody runs is worse than none, because it looks like coverage.
