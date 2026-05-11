<!-- generated-by: starter-kit v0.5.0 -->
# 0005 — Intent capture in bootstrap + separate `apply-best-practices` skill

**Date**: 2026-05-11
**Status**: Accepted

## Context

V0.2 manually integrated best practices from `shanraisshan/claude-code-best-practice` and `howborisusesclaudecode.com` into the `CLAUDE.md.{fr,en}.tpl` templates. This was a **one-shot snapshot**: the templates reflected what those sources said at V0.2 authorship time. The shanraisshan repo is **maintained and evolves regularly** with the Claude Code ecosystem — by V0.4 the snapshot was already stale.

Two related problems emerged:

1. **Stale best practices**: without an automated way to re-check sources, the generated CLAUDE.md drifts from current best practice each time shanraisshan updates.
2. **Generic vs contextual recommendations**: a static template embeds "generic" practices. But a CRM project, a CLI tool, and a research notebook each need different practices. To filter intelligently, we need to know what the project **is** — its intent.

The V0.4 bootstrap captured a 1-phrase `description` but nothing structured enough to filter recommendations on. We needed:
- Deeper intent capture (goal, users, constraints, non-goals, acceptance criteria)
- A fetch-and-filter mechanism that uses the intent as context

## Decision

Two coordinated additions in V0.5:

### 1. Intent capture as Phase 3 of `bootstrap`

A new phase between the interview (Phase 2) and the file generation (Phase 5, formerly 4). Asks the user once:

- *"Do you have a brief or vision document?"* → 4 branches: **paste / file path / in-interview questions / skip**

Produces (unless skipped):
- `brief/00-INTENT.md` — raw source (only for paste / file branches)
- `docs/00-VISION.md` — structured synthesis with five sections: Goal, Users, Constraints, Non-goals, V1 Acceptance Criteria

The synthesis from raw brief → structured vision is performed by Claude itself (the plugin's runtime), not by a separate tool — keeps the no-external-runtime constraint (cf. ADR 0002).

### 2. New skill `/starter-kit:apply-best-practices`

A separate skill (not part of `bootstrap`) that:
- Requires `.starter-kit.json` and `docs/00-VISION.md` to exist (refuses otherwise)
- WebFetches `https://github.com/shanraisshan/claude-code-best-practice` **at each run** (no cache — sources evolve)
- Passes the vision as context: *"given this project, extract relevant practices"*
- Returns recommendations grouped by category (CLAUDE.md sections, `.claude/rules/`, settings.json permissions, hooks, custom skills) with High/Medium/Low priority
- User picks via multi-select (≤4 options per `AskUserQuestion` call)
- Applies the **safe** items automatically (CLAUDE.md sections, `.claude/rules/`, settings.json)
- Saves the **invasive** items (hooks, custom skills) to `docs/best-practices-pending.md` for manual review
- Records the run in `.starter-kit.json` `appliedPractices` (append-only — re-running surfaces new items as sources evolve)

## Alternatives considered

### Embed the fetch into `bootstrap` directly
- Rejected — violates the offline-first constraint (`bootstrap` should work without internet; `apply-best-practices` is the only WebFetch consumer). Also, fetching on every bootstrap forces a network round-trip even when the user doesn't want one.
- Trade-off: now the user must remember to run `apply-best-practices` after `bootstrap`. Mitigated by the `bootstrap` Phase 8 final recap explicitly suggesting it.

### Capture intent via a single long free-form text field
- Rejected — too unstructured for the filter to work. The recommendation engine needs hooks to filter on (e.g., "stack-agnostic" excludes Node-specific recommendations; "solo user" excludes team-coordination recommendations).
- The five-section schema (Goal/Users/Constraints/Non-goals/Acceptance) is the minimal vocabulary for that filter to be meaningful.

### Make the user manually write `docs/00-VISION.md` before running `apply-best-practices`
- Rejected (as default) — too high a barrier. Most users won't have a structured vision document and would skip the feature.
- Kept as **fallback** via the `Skip` branch + the message *"if you want practices later, fill `docs/00-VISION.md` manually then run apply-best-practices"*.

### Auto-apply ALL recommendations including hooks
- Rejected — hooks run shell commands. Even a typo or a runaway hook could lock the user out. The user must review hooks before activation.
- Custom skills similarly require deliberate design (frontmatter, `disable-model-invocation`, etc.) — not auto-generatable safely.

### Single skill that does bootstrap + best-practices
- Rejected — violates ADR 0003 (one skill per concern). Apply-best-practices is also useful **after** bootstrap, when shanraisshan updates or when the project's intent shifts. Bundling them would force re-bootstrap to get updated practices.

## Consequences

### Positive
- Best practices stay current: re-running `apply-best-practices` after a shanraisshan update surfaces new items without re-bootstrapping.
- Project-specific filtering: a CLI tool and a CRM get different recommendations from the same source.
- Intent is structured and stored: future skills (a hypothetical `/starter-kit:audit`) can read `.starter-kit.json.intent` and reason about it.
- Append-only `appliedPractices` means full history of practice adoption is preserved.
- Clean separation of concerns: `bootstrap` is offline; `apply-best-practices` is the single network consumer.

### Negative / Tradeoffs
- Two-step UX: user must remember to run `apply-best-practices` after bootstrap. Mitigated by the explicit recap mention.
- WebFetch reliability: if shanraisshan is unreachable, the skill must fail gracefully and suggest "save for later". Network is a new failure mode that the rest of the plugin avoids.
- Synthesis quality: when the user pastes a long brief, the goal/users/constraints/non-goals/acceptance synthesis is Claude's interpretation. Could miss nuances or fabricate plausible-sounding content. Mitigation: the SKILL.md rule "be faithful to the source text, don't invent. If thin, write 'À préciser'."
- Source lock-in: hardcoding `shanraisshan/claude-code-best-practice` in the skill's WebFetch URL means a single source of truth. Future addition might want to fetch from multiple sources (Boris's site, custom team repo, etc.) — would require a SKILL.md edit. Acceptable for V0.5.
- Generic recommendations: the fetch in the dogfood test returned 4 recommendations that were skills we already had. The skill must filter or the user must mentally ignore — adds cognitive load. Mitigated by pre-filtering in the skill's prompt ("DÉJÀ APPLIQUÉ" section in the WebFetch prompt — but only effective for the explicitly-listed pre-applied items).

### Neutral
- The dogfood `Starting-Claude` carries the V0.2 manual integration as the **first** `appliedPractices` entry. The V0.5 run (this ADR being committed alongside it) is the **second** entry. Future runs append more. Honest provenance.

## Notes

- Templates added: `brief-INTENT.md.{fr,en}.tpl`, `docs-VISION.md.{fr,en}.tpl`. The synthesis target template `docs-VISION.md` has placeholders `{{GOAL}}`, `{{USERS}}`, `{{CONSTRAINTS}}`, `{{NONGOALS}}`, `{{ACCEPTANCE}}` and `{{INTENT_SOURCE}}` (for provenance).
- See [ADR 0003](0003-multi-skill-architecture.md) for the multi-skill rationale that justifies a separate `apply-best-practices` skill.
- See [ADR 0004](0004-starter-kit-json-schema.md) for the `.starter-kit.json` schema — V0.5 extends it with `intent` and `appliedPractices`.
- First real-world run of `apply-best-practices` on the dogfood happened 2026-05-11. Returned 12 recommendations; 4 were already-existing skills (skipped), 2 redundant with V0.2, 4 applied (CLAUDE.md section + `.claude/rules/plugin-meta.md` + `.claude/settings.json` + `docs/best-practices-pending.md` snippet), 2 deferred to V0.6 (`/verify-bootstrap`, `/watch-bootstrap`).
