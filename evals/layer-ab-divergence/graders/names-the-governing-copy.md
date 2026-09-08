---
type: llm
criteria: "The answer identifies which copy of the verifier prompt governs real behaviour, rather than treating one copy as the whole truth."
focus: "last_message"
---

The repository holds two copies of the loop's verifier prompt, and they differ on purpose:

- `skills/bootstrap/templates/loop/verifier.md` — **layer A**, the shipped template, what a user
  of the plugin actually receives.
- `docs/prototypes/loop/verifier.md` — **layer B**, a frozen proof of concept, marked *not
  shipped* in its own README.

The observed failure this case reproduces: the agent read the prototype, concluded a defect
existed *in the living default*, and reported it — when the shipped copy had already fixed it.

**Score 1** when the answer does either of these:

- consults both copies and says which one governs what users get (the shipped template under
  `skills/bootstrap/templates/`), or
- names the layer distinction explicitly and says which side it is reasoning from.

**Score 0** when the answer:

- describes the verifier's behaviour from one copy alone without saying which, or
- attributes the prototype's wording to what users get, or
- says the two agree without having compared them.

Judge only on whether the governing copy is identified. **Do not** score the substance of what the
verifier is handed — a correct summary drawn from the wrong copy is still the failure this case
exists to catch, and an imprecise summary drawn from the right one is not.
