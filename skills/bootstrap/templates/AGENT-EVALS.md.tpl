<!-- generated-by: groundrules v1.11.0 -->
# Agent evals — {{PROJECT_NAME}}

> A log of the **agent's own** observed failure modes on this project — recurring mistakes,
> hallucinations, drifts — and the guard added for each. Reverse-chronological (newest at
> the top). This is **meta**: it's about how the agent behaves *here*, not about the
> project's domain.

**How this differs from `docs/LEARNINGS.md`**: LEARNINGS captures rules about the *project*
(domain gotchas, stack pitfalls, conventions). AGENT-EVALS captures patterns about the
*agent* (what it gets wrong on this repo, and the rule/guard that should stop it). An eval
entry usually produces a fix in `CLAUDE.md` or `.claude/rules/` — link it.

**When to add an entry**: when the agent repeats a mistake, fabricates a fact/API, drifts
from an instruction, or you catch a hallucination. Capture it at the next checkpoint
(see `CLAUDE.md` → "Capture at checkpoints" — typically before a push/release).

---

<!-- Example:

## YYYY-MM-DD — Invents config keys that don't exist

**Observed**: proposed `app.config.ts` keys (`retryBudget`, `edgeRegion`) that aren't in the
schema — twice in one session.
**Trigger**: asked to "tune performance config" without being pointed at the schema file.
**Guard added**: `CLAUDE.md` now says "never propose a config key without first reading
`src/config/schema.ts`; if unsure, say so." (or a `.claude/rules/config.md` with `paths:`)
**Status**: watching — re-evaluate after a few sessions.

-->

<!-- Hardening a *stubborn* guard (one that keeps getting rationalized away): add a
**rationalization table** (the excuse the agent makes under pressure → the rebuttal) and a
**red-flag stop-line**. Example:

| Rationalization | Reality |
|---|---|
| "the schema probably has that key" | you haven't read it — read it |
| "it's obviously a standard key" | obvious-but-unverified = invented |

**Red flag — STOP**: proposing any config key without having read the schema *this turn*.

-->
