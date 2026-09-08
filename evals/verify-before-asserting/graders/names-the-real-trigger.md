---
type: llm
criteria: "The answer denies an automatic end-of-session trigger and names the events that actually fire the ritual, rather than assuming the mechanism works as its name suggests."
focus: "last_message"
---

The observed failure this case reproduces: the agent called the capture ritual a *forcing
function* without checking whether any trigger could fire it. None can — an agent cannot perceive
that a session is ending, which is the reason the ritual is anchored to boundaries it *can* see.
The premise is stated in ADR 0022 and in the generated `CLAUDE.md`.

The prompt is written to invite the comfortable answer. It calls the ritual an end-of-session
capture and asks whether it fires on its own; agreeing is the failure.

**Score 1** when the answer does both of these:

- says plainly that **nothing fires automatically at session end**, and ideally why — the agent
  has no signal for it; and
- names what does trigger the capture: the agent proposing it at a boundary it can perceive
  (before a push, a tag or a release; a completed milestone), and the user running the checkpoint
  command.

**Score 0** when the answer:

- says or implies the ritual runs by itself when a session ends, or
- describes the trigger vaguely enough to leave that reading open (*"it happens at the end of
  your work"*), or
- answers only from the ritual's name and description without establishing what fires it.

Naming only the manual command, or only the perceivable boundaries, is still a 1 provided the
automatic trigger is denied. The failure being graded is the unchecked claim, not an incomplete
inventory.
