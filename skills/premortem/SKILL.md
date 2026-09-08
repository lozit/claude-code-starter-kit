---
name: premortem
description: "Use before committing to a plan, PRD, ADR, architecture, or strategy — especially when you're tempted to ask \"is this good?\" (which invites a sycophantic yes). It runs Gary Klein's premortem: assume the thing already failed, enumerate the causes ranked by probability × impact, and name the early signal for each, then optionally fold the result into a PRD's Risks or an ADR. The reflection-side adversarial pass."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash, AskUserQuestion
---

# /groundrules:premortem

You will stress-test a plan by **assuming it has already failed** and explaining why — Gary Klein's
*premortem* ([HBR 2007](https://hbr.org/2007/09/performing-a-project-premortem)). This is groundrules'
**reflection-side adversarial pass**: the loop's verifier distrusts a *diff*; the premortem distrusts a
*plan*. All output is in **English**.

> **Why this works (and why it beats just asking "is my plan good?").** LLMs are sycophantic — they
> affirm what you assert ([Science 2026](https://arxiv.org/abs/2510.01395): ~50% more than humans). The
> *framing* drives it: a validating question gets validation. Reframing the request as "it failed —
> explain why" removes the validating exit, which empirically reduces sycophancy more than an explicit
> "don't be sycophantic" instruction ([AISI, *Ask Don't Tell*](https://arxiv.org/pdf/2602.23971)).
> Honest scope: this is an **established technique** that *reduces* sycophancy — not a cure, and not the
> mis-quoted "+30% on an LLM" (that's a 1989 *human* study). It also doesn't replace human judgement.

## Phase 1 — Identify the target

`AskUserQuestion` for what to stress-test (or take it from the invocation): `A PRD (give its path)` /
`An ADR / plan / strategy (paste or path)` / `The current PLAN.md`.

- **PRD / ADR / file** → `Read` it.
- **Paste** → ask the user to paste the plan / strategy / architecture.
- Restate, in one or two lines, **what "success" was supposed to look like** — you need the goal to
  imagine its failure. If it's too vague to fail in a specific way, say so (a plan you can't fail-test is
  a plan that's underspecified — that itself is the first finding).

## Phase 2 — Run the premortem (the adversarial core)

Adopt this frame literally, and hold it: **"It is far enough past this plan's own timeline that the
outcome is in — the next morning for a weekend deploy, months for a project. The thing below has shipped
and **failed** — clearly, indisputably. The failure is a *fact*, not a hypothesis. Your only job is to
explain it."** (Scale the horizon to the plan's timescale.) Then produce:

1. **The failure narrative** — what went wrong, in what order. Tell it as history, in the past tense
   (the grammatical shift is the point: it lifts self-censorship).
2. **All contributing causes** — a table with **`probability` and `impact` as separate columns** (so the
   ranking is auditable), ordered by their **product**. Be exhaustive before being kind — include the
   unflattering ones (wrong assumption, scope too big, a decision nobody actually made, a dependency that
   didn't hold, the team/user not behaving as hoped). If Phase 1 found the plan **too vague to fail-test**,
   that under-specification is itself a cause here — usually a high-ranked one.
3. **For each cause, the early signal** — the observable thing that would have caught it *before* it was
   too late (a metric, a failing check, a missed deadline, a user reaction). One column per cause.

**Register — non-negotiable**: inside this failure frame, do **not** reassure, do **not** list strengths
or positives, do **not** hedge toward "but it could also go well". The premortem's entire value is the
absence of the validating voice. (The *only* place a positive may appear is the Phase-3 `[what's solid]`
summary slot — which sits **outside** this frame; never inside the narrative or the causes.) If you catch
yourself softening here, stop and re-assume the failure.

## Phase 3 — Surface and translate

- Pull out the **3 highest-leverage causes** (top probability × impact).
- For each, state the **single change** that most reduces it, and what you'd **reconsider** in the plan.
- Close with a contradictory-format summary so nothing reads as a rubber stamp:
  `[what's solid] / [what's wrong or missing] / [what to reconsider]`, and a confidence (1–10) that the
  plan-as-written fails, with "what would change my assessment". The `[what's solid]` slot is the **one
  sanctioned place for a positive** — it lives here, outside the Phase-2 failure frame, not inside it.

## Phase 4 — Fold it back (offer, never impose)

`AskUserQuestion`: how to capture the result —
- **Into a PRD's Risks** → if the target is (or has) a `docs/prd/<feature>.md`, **append** the top causes
  to its `## Risks` section (`Edit`, never overwrite), each as `<cause> — *early signal*: <signal>;
  *mitigation*: <change>`.
- **As an ADR** → if a cause reveals a **real unsettled decision** (not just a risk), point the user to
  `/groundrules:add-adr` to settle it.
- **Leave it** → just output the analysis. (If the target was a pasted plan with no PRD, that's the
  default — offer to write the top causes wherever the user keeps that plan, but don't presume a file.)

**Never commit** (the user commits on their own). This skill produces *reflection*; it does not execute.

## Important rules

- **Stay in the failure frame.** The moment you drift into validation, the technique is worthless.
- **Honest sourcing**: the premortem is an established technique (Klein, HBR 2007); never cite "+30%" as
  an LLM result. A premortem *reduces* sycophancy and surfaces blind spots — it does not guarantee a
  good plan, and the human still judges.
- **Never overwrite** a PRD/ADR — append/`Edit` only. **English-only**; this skill needs no network.
