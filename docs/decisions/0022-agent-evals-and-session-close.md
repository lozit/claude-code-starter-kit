<!-- generated-by: groundrules v1.11.0 -->
# 0022 — Session-close ritual + optional agent-evals log

**Date**: 2026-06-08
**Status**: Accepted

## Context

A synthesized article on agent memory (flat dated markdown in `.claude/memory/`: `decisions`,
`learnings`, `blockers`, `journal`, `evals`, plus a 5-minute end-of-session ritual) was
compared against groundrules. Most of it groundrules already does better: `decisions` →
numbered ADRs (addressable, supersedable), `learnings` → `docs/LEARNINGS.md` (rule format),
`blockers` → a learning with a cost. Two ideas were genuinely missing, and two of the
article's mechanics were rejected for conflicting with prior decisions.

## Decision

Adopt the two missing ideas:

1. **Checkpoint capture ritual** — a convention in the generated `CLAUDE.md` (full + lean):
   route three questions — *decided* → `add-adr`, *learned* (incl. a 30+ min blocker + fix)
   → `learn`, *agent mistake/hallucination/drift caught* → `AGENT-EVALS.md`. A forcing
   function groundrules lacked (it only had on-demand capture).

   **Anchored to perceivable boundaries, not "session end".** An agent cannot perceive that
   a session is ending — there is no model-visible session-end signal, `CLAUDE.md` is loaded
   at *start* only, and hooks can't drive an agent turn at exit (`SessionEnd` fires too late;
   `Stop` fires every turn). So the ritual is anchored to boundaries the agent *does* flow
   through and can act on: **before a `git push`/tag/release** (the most reliable moment —
   the agent is about to ship) or at a completed `PLAN.md` milestone. The agent **proposes it
   proactively** there. The `RELEASE.md` template's pre-release checklist also carries the
   capture step, so it's concretely wired into the release flow.

   **Manual trigger too.** A `/groundrules:checkpoint` skill lets the user run the ritual on
   demand — the belt-and-braces complement to the agent's proactive triggering (the user
   may not rely on the agent noticing the boundary). The skill gathers what changed (git
   status, commits since the last tag, the `[Unreleased]` CHANGELOG) and routes the three
   questions to ADR / LEARNINGS / AGENT-EVALS, manufacturing nothing when there's nothing.
2. **`docs/AGENT-EVALS.md`** — a new **optional** generated doc (placeholder
   `{{HAS_AGENT_EVALS}}`, wired into bootstrap Call 2b, adopt Call 3b, verify whitelist):
   a log of the agent's **own** failure modes on this project + the guard added for each.
   Distinct from `LEARNINGS.md` (project/domain) — this is meta, about the agent's behavior.

## Alternatives considered (and the article's mechanics rejected)

- **`journal.md` (per-session factual trace)** — rejected: largely duplicates `git log`;
  groundrules keeps `PLAN.md` (now) + `CHANGELOG` (shipped) + git (history) and avoids a
  separate journal that goes stale.
- **Memory in `.claude/memory/`** — rejected as the home: durable knowledge belongs in
  `docs/` (human-facing, where every contributor and tool looks), not in a tool-specific
  config dir framed as the agent's private memory (cf. ADR 0020, "the repo is the only
  memory"). `AGENT-EVALS.md` therefore lives in `docs/`, not `.claude/`.
- **Auto-loading via `@imports` / SessionStart hook** — rejected: importing append-only
  journals force-loads unbounded content into every session, the exact context-rot /
  cache-busting failure mode ADR 0021 warns against. groundrules keeps the index +
  on-demand read instead (the session-start list points; files are read when needed).
- **A separate `blockers.md`** — rejected: a blocker + its fix *is* a LEARNINGS entry
  (the rule format's *Why* already carries "what it cost"); the 30+ min trigger is folded
  into the session-close ritual instead.

## Consequences

### Positive
- A real end-of-session capture habit, not just on-demand skills.
- A dedicated place to accumulate agent-behavior observations for tuning `CLAUDE.md` /
  `.claude/rules/` over time — previously a mistake only became a one-off rule, never a log.

### Negative / Tradeoffs
- One more optional doc (now 8 in Call 2b/3b). Still a manageable multiSelect; revisit if
  the list keeps growing.
- `AGENT-EVALS.md` only pays off on longer agent-driven projects; it's unchecked by default.

## Notes

- Builds on ADR 0020 (repo is the only memory) and ADR 0021 (context economy) — both of
  which the article's location and auto-load choices would have violated.
