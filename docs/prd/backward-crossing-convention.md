<!-- generated-by: groundrules v1.11.0 -->
# PRD — Backward-crossing convention (triaging `loop/blocked.md`)

> Product Requirements Document for a single feature. Written **before** building, so the agent
> builds the right thing — not a coherent surprise. Validate it (and answer the open questions)
> before any code. Update it if the scope shifts.

**Date**: 2026-06-14 · **Status**: draft — fork (convention vs skill) + all 3 open questions resolved; ready to build · **Milestone**: M1 loop-readiness (fifth brick)

## Problem

When the loop parks a decision in `loop/blocked.md` (the maker's `BLOCKED` status), it has re-entered
**reflection** — human territory ([ADR 0027](../decisions/0027-reflection-realization-interactive-loop.md)
§3). But there is no codified **triage** telling the human (or an interactive agent) *what to do with a
blocker*: the three routes — **re-decompose**, **decide → ADR**, **fix interactively** — and when each
applies. Without it, `loop/blocked.md` risks becoming a graveyard: blockers pile up, nothing records how
(or whether) they were resolved, and the loop never gets smarter.

ADR 0027 decided this is a **convention first, a skill only if it earns it** — confirmed 2026-06-14
(convention chosen: the resolution work already lives in `add-adr` / `realize` / interactive sessions; a
triage skill would be a thin router). Brick 5 codifies that convention so the backward crossing is
**actionable and leaves the repo smarter**, not just unblocked.

## Success criteria

- The generated loop scaffolding documents a clear **"Triaging `loop/blocked.md`"** convention: the
  three routes, when each applies, and the principle that a resolved blocker should **bonify the repo**
  (a decision → an ADR that makes the next loop run smarter; a too-big task → a re-decomposition; a
  human-only fix → an interactive session) — never a silent guess.
- `loop/blocked.md` becomes an **audit trail, not a graveyard**: the convention adds a **`Resolution:`**
  line per blocker (route taken + a pointer — the ADR, the new backlog task, or the fixing commit), so a
  triaged blocker is visibly closed.
- The convention is reachable from where the agent actually is: it **lives in `loop/README.md`** (the
  loop namespace owns it) with a **one-line breadcrumb** in the loop-conditional `CLAUDE.md` so an
  always-loaded pointer exists.
- **No new skill** (convention only — promotion deferred per ADR 0027); **no runtime**; templates/docs
  only; English; signatures consistent.

## Scope

**In scope**
- **`loop/README.md.tpl`** — expand the current one-line triage note into a proper **"Triaging
  `loop/blocked.md` (the backward crossing)"** section: the 3 routes (→ `realize` / → `add-adr` →
  re-add task / → interactive), when each applies, the `Resolution:` convention, the repo-gets-smarter
  principle.
- **`loop/maker.md`** — extend the `blocked.md` entry format the maker writes to include a
  `Resolution:` field (initially `Resolution: (open — awaiting triage)`), so the audit-trail shape
  exists from the moment a blocker is written.
- **A one-line breadcrumb** in the loop-conditional `CLAUDE.md` content (the `## Invariants` snippet's
  neighbourhood, or a short loop-conditional line): "On a parked blocker, triage `loop/blocked.md` —
  see `loop/README.md`."
- README/CHANGELOG; PRD is the reflection home.

**Out of scope** (explicit)
- **A `/groundrules:triage` skill** — explicitly deferred (ADR 0027; convention chosen 2026-06-14).
  Revisit only if blockers prove to need orchestration (long/repetitive `blocked.md`).
- **Automating the triage** — no auto-unpark, no auto-ADR; triage is a human judgement. The convention
  guides; it doesn't act.
- **Changing `realize` / `add-adr`** — they already do the resolution work; the convention *routes* to
  them, it doesn't modify them.
- **Template refinement** (brick 6); the superpowers case.

## Constraints

- **Template over code** (ADR 0002): the convention is doc text in templates; no logic, no engine.
- **The guard** (ADR 0027): triage is reflection — human-owned; the convention never auto-resolves.
- **CLAUDE.md stays lean** (ADR 0024): only a one-line breadcrumb there; the detail lives in
  `loop/README.md` (map, not territory).
- **English-only**; carry the `generated-by` signature.

## Build plan

Ordered steps, each with a validation point.

1. **Expand `loop/README.md.tpl`** with the triage section (3 routes + when + `Resolution:` +
   repo-gets-smarter). Validate: a fresh reader, given a populated `blocked.md`, can pick the right
   route from the section alone.
2. **Extend the `blocked.md` format in `loop/maker.md`** with the `Resolution:` field. Validate:
   consistent with the section in (1); no contradiction with the existing 4-status protocol.
3. **One-line breadcrumb** in the loop-conditional `CLAUDE.md` content. Validate: stays one line; only
   emitted when loop scaffolding is opted in.
4. **README / CHANGELOG / PLAN**. Validate: drift checks clean.
5. **Fresh-subagent E2E**: give an agent a `loop/blocked.md` with three planted blockers (one too-big,
   one hiding a decision, one human-only fix) + the convention, and have it **triage each**. Validate:
   it routes correctly (re-decompose → `realize`; decision → `add-adr` then re-add; fix → interactive),
   writes a `Resolution:` line per blocker, and never auto-guesses a parked decision.

## Risks

What could go wrong, and the mitigation.

- **The convention is ignored** (it's "just docs"). *Mitigation*: anchor it where the agent already
  looks — `loop/README.md` (read when triaging) + a `CLAUDE.md` breadcrumb (always loaded); the maker
  writes the `Resolution: (open)` stub so the next reader sees an explicit TODO.
- **`blocked.md` graveyard persists** despite the convention. *Mitigation*: the `Resolution:` field makes
  an un-triaged blocker visibly open; the loop docs frame triage as the price of running the loop.
- **Convention creep toward a skill.** *Mitigation*: scope is doc-only; the skill is explicitly deferred
  with a stated trigger to revisit.

## Open questions — resolved (2026-06-14, on their leans)

- **CLAUDE.md breadcrumb** → **resolved: yes**, a one-line loop-conditional breadcrumb (always-loaded
  pointer) + the detail in `loop/README.md` (map, not territory).
- **`Resolution:` field** → **resolved: the maker writes the stub** `Resolution: (open — awaiting
  triage)` so the audit shape exists immediately; the human replaces it on triage.
- **Auto-re-add a resolved blocker's task** → **resolved: no** — the convention tells the human to
  re-add the decided/decomposed task (via `realize` or by hand); triage stays human-owned, no automation.
