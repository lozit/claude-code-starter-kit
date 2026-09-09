<!-- generated-by: groundrules v1.11.0 -->
# 0033 — adopt: "Full adoption" mode (consolidate + reformat, single grouped confirmation)

**Date**: 2026-06-26
**Status**: Accepted

## Context

`/groundrules:adopt` offers two strategies (ADR 0018): **Map in place** (default — zero moves, roles
recorded) and **Consolidate** (Phase 4b migrates each role-mapped file to its canonical path). Consolidate
already covers the mechanics a maintainer needs to turn an existing project *into* a groundrules project:
`git mv` for 1:1 moves, content merge into the canonical target, an **optional reformat** to the template
structure, and a final reference sweep.

But for a solo maintainer who owns the whole repo and wants to go *all the way* — "identify how things exist
and transform the documents so they become groundrules documents" — Consolidate is friction-heavy by design:

- **Reformat is offered, not applied.** Every merged file prompts `Migrate as-is` / `Migrate and reformat`.
- **Confirmation is per-file.** Phase 4b confirms each move/merge/source-fate individually (3–4 at a time).
- **No completeness push.** adopt generates only what's missing; it never frames "to be a *complete*
  groundrules project you're still missing X, Y, Z."

ADR 0018 deliberately **rejected** "automatic consolidation without per-file confirmation" because it would
violate the never-overwrite / never-delete-silently rule. That rejection targeted *no* confirmation — not a
*single, informed, grouped* confirmation. The gap is a faster lane that stays honest.

## Decision

Add a third adoption strategy, **Full adoption**, plus a `--full` flag that selects it without the interview.

- **Selection (two forms, per the request):** a third option in Call 1 (`Full adoption`) **and** a `--full`
  argument (parsed like `--dry-run`) that forces it. `--full` + `--dry-run` together = full plan, no writes.
- **Single grouped confirmation, not per-file.** The **Phase 3 recap is the gate**: in Full mode it must
  enumerate *every* migrate / merge / reformat / source removal so the one Confirm/Cancel is fully informed.
  Phase 4b then executes **without re-prompting per file**. This is the line ADR 0018 drew — confirmed and
  reversible, never silent.
- **Reformat is the default**, not a per-file question: sources whose format differs from the template are
  migrated *and reformatted* into the groundrules structure.
- **Merged sources are removed** (`git rm`) by default for a clean canonical layout, instead of Consolidate's
  keep-with-pointer default. Reversible: `git mv` preserves history and `git rm` is recoverable from git —
  and every removal is listed in the Phase 3 recap before the single confirmation.
- **Completeness pass.** Call 3b (optional docs) pre-checks *every applicable* doc — not just the detected
  ones — and is framed as "to be a complete groundrules project". The user still unchecks what they don't want
  (it stays a multiSelect, never a silent generation).

`.groundrules.json` records `adoptionMode: "full"` (alongside the existing `"map"` / `"consolidate"`).

## Alternatives considered

- **Just tell users to pick Consolidate + check reformat everywhere** — rejected: that *is* ~80% of it but
  costs many clicks and encodes no "go to completion" posture; the request was explicitly to reduce that.
- **A separate `/groundrules:fullify` skill** — rejected for the same reason ADR 0018 rejected a separate
  `consolidate` skill: the decision belongs at adoption time and reuses Phase 4b wholesale.
- **No confirmation at all** (truly silent) — rejected: re-litigates ADR 0018 and breaks Posture (ADR 0026,
  stay reversible). The single grouped confirmation is the deliberate middle.
- **Default source fate = keep-with-pointer (like Consolidate)** — rejected for Full mode: pointer stubs
  defeat the "clean canonical layout" intent; git history already makes `git rm` reversible.

## Consequences

### Positive
- A maintainer can convert an owned project to a complete, canonical groundrules layout in **one pass, one
  confirmation**, with history preserved.
- Reuses all of Phase 4b — no new skill, no new mechanics, just a strategy that flips the defaults.
- Map-in-place stays the safe default; Consolidate's per-file caution is untouched.

### Negative / Tradeoffs
- Full mode removes merged sources by default — more aggressive than Consolidate. Mitigated by: single
  informed recap, `git rm` recoverability, and `--dry-run`.
- The single grouped confirmation puts more weight on the Phase 3 recap being complete and accurate; the skill
  requires it to enumerate every action before the gate.
- Intended for projects the user owns (solo/full control). The skill doesn't *enforce* that — it's a posture
  note, not a guard (consistent with ADR 0025, no runtime guard).
