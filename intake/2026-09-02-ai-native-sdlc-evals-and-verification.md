# The AI-native SDLC playbook — what it raises for groundrules

**Written**: 2026-09-02, from a deliberation session in the operator's private cockpit. It
carries **the reasoning, not a decision**: the analysis belongs here, against this
repository's own documentation, because several of these subjects are already settled here
and a session elsewhere cannot know how.

Source: Anthropic, *The AI-Native SDLC playbook* — <https://claude.com/blog/the-ai-native-sdlc-playbook>
(a course version exists at <https://academy.claude.com/courses/ai-native-sdlc-playbook/introduction>).
Read the source before acting on this note; what follows is a reading, not a substitute.

---

## What the playbook actually says

**An artifact chain.** Six stages, each **ending by committing a versioned artifact** that
the next stage reads: `intent.md` (problem, intended outcome, affected systems, constraints)
→ `spec.md` → `plan.md` → the diff and its tests → the PR and its review findings → the
incident record, **which becomes a new `intent.md`** and closes the loop.

> *"The chain of commits is also the audit trail: who asked for what, what the agent
> produced, and who approved it."*

**Three kinds of control, not two.** This is the distinction worth the reading:

| | Nature |
|---|---|
| **Skills** | advisory — encode institutional knowledge, make a policy *likely* to be followed |
| **Hooks** | deterministic — they **block**. The wall |
| **Evals** | **regression suites that validate the agent's configuration**, run when `CLAUDE.md`, a skill or a hook changes. *Production incidents become permanent evals* |

**Human-in-the-loop, stated as separation of duties.** An agent never approves its own work;
a code owner holds the merge. *"Humans remain accountable for every decision that requires
judgment."*

---

## Why this lands here rather than being applied elsewhere

A documentation backbone that lays down ADRs, LEARNINGS, PLAN and CHANGELOG across every
repository it bootstraps is **already the artifact chain**, under other names — an intake
brief where the playbook writes `intent.md`, a specification where it writes `spec.md`,
`PLAN.md` where it writes `plan.md`, and a learnings file where it turns an incident back
into an intent.

So the interesting question is not whether to adopt the chain. It is **which of the three
controls this project already has, which it has decided against, and on what grounds.**

---

## Four tensions with what this repository already holds

Named, not resolved. Each one is a question for a session that can read the decision behind it.

**1 — `docs/AGENT-EVALS.md` and the playbook's "evals" are not the same object.** The file
here is a **log of observed failure modes with the guard added for each**, fed by the
checkpoint ritual — retrospective and narrative. The playbook means a **runnable regression
suite over the agent's configuration**, fired by a change. Same word, two things. Is the
existing file the right home for the second, a different artifact, or is the second out of
scope? Deciding that the word is already taken is a legitimate outcome.

**2 — A change-triggered eval collides with ADR 0025.** The natural trigger is mechanical: a
commit touching `CLAUDE.md`, `.claude/skills/**` or a hook configuration. But ADR 0025
rejected runtime hooks **on principle** — *machinery against groundrules' nature* (template
over code, offline-first, no runtime), plus a harness-agnostic direction that a
Claude-Code-specific hook does not port to. So either the trigger is not a hook (a
convention? a documented manual pass? something the harness offers portably?), or the eval
idea stops at that wall. **This repository is the only place that can weigh that**, and the
argument for the wall may well win.

**3 — Verification by a fresh context, which ADR 0032 does not cover.** The premortem is
already adopted here as the adversarial technique, across three surfaces. What the playbook
adds is a **separation of duties reduced to a single operator**:

> The agent that wrote the code holds the *justifications* in its context. It reads the diff
> as confirmation of its own intent rather than against the specification — the same reason
> an author reads their own text badly. A **fresh** agent given only the **acceptance
> criteria** and the **diff** has no access to the intent, so it can only confront the
> artifact with the requirement.

Two conditions decide whether that works, and both are easy to lose:

- **What it receives.** The criteria and the diff. **Not** the conversation, the plan's
  reasoning, or the commit messages — those carry the author's framing. A fresh agent fed
  the author's narrative is a contaminated fresh agent.
- **When the criteria were written.** ⚠️ If the verification prompt is composed *after* the
  code, the author's framing goes back in without anyone noticing. Which gives the rule
  worth testing here: **acceptance criteria are written at specification time and are what
  the verifier receives.** A specification that ships its own acceptance criteria is not a
  new artifact — it is a PRD template question.

`docs/prototypes/loop/verifier.md` already exists. Does it already do this, does it
contradict it, or is this the missing framing?

**4 — What does not transfer, and leaves a hole.** The playbook's separation rests on code
owners and branch protection, i.e. **a team**. A single operator on trunk has no second
person. The *principle* — separate who produces from who accepts — still holds, but its
single-operator form is currently implicit: the human reads the diff before it lands. Is
that worth making explicit as a convention, or does making it explicit turn a habit into
ceremony?

---

## What is asked of a session here

Read this against `docs/AGENT-EVALS.md`, ADR 0025, ADR 0032, ADR 0002 and
`docs/prototypes/loop/verifier.md`, and **decide in this repository's terms**. Any of the
four may end as a refusal with its reason recorded — that is an outcome, not a failure. The
upstream session deliberately did not choose, because it could not see the decisions behind
these files.
