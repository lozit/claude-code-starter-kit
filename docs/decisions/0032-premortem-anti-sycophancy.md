<!-- generated-by: groundrules v1.11.0 -->
# 0032 — Adopt the premortem as a reflection-phase adversarial technique (anti-sycophancy)

**Date**: 2026-06-20
**Status**: Accepted

## Context

groundrules already takes a stance against LLM **sycophancy** — the `## Posture` section in the generated
`CLAUDE.md` (ADR 0026) instructs the agent to *push back, don't be sycophantic*, and the README cites the
phenomenon ([Sharma et al., 2023](https://arxiv.org/abs/2310.13548)). An intake analysis
(`intake/premortem-et-complaisance-llm.md`) surfaced newer, stronger evidence and a concrete technique:

- **Sycophancy is worse and more measured than our 2023 citation reflects.** [*Sycophantic AI Decreases
  Prosocial Intentions and Promotes Dependence*](https://arxiv.org/abs/2510.01395) (Science, 2026; 11
  SOTA models) found models affirm users' actions **~50% more than humans**, even when the request
  mentions manipulation or deception — and users *prefer* the sycophantic answer, creating a perverse
  training incentive.
- **The framing of the request drives sycophancy — and reframing beats instructing.** AISI's
  [*Ask Don't Tell*](https://arxiv.org/pdf/2602.23971) found that the *same* claim posed as a **question**
  yields near-zero sycophancy while posed as a statement produces markedly more (a ~24-point gap), and
  that **reframing the input as a question outperforms an explicit "don't be sycophantic" instruction.**
- **The premortem** (Gary Klein, [HBR 2007](https://hbr.org/2007/09/performing-a-project-premortem)) is a
  structural reframing: *assume the plan has already failed, then explain why.* It removes the validating
  exit a "is this good?" question offers.

The implication for us is precise and a little humbling: our `## Posture` is an *instruction*, and the
AISI evidence says **a reframing technique is a stronger lever than an instruction**. Our adversarial
discipline is strong on the *realization* side (the loop's verifier *distrusts the maker's report*) but
soft on the *reflection* side. The premortem fills exactly that gap.

> **Honesty guard.** The viral framing of this idea ("premortem gives the AI +30% more failure causes")
> misattributes a **1989 human study** (Mitchell, Russo & Pennington) as an LLM result. We adopt the
> premortem as an **established technique** (HBR 2007), never citing the "+30%" as measured on an LLM —
> consistent with the README's science-vs-established-practice caveat.

## Decision

**Adopt the premortem as groundrules' reflection-phase adversarial technique**, across three surfaces —
and as **both a convention and a skill** (the cheap nudge earns its place; the ritual earns a skill):

1. **`PRD.md.tpl` *Risks* hint** — a one-line premortem prompt in the Risks section, so the section is
   populated adversarially ("assume it shipped and failed; list causes by probability × impact + the
   early signal for each") instead of optimistically.
2. **`CLAUDE.md.tpl` *Posture* pointer** — one line telling the user the *technique*: to stress-test a
   plan, ask for a **premortem**, not a thumbs-up — reframing as a critique elicits far less sycophancy
   than "is this good?" (and, per AISI, than telling the agent to "push back").
3. **New skill `/groundrules:premortem`** — point it at a plan / PRD / ADR / strategy; it runs the
   "it already failed, explain why" pass (failure narrative · causes ranked by probability × impact ·
   the early detection signal per cause), in a strictly adversarial register, and offers to fold the
   result into a PRD's *Risks* or surface a real decision as an ADR. Never commits.

The premortem is the **reflection-side twin of the loop's verifier**: both assume the worst and
re-derive — the verifier on a *diff*, the premortem on a *plan*.

## Alternatives considered

- **Strengthen the `## Posture` instruction only.** Rejected: AISI shows a reframing technique outperforms
  an explicit no-sycophancy *instruction*; we already have the instruction and it is necessary-not-
  sufficient. Giving the user the *technique* is the higher-leverage move.
- **A skill only (no template/posture nudge).** Rejected: the PRD-Risks hint and the one-line Posture
  pointer are near-zero-cost and reach every project; the skill is for the deliberate, reusable pass.
- **Chase the "+30%" headline.** Rejected: it's a 1989 *human* result; citing it as an LLM gain would
  break the README's honest-sourcing standard.
- **Fold premortem into `/groundrules:prd`'s self-review.** Rejected: the premortem applies to *any*
  artifact (a plan, an ADR, an architecture, a raw strategy), not only a PRD — it deserves to be
  invocable on its own.

## Consequences

### Positive
- Restores adversarial symmetry: the verifier guards *realization*, the premortem guards *reflection*.
- A concrete, evidence-backed anti-sycophancy tool for the **plan-approval moment** (the
  reflection→realization crossing), beyond a passive instruction.
- Refreshes the README's sycophancy evidence with the 2026 Science study (kept **alongside** Sharma 2023,
  not replacing it).

### Negative / Tradeoffs
- One more skill to maintain (14th); `CLAUDE.md` grows by ~1 line (kept within the <200 budget, ADR 0024).
- **A technique, not a cure.** The intake's "limite de fond" stands: even reframed, the reward model's
  pull toward agreement can suppress a correct answer — the premortem reduces sycophancy, it doesn't
  eliminate it. We claim the former, not the latter.

### Neutral
- Honest sourcing: premortem framed as an established technique (Klein, HBR 2007), like ADRs / TDD in the
  README's "Established practices" — not dressed as an LLM lab result.

## Notes

- Sources verified 2026-06-20: [Science 2026 / arXiv 2510.01395](https://arxiv.org/abs/2510.01395)
  (DOI 10.1126/science.aec8352); [AISI *Ask Don't Tell* / arXiv 2602.23971](https://arxiv.org/pdf/2602.23971);
  [Klein, HBR 2007](https://hbr.org/2007/09/performing-a-project-premortem). Intake:
  `intake/premortem-et-complaisance-llm.md`. Related: ADR 0026 (Posture), ADR 0027 (reflection/realization;
  could-act ≠ cleared-to-act).
